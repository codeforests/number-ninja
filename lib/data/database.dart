import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Single-row app settings (id is always 1).
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get pinHash => text().nullable()();
  TextColumn get pinSalt => text().nullable()();
  IntColumn get dailyLimitMin => integer().withDefault(const Constant(20))();
  IntColumn get bankVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per app opening.
class PlaySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
}

/// A round of (usually 10) questions in one topic.
class Rounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(PlaySessions, #id)();
  TextColumn get topicId => text()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get score => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get stars => integer().withDefault(const Constant(0))();

  /// Null until the last answer is saved; a quit round stays null (schema v2).
  DateTimeColumn get finishedAt => dateTime().nullable()();
}

/// Every answer she gives: the raw record behind every chart.
class Attempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  TextColumn get questionId => text()();
  TextColumn get answerGiven => text()();
  BoolColumn get correct => boolean()();
  IntColumn get timeMs => integer()();
  DateTimeColumn get answeredAt => dateTime()();
}

/// Screen-time usage per calendar day (yyyy-MM-dd, local time).
class DailyUsage extends Table {
  TextColumn get day => text()();
  IntColumn get secondsUsed => integer().withDefault(const Constant(0))();
  IntColumn get extraSecondsGranted =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

class BadgesEarned extends Table {
  TextColumn get badgeId => text()();
  DateTimeColumn get earnedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {badgeId};
}

/// Wrong-PIN counter (single row, id is always 1), PAR-03.
class PinLockout extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    AppSettings,
    PlaySessions,
    Rounds,
    Attempts,
    DailyUsage,
    BadgesEarned,
    PinLockout,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'number_ninja'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(appSettings).insert(AppSettingsCompanion.insert());
      await into(pinLockout).insert(PinLockoutCompanion.insert());
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await _from1To2(m);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Adds `rounds.finished_at` and backfills it for rounds that got all
  /// their answers (M1 rounds were always 10 questions).
  Future<void> _from1To2(Migrator m) async {
    await m.addColumn(rounds, rounds.finishedAt);
    await customStatement('''
      UPDATE rounds SET finished_at = (
        SELECT MAX(answered_at) FROM attempts WHERE attempts.round_id = rounds.id
      )
      WHERE (SELECT COUNT(*) FROM attempts WHERE attempts.round_id = rounds.id)
        >= 10
    ''');
  }

  Future<AppSetting> getSettings() =>
      (select(appSettings)..where((s) => s.id.equals(1))).getSingle();

  Stream<AppSetting> watchSettings() =>
      (select(appSettings)..where((s) => s.id.equals(1))).watchSingle();
}
