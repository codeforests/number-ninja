import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show immutable;

import '../../domain/quiz.dart';
import '../../domain/round_builder.dart';
import '../../providers.dart';

/// Rounds are played at level 1 until FEAT-04 adds difficulty steps (PRC-09).
const playLevel = 1;

/// Shuffles rounds; overridden with a seeded one in tests.
final quizRandomProvider = Provider<Random>((ref) => Random());

/// A finished round, handed to the result screen (SCR-05).
@immutable
class RoundSummary {
  const RoundSummary({
    required this.topicId,
    required this.score,
    required this.total,
    required this.durationMs,
    required this.stars,
  });

  final String topicId;
  final int score;
  final int total;
  final int durationMs;
  final int stars;
}

@immutable
class RoundState {
  const RoundState({
    this.topicId,
    this.roundId,
    this.quiz,
    this.saving = false,
    this.error,
  });

  final String? topicId;
  final int? roundId;

  /// Null while the round is being built.
  final Quiz? quiz;

  /// True between Check and the attempt being saved.
  final bool saving;
  final Object? error;

  RoundSummary get summary => RoundSummary(
    topicId: topicId!,
    score: quiz!.score,
    total: quiz!.questions.length,
    durationMs: quiz!.durationMs,
    stars: quiz!.stars,
  );
}

/// One round of SCR-04: builds it, saves each answer before its feedback
/// shows (NFR-05), and moves on without I/O (NFR-04).
class QuizController extends Notifier<RoundState> {
  @override
  RoundState build() => const RoundState();

  /// Builds and starts a new round of [topicId].
  Future<void> start(String topicId) async {
    state = RoundState(topicId: topicId);
    try {
      final bank = await ref.read(bankProvider.future);
      final repo = ref.read(roundRepositoryProvider);
      final recent = await repo.recentCorrectIds(topicId);
      final questions = buildRound(
        topicQuestions: bank.byTopic[topicId] ?? const [],
        level: playLevel,
        recentCorrect: recent,
        random: ref.read(quizRandomProvider),
      );
      if (questions.isEmpty) throw StateError('no questions for $topicId');
      final roundId = await repo.startRound(topicId, playLevel);
      if (!ref.mounted) return;
      state = RoundState(
        topicId: topicId,
        roundId: roundId,
        quiz: Quiz.start(questions, ref.read(clockProvider)()),
      );
    } catch (e) {
      if (ref.mounted) state = RoundState(topicId: topicId, error: e);
    }
  }

  /// Checks [given], saves the attempt (and, after the last question, the
  /// round), then shows feedback.
  Future<void> check(Object given) async {
    final s = state;
    final quiz = s.quiz;
    if (quiz == null || s.saving || quiz.phase != QuizPhase.answering) return;
    final answered = quiz.answer(given, ref.read(clockProvider)());
    state = RoundState(
      topicId: s.topicId,
      roundId: s.roundId,
      quiz: quiz,
      saving: true,
    );
    final repo = ref.read(roundRepositoryProvider);
    await repo.saveAttempt(s.roundId!, answered.lastResult!);
    if (answered.isLast) {
      await repo.finishRound(
        s.roundId!,
        score: answered.score,
        durationMs: answered.durationMs,
        stars: answered.stars,
      );
    }
    if (!ref.mounted) return;
    state = RoundState(topicId: s.topicId, roundId: s.roundId, quiz: answered);
  }

  /// The next question, or done after the last. No database or bank work.
  void next() {
    final s = state;
    final quiz = s.quiz;
    if (quiz == null || quiz.phase != QuizPhase.feedback) return;
    state = RoundState(
      topicId: s.topicId,
      roundId: s.roundId,
      quiz: quiz.next(ref.read(clockProvider)()),
    );
  }
}

final quizControllerProvider =
    NotifierProvider.autoDispose<QuizController, RoundState>(
      QuizController.new,
    );
