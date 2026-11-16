import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/screen_time.dart';
import 'database.dart';

/// Screen-time usage per day and the daily limit (TIM-01..05), kept in
/// `daily_usage` and `app_settings` (design §4). Since schema v7 a device
/// writes only its own `(day, device_id)` row; a day's totals sum every
/// device's row, so the limit holds across tablets (FEAT-14, ADR-04).
class UsageRepository implements UsageStore {
  UsageRepository(this._db, {this.clock = systemClock});

  final AppDatabase _db;
  final Clock clock;

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
              DailyUsageCompanion.insert(day: day, deviceId: device),
              mode: InsertMode.insertOrIgnore,
            );
        await _db.customUpdate(
          'UPDATE daily_usage SET $column = $column + ?, dirty = dirty + 1 '
          'WHERE day = ? AND device_id = ?',
          variables: [
            Variable.withInt(amount),
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
              ..where(_db.dailyUsage.day.equals(day)))
            .getSingle();
    final settings = await _db.getSettings();
    return ScreenTimeStatus(
      day: day,
      usedSeconds: row.read(used) ?? 0,
      limitMinutes: settings.dailyLimitMin,
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
      await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
        AppSettingsCompanion(dailyLimitMin: Value(m)),
      );
      await _db.stampFields([syncFieldDailyLimit], clock());
    });
    return m;
  }

  /// Whether sound effects play (PRC-11); on unless a parent turned it off.
  Future<bool> soundOn() async => (await _db.getSettings()).soundOn;

  /// Turns sound effects on or off (PRC-11).
  Future<void> setSoundOn(bool on) => _db.transaction(() async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
      AppSettingsCompanion(soundOn: Value(on)),
    );
    await _db.stampFields([syncFieldSound], clock());
  });
}
