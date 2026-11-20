import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/daily.dart';
import 'package:number_ninja/domain/stats.dart';

AttemptRecord rec(
  DateTime at, {
  bool correct = true,
  String topic = 'p1.bonds',
}) => AttemptRecord(
  questionId: 'q',
  topicId: topic,
  correct: correct,
  timeMs: 4000,
  answeredAt: at,
);

void main() {
  test('dayBounds runs from local midnight to the next one (AC-1)', () {
    final b = dayBounds('2026-11-20');
    expect(b.start, DateTime(2026, 11, 20));
    expect(b.end, DateTime(2026, 11, 21));
    // Built from calendar fields, never start + 24 h.
    final m = dayBounds('2026-03-31');
    expect(m.end, DateTime(2026, 4, 1));
    expect(dayBounds('2026-12-31').end, DateTime(2027, 1, 1));
  });

  test('shiftDay steps calendar days across months and years', () {
    expect(shiftDay('2026-11-01', -1), '2026-10-31');
    expect(shiftDay('2026-12-31', 1), '2027-01-01');
    expect(shiftDay('2024-02-28', 1), '2024-02-29');
  });

  test('recentDays: latest days with answers, newest first, capped', () {
    final rs = [
      for (var d = 1; d <= 9; d++) rec(DateTime(2026, 11, d, 10)),
      rec(DateTime(2026, 11, 9, 23, 59), correct: false),
    ];
    final days = recentDays(rs);
    expect(days.map((d) => d.day), [
      '2026-11-09',
      '2026-11-08',
      '2026-11-07',
      '2026-11-06',
      '2026-11-05',
      '2026-11-04',
      '2026-11-03',
    ]);
    expect(
      days.first.tally,
      const Tally(attempts: 2, correct: 1, totalMs: 8000),
    );
    expect(recentDays(rs, limit: 2), hasLength(2));
    expect(recentDays(const []), isEmpty);
  });

  test('DayDetail adds up its rounds\' answers', () {
    DayAnswer a(bool c, String t) => DayAnswer(
      record: rec(DateTime(2026, 11, 20, 9), correct: c, topic: t),
      given: 'x',
    );
    DayRound r(int id, List<DayAnswer> answers) => DayRound(
      id: id,
      topicId: 'p1.bonds',
      level: 1,
      revision: false,
      startedAt: DateTime(2026, 11, 20, 9),
      finishedAt: null,
      score: 0,
      stars: 0,
      durationMs: 0,
      answers: answers,
    );
    final d = DayDetail(
      day: '2026-11-20',
      rounds: [
        r(1, [a(true, 'p1.bonds'), a(false, 'p1.bonds')]),
        r(2, [a(true, 'p2.times')]),
      ],
      secondsUsed: 600,
    );
    expect(d.records, hasLength(3));
    expect(d.tally.correct, 2);
    expect(d.topics['p1.bonds']!.attempts, 2);
    expect(d.topics['p2.times']!.accuracy, 1);
  });
}
