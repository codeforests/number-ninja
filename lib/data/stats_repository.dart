import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/question.dart';
import '../domain/stats.dart';
import '../domain/topics.dart';
import 'database.dart';

/// Reads attempts for the dashboard (PAR-05..08) and resets progress
/// (PAR-10). Joins attempts to the bank by question id (design §4).
class StatsRepository {
  StatsRepository(this.db, this.bank, {required this.clock})
    : _topicOf = {for (final q in bank.questions) q.id: q.topic};

  final AppDatabase db;
  final QuestionBank bank;
  final Clock clock;
  final Map<String, String> _topicOf;

  /// Attempts answered at or after [since] (all when null), optionally only
  /// those whose question is in [topicId]. Unknown question ids are skipped.
  Future<List<AttemptRecord>> records({
    DateTime? since,
    String? topicId,
  }) async {
    final q = db.select(db.attempts);
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

  /// Deletes all attempts, rounds, play sessions and badges in one
  /// transaction (PAR-10). The PIN, daily limit, lockout and `daily_usage`
  /// stay, so a reset never gives screen time back (TIM-05).
  Future<void> resetProgress() => db.transaction(() async {
    await db.delete(db.attempts).go();
    await db.delete(db.rounds).go();
    await db.delete(db.playSessions).go();
    await db.delete(db.badgesEarned).go();
  });
}
