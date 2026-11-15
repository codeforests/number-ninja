/// Parent dashboard stats (PAR-05..08), worked out from saved attempts
/// joined to the bank (design §4). Never stored.
library;

import 'topics.dart';

/// One saved answer, with the topic of its question (not of its round).
class AttemptRecord {
  const AttemptRecord({
    required this.questionId,
    required this.topicId,
    required this.correct,
    required this.timeMs,
    required this.answeredAt,
  });

  final String questionId;
  final String topicId;
  final bool correct;
  final int timeMs;
  final DateTime answeredAt;
}

/// A saved answer before its question's topic is looked up.
typedef RawAttempt = ({
  String questionId,
  bool correct,
  int timeMs,
  DateTime answeredAt,
});

/// Joins [rows] to the bank by question id ([topicOf]: question id → topic
/// id), so a mixed-in question counts for its own topic. Rows whose question
/// is not in the bank are skipped.
List<AttemptRecord> withBankTopics(
  Iterable<RawAttempt> rows,
  Map<String, String> topicOf,
) => [
  for (final r in rows)
    if (topicOf[r.questionId] case final topic?)
      AttemptRecord(
        questionId: r.questionId,
        topicId: topic,
        correct: r.correct,
        timeMs: r.timeMs,
        answeredAt: r.answeredAt,
      ),
];

/// The period the dashboard shows (PAR-05). Rolling, from the clock.
enum StatsPeriod {
  days7('7 days', 'Last 7 days', '7'),
  days30('30 days', 'Last 30 days', '30'),
  all('All time', 'All time', 'all');

  const StatsPeriod(this.label, this.longLabel, this.query);

  final String label;
  final String longLabel;

  /// Its value in a route query (`?p=7|30|all`).
  final String query;

  /// The earliest `answered_at` counted, or null for all time.
  DateTime? since(DateTime now) => switch (this) {
    days7 => now.subtract(const Duration(days: 7)),
    days30 => now.subtract(const Duration(days: 30)),
    all => null,
  };

  static StatsPeriod fromQuery(String? q) =>
      values.firstWhere((p) => p.query == q, orElse: () => days30);

  bool includes(DateTime answeredAt, DateTime now) {
    final s = since(now);
    return s == null || !answeredAt.isBefore(s);
  }
}

/// Each attempt's time counts at most this much towards an average.
const timeCap = Duration(seconds: 120);

/// Counts for a group of attempts.
class Tally {
  const Tally({this.attempts = 0, this.correct = 0, this.totalMs = 0});

  static const empty = Tally();

  final int attempts;
  final int correct;

  /// Sum of `time_ms`, each capped at [timeCap].
  final int totalMs;

  int get wrong => attempts - correct;

  /// 0–1, or null with no attempts.
  double? get accuracy => attempts == 0 ? null : correct / attempts;

  /// Mean seconds per question (capped), or null with no attempts.
  double? get avgSeconds => attempts == 0 ? null : totalMs / attempts / 1000;

  Tally add(AttemptRecord r) => Tally(
    attempts: attempts + 1,
    correct: correct + (r.correct ? 1 : 0),
    totalMs: totalMs + _capped(r.timeMs),
  );

  @override
  bool operator ==(Object other) =>
      other is Tally &&
      other.attempts == attempts &&
      other.correct == correct &&
      other.totalMs == totalMs;

  @override
  int get hashCode => Object.hash(attempts, correct, totalMs);

  @override
  String toString() =>
      'Tally(attempts: $attempts, correct: $correct, totalMs: $totalMs)';
}

int _capped(int ms) {
  final cap = timeCap.inMilliseconds;
  return ms < 0 ? 0 : (ms > cap ? cap : ms);
}

Tally overall(Iterable<AttemptRecord> records) =>
    records.fold(Tally.empty, (t, r) => t.add(r));

/// Tallies per topic id; topics with no attempts are absent.
Map<String, Tally> byTopic(Iterable<AttemptRecord> records) {
  final m = <String, Tally>{};
  for (final r in records) {
    m[r.topicId] = (m[r.topicId] ?? Tally.empty).add(r);
  }
  return m;
}

