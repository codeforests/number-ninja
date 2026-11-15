import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/screen_time.dart';

void main() {
  group('in memory', () {
    late AppDatabase db;
    late UsageRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = UsageRepository(db);
    });
    tearDown(() => db.close());

    test('a day with no row has zero use and the default limit', () async {
      final s = await repo.status('2027-01-05');
      expect(s.usedSeconds, 0);
      expect(s.extraSeconds, 0);
      expect(s.limitMinutes, 20);
      expect(await repo.latestDay(), isNull);
    });

    test('addSeconds upserts and accumulates per day', () async {
      await repo.addSeconds('2027-01-05', 10);
      await repo.addSeconds('2027-01-05', 15);
      await repo.addSeconds('2027-01-06', 7);
      await repo.addSeconds('2027-01-06', 0);
      expect((await repo.status('2027-01-05')).usedSeconds, 25);
      expect((await repo.status('2027-01-06')).usedSeconds, 7);
      expect(await repo.latestDay(), '2027-01-06');
    });

    test('grantExtra adds minutes as seconds to that day only', () async {
      await repo.grantExtra('2027-01-05', 10);
      await repo.addSeconds('2027-01-05', 30);
      await repo.grantExtra('2027-01-05', 5);
      final s = await repo.status('2027-01-05');
      expect(s.extraSeconds, 15 * 60);
      expect(s.usedSeconds, 30);
      expect((await repo.status('2027-01-06')).extraSeconds, 0);
    });

    test('setDailyLimit clamps to 5–120 and is read by status (D5)', () async {
      expect(await repo.setDailyLimit(45), 45);
      expect((await repo.status('2027-01-05')).limitMinutes, 45);
      expect(await repo.setDailyLimit(2), 5);
      expect((await db.getSettings()).dailyLimitMin, 5);
      expect(await repo.setDailyLimit(500), 120);
      expect((await db.getSettings()).dailyLimitMin, 120);
    });

    test('works as the ScreenTimeClock store', () async {
      var elapsed = Duration.zero;
      final clock = ScreenTimeClock(
        repo,
        now: () => DateTime(2027, 1, 5, 9),
        elapsed: () => elapsed,
      )..start();
      elapsed = const Duration(seconds: 12);
      final s = await clock.flush();
      expect(s.day, '2027-01-05');
      expect(s.usedSeconds, 12);
    });
  });

  test('used seconds survive closing and reopening the database '
      '(AC-2, TIM-05)', () async {
    final dir = await Directory.systemTemp.createTemp('usage_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/app.sqlite');

    var db = AppDatabase(NativeDatabase(file));
    await UsageRepository(db).addSeconds('2027-01-05', 600);
    await UsageRepository(db).grantExtra('2027-01-05', 5);
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final s = await UsageRepository(db).status('2027-01-05');
    expect(s.usedSeconds, 600);
    expect(s.extraSeconds, 300);
    expect(await UsageRepository(db).latestDay(), '2027-01-05');
  });
}
