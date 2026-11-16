import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/progress.dart';
import '../domain/quiz.dart';
import 'database.dart';

const roundKindNormal = 'normal';
const roundKindRevision = 'revision';

/// Saves rounds and attempts (PRC-04, PRC-06) and reads recent results
/// (PRC-08).
class RoundRepository {
  RoundRepository(this.db, {required this.clock});

  final AppDatabase db;
  final Clock clock;

  /// This app opening's `play_sessions` row, created on first use.
  /// FEAT-05 may take this over.
  int? _sessionId;

  /// Drops the cached session after a progress reset deleted it (PAR-10),
  /// so the next round starts a new one.
  void forgetSession() => _sessionId = null;

  Future<int> _session() async => _sessionId ??= await db
      .into(db.playSessions)
      .insert(PlaySessionsCompanion.insert(startedAt: clock()));

  /// Creates a `rounds` row and returns its id. [kind] is `normal` or
  /// `revision` (REV-04).
  Future<int> startRound(
    String topicId,
    int level, {
    String kind = roundKindNormal,
  }) async {
    final session = await _session();
    return db
        .into(db.rounds)
        .insert(
          RoundsCompanion.insert(
            sessionId: session,
            topicId: topicId,
            level: Value(level),
            startedAt: clock(),
            kind: Value(kind),
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

  /// Writes the final score and stamps `finished_at`. A quit round keeps
  /// score 0 and no `finished_at`, so it never counts (PRC-09).
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
      finishedAt: Value(clock()),
    ),
  );

  /// Normal rounds with a `finished_at`, optionally of one topic. Revision
  /// rounds are left out, so levels, best stars and the topic lock ignore
  /// them (REV-04).
  Future<List<FinishedRound>> finishedRounds({String? topicId}) async {
    final q = db.select(db.rounds)
      ..where((r) => r.finishedAt.isNotNull() & r.kind.equals(roundKindNormal));
    if (topicId != null) q.where((r) => r.topicId.equals(topicId));
    return [
      for (final r in await q.get())
        FinishedRound(
          id: r.id,
          topicId: r.topicId,
          level: r.level,
          stars: r.stars,
          score: r.score,
          startedAt: r.startedAt,
        ),
    ];
  }

  /// Best stars and current level of every topic played (PRC-07, PRC-09).
  Future<Map<String, TopicProgress>> progress() async =>
      progressByTopic(await finishedRounds());

  /// The level her next round of [topicId] is played at (PRC-09), or
  /// [start] when it has no finished round yet (PRO-03).
  Future<int> levelFor(String topicId, {int start = minLevel}) async =>
      progressByTopic(await finishedRounds(topicId: topicId))[topicId]?.level ??
      start;

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
