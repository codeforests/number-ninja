import 'dart:async';

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show immutable;

import '../../data/sound_player.dart';
import '../../domain/badges.dart';
import '../../domain/profile.dart';
import '../../domain/progress.dart' as progress;
import '../../domain/question.dart';
import '../../domain/quiz.dart';
import '../../domain/round_builder.dart';
import '../../domain/topics.dart';
import '../../providers.dart';

/// Shuffles rounds; overridden with a seeded one in tests.
final quizRandomProvider = Provider<Random>((ref) => Random());

/// A finished round, handed to the result screen (SCR-05).
@immutable
class RoundSummary {
  const RoundSummary({
    required this.topicId,
    required this.level,
    required this.score,
    required this.total,
    required this.durationMs,
    required this.stars,
    this.newBadges = const [],
  });

  final String topicId;

  /// The level the round was played at.
  final int level;
  final int score;
  final int total;
  final int durationMs;
  final int stars;

  /// Badges this round earned, in shelf order (BDG-02).
  final List<Badge> newBadges;

  /// The level the topic's next round is played at (PRC-09).
  int get nextLevel => progress.nextLevel(level, stars);

  bool get levelUp => nextLevel > level;
}

@immutable
class RoundState {
  const RoundState({
    this.topicId,
    this.level = progress.minLevel,
    this.roundId,
    this.quiz,
    this.saving = false,
    this.error,
    this.newBadges = const [],
    this.locked = false,
  });

  final String? topicId;

  /// The topic is locked (PRC-14): no round was started.
  final bool locked;
  final int level;
  final int? roundId;

  /// Null while the round is being built.
  final Quiz? quiz;

  /// True between Check and the attempt being saved.
  final bool saving;
  final Object? error;

  /// Badges awarded when the round finished (BDG-02).
  final List<Badge> newBadges;

  RoundSummary get summary => RoundSummary(
    topicId: topicId!,
    level: level,
    score: quiz!.score,
    total: quiz!.questions.length,
    durationMs: quiz!.durationMs,
    stars: quiz!.stars,
    newBadges: newBadges,
  );
}

/// One round of SCR-04: builds it, saves each answer before its feedback
/// shows (NFR-05), and moves on without I/O (NFR-04).
class QuizController extends Notifier<RoundState> {
  @override
  RoundState build() => const RoundState();

  /// Builds and starts a new round of [topicId] at its current level
  /// (PRC-09).
  Future<void> start(String topicId) async {
    state = RoundState(topicId: topicId);
    try {
      // Listen, not read: an autoDispose provider read once is disposed
      // before its future completes.
      final sub = ref.listen(topicLocksProvider.future, (_, _) {});
      final locks = await sub.read().whenComplete(sub.close);
      if (locks[topicId]?.isLocked ?? false) {
        if (ref.mounted) state = RoundState(topicId: topicId, locked: true);
        return;
      }
      final bank = await ref.read(bankProvider.future);
      final repo = ref.read(roundRepositoryProvider);
      final profile = await ref.read(profileRepositoryProvider).load();
      int start(String id) => startLevel(profile, topicsById[id]);
      final level = await repo.levelFor(topicId, start: start(topicId));
      final recent = await repo.recentCorrectIds(topicId);
      final random = ref.read(quizRandomProvider);
      final stats = await ref.read(statsRepositoryProvider.future);
      final mixTopic = await stats.mixInTopic(topicId);
      final mixIn = mixTopic == null
          ? const <Question>[]
          : pickMixIn(
              candidates: bank.byTopic[mixTopic] ?? const [],
              level: await repo.levelFor(mixTopic, start: start(mixTopic)),
              recentCorrect: await repo.recentCorrectIds(mixTopic),
              random: random,
            );
      final questions = buildRound(
        topicQuestions: bank.byTopic[topicId] ?? const [],
        level: level,
        recentCorrect: recent,
        random: random,
        mixIn: mixIn,
      );
      if (questions.isEmpty) throw StateError('no questions for $topicId');
      final roundId = await repo.startRound(topicId, level);
      if (!ref.mounted) return;
      state = RoundState(
        topicId: topicId,
        level: level,
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
    unawaited(
      ref
          .read(soundEffectsProvider)
          .play(
            answered.lastResult!.correct
                ? SoundEffect.right
                : SoundEffect.wrong,
          ),
    );
    state = RoundState(
      topicId: s.topicId,
      level: s.level,
      roundId: s.roundId,
      quiz: quiz,
      saving: true,
    );
    final repo = ref.read(roundRepositoryProvider);
    await repo.saveAttempt(s.roundId!, answered.lastResult!);
    var newBadges = const <Badge>[];
    if (answered.isLast) {
      await repo.finishRound(
        s.roundId!,
        score: answered.score,
        durationMs: answered.durationMs,
        stars: answered.stars,
      );
      newBadges = await _awardBadges();
    }
    if (!ref.mounted) return;
    state = RoundState(
      topicId: s.topicId,
      level: s.level,
      roundId: s.roundId,
      quiz: answered,
      newBadges: newBadges,
    );
  }

  /// The next question, or done after the last. No database or bank work.
  void next() {
    final s = state;
    final quiz = s.quiz;
    if (quiz == null || quiz.phase != QuizPhase.feedback) return;
    state = RoundState(
      topicId: s.topicId,
      level: s.level,
      roundId: s.roundId,
      quiz: quiz.next(ref.read(clockProvider)()),
      newBadges: s.newBadges,
    );
  }

  /// Awards badges after a finished round. The round is already saved, so
  /// a failure here only means no celebration (FEAT-08 design).
  Future<List<Badge>> _awardBadges() async {
    try {
      final badges = await ref.read(badgeRepositoryProvider.future);
      return await badges.awardNew();
    } catch (_) {
      return const [];
    }
  }
}

final quizControllerProvider =
    NotifierProvider.autoDispose<QuizController, RoundState>(
      QuizController.new,
    );
