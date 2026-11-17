/// The PDF progress report's content (PAR-09, FEAT-07): every number comes
/// from `stats.dart` over the same records SCR-09 shows. Display strings are
/// ASCII only, because the PDF's built-in Helvetica has no Unicode.
library;

import 'stats.dart';
import 'topics.dart';

const reportTrackNames = {
  Track.p1: 'P1',
  Track.p2: 'P2',
  Track.olympiad: 'Olympiad',
};

/// Shown where there is no data (the dashboard's "–" is not ASCII).
const noData = '-';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

// The class below has fields of the same names.
const _allTopics = topics;
const _needsPractice = needsPractice;

String _two(int n) => n.toString().padLeft(2, '0');

/// `15 Nov 2026`.
String reportDate(DateTime t) => '${t.day} ${_months[t.month - 1]} ${t.year}';

/// `9 Nov`, for week labels.
String reportWeek(DateTime t) => '${t.day} ${_months[t.month - 1]}';

String reportPct(Tally? t) {
  final a = t?.accuracy;
  return a == null ? noData : '${(a * 100).round()} %';
}

String reportSecs(Tally? t) {
  final s = t?.avgSeconds;
  return s == null ? noData : '${s.toStringAsFixed(1)} s';
}

String reportCount(Tally? t) =>
    t == null || t.attempts == 0 ? noData : '${t.attempts}';

String _periodSuffix(StatsPeriod p) => switch (p) {
  StatsPeriod.days7 => '7d',
  StatsPeriod.days30 => '30d',
  StatsPeriod.all => 'all',
};

/// `number-ninja-report-2026-11-15-30d.pdf` (NFR-08: [now] is injected).
String reportFileName(StatsPeriod period, DateTime now) =>
    'number-ninja-report-${now.year}-${_two(now.month)}-${_two(now.day)}'
    '-${_periodSuffix(period)}.pdf';

/// One row of the track summary.
class ReportRow {
  const ReportRow({
    required this.label,
    required this.accuracy,
    required this.avgTime,
    required this.answers,
  });

  final String label;
  final String accuracy;
  final String avgTime;
  final String answers;
}

/// One topic row; [flagged] when it needs practice (PAR-07).
class ReportTopicRow extends ReportRow {
  const ReportTopicRow({
    required this.topicId,
    required this.track,
    required this.flagged,
    required super.label,
    required super.accuracy,
    required super.avgTime,
    required super.answers,
  });

  final String topicId;
  final Track track;
  final bool flagged;

  String get trackLabel => reportTrackNames[track]!;
}

class ReportData {
  const ReportData({
    required this.period,
    required this.now,
    required this.from,
    required this.tracks,
    required this.topics,
    required this.needsPractice,
    required this.weeks,
    required this.accuracyTrend,
    required this.speedTrend,
    required this.isEmpty,
  });

  final StatsPeriod period;
  final DateTime now;

  /// The period's first instant, or null for all time.
  final DateTime? from;

  /// All three tracks, in [Track] order.
  final List<ReportRow> tracks;

  /// All topics, in design §2 order.
  final List<ReportTopicRow> topics;
  final List<ReportTopicRow> needsPractice;

  /// Monday of each of the last 8 weeks, oldest first (as on SCR-09).
  final List<DateTime> weeks;

  /// Per track, one value per week: accuracy in % (0–100) or seconds per
  /// question; null for a week with no answers.
  final Map<Track, List<double?>> accuracyTrend;
  final Map<Track, List<double?>> speedTrend;

  /// No answers in the period.
  final bool isEmpty;

  String get title => 'BrainBubblz progress report';

  String get periodLine => from == null
      ? 'All time: up to ${reportDate(now)}'
      : '${period.longLabel}: ${reportDate(from!)} - ${reportDate(now)}';

  String get createdLine =>
      'Created ${reportDate(now)} ${_two(now.hour)}:${_two(now.minute)}';

  List<String> get weekLabels => [for (final w in weeks) reportWeek(w)];

  /// Every string the report draws, for the ASCII check.
  Iterable<String> get allText sync* {
    yield title;
    yield periodLine;
    yield createdLine;
    yield* weekLabels;
    for (final r in [...tracks, ...topics]) {
      yield r.label;
      yield r.accuracy;
      yield r.avgTime;
      yield r.answers;
    }
    for (final r in topics) {
      yield r.trackLabel;
    }
  }

  /// Builds the report for [period] from every saved attempt [all] (trends
  /// use all of them, like SCR-09; the rest only the period's).
  static ReportData build(
    List<AttemptRecord> all,
    StatsPeriod period,
    DateTime now,
  ) {
    final rs = [
      for (final r in all)
        if (period.includes(r.answeredAt, now)) r,
    ];
    final topicTallies = byTopic(rs);
    final trackTallies = byTrack(rs);
    final needIds = _needsPractice(topicTallies, overall(rs));
    final needs = needIds.toSet();

    final topicRows = [
      for (final t in _allTopics)
        ReportTopicRow(
          topicId: t.id,
          track: t.track,
          flagged: needs.contains(t.id),
          label: t.name,
          accuracy: reportPct(topicTallies[t.id]),
          avgTime: reportSecs(topicTallies[t.id]),
          answers: reportCount(topicTallies[t.id]),
        ),
    ];
    final byId = {for (final r in topicRows) r.topicId: r};

    final trends = {
      for (final tr in Track.values)
        tr: weeklyTrend([
          for (final r in all)
            if (topicsById[r.topicId]?.track == tr) r,
        ], now),
    };

    return ReportData(
      period: period,
      now: now,
      from: period.since(now),
      tracks: [
        for (final tr in Track.values)
          ReportRow(
            label: reportTrackNames[tr]!,
            accuracy: reportPct(trackTallies[tr]),
            avgTime: reportSecs(trackTallies[tr]),
            answers: reportCount(trackTallies[tr]),
          ),
      ],
      topics: topicRows,
      needsPractice: [for (final id in needIds) byId[id]!],
      weeks: [for (final p in trends[Track.p1]!) p.weekStart],
      accuracyTrend: {
        for (final MapEntry(:key, :value) in trends.entries)
          key: [
            for (final p in value)
              p.tally?.accuracy == null ? null : p.tally!.accuracy! * 100,
          ],
      },
      speedTrend: {
        for (final MapEntry(:key, :value) in trends.entries)
          key: [for (final p in value) p.tally?.avgSeconds],
      },
      isEmpty: rs.isEmpty,
    );
  }
}
