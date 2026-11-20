import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/report.dart';
import 'package:number_ninja/domain/stats.dart';
import 'package:number_ninja/domain/topics.dart';

final now = DateTime(2026, 11, 15, 14, 5); // a Sunday

AttemptRecord rec(
  String topic, {
  bool correct = true,
  int ms = 10000,
  DateTime? at,
  String? q,
}) => AttemptRecord(
  questionId: q ?? '$topic-q',
  topicId: topic,
  correct: correct,
  timeMs: ms,
  answeredAt: at ?? now,
);

List<AttemptRecord> many(
  String topic,
  int n, {
  required int correct,
  int ms = 10000,
  DateTime? at,
}) => [
  for (var i = 0; i < n; i++)
    rec(topic, correct: i < correct, ms: ms, q: '$topic-$i', at: at),
];

bool isAscii(String s) => s.codeUnits.every((c) => c >= 0x20 && c < 0x7f);

void main() {
  final records = [
    ...many('p1.bonds', 10, correct: 5, ms: 8000), // 50 %, needs practice
    ...many('p2.times', 4, correct: 3, ms: 4500),
    ...many('oly.logic', 12, correct: 12, ms: 5000),
    // 20 days ago: in 30 days and all time, not in 7 days.
    ...many(
      'p2.times',
      6,
      correct: 6,
      ms: 3000,
      at: now.subtract(const Duration(days: 20)),
    ),
    // 100 days ago: all time only, outside the 8-week trend.
    rec('p1.money', at: now.subtract(const Duration(days: 100))),
  ];

  group('content (AC-1)', () {
    test('track and topic rows match byTrack / byTopic', () {
      final d = ReportData.build(records, StatsPeriod.days30, now);
      final rs = [
        for (final r in records)
          if (StatsPeriod.days30.includes(r.answeredAt, now)) r,
      ];
      final tracks = byTrack(rs);
      final topicT = byTopic(rs);

      expect([for (final r in d.tracks) r.label], ['P1', 'P2', 'Olympiad']);
      for (final (i, tr) in Track.values.indexed) {
        final t = tracks[tr];
        expect(d.tracks[i].accuracy, '${(t!.accuracy! * 100).round()} %');
        expect(d.tracks[i].avgTime, '${t.avgSeconds!.toStringAsFixed(1)} s');
        expect(d.tracks[i].answers, '${t.attempts}');
      }
      expect(d.tracks[1].accuracy, '90 %'); // P2: 9 of 10
      expect(d.tracks[1].avgTime, '3.6 s');
      expect(d.tracks[1].answers, '10');

      expect(d.topics.map((r) => r.topicId), topics.map((t) => t.id));
      expect(d.topics, hasLength(23));
      for (final r in d.topics) {
        final t = topicT[r.topicId];
        expect(r.label, topicsById[r.topicId]!.name);
        expect(r.track, topicsById[r.topicId]!.track);
        if (t == null) {
          expect([r.accuracy, r.avgTime, r.answers], ['-', '-', '-']);
        } else {
          expect(r.accuracy, '${(t.accuracy! * 100).round()} %');
          expect(r.avgTime, '${t.avgSeconds!.toStringAsFixed(1)} s');
          expect(r.answers, '${t.attempts}');
        }
      }
      final bonds = d.topics.firstWhere((r) => r.topicId == 'p1.bonds');
      expect(
        [bonds.accuracy, bonds.avgTime, bonds.answers],
        ['50 %', '8.0 s', '10'],
      );
    });

    test('non-whole accuracy rounds to the nearest whole %', () {
      final d = ReportData.build(
        [
          ...many('p1.bonds', 3, correct: 2), // 66.7 %
          ...many('p2.times', 3, correct: 1), // 33.3 %
        ],
        StatsPeriod.days7,
        now,
      );
      String topic(String id) =>
          d.topics.firstWhere((r) => r.topicId == id).accuracy;
      expect([topic('p1.bonds'), topic('p2.times')], ['67 %', '33 %']);
      expect([d.tracks[0].accuracy, d.tracks[1].accuracy], ['67 %', '33 %']);
    });

    test('a track with no answers shows "-"', () {
      final d = ReportData.build(
        many('p2.times', 3, correct: 3),
        StatsPeriod.days7,
        now,
      );
      expect(
        [d.tracks[0].accuracy, d.tracks[0].avgTime, d.tracks[0].answers],
        ['-', '-', '-'],
      );
    });

    test('needs practice and flagged match needsPractice', () {
      final d = ReportData.build(records, StatsPeriod.days30, now);
      final rs = [
        for (final r in records)
          if (StatsPeriod.days30.includes(r.answeredAt, now)) r,
      ];
      final expected = needsPractice(byTopic(rs), overall(rs));
      expect(expected, ['p1.bonds']);
      expect(d.needsPractice.map((r) => r.topicId), expected);
      expect(d.needsPractice.single.trackLabel, 'P1');
      expect([
        for (final r in d.topics)
          if (r.flagged) r.topicId,
      ], expected);
    });

    test('trends: 8 weeks, nulls for empty weeks, per track', () {
      final d = ReportData.build(records, StatsPeriod.days7, now);
      expect(d.weeks, hasLength(8));
      expect(d.weeks.last, DateTime(2026, 11, 9));
      expect(d.weeks.first, DateTime(2026, 9, 21));
      expect(d.weekLabels.last, '9 Nov');
      for (final tr in Track.values) {
        expect(d.accuracyTrend[tr], hasLength(8));
        expect(d.speedTrend[tr], hasLength(8));
      }
      // Trends use all records like SCR-09, not only the 7-day period.
      final p2 = d.accuracyTrend[Track.p2]!;
      expect(p2.last, 75); // 3 of 4 this week
      expect(p2[5], 100); // 20 days ago: week of 26 Oct
      expect(p2.where((v) => v == null), hasLength(6));
      expect(d.speedTrend[Track.p2]![5], 3.0);
      // The 100-day-old P1 answer is outside the 8 weeks.
      expect(d.accuracyTrend[Track.p1]!.whereType<double>(), [50]);
    });

    test('period line and dates for 7 / 30 days and all time', () {
      expect(
        ReportData.build(records, StatsPeriod.days7, now).periodLine,
        'Last 7 days: 8 Nov 2026 - 15 Nov 2026',
      );
      expect(
        ReportData.build(records, StatsPeriod.days30, now).periodLine,
        'Last 30 days: 16 Oct 2026 - 15 Nov 2026',
      );
      final all = ReportData.build(records, StatsPeriod.all, now);
      expect(all.periodLine, 'All time: up to 15 Nov 2026');
      expect(all.from, isNull);
      expect(all.createdLine, 'Created 15 Nov 2026 14:05');
      expect(all.title, 'BrainBubblz progress report');
      // The 100-day answer counts in all time only.
      final money = all.topics.firstWhere((r) => r.topicId == 'p1.money');
      expect(money.answers, '1');
    });

    test('isEmpty with no records in the period', () {
      final old = [rec('p1.bonds', at: now.subtract(const Duration(days: 9)))];
      expect(ReportData.build(old, StatsPeriod.days7, now).isEmpty, isTrue);
      expect(ReportData.build(old, StatsPeriod.days30, now).isEmpty, isFalse);
      expect(ReportData.build(const [], StatsPeriod.all, now).isEmpty, isTrue);
      final empty = ReportData.build(const [], StatsPeriod.all, now);
      expect(empty.topics, hasLength(23));
      expect(empty.needsPractice, isEmpty);
    });

    test('every string is ASCII', () {
      for (final p in StatsPeriod.values) {
        for (final rs in [records, <AttemptRecord>[]]) {
          final d = ReportData.build(rs, p, now);
          final bad = d.allText.where((s) => !isAscii(s)).toList();
          expect(bad, isEmpty, reason: '$p');
        }
      }
    });
  });

  group('file name (AC-3)', () {
    test('from the injected clock', () {
      expect(
        reportFileName(StatsPeriod.days30, now),
        'brainbubblz-report-2026-11-15-30d.pdf',
      );
      expect(
        reportFileName(StatsPeriod.days7, now),
        'brainbubblz-report-2026-11-15-7d.pdf',
      );
      expect(
        reportFileName(StatsPeriod.all, DateTime(2027, 1, 5)),
        'brainbubblz-report-2027-01-05-all.pdf',
      );
    });
  });
}
