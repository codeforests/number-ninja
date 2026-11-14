import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'fresh database has one settings row with defaults and no PIN',
    () async {
      final rows = await db.select(db.appSettings).get();
      expect(rows, hasLength(1));
      expect(rows.single.dailyLimitMin, 20);
      expect(rows.single.bankVersion, 1);
      expect(rows.single.pinHash, isNull);
      expect(rows.single.pinSalt, isNull);
    },
  );

  test('fresh database has a zeroed PIN lockout row', () async {
    final rows = await db.select(db.pinLockout).get();
    expect(rows, hasLength(1));
    expect(rows.single.failedCount, 0);
    expect(rows.single.lockedUntil, isNull);
  });

  test('all progress tables start empty', () async {
    expect(await db.select(db.playSessions).get(), isEmpty);
    expect(await db.select(db.rounds).get(), isEmpty);
    expect(await db.select(db.attempts).get(), isEmpty);
    expect(await db.select(db.dailyUsage).get(), isEmpty);
    expect(await db.select(db.badgesEarned).get(), isEmpty);
  });
}
