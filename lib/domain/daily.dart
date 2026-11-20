/// One calendar day of progress for SCR-16 (PAR-11), worked out from saved
/// attempts and rounds. Never stored.
library;

import 'screen_time.dart';
import 'stats.dart';

/// Local midnight of [day] (`yyyy-MM-dd`) to the next local midnight. Built
/// from calendar fields, so a 23 h or 25 h daylight-saving day is right.
({DateTime start, DateTime end}) dayBounds(String day) {
  final d = DateTime.parse(day);
  return (
    start: DateTime(d.year, d.month, d.day),
    end: DateTime(d.year, d.month, d.day + 1),
  );
}

/// The day [day] key moved by [days] calendar days.
String shiftDay(String day, int days) {
  final d = DateTime.parse(day);
  return dayKey(DateTime(d.year, d.month, d.day + days));
}

/// One saved answer with what she gave.
class DayAnswer {
  const DayAnswer({required this.record, required this.given});

  final AttemptRecord record;
  final String given;
}

/// A round with its answers from one day.
class DayRound {
  const DayRound({
    required this.id,
    required this.topicId,
    required this.level,
    required this.revision,
    required this.startedAt,
    required this.finishedAt,
    required this.score,
    required this.stars,
    required this.durationMs,
    required this.answers,
  });

  final int id;
  final String topicId;
  final int level;
  final bool revision;
  final DateTime startedAt;

  /// Null for a quit round (PRC-09).
  final DateTime? finishedAt;
  final int score;
  final int stars;
  final int durationMs;

  /// That day's answers, in answer order.
  final List<DayAnswer> answers;
}

/// Everything SCR-16 shows for one day.
class DayDetail {
  const DayDetail({
    required this.day,
    required this.rounds,
    required this.secondsUsed,
  });

  final String day;

  /// By start time.
  final List<DayRound> rounds;

  /// Screen time used that day, summed over her devices.
  final int secondsUsed;

  List<AttemptRecord> get records => [
    for (final r in rounds)
      for (final a in r.answers) a.record,
  ];

  Tally get tally => overall(records);

  Map<String, Tally> get topics => byTopic(records);
}

/// The [limit] latest days with answers, newest first, with their tallies.
List<({String day, Tally tally})> recentDays(
  Iterable<AttemptRecord> records, {
  int limit = 7,
}) {
  final byDay = <String, Tally>{};
  for (final r in records) {
    final k = dayKey(r.answeredAt);
    byDay[k] = (byDay[k] ?? Tally.empty).add(r);
  }
  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return [for (final d in days.take(limit)) (day: d, tally: byDay[d]!)];
}
