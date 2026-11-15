import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/stats_repository.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/domain/stats.dart';

Question q(String id, String topic) => Question(
  id: id,
  topic: topic,
  level: 1,
  format: QuestionFormat.number,
  prompt: id,
  answer: '1',
  explanation: '',
);

void main() {
  late AppDatabase db;
  late DateTime now;
  late RoundRepository rounds;
  late StatsRepository stats;

  final bank = QuestionBank(
    version: 1,
    questions: [
      for (var i = 0; i < 12; i++) q('b$i', 'p1.bonds'),
      for (var i = 0; i < 12; i++) q('t$i', 'p2.times'),
      for (var i = 0; i < 12; i++) q('m$i', 'p1.money'),
      for (var i = 0; i < 12; i++) q('o$i', 'oly.logic'),
    ],
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 18, 9);
    rounds = RoundRepository(db, clock: () => now);
    stats = StatsRepository(db, bank, clock: () => now);
  });
  tearDown(() => db.close());

  Future<void> answer(String topic, String qid, bool correct) async {
    final id = await rounds.startRound(topic, 1);
    await rounds.saveAttempt(
      id,
      AnswerResult(questionId: qid, given: 'x', correct: correct, timeMs: 2000),
    );
  }

  test('records join the bank, filter by date and topic', () async {
    now = DateTime(2026, 11, 1, 9); // 17 days ago
    await answer('p1.bonds', 'b1', true);
    now = DateTime(2026, 11, 18, 9);
    await answer('p1.bonds', 't1', false); // mixed in: counts for p2.times
    await answer('p1.bonds', 'gone', true); // not in the bank

    final all = await stats.records();
    expect(all.map((r) => (r.questionId, r.topicId)), [
      ('b1', 'p1.bonds'),
      ('t1', 'p2.times'),
    ]);
    expect(all.last.timeMs, 2000);
    expect(all.last.correct, isFalse);
    expect(all.last.answeredAt, now);

    expect(await stats.recordsIn(StatsPeriod.days7), hasLength(1));
    expect(await stats.recordsIn(StatsPeriod.days30), hasLength(2));
    expect(
      await stats.records(since: DateTime(2026, 11, 1, 9)),
      hasLength(2),
      reason: 'since is inclusive',
    );
    final times = await stats.records(topicId: 'p2.times');
    expect(times.single.questionId, 't1');
  });

  test('mix-in topic: 30-day needs practice, School only, not own', () async {
    expect(await stats.mixInTopic('p1.money'), isNull);
    for (var i = 0; i < 10; i++) {
      await answer('oly.logic', 'o$i', false);
      await answer('p1.bonds', 'b$i', i < 3);
      await answer('p2.times', 't$i', true);
    }
    expect(await stats.mixInTopic('p1.money'), 'p1.bonds');
    expect(await stats.mixInTopic('p2.times'), 'p1.bonds');
    expect(await stats.mixInTopic('p1.bonds'), isNull);
    expect(await stats.mixInTopic('oly.patterns'), isNull);
    now = now.add(const Duration(days: 31));
    expect(await stats.mixInTopic('p1.money'), isNull);
  });

  test('reset deletes progress and keeps PIN, limit and usage '
      '(AC-7 data)', () async {
    final pins = PinRepository(db, clock: () => now);
    final usage = UsageRepository(db);
    await pins.setPin('1234');
    await usage.setDailyLimit(30);
    await usage.addSeconds('2026-11-18', 300);
    final id = await rounds.startRound('p1.bonds', 1);
    await rounds.saveAttempt(
      id,
      const AnswerResult(
        questionId: 'b1',
        given: '1',
        correct: true,
        timeMs: 1,
      ),
    );
    await rounds.finishRound(id, score: 10, durationMs: 1, stars: 3);
    await db
        .into(db.badgesEarned)
        .insert(BadgesEarnedCompanion.insert(badgeId: 'x', earnedAt: now));
    await usage.setSoundOn(false); // FEAT-09 AC-2: reset keeps the switch

    await stats.resetProgress();

    expect(await db.select(db.attempts).get(), isEmpty);
    expect(await db.select(db.rounds).get(), isEmpty);
    expect(await db.select(db.playSessions).get(), isEmpty);
    expect(await db.select(db.badgesEarned).get(), isEmpty);
    expect(await pins.verify('1234'), isA<PinOk>());
    final s = await usage.status('2026-11-18');
    expect(s.limitMinutes, 30);
    expect(s.usedSeconds, 300);
    expect(await usage.soundOn(), isFalse);
    expect(await RoundRepository(db, clock: () => now).progress(), isEmpty);
    // A fresh RoundRepository (provider invalidated) can start a round.
    final again = RoundRepository(db, clock: () => now);
    expect(await again.startRound('p1.bonds', 1), greaterThan(0));
  });
}