/// Tallies per track; tracks with no attempts are absent. Records of an
/// unknown topic are skipped.
Map<Track, Tally> byTrack(Iterable<AttemptRecord> records) {
  final m = <Track, Tally>{};
  for (final r in records) {
    final track = topicsById[r.topicId]?.track;
    if (track == null) continue;
    m[track] = (m[track] ?? Tally.empty).add(r);
  }
  return m;
}

/// Topics that need practice (PAR-07): at least [minAttempts] attempts and
/// accuracy below [below] or an average slower than [overall]'s. Lowest
/// accuracy first, then topic id.
List<String> needsPractice(
  Map<String, Tally> topicTallies,
  Tally overall, {
  int minAttempts = 10,
  double below = 0.7,
}) {
  final avg = overall.avgSeconds;
  final out = [
    for (final MapEntry(key: id, value: t) in topicTallies.entries)
      if (t.attempts >= minAttempts &&
          (t.accuracy! < below || (avg != null && t.avgSeconds! > avg)))
        id,
  ];
  out.sort((a, b) {
    final d = topicTallies[a]!.accuracy!.compareTo(topicTallies[b]!.accuracy!);
    return d != 0 ? d : a.compareTo(b);
  });
  return out;
}

/// Monday 00:00 local time of the week [t] falls in.
DateTime weekStart(DateTime t) =>
    DateTime(t.year, t.month, t.day - (t.weekday - DateTime.monday));

/// One week of a trend; [tally] is null for a week with no attempts.
class WeekPoint {
  const WeekPoint(this.weekStart, this.tally);

  final DateTime weekStart;
  final Tally? tally;
}

/// The last [weeks] weeks, oldest first, ending with the week of [now]
/// (PAR-06). Attempts outside them are ignored.
List<WeekPoint> weeklyTrend(
  Iterable<AttemptRecord> records,
  DateTime now, {
  int weeks = 8,
}) {
  final current = weekStart(now);
  final starts = [
    for (var i = weeks - 1; i >= 0; i--)
      DateTime(current.year, current.month, current.day - 7 * i),
  ];
  final tallies = <DateTime, Tally>{};
  for (final r in records) {
    final w = weekStart(r.answeredAt);
    if (w.isBefore(starts.first) || w.isAfter(current)) continue;
    tallies[w] = (tallies[w] ?? Tally.empty).add(r);
  }
  return [for (final s in starts) WeekPoint(s, tallies[s])];
}

/// A question's tally (PAR-08).
class QuestionTally {
  const QuestionTally(this.questionId, this.tally);

  final String questionId;
  final Tally tally;
}

Map<String, Tally> _byQuestion(Iterable<AttemptRecord> records) {
  final m = <String, Tally>{};
  for (final r in records) {
    m[r.questionId] = (m[r.questionId] ?? Tally.empty).add(r);
  }
  return m;
}

/// The [n] questions answered wrong most often: wrong count, then wrong
/// rate (both highest first), then id. Only questions with a wrong answer.
List<QuestionTally> mostMissed(Iterable<AttemptRecord> records, {int n = 5}) {
  final list = [
    for (final MapEntry(key: id, value: t) in _byQuestion(records).entries)
      if (t.wrong > 0) QuestionTally(id, t),
  ];
  list.sort((a, b) {
    var d = b.tally.wrong.compareTo(a.tally.wrong);
    if (d != 0) return d;
    d = (b.tally.wrong / b.tally.attempts).compareTo(
      a.tally.wrong / a.tally.attempts,
    );
    return d != 0 ? d : a.questionId.compareTo(b.questionId);
  });
  return list.take(n).toList();
}

/// The [n] questions with the highest average (capped) time, then id.
List<QuestionTally> slowest(Iterable<AttemptRecord> records, {int n = 5}) {
  final list = [
    for (final MapEntry(key: id, value: t) in _byQuestion(records).entries)
      QuestionTally(id, t),
  ];
  list.sort((a, b) {
    final d = b.tally.avgSeconds!.compareTo(a.tally.avgSeconds!);
    return d != 0 ? d : a.questionId.compareTo(b.questionId);
  });
  return list.take(n).toList();
}
