import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/domain/quiz.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late RoundRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 15, 9);
    repo = RoundRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  AnswerResult r(String id, bool correct) =>
      AnswerResult(questionId: id, given: 'x', correct: correct, timeMs: 1500);

  test('start, save and finish a round', () async {
    final id = await repo.startRound('p2.times', 1);
    now = now.add(const Duration(seconds: 3));
    await repo.saveAttempt(id, r('q1', true));

    final round = await db.select(db.rounds).getSingle();
    expect(round.topicId, 'p2.times');
    expect(round.level, 1);
    expect(round.score, 0);
    final attempt = await db.select(db.attempts).getSingle();
    expect(attempt.roundId, id);
    expect(attempt.questionId, 'q1');
    expect(attempt.answerGiven, 'x');
    expect(attempt.correct, isTrue);
    expect(attempt.timeMs, 1500);
    expect(attempt.answeredAt, now);

    await repo.finishRound(id, score: 7, durationMs: 42000, stars: 1);
    final done = await db.select(db.rounds).getSingle();
    expect(done.score, 7);
    expect(done.durationMs, 42000);
    expect(done.stars, 1);
  });

  test('one play session per repository (app opening)', () async {
    await repo.startRound('a', 1);
    await repo.startRound('b', 1);
    expect(await db.select(db.playSessions).get(), hasLength(1));
    final rounds = await db.select(db.rounds).get();
    expect(rounds.map((e) => e.sessionId).toSet(), hasLength(1));
  });

  test('recentCorrectIds covers exactly the last 3 rounds (AC-1)', () async {
    Future<void> round(String topic, List<AnswerResult> rs) async {
      now = now.add(const Duration(minutes: 1));
      final id = await repo.startRound(topic, 1);
      for (final a in rs) {
        await repo.saveAttempt(id, a);
      }
    }

    await round('t', [r('old', true)]); // 4th most recent: excluded
    await round('t', [r('a', true), r('wrong', false)]);
    await round('other', [r('elsewhere', true)]);
    await round('t', [r('b', true)]);
    await round('t', [r('c', true), r('a', true)]);

    expect(await repo.recentCorrectIds('t'), {'a', 'b', 'c'});
    expect(await repo.recentCorrectIds('other'), {'elsewhere'});
    expect(await repo.recentCorrectIds('none'), isEmpty);
  });
}
