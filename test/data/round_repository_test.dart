import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/domain/progress.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/domain/topic_lock.dart';
import 'package:number_ninja/domain/topics.dart';

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

  group('progress (AC-2)', () {
    Future<int> play(
      String topic,
      int level,
      int stars, {
      bool finish = true,
    }) async {
      now = now.add(const Duration(minutes: 1));
      final id = await repo.startRound(topic, level);
      await repo.saveAttempt(id, r('q', true));
      if (finish) {
        await repo.finishRound(id, score: 0, durationMs: 1000, stars: stars);
      }
      return id;
    }

    test('finishRound stamps finished_at with the clock', () async {
      final id = await play('t', 1, 2);
      final row = await (db.select(
        db.rounds,
      )..where((x) => x.id.equals(id))).getSingle();
      expect(row.finishedAt, now);
    });

    test('a never-played topic is level 1 and absent from progress', () async {
      expect(await repo.levelFor('t'), 1);
      expect(await repo.progress(), isEmpty);
    });

    test('a never-played topic starts at the given level (PRO-03)', () async {
      expect(await repo.levelFor('t', start: 3), 3);
      await play('t', 3, 2); // finished: PRC-09 from now on
      expect(await repo.levelFor('t', start: 1), 3);
    });

    test('a quit round changes neither level nor best stars', () async {
      await play('t', 1, 3); // -> level 2, best 3
      await play('t', 2, 0, finish: false); // quit
      expect(await repo.levelFor('t'), 2);
      expect(
        (await repo.progress())['t'],
        const TopicProgress(bestStars: 3, level: 2, rounds: 1),
      );
      expect(await repo.finishedRounds(topicId: 't'), hasLength(1));
    });

    test('level follows the latest finished round, per topic', () async {
      await play('t', 1, 3);
      await play('u', 1, 2);
      await play('t', 2, 1);
      expect(await repo.levelFor('t'), 1);
      expect(await repo.levelFor('u'), 1);
      final p = await repo.progress();
      expect(p['t'], const TopicProgress(bestStars: 3, level: 1, rounds: 2));
      expect(p['u'], const TopicProgress(bestStars: 2, level: 1, rounds: 1));
    });
  });

  group('revision rounds (FEAT-11 AC-2, REV-04)', () {
    test('kind defaults to normal; revision is stored', () async {
      final a = await repo.startRound('p1.place', 1);
      final b = await repo.startRound('p1.place', 2, kind: roundKindRevision);
      final rows = await db.select(db.rounds).get();
      expect(rows.firstWhere((r) => r.id == a).kind, roundKindNormal);
      expect(rows.firstWhere((r) => r.id == b).kind, roundKindRevision);
    });

    test('a 3-star revision round changes no level, stars or lock', () async {
      final id = await repo.startRound('p1.place', 1, kind: roundKindRevision);
      await repo.finishRound(id, score: 10, durationMs: 60000, stars: 3);
      expect(await repo.finishedRounds(), isEmpty);
      expect(await repo.progress(), isEmpty);
      expect(await repo.levelFor('p1.place'), 1);
      final locks = topicLocks(
        topics: topics,
        rounds: await repo.finishedRounds(),
        schoolYear: 1,
      );
      expect(locks['p1.bonds'], isA<TopicLocked>());

      final n = await repo.startRound('p1.place', 1);
      await repo.finishRound(n, score: 7, durationMs: 60000, stars: 1);
      final after = topicLocks(
        topics: topics,
        rounds: await repo.finishedRounds(),
        schoolYear: 1,
      );
      expect(after['p1.bonds'], isNot(isA<TopicLocked>()));
    });
  });
}
