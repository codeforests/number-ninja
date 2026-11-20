import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/screen_time.dart';
import 'database.dart';

/// Screen-time usage per day and the daily limit (TIM-01..05), kept in
/// `daily_usage` and `children` (design §4); per child since FEAT-25
/// (FAM-04): usage, limit, extra time and sound are [childId]'s. Since schema v7 a device
/// writes only its own `(day, device_id)` row; a day's totals sum every
/// device's row, so the limit holds across tablets (FEAT-14, ADR-04).
class UsageRepository implements UsageStore {
  UsageRepository(this._db, {this.clock = systemClock, this.childId = 1});

  final AppDatabase _db;

  final int childId;
  final Clock clock;

  /// The latest day any child used on this device: the clock is shared, so
  /// the clock-back rule (TIM-05) looks at every child (FEAT-25 AD-5).
  @override
  Future<String?> latestDay() async {
    final max = _db.dailyUsage.day.max();
    final row = await (_db.selectOnly(
      _db.dailyUsage,
    )..addColumns([max])).getSingle();
    return row.read(max);
  }

  /// Adds to this device's row of [day], marking it unsent.
  Future<void> _add(String day, String column, int amount) =>
      _db.transaction(() async {
        final device = await _db.deviceId();
        await _db
            .into(_db.dailyUsage)
            .insert(
              DailyUsageCompanion.insert(
                childId: childId,
                day: day,
                deviceId: device,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        await _db.customUpdate(
          'UPDATE daily_usage SET $column = $column + ?, dirty = dirty + 1 '
          'WHERE child_id = ? AND day = ? AND device_id = ?',
          variables: [
            Variable.withInt(amount),
            Variable.withInt(childId),
            Variable.withString(day),
            Variable.withString(device),
          ],
          updates: {_db.dailyUsage},
        );
      });

  @override
  Future<void> addSeconds(String day, int seconds) async {
    if (seconds <= 0) return;
    await _add(day, 'seconds_used', seconds);
  }

  @override
  Future<ScreenTimeStatus> status(String day) async {
    final used = _db.dailyUsage.secondsUsed.sum();
    final extra = _db.dailyUsage.extraSecondsGranted.sum();
    final row =
        await (_db.selectOnly(_db.dailyUsage)
              ..addColumns([used, extra])
              ..where(
                _db.dailyUsage.day.equals(day) &
                    _db.dailyUsage.childId.equals(childId),
              ))
            .getSingle();
    final child = await _child();
    return ScreenTimeStatus(
      day: day,
      usedSeconds: row.read(used) ?? 0,
      limitMinutes: child?.dailyLimitMin ?? 20,
      extraSeconds: row.read(extra) ?? 0,
    );
  }

  /// Adds [minutes] of extra time to [day] (TIM-04).
  Future<void> grantExtra(String day, int minutes) async {
    if (minutes <= 0) return;
    await _add(day, 'extra_seconds_granted', minutes * 60);
  }

  /// Saves the daily limit, clamped to 5–120 minutes (D5, TIM-04), and
  /// returns the saved value.
  Future<int> setDailyLimit(int minutes) async {
    final m = minutes.clamp(minDailyLimit, maxDailyLimit);
    await _db.transaction(() async {
      await (_db.update(_db.children)..where((c) => c.id.equals(childId)))
          .write(ChildrenCompanion(dailyLimitMin: Value(m)));
      await _db.stampFields(childId, [syncFieldDailyLimit], clock());
    });
    return m;
  }

  /// Whether sound effects play (PRC-11); on unless a parent turned it off.
  Future<bool> soundOn() async => (await _child())?.soundOn ?? true;

  /// Her row; null just after she was removed, while the app moves on to
  /// another child (defaults then).
  Future<ChildRow?> _child() => (_db.select(
    _db.children,
  )..where((c) => c.id.equals(childId))).getSingleOrNull();

  /// Turns sound effects on or off (PRC-11).
  Future<void> setSoundOn(bool on) => _db.transaction(() async {
    await (_db.update(_db.children)..where((c) => c.id.equals(childId))).write(
      ChildrenCompanion(soundOn: Value(on)),
    );
    await _db.stampFields(childId, [syncFieldSound], clock());
  });
}
