import 'package:drift/drift.dart';

import '../domain/screen_time.dart';
import 'database.dart';

/// Screen-time usage per day and the daily limit (TIM-01..05), kept in
/// `daily_usage` and `app_settings` (design §4).
class UsageRepository implements UsageStore {
  UsageRepository(this._db);

  final AppDatabase _db;

  static const minLimit = 5;
  static const maxLimit = 120;

  @override
  Future<String?> latestDay() async {
    final max = _db.dailyUsage.day.max();
    final row = await (_db.selectOnly(
      _db.dailyUsage,
    )..addColumns([max])).getSingle();
    return row.read(max);
  }

  Future<void> _ensureRow(String day) => _db
      .into(_db.dailyUsage)
      .insert(
        DailyUsageCompanion.insert(day: day),
        mode: InsertMode.insertOrIgnore,
      );

  @override
  Future<void> addSeconds(String day, int seconds) async {
    if (seconds <= 0) return;
    await _db.transaction(() async {
      await _ensureRow(day);
      await _db.customUpdate(
        'UPDATE daily_usage SET seconds_used = seconds_used + ? WHERE day = ?',
        variables: [Variable.withInt(seconds), Variable.withString(day)],
        updates: {_db.dailyUsage},
      );
    });
  }

  @override
  Future<ScreenTimeStatus> status(String day) async {
    final row = await (_db.select(
      _db.dailyUsage,
    )..where((u) => u.day.equals(day))).getSingleOrNull();
    final settings = await _db.getSettings();
    return ScreenTimeStatus(
      day: day,
      usedSeconds: row?.secondsUsed ?? 0,
      limitMinutes: settings.dailyLimitMin,
      extraSeconds: row?.extraSecondsGranted ?? 0,
    );
  }

  /// Adds [minutes] of extra time to [day] (TIM-04).
  Future<void> grantExtra(String day, int minutes) async {
    if (minutes <= 0) return;
    await _db.transaction(() async {
      await _ensureRow(day);
      await _db.customUpdate(
        'UPDATE daily_usage SET extra_seconds_granted = '
        'extra_seconds_granted + ? WHERE day = ?',
        variables: [Variable.withInt(minutes * 60), Variable.withString(day)],
        updates: {_db.dailyUsage},
      );
    });
  }

  /// Saves the daily limit, clamped to 5–120 minutes (D5, TIM-04), and
  /// returns the saved value.
  Future<int> setDailyLimit(int minutes) async {
    final m = minutes.clamp(minLimit, maxLimit);
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
      AppSettingsCompanion(dailyLimitMin: Value(m)),
    );
    return m;
  }
}
