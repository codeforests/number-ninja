import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/quiz.dart';
import 'database.dart';

/// Saves rounds and attempts (PRC-04, PRC-06) and reads recent results
/// (PRC-08).
class RoundRepository {
  RoundRepository(this.db, {required this.clock});

  final AppDatabase db;
  final Clock clock;

  /// This app opening's `play_sessions` row, created on first use.
  /// FEAT-05 may take this over.
  int? _sessionId;

  Future<int> _session() async => _sessionId ??= await db
      .into(db.playSessions)
      .insert(PlaySessionsCompanion.insert(startedAt: clock()));

  /// Creates a `rounds` row and returns its id.
  Future<int> startRound(String topicId, int level) async {
    final session = await _session();
    return db
        .into(db.rounds)
        .insert(
          RoundsCompanion.insert(
            sessionId: session,
            topicId: topicId,
            level: Value(level),
            startedAt: clock(),
          ),
        );
  }

  /// Inserts one answer, stamped with the clock (PRC-04, NFR-05).
  Future<void> saveAttempt(int roundId, AnswerResult r) => db
      .into(db.attempts)
      .insert(
        AttemptsCompanion.insert(
          roundId: roundId,
          questionId: r.questionId,
          answerGiven: r.given,
          correct: r.correct,
          timeMs: r.timeMs,
          answeredAt: clock(),
        ),
      );

  /// Writes the final score. An unfinished round keeps score 0.
  Future<void> finishRound(
    int roundId, {
    required int score,
    required int durationMs,
    required int stars,
  }) => (db.update(db.rounds)..where((r) => r.id.equals(roundId))).write(
    RoundsCompanion(
      score: Value(score),
      durationMs: Value(durationMs),
      stars: Value(stars),
    ),
  );

  /// Question ids answered correctly in the topic's last [rounds] rounds,
  /// by start time (PRC-08).
  Future<Set<String>> recentCorrectIds(String topicId, {int rounds = 3}) async {
    final recent =
        await (db.select(db.rounds)
              ..where((r) => r.topicId.equals(topicId))
              ..orderBy([
                (r) => OrderingTerm.desc(r.startedAt),
                (r) => OrderingTerm.desc(r.id),
              ])
              ..limit(rounds))
            .get();
    if (recent.isEmpty) return {};
    final rows =
        await (db.select(db.attempts)..where(
              (a) =>
                  a.roundId.isIn(recent.map((r) => r.id)) &
                  a.correct.equals(true),
            ))
            .get();
    return {for (final a in rows) a.questionId};
  }
}
