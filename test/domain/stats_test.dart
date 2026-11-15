import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/stats.dart';
import 'package:number_ninja/domain/topics.dart';

final now = DateTime(2026, 11, 18, 15); // a Wednesday

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
}) => [
  for (var i = 0; i < n; i++)
    rec(topic, correct: i < correct, ms: ms, q: '$topic-$i'),
];

void main() {
  group('tallies (AC-1)', () {
    test('accuracy, capped average and counts per topic', () {
      final t = byTopic([
        rec('p1.bonds', ms: 4000),
        rec('p1.bonds', correct: false, ms: 300000), // capped at 120 s
        rec('p2.times', ms: 6000),
      ]);
      expect(
        t['p1.bonds'],
        const Tally(attempts: 2, correct: 1, totalMs: 124000),
      );
      expect(t['p1.bonds']!.accuracy, 0.5);
      expect(t['p1.bonds']!.avgSeconds, 62.0);
      expect(t['p2.times']!.avgSeconds, 6.0);
      expect(t.containsKey('p1.money'), isFalse);
    });

    test('empty tally has null accuracy and average', () {
      expect(Tally.empty.accuracy, isNull);
      expect(Tally.empty.avgSeconds, isNull);
      expect(overall([]), Tally.empty);
    });

    test('per track and overall', () {
      final rs = [
        rec('p1.bonds'),
        rec('p1.money', correct: false),
        rec('p2.times'),
        rec('oly.logic', correct: false),
        rec('nope.topic'),
      ];
      final t = byTrack(rs);
      expect(t[Track.p1], const Tally(attempts: 2, correct: 1, totalMs: 20000));
      expect(t[Track.p2]!.attempts, 1);
      expect(t[Track.olympiad]!.accuracy, 0.0);
      expect(overall(rs).attempts, 5);
    });

    test('unknown question ids are skipped; mixed-in counts for its own '
        'topic', () {
      final rows = <RawAttempt>[
        (questionId: 'a', correct: true, timeMs: 1000, answeredAt: now),
        (questionId: 'gone', correct: true, timeMs: 1000, answeredAt: now),
        // answered in a p1.money round, but the question is p2.times
        (questionId: 'b', correct: false, timeMs: 1000, answeredAt: now),
      ];
      final rs = withBankTopics(rows, {'a': 'p1.money', 'b': 'p2.times'});
      expect(rs.map((r) => r.questionId), ['a', 'b']);
      expect(byTopic(rs).keys.toSet(), {'p1.money', 'p2.times'});
      expect(byTopic(rs)['p2.times']!.wrong, 1);
    });

    test('period filters at exact 7- and 30-day boundaries', () {
      final at7 = now.subtract(const Duration(days: 7));
      final at30 = now.subtract(const Duration(days: 30));
      final ms = const Duration(milliseconds: 1);
      expect(StatsPeriod.days7.since(now), at7);
      expect(StatsPeriod.days7.includes(at7, now), isTrue);
      expect(StatsPeriod.days7.includes(at7.subtract(ms), now), isFalse);
      expect(StatsPeriod.days30.since(now), at30);
      expect(StatsPeriod.days30.includes(at30, now), isTrue);
      expect(StatsPeriod.days30.includes(at30.subtract(ms), now), isFalse);
      expect(StatsPeriod.all.since(now), isNull);
      expect(StatsPeriod.all.includes(DateTime(2000), now), isTrue);
    });

    test('period query round trip, default 30 days', () {
      for (final p in StatsPeriod.values) {
        expect(StatsPeriod.fromQuery(p.query), p);
      }
      expect(StatsPeriod.fromQuery(null), StatsPeriod.days30);
      expect(StatsPeriod.fromQuery('x'), StatsPeriod.days30);
    });
  });

  group('needs practice (AC-2)', () {
    test('9 attempts never listed, even at 0 %', () {
      final t = byTopic(many('p1.bonds', 9, correct: 0));
      expect(needsPractice(t, Tally.empty), isEmpty);
    });

    test('10 attempts at 69 % listed, 70 % not', () {
      // 69 %: 9 of 13 is 69.2 %, 7 of 10 is exactly 70 %.
      // Same speed everywhere, so only accuracy decides.
      final rs = [
        ...many('p1.bonds', 13, correct: 9),
        ...many('p1.money', 10, correct: 7),
      ];
      expect(needsPractice(byTopic(rs), overall(rs)), ['p1.bonds']);
    });

    test('slower than the overall average is listed', () {
      final rs = [
        ...many('p1.bonds', 10, correct: 10, ms: 5000),
        ...many('p1.money', 10, correct: 10, ms: 15000),
      ];
      expect(needsPractice(byTopic(rs), overall(rs)), ['p1.money']);
    });

    test('ordered by lowest accuracy, then topic id', () {
      final rs = [
        ...many('p2.times', 10, correct: 6),
        ...many('p1.money', 10, correct: 2),
        ...many('p1.bonds', 10, correct: 6),
      ];
      expect(needsPractice(byTopic(rs), overall(rs)), [
        'p1.money',
        'p1.bonds',
        'p2.times',
      ]);
    });
  });

  group('weekly trend (AC-3)', () {
    test('weeks start Monday 00:00', () {
      expect(weekStart(now), DateTime(2026, 11, 16));
      expect(weekStart(DateTime(2026, 11, 16)), DateTime(2026, 11, 16));
      // Sunday 23:59 belongs to the week before.
      expect(weekStart(DateTime(2026, 11, 22, 23, 59)), DateTime(2026, 11, 16));
      expect(weekStart(DateTime(2026, 11, 23)), DateTime(2026, 11, 23));
      // across a month end: Sat 1 Nov 2025 is in the week of Mon 27 Oct.
      expect(weekStart(DateTime(2025, 11, 1, 9)), DateTime(2025, 10, 27));
    });

    test('8 points ending with this week, empty weeks null', () {
      final sunNight = DateTime(2026, 11, 15, 23, 30); // last week
      final w = weeklyTrend([
        rec('p1.bonds', at: now),
        rec('p1.bonds', correct: false, at: sunNight),
        rec('p1.bonds', at: DateTime(2026, 9, 1)), // too old
      ], now);
      expect(w, hasLength(8));
      expect(w.last.weekStart, DateTime(2026, 11, 16));
      expect(w.first.weekStart, DateTime(2026, 9, 28));
      expect(w.last.tally!.attempts, 1);
      expect(w[6].weekStart, DateTime(2026, 11, 9));
      expect(w[6].tally!.correct, 0);
      expect(w.take(6).every((p) => p.tally == null), isTrue);
    });

    test('a week across a month end collects both months', () {
      final n = DateTime(2026, 12, 2); // Wed; week starts Mon 30 Nov
      final w = weeklyTrend([
        rec('p1.bonds', at: DateTime(2026, 11, 30, 8)),
        rec('p1.bonds', at: DateTime(2026, 12, 1, 8)),
      ], n);
      expect(w.last.weekStart, DateTime(2026, 11, 30));
      expect(w.last.tally!.attempts, 2);
    });
  });

  group('most missed and slowest (PAR-08)', () {
    test('most missed: wrong count, then rate, then id; only missed', () {
      final rs = [
        rec('t', q: 'a', correct: false),
        rec('t', q: 'a', correct: false),
        rec('t', q: 'a'),
        rec('t', q: 'b', correct: false),
        rec('t', q: 'b', correct: false),
        rec('t', q: 'c', correct: false),
        rec('t', q: 'd', correct: false),
        rec('t', q: 'e'),
      ];
      expect(mostMissed(rs).map((x) => x.questionId), ['b', 'a', 'c', 'd']);
      expect(mostMissed(rs, n: 2), hasLength(2));
    });

    test('slowest: highest average first, then id', () {
      final rs = [
        rec('t', q: 'a', ms: 3000),
        rec('t', q: 'b', ms: 9000),
        rec('t', q: 'c', ms: 9000),
        rec('t', q: 'd', ms: 500000),
      ];
      expect(slowest(rs).map((x) => x.questionId), ['d', 'b', 'c', 'a']);
      expect(slowest(rs).first.tally.avgSeconds, 120.0);
    });
  });
}
