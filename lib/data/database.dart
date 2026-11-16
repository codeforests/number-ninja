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
  BoolColumn get soundOn => boolean().withDefault(const Constant(true))();

  /// Ask for the child profile before play (PRO-02). True on a new install,
  /// false on one updated from v3; saving the profile clears it.
  BoolColumn get profilePending =>
      boolean().withDefault(const Constant(true))();

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

/// The child profile (single row, id is always 1), PRO-01. Absent until the
/// parent first saves it.
@DataClassName('ProfileRow')
class ChildProfiles extends Table {
  @override
  String get tableName => 'child_profile';

  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get nickname => text()();
  IntColumn get schoolYear => integer()();
  IntColumn get schoolStartLevel => integer().nullable()();
  IntColumn get olympiadStartLevel => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Wrong-PIN counter (single row, id is always 1), PAR-03.
class PinLockout extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Topics the parent opened by hand (PRC-14, FEAT-17); kept by the reset.
class TopicUnlocks extends Table {
  TextColumn get topicId => text()();
  DateTimeColumn get openedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {topicId};
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
    ChildProfiles,
    TopicUnlocks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'number_ninja'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(appSettings).insert(AppSettingsCompanion.insert());
      await into(pinLockout).insert(PinLockoutCompanion.insert());
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await _from1To2(m);
      if (from < 3) await m.addColumn(appSettings, appSettings.soundOn);
      if (from < 4) {
        await m.addColumn(appSettings, appSettings.profilePending);
        await m.createTable(childProfiles);
        // An updated install keeps working without a profile (PRO-02).
        await customStatement('UPDATE app_settings SET profile_pending = 0');
      }
      if (from < 5) await m.createTable(topicUnlocks);
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
