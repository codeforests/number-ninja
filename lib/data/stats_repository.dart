import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/daily.dart';
import '../domain/question.dart';
import '../domain/screen_time.dart';
import '../domain/stats.dart';
import '../domain/topics.dart';
import 'database.dart';
import 'round_repository.dart';

/// Reads attempts for the dashboard (PAR-05..08) and resets progress
/// (PAR-10). Joins attempts to the bank by question id (design §4).
class StatsRepository {
  StatsRepository(this.db, this.bank, {required this.clock, this.childId = 1})
    : _topicOf = {for (final q in bank.questions) q.id: q.topic};

  final AppDatabase db;

  /// The child whose answers these are (FEAT-25, FAM-03).
  final int childId;
  final QuestionBank bank;
  final Clock clock;
  final Map<String, String> _topicOf;

  /// Attempts answered at or after [since] (all when null), optionally only
  /// those whose question is in [topicId]. Unknown question ids are skipped.
  Future<List<AttemptRecord>> records({
    DateTime? since,
    String? topicId,
  }) async {
    final q = db.select(db.attempts)..where((a) => a.childId.equals(childId));
    if (since != null) q.where((a) => a.answeredAt.isBiggerOrEqualValue(since));
    final rows = await q.get();
    final out = withBankTopics([
      for (final a in rows)
        (
          questionId: a.questionId,
          correct: a.correct,
          timeMs: a.timeMs,
          answeredAt: a.answeredAt,
        ),
    ], _topicOf);
    return topicId == null
        ? out
        : [
            for (final r in out)
              if (r.topicId == topicId) r,
          ];
  }

  /// Attempts in [period], counted back from the clock.
  Future<List<AttemptRecord>> recordsIn(
    StatsPeriod period, {
    String? topicId,
  }) => records(since: period.since(clock()), topicId: topicId);

  /// One local calendar day (`yyyy-MM-dd`) for SCR-16 (PAR-11): that day's
  /// answers grouped by round, and screen time summed over her devices. An
  /// answer whose question isn't in the bank counts for its round's topic.
  Future<DayDetail> day(String day) async {
    final b = dayBounds(day);
    final rows =
        await (db.select(db.attempts)
              ..where(
                (a) =>
                    a.childId.equals(childId) &
                    a.answeredAt.isBiggerOrEqualValue(b.start) &
                    a.answeredAt.isSmallerThanValue(b.end),
              )
              ..orderBy([(a) => OrderingTerm.asc(a.answeredAt)]))
            .get();
    final ids = {for (final a in rows) a.roundId};
    final rounds = ids.isEmpty
        ? const <Round>[]
        : await (db.select(db.rounds)..where((r) => r.id.isIn(ids))).get();
    final byRound = <int, List<DayAnswer>>{};
    final roundById = {for (final r in rounds) r.id: r};
    for (final a in rows) {
      byRound
          .putIfAbsent(a.roundId, () => [])
          .add(
            DayAnswer(
              record: AttemptRecord(
                questionId: a.questionId,
                topicId:
                    _topicOf[a.questionId] ??
                    roundById[a.roundId]?.topicId ??
                    '',
                correct: a.correct,
                timeMs: a.timeMs,
                answeredAt: a.answeredAt,
              ),
              given: a.answerGiven,
            ),
          );
    }
    final dayRounds = [
      for (final r in rounds)
        DayRound(
          id: r.id,
          topicId: r.topicId,
          level: r.level,
          revision: r.kind == roundKindRevision,
          startedAt: r.startedAt,
          finishedAt: r.finishedAt,
          score: r.score,
          stars: r.stars,
          durationMs: r.durationMs,
          answers: byRound[r.id] ?? const [],
        ),
    ]..sort((x, y) => x.startedAt.compareTo(y.startedAt));
    final usage = await (db.select(
      db.dailyUsage,
    )..where((u) => u.day.equals(day) & u.childId.equals(childId))).get();
    return DayDetail(
      day: day,
      rounds: dayRounds,
      secondsUsed: usage.fold(0, (s, u) => s + u.secondsUsed),
    );
  }

  /// The day of her first saved answer, or null with none.
  Future<String?> firstDay() async {
    final first =
        await (db.select(db.attempts)
              ..where((a) => a.childId.equals(childId))
              ..orderBy([(a) => OrderingTerm.asc(a.answeredAt)])
              ..limit(1))
            .getSingleOrNull();
    return first == null ? null : dayKey(first.answeredAt);
  }

  /// The School topic a School round of [roundTopic] mixes in from
  /// (design §5): the first 30-day needs-practice P1/P2 topic other than
  /// [roundTopic], or null. Olympiad rounds never mix in.
  Future<String?> mixInTopic(String roundTopic) async {
    final own = topicsById[roundTopic];
    if (own == null || own.track == Track.olympiad) return null;
    final rs = await recordsIn(StatsPeriod.days30);
    for (final id in needsPractice(byTopic(rs), overall(rs))) {
      final t = topicsById[id];
      if (id != roundTopic && t != null && t.track != Track.olympiad) {
        return id;
      }
    }
    return null;
  }

  /// Deletes this child's attempts, rounds and badges in one transaction
  /// (PAR-10, per child since FEAT-25 AD-11), and play sessions no round
  /// uses any more. The PIN, daily limit, lockout and `daily_usage` stay,
  /// so a reset never gives screen time back (TIM-05).
  Future<void> resetProgress() => db.transaction(() async {
    await (db.delete(
      db.attempts,
    )..where((a) => a.childId.equals(childId))).go();
    await (db.delete(db.rounds)..where((r) => r.childId.equals(childId))).go();
    await db.customStatement(
      'DELETE FROM play_sessions WHERE id NOT IN '
      '(SELECT session_id FROM rounds)',
    );
    await (db.delete(
      db.badgesEarned,
    )..where((b) => b.childId.equals(childId))).go();
  });
}
