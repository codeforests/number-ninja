import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/stats_repository.dart';
import 'package:number_ninja/data/topic_lock_repository.dart';
import 'package:number_ninja/domain/question.dart';

void main() {
  late AppDatabase db;
  late TopicLockRepository repo;
  late DateTime now;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 16, 9);
    repo = TopicLockRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('open stores the topic with the clock, once (AC-2)', () async {
    expect(await repo.opened(), isEmpty);
    await repo.open('p1.money');
    now = now.add(const Duration(hours: 1));
    await repo.open('p1.money');
    final rows = await db.select(db.topicUnlocks).get();
    expect(rows.single.topicId, 'p1.money');
    expect(rows.single.openedAt, DateTime(2026, 11, 16, 9));
    expect(await repo.opened(), {'p1.money'});
  });

  test('close removes the opening', () async {
    await repo.open('p1.money');
    await repo.open('p1.time');
    await repo.close('p1.money');
    expect(await repo.opened(), {'p1.time'});
  });

  test('reset progress keeps openings (PAR-10)', () async {
    await repo.open('p2.place');
    await StatsRepository(
      db,
      QuestionBank(version: 1, questions: const []),
      clock: () => now,
    ).resetProgress();
    expect(await repo.opened(), {'p2.place'});
  });

  test('finishedRounds carries the score', () async {
    final rounds = RoundRepository(db, clock: () => now);
    final id = await rounds.startRound('p1.place', 2);
    await rounds.finishRound(id, score: 7, durationMs: 1000, stars: 1);
    expect((await rounds.finishedRounds()).single.score, 7);
  });
}
