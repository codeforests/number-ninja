import 'answers.dart';
import 'question.dart';
import 'stars.dart';

enum QuizPhase { answering, feedback, done }

/// One answered question (PRC-04).
class AnswerResult {
  const AnswerResult({
    required this.questionId,
    required this.given,
    required this.correct,
    required this.timeMs,
  });

  final String questionId;

  /// What she gave, as stored in `attempts.answer_given` ([answerText]).
  final String given;
  final bool correct;
  final int timeMs;
}

/// Immutable state of one round. Time comes in as a parameter (NFR-08).
class Quiz {
  const Quiz._({
    required this.questions,
    required this.index,
    required this.phase,
    required this.results,
    required this.shownAt,
  });

  /// A new round showing the first question at [now].
  factory Quiz.start(List<Question> questions, DateTime now) => Quiz._(
    questions: List.unmodifiable(questions),
    index: 0,
    phase: questions.isEmpty ? QuizPhase.done : QuizPhase.answering,
    results: const [],
    shownAt: now,
  );

  final List<Question> questions;
  final int index;
  final QuizPhase phase;
  final List<AnswerResult> results;

  /// When the current question was shown.
  final DateTime shownAt;

  Question get current => questions[index];
  bool get isLast => index == questions.length - 1;

  /// The result for the current question, once answered.
  AnswerResult? get lastResult =>
      phase == QuizPhase.answering || results.isEmpty ? null : results.last;

  int get score => results.where((r) => r.correct).length;

  /// Sum of answer times, so reading feedback isn't counted.
  int get durationMs => results.fold(0, (s, r) => s + r.timeMs);

  int get stars => starsFor(score);

  /// Answers the current question with [given] at [now].
  Quiz answer(Object given, DateTime now) {
    if (phase != QuizPhase.answering) {
      throw StateError('answer() in phase $phase');
    }
    final q = current;
    final ms = now.difference(shownAt).inMilliseconds;
    final result = AnswerResult(
      questionId: q.id,
      given: answerText(q, given),
      correct: isCorrect(q, given),
      timeMs: ms < 0 ? 0 : ms,
    );
    return Quiz._(
      questions: questions,
      index: index,
      phase: QuizPhase.feedback,
      results: List.unmodifiable([...results, result]),
      shownAt: shownAt,
    );
  }

  /// Moves to the next question shown at [now], or to done after the last.
  Quiz next(DateTime now) {
    if (phase != QuizPhase.feedback) {
      throw StateError('next() in phase $phase');
    }
    return Quiz._(
      questions: questions,
      index: isLast ? index : index + 1,
      phase: isLast ? QuizPhase.done : QuizPhase.answering,
      results: results,
      shownAt: isLast ? shownAt : now,
    );
  }
}

/// [given] as text: drag lists joined with `, `.
String answerText(Question q, Object given) =>
    given is List ? given.join(', ') : given.toString().trim();

/// The correct answer as shown in "The answer is …".
String correctAnswerText(Question q) => answerText(q, q.answer);
