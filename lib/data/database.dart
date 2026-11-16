import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/ids.dart';

part 'database.g.dart';

final _random = Random.secure();
String _newId() => newId(_random);

/// SQL for a new id in migrations, the same shape as [newId].
const _sqlNewId = 'lower(hex(randomblob(16)))';

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

  /// This install's id (schema v7, FEAT-14): keys its own `daily_usage` rows.
  TextColumn get deviceId => text().clientDefault(_newId)();

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
@TableIndex(name: 'rounds_uuid', columns: {#uuid}, unique: true)
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

  /// `normal` or `revision` (schema v6, REV-04). A revision round never
  /// counts for levels, best stars or the topic lock.
  TextColumn get kind => text().withDefault(const Constant('normal'))();

  /// Sync id (schema v7, FEAT-14); [dirty] > 0 means not yet on the server,
  /// [remoteId] is the server record once known.
  TextColumn get uuid => text().clientDefault(_newId)();
  IntColumn get dirty => integer().withDefault(const Constant(1))();
  TextColumn get remoteId => text().nullable()();
}

/// Every answer she gives: the raw record behind every chart.
@TableIndex(name: 'attempts_uuid', columns: {#uuid}, unique: true)
class Attempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roundId => integer().references(Rounds, #id)();
  TextColumn get questionId => text()();
  TextColumn get answerGiven => text()();
  BoolColumn get correct => boolean()();
  IntColumn get timeMs => integer()();
  DateTimeColumn get answeredAt => dateTime()();

  /// Sync id and unsent flag (schema v7, FEAT-14). Attempts never change.
  TextColumn get uuid => text().clientDefault(_newId)();
  IntColumn get dirty => integer().withDefault(const Constant(1))();
}

/// Screen-time usage per calendar day (yyyy-MM-dd, local time) and device
/// (schema v7): a device writes only its own rows, others come from sync.
class DailyUsage extends Table {
  TextColumn get day => text()();
  TextColumn get deviceId => text()();
  IntColumn get secondsUsed => integer().withDefault(const Constant(0))();
  IntColumn get extraSecondsGranted =>
      integer().withDefault(const Constant(0))();
  IntColumn get dirty => integer().withDefault(const Constant(1))();
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {day, deviceId};
}

class BadgesEarned extends Table {
  TextColumn get badgeId => text()();
  DateTimeColumn get earnedAt => dateTime()();
  IntColumn get dirty => integer().withDefault(const Constant(1))();
  TextColumn get remoteId => text().nullable()();

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

/// When each synced profile or settings field last changed here (FEAT-14,
/// last change wins per field). Fields: [syncFieldNames].
class SyncFields extends Table {
  TextColumn get field => text()();
  DateTimeColumn get changedAt => dateTime()();
  IntColumn get dirty => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {field};
}

/// Sync bookkeeping (single row, id is always 1), FEAT-14.
class SyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get accountId => text().nullable()();
  TextColumn get childId => text().nullable()();
  IntColumn get resetEpoch => integer().withDefault(const Constant(0))();
  BoolColumn get pendingReset => boolean().withDefault(const Constant(false))();

  /// JSON map: collection name -> last `updated` seen.
  TextColumn get cursors => text().withDefault(const Constant('{}'))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

const syncFieldNickname = 'nickname';
const syncFieldSchoolYear = 'school_year';
const syncFieldStartSchool = 'start_level_school';
const syncFieldStartOlympiad = 'start_level_olympiad';
const syncFieldDailyLimit = 'daily_limit_min';
const syncFieldSound = 'sound_on';
const syncFieldTopics = 'unlocked_topics';
const profileSyncFields = [
  syncFieldNickname,
  syncFieldSchoolYear,
  syncFieldStartSchool,
  syncFieldStartOlympiad,
];
const syncFieldNames = [
  ...profileSyncFields,
  syncFieldDailyLimit,
  syncFieldSound,
  syncFieldTopics,
];

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
    SyncFields,
    SyncState,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'number_ninja'));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(appSettings).insert(AppSettingsCompanion.insert());
      await into(pinLockout).insert(PinLockoutCompanion.insert());
      await _seedSync(profileTime: null);
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
      if (from < 6) await m.addColumn(rounds, rounds.kind);
      if (from < 7) await _from6To7(m);
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

  /// Schema v7 (FEAT-14): ids, dirty flags, per-device usage, sync tables.
  /// Every existing row is dirty (unsent).
  Future<void> _from6To7(Migrator m) async {
    final newId = const CustomExpression<String>(_sqlNewId);
    await m.alterTable(
      TableMigration(
        appSettings,
        newColumns: [appSettings.deviceId],
        columnTransformer: {appSettings.deviceId: newId},
      ),
    );
    await m.alterTable(
      TableMigration(
        rounds,
        newColumns: [rounds.uuid, rounds.dirty, rounds.remoteId],
        columnTransformer: {rounds.uuid: newId},
      ),
    );
    await m.alterTable(
      TableMigration(
        attempts,
        newColumns: [attempts.uuid, attempts.dirty],
        columnTransformer: {attempts.uuid: newId},
      ),
    );
    await m.createIndex(roundsUuid);
    await m.createIndex(attemptsUuid);
    await m.alterTable(
      TableMigration(
        dailyUsage,
        newColumns: [
          dailyUsage.deviceId,
          dailyUsage.dirty,
          dailyUsage.remoteId,
        ],
        columnTransformer: {
          dailyUsage.deviceId: const CustomExpression<String>(
            '(SELECT device_id FROM app_settings WHERE id = 1)',
          ),
        },
      ),
    );
    await m.addColumn(badgesEarned, badgesEarned.dirty);
    await m.addColumn(badgesEarned, badgesEarned.remoteId);
    await m.createTable(syncFields);
    await m.createTable(syncState);
    final profile = await (select(
      childProfiles,
    )..where((p) => p.id.equals(1))).getSingleOrNull();
    await _seedSync(profileTime: profile?.updatedAt);
  }

  /// The `sync_state` row and one `sync_fields` row per field: profile
  /// fields at [profileTime] (if any), the rest at time 0, so on a second
  /// tablet the account's values beat untouched defaults.
  Future<void> _seedSync({required DateTime? profileTime}) async {
    await into(syncState).insert(SyncStateCompanion.insert());
    final zero = DateTime.fromMillisecondsSinceEpoch(0);
    for (final f in syncFieldNames) {
      final at = profileSyncFields.contains(f) ? profileTime ?? zero : zero;
      await into(syncFields)
          .insert(SyncFieldsCompanion.insert(field: f, changedAt: at));
    }
  }

  /// Records that [fields] changed here at [at] (FEAT-14, last change wins).
  Future<void> stampFields(Iterable<String> fields, DateTime at) async {
    for (final f in fields) {
      await customStatement(
        'INSERT INTO sync_fields (field, changed_at, dirty) VALUES (?, ?, 1) '
        'ON CONFLICT(field) DO UPDATE SET changed_at = excluded.changed_at, '
        'dirty = dirty + 1',
        [f, at.millisecondsSinceEpoch ~/ 1000],
      );
    }
    notifyUpdates({const TableUpdate('sync_fields')});
  }

  /// This install's device id (FEAT-14).
  Future<String> deviceId() async => (await getSettings()).deviceId;

  Future<AppSetting> getSettings() =>
      (select(appSettings)..where((s) => s.id.equals(1))).getSingle();

  Stream<AppSetting> watchSettings() =>
      (select(appSettings)..where((s) => s.id.equals(1))).watchSingle();
}
