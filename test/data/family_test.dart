import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/badge_repository.dart';
import 'package:number_ninja/data/child_repository.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/stats_repository.dart';
import 'package:number_ninja/data/topic_lock_repository.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/family.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/domain/screen_time.dart';

Question q(String id, String topic) => Question(
  id: id,
  topic: topic,
  level: 1,
  format: QuestionFormat.number,
  prompt: id,
  answer: '1',
  explanation: '',
);

/// FEAT-25 AC-2 and the data part of AC-3: two children on one tablet each
/// see only their own rows.
void main() {
  late AppDatabase db;
  late DateTime now;
  late ChildRepository family;
  late int mia;
  late int leo;

  final bank = QuestionBank(
    version: 1,
    questions: [
      for (var i = 0; i < 12; i++) q('b$i', 'p1.bonds'),
      for (var i = 0; i < 12; i++) q('t$i', 'p2.times'),
    ],
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 18, 9);
    family = ChildRepository(db, clock: () => now);
    mia = 1;
    await ProfileRepository(
      db,
      clock: () => now,
    ).save(const ChildProfile(nickname: 'Mia', schoolYear: 2));
    leo = await family.add(
      const ChildProfile(nickname: 'Leo', schoolYear: 1),
      pickAvatar: true,
    );
  });
  tearDown(() => db.close());

  RoundRepository rounds(int child) =>
      RoundRepository(db, clock: () => now, childId: child);
  StatsRepository stats(int child) =>
      StatsRepository(db, bank, clock: () => now, childId: child);
  UsageRepository usage(int child) =>
      UsageRepository(db, clock: () => now, childId: child);

  Future<void> play(int child, String topic, {int score = 10}) async {
    final r = rounds(child);
    final id = await r.startRound(topic, 1);
    for (var i = 0; i < 10; i++) {
      await r.saveAttempt(
        id,
        AnswerResult(
          questionId: '${topic == 'p1.bonds' ? 'b' : 't'}$i',
          given: '1',
          correct: i < score,
          timeMs: 1000,
        ),
      );
    }
    await r.finishRound(id, score: score, durationMs: 10000, stars: 3);
  }

  test('the family lists both children; Leo gets the next avatar', () async {
    expect(await family.all(), [
      const FamilyChild(id: 1, nickname: 'Mia', schoolYear: 2, avatar: 'fox'),
      FamilyChild(id: leo, nickname: 'Leo', schoolYear: 1, avatar: 'owl'),
    ]);
    final miaProfile = await ProfileRepository(db, clock: () => now).load();
    final leoProfile = await ProfileRepository(
      db,
      clock: () => now,
      childId: leo,
    ).load();
    expect(miaProfile?.nickname, 'Mia');
    expect(leoProfile?.nickname, 'Leo');
    // Leo has his own sync field rows (FEAT-14 per child).
    final fields = await (db.select(
      db.syncFields,
    )..where((f) => f.childId.equals(leo))).get();
    expect(fields, hasLength(syncFieldNames.length));
  });

  test(
    'rounds, levels, stars, stats, day and mix-in are per child (AC-2)',
    () async {
      await play(mia, 'p1.bonds');
      await play(mia, 'p1.bonds');
      await play(leo, 'p2.times', score: 2);

      expect((await rounds(mia).progress()).keys, ['p1.bonds']);
      expect((await rounds(leo).progress()).keys, ['p2.times']);
      expect(await rounds(mia).levelFor('p1.bonds'), greaterThan(1));
      expect(await rounds(leo).levelFor('p1.bonds'), 1);
      expect(await rounds(leo).recentCorrectIds('p1.bonds'), isEmpty);
      expect(await rounds(mia).recentCorrectIds('p1.bonds'), hasLength(10));

      expect(await stats(mia).records(), hasLength(20));
      expect(await stats(leo).records(), hasLength(10));
      final day = await stats(leo).day('2026-11-18');
      expect(day.rounds.map((r) => r.topicId), ['p2.times']);
      expect(await stats(mia).firstDay(), '2026-11-18');
      // Leo needs practice in p2.times; Mia's p1.bonds round doesn't mix it in.
      expect(await stats(mia).mixInTopic('p1.bonds'), isNull);
      expect(await stats(leo).mixInTopic('p1.bonds'), 'p2.times');
    },
  );

  test('badges and topic locks are per child (AC-2)', () async {
    await play(mia, 'p1.bonds');
    final miaBadges = BadgeRepository(
      db,
      stats(mia),
      clock: () => now,
      childId: mia,
    );
    final leoBadges = BadgeRepository(
      db,
      stats(leo),
      clock: () => now,
      childId: leo,
    );
    expect(await miaBadges.awardNew(), isNotEmpty);
    expect(await leoBadges.awardNew(), isEmpty);
    expect(await leoBadges.earned(), isEmpty);

    final miaLocks = TopicLockRepository(db, clock: () => now);
    final leoLocks = TopicLockRepository(db, clock: () => now, childId: leo);
    await leoLocks.open('p2.times');
    expect(await leoLocks.opened(), {'p2.times'});
    expect(await miaLocks.opened(), isEmpty);
    await miaLocks.open('p2.times');
    await leoLocks.close('p2.times');
    expect(await miaLocks.opened(), {'p2.times'});
  });

  test('reset clears only the current child (AC-2, AD-11)', () async {
    await play(mia, 'p1.bonds');
    await play(leo, 'p2.times');
    await BadgeRepository(
      db,
      stats(leo),
      clock: () => now,
      childId: leo,
    ).awardNew();
    await stats(leo).resetProgress();
    expect(await rounds(leo).progress(), isEmpty);
    expect(await stats(leo).records(), isEmpty);
    expect(await rounds(mia).progress(), hasLength(1));
    expect(await stats(mia).records(), hasLength(10));
    final playSessions = await db.select(db.playSessions).get();
    expect(playSessions, isNotEmpty); // Mia's round still uses one
  });

  test(
    'screen time, limit, extra time and sound are per child (AC-3 data)',
    () async {
      const today = '2026-11-18';
      await usage(mia).addSeconds(today, 20 * 60);
      await usage(mia).grantExtra(today, 5);
      expect(await usage(mia).setDailyLimit(30), 30);
      await usage(mia).setSoundOn(false);

      final miaStatus = await usage(mia).status(today);
      final leoStatus = await usage(leo).status(today);
      expect(
        [miaStatus.usedSeconds, miaStatus.extraSeconds, miaStatus.limitMinutes],
        [1200, 300, 30],
      );
      expect(
        [leoStatus.usedSeconds, leoStatus.extraSeconds, leoStatus.limitMinutes],
        [0, 0, 20],
      );
      expect(await usage(mia).soundOn(), isFalse);
      expect(await usage(leo).soundOn(), isTrue);
      // The clock-back rule uses the latest day of any child (AD-5).
      await usage(mia).addSeconds('2026-11-19', 1);
      expect(await usage(leo).latestDay(), '2026-11-19');
    },
  );

  test('add stops at 4 children; remove keeps the last and deletes only her '
      'rows (FAM-01, AD-1, AD-10)', () async {
    await play(leo, 'p2.times');
    await play(mia, 'p1.bonds');
    await usage(leo).addSeconds('2026-11-18', 60);
    await family.add(const ChildProfile(nickname: 'Ana', schoolYear: 1));
    await family.add(const ChildProfile(nickname: 'Ben', schoolYear: 1));
    await expectLater(
      family.add(const ChildProfile(nickname: 'Cy', schoolYear: 1)),
      throwsStateError,
    );

    await family.setCurrent(leo);
    await family.remove(leo);
    expect((await family.all()).map((c) => c.nickname), ['Mia', 'Ana', 'Ben']);
    expect(await family.current(), mia);
    expect(await stats(leo).records(), isEmpty);
    expect(await usage(leo).status('2026-11-18'), isA<ScreenTimeStatus>());
    final leoUsage = await (db.select(
      db.dailyUsage,
    )..where((u) => u.childId.equals(leo))).get();
    expect(leoUsage, isEmpty);
    expect(await stats(mia).records(), hasLength(10));

    for (final c in (await family.all()).skip(1)) {
      await family.remove(c.id);
    }
    await expectLater(family.remove(mia), throwsStateError);
  });

  test(
    'a linked child removed offline waits as pending delete (AD-10)',
    () async {
      await (db.update(db.children)..where((c) => c.id.equals(leo))).write(
        const ChildrenCompanion(remoteId: Value('r-leo')),
      );
      await family.remove(leo);
      expect((await family.all()).map((c) => c.id), [mia]);
      final row = await db.child(leo);
      expect(row.pendingDelete, isTrue);
    },
  );

  test('current falls back to the first child when hers is gone', () async {
    await family.setCurrent(leo);
    expect(await family.current(), leo);
    await (db.delete(db.children)..where((c) => c.id.equals(leo))).go();
    expect(await family.current(), mia);
    expect((await db.getSettings()).currentChildId, mia);
  });
}
