import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/data/stats_repository.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/question.dart';

void main() {
  late AppDatabase db;
  late ProfileRepository repo;
  late DateTime now;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 18, 9);
    repo = ProfileRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  const mia = ChildProfile(nickname: 'Mia', schoolYear: 2);

  test('a new install is pending with no profile (PRO-02)', () async {
    expect(await repo.pending(), isTrue);
    expect(await repo.load(), isNull);
  });

  test('save stores the profile, stamps it and clears pending', () async {
    await repo.save(
      const ChildProfile(
        nickname: '  Mia ',
        schoolYear: 2,
        schoolStartLevel: 3,
        olympiadStartLevel: 1,
      ),
    );
    expect(
      await repo.load(),
      const ChildProfile(
        nickname: 'Mia',
        schoolYear: 2,
        schoolStartLevel: 3,
        olympiadStartLevel: 1,
      ),
    );
    expect(await repo.pending(), isFalse);
    final row = await db.select(db.childProfiles).getSingle();
    expect(row.updatedAt, now);
  });

  test('a second save overwrites, including clearing overrides', () async {
    await repo.save(
      const ChildProfile(nickname: 'Mia', schoolYear: 1, schoolStartLevel: 2),
    );
    now = now.add(const Duration(days: 1));
    await repo.save(const ChildProfile(nickname: 'Bee', schoolYear: 3));
    expect(
      await repo.load(),
      const ChildProfile(nickname: 'Bee', schoolYear: 3),
    );
    expect(await db.select(db.childProfiles).get(), hasLength(1));
    expect((await db.select(db.childProfiles).getSingle()).updatedAt, now);
  });

  test('watch emits saves', () async {
    final seen = <ChildProfile?>[];
    final sub = repo.watch().listen(seen.add);
    await pumpEventQueue();
    await repo.save(mia);
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [null, mia]);
  });

  test('reset progress keeps the profile (PAR-10)', () async {
    await repo.save(mia);
    await StatsRepository(
      db,
      QuestionBank(version: 1, questions: const []),
      clock: () => now,
    ).resetProgress();
    expect(await repo.load(), mia);
    expect(await repo.pending(), isFalse);
  });
}
