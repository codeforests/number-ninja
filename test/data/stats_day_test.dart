import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/stats_repository.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/quiz.dart';

Question q(String id, String topic) => Question(
  id: id,
  topic: topic,
  level: 1,
  format: QuestionFormat.number,
  prompt: id,
  answer: '1',
  explanation: '',
);

/// FEAT-18 AC-2: one local day of answers, rounds and screen time.
void main() {
  late AppDatabase db;
  late DateTime now;
  late RoundRepository rounds;
  late StatsRepository stats;

  final bank = QuestionBank(
    version: 1,
    questions: [
      for (var i = 0; i < 5; i++) q('b$i', 'p1.bonds'),
      for (var i = 0; i < 5; i++) q('t$i', 'p2.times'),
    ],
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 18, 9);
    rounds = RoundRepository(db, clock: () => now);
    stats = StatsRepository(db, bank, clock: () => now);
  });
  tearDown(() => db.close());

  Future<void> answer(
    int round,
    String qid,
    bool correct, {
    String given = 'x',
  }) => rounds.saveAttempt(
    round,
    AnswerResult(questionId: qid, given: given, correct: correct, timeMs: 3000),
  );

  test('day() keeps only that local day and groups by round', () async {
    now = DateTime(2026, 11, 17, 23, 59);
    final late = await rounds.startRound('p1.bonds', 2);
    await answer(late, 'b0', true); // 17th
    now = DateTime(2026, 11, 18);
    await answer(late, 'b1', false, given: '7'); // midnight: the 18th
    now = DateTime(2026, 11, 18, 10);
    final rev = await rounds.startRound('p1.bonds', 1, kind: roundKindRevision);
    await answer(rev, 't1', true); // mixed in: its own topic
    await answer(rev, 'gone', false); // not in the bank: the round's topic
    await rounds.finishRound(rev, score: 1, durationMs: 60000, stars: 1);
    now = DateTime(2026, 11, 19);
    await answer(rev, 'b2', true); // next day

    final d = await stats.day('2026-11-18');
    expect(d.rounds.map((r) => r.id), [late, rev]);
    expect(d.rounds.first.level, 2);
    expect(d.rounds.first.revision, isFalse);
    expect(d.rounds.first.finishedAt, isNull);
    expect(d.rounds.first.answers.single.given, '7');
    expect(d.rounds.first.answers.single.record.questionId, 'b1');
    final r = d.rounds.last;
    expect(r.revision, isTrue);
    expect((r.score, r.stars, r.durationMs), (1, 1, 60000));
    expect(r.answers.map((a) => (a.record.questionId, a.record.topicId)), [
      ('t1', 'p2.times'),
      ('gone', 'p1.bonds'),
    ]);
    expect(d.tally.attempts, 3);
    expect(d.tally.correct, 1);

    expect((await stats.day('2026-11-17')).records.single.questionId, 'b0');
    expect((await stats.day('2026-11-19')).records.single.questionId, 'b2');
    expect((await stats.day('2026-11-20')).rounds, isEmpty);
  });

  test('day() sums screen time over her devices', () async {
    await db
        .into(db.dailyUsage)
        .insert(
          DailyUsageCompanion.insert(
            childId: 1,
            day: '2026-11-18',
            deviceId: 'a',
            secondsUsed: const Value(300),
          ),
        );
    await db
        .into(db.dailyUsage)
        .insert(
          DailyUsageCompanion.insert(
            childId: 1,
            day: '2026-11-18',
            deviceId: 'b',
            secondsUsed: const Value(420),
          ),
        );
    await db
        .into(db.dailyUsage)
        .insert(
          DailyUsageCompanion.insert(
            childId: 1,
            day: '2026-11-17',
            deviceId: 'a',
            secondsUsed: const Value(999),
          ),
        );
    expect((await stats.day('2026-11-18')).secondsUsed, 720);
    expect((await stats.day('2026-11-16')).secondsUsed, 0);
  });

  test('firstDay() is the earliest answer\'s day, or null', () async {
    expect(await stats.firstDay(), isNull);
    final id = await rounds.startRound('p1.bonds', 1);
    await answer(id, 'b0', true);
    now = DateTime(2026, 10, 2, 8);
    await answer(id, 'b1', true);
    expect(await stats.firstDay(), '2026-10-02');
  });
}
