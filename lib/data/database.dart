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

  /// Last successful bank check (schema v8, FEAT-15 D7); null = never.
  DateTimeColumn get bankCheckedAt => dateTime().nullable()();

  /// Outcome of the last bank check attempt, shown on SCR-11 (BNK-12).
  TextColumn get bankCheckNote => text().nullable()();

  /// The child playing now (schema v9, FEAT-25 AD-3); a `children.id`.
  IntColumn get currentChildId => integer().withDefault(const Constant(1))();

  /// "Ask for PIN to change child" (FEAT-25 AD-4); device-only, like the PIN.
  BoolColumn get switchNeedsPin =>
      boolean().withDefault(const Constant(false))();

  /// The first-run setup step to resume at (schema v10, FEAT-26 AD-1), a
  /// `SetupStep` name; null = setup finished. Fresh databases start at
  /// `welcome` (set in onCreate).
  TextColumn get setupStep => text().nullable()();

  /// "Send crash reports" (schema v11, FEAT-24 AD-2, AD-3); device-only.
  BoolColumn get crashReports => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Captured app errors waiting to be sent (schema v11, FEAT-24 AD-8). The
/// same [signature] and [appVersion] on an unsent row bumps [count].
class CrashReports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get signature => text()();
  TextColumn get appVersion => text()();
  IntColumn get bankVersion => integer()();
  TextColumn get os => text()();
  TextColumn get device => text()();
  TextColumn get screen => text()();
  TextColumn get errorType => text()();
  TextColumn get message => text()();
  TextColumn get stack => text()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  DateTimeColumn get firstAt => dateTime()();
  DateTimeColumn get lastAt => dateTime()();
  DateTimeColumn get sentAt => dateTime().nullable()();
}

/// The cached Plus answer of the server (schema v12, FEAT-30 PD-3): one row,
/// `id = 1`, device state that is never synced.
class PlusState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get plus => boolean()();
  DateTimeColumn get until => dateTime().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get status => text().nullable()();
  BoolColumn get willRenew => boolean().withDefault(const Constant(false))();
  DateTimeColumn get endedAt => dateTime().nullable()();
  DateTimeColumn get serverCheckedAt => dateTime()();
  DateTimeColumn get deviceCheckedAt => dateTime()();
  TextColumn get accountId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The children of the family (schema v9, FEAT-25, FAM-01). There is always
/// at least one; an empty [nickname] means the parent hasn't filled in her
/// profile yet (AD-2).
@DataClassName('ChildRow')
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nickname => text().withDefault(const Constant(''))();
  IntColumn get schoolYear => integer().withDefault(const Constant(1))();
  IntColumn get schoolStartLevel => integer().nullable()();
  IntColumn get olympiadStartLevel => integer().nullable()();

  /// An avatar id from `lib/ui/avatars.dart` (AD-7).
  TextColumn get avatar => text().withDefault(const Constant('fox'))();
  IntColumn get dailyLimitMin => integer().withDefault(const Constant(20))();
  BoolColumn get soundOn => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// The server `children` record once linked (AD-8).
  TextColumn get remoteId => text().nullable()();
  IntColumn get resetEpoch => integer().withDefault(const Constant(0))();
  BoolColumn get pendingReset => boolean().withDefault(const Constant(false))();

  /// Removed here while offline: hidden everywhere until the next sync
  /// deletes the server record (AD-10).
  BoolColumn get pendingDelete =>
      boolean().withDefault(const Constant(false))();
}

/// Downloaded question banks (schema v8, FEAT-15 D7); the newest good one
/// is kept, its file under app support `banks/`.
@DataClassName('BankFileRow')
class BankFiles extends Table {
  IntColumn get version => integer()();
  IntColumn get format => integer()();
  TextColumn get sha256 => text()();

  /// File name under the banks directory.
  TextColumn get path => text()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {version};
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

  /// The child who played it (schema v9, FEAT-25).
  IntColumn get childId => integer()();
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

  /// Same as the round's (schema v9), so per-child queries need no join.
  IntColumn get childId => integer()();
  TextColumn get questionId => text()();
  TextColumn get answerGiven => text()();
  BoolColumn get correct => boolean()();
  IntColumn get timeMs => integer()();
  DateTimeColumn get answeredAt => dateTime()();

  /// Sync id and unsent flag (schema v7, FEAT-14). Attempts never change.
  TextColumn get uuid => text().clientDefault(_newId)();
  IntColumn get dirty => integer().withDefault(const Constant(1))();
}

/// Screen-time usage per child (schema v9), calendar day (yyyy-MM-dd, local
/// time) and device (schema v7): a device writes only its own rows, others
/// come from sync.
class DailyUsage extends Table {
  IntColumn get childId => integer()();
  TextColumn get day => text()();
  TextColumn get deviceId => text()();
  IntColumn get secondsUsed => integer().withDefault(const Constant(0))();
  IntColumn get extraSecondsGranted =>
      integer().withDefault(const Constant(0))();
  IntColumn get dirty => integer().withDefault(const Constant(1))();
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {childId, day, deviceId};
}

class BadgesEarned extends Table {
  IntColumn get childId => integer()();
  TextColumn get badgeId => text()();
  DateTimeColumn get earnedAt => dateTime()();
  IntColumn get dirty => integer().withDefault(const Constant(1))();
  TextColumn get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {childId, badgeId};
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
  IntColumn get childId => integer()();
  TextColumn get topicId => text()();
  DateTimeColumn get openedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {childId, topicId};
}

/// When each synced profile or settings field of a child last changed here
/// (FEAT-14, last change wins per field; per child since v9). Fields:
/// [syncFieldNames].
class SyncFields extends Table {
  IntColumn get childId => integer()();
  TextColumn get field => text()();
  DateTimeColumn get changedAt => dateTime()();
  IntColumn get dirty => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {childId, field};
}

/// Sync bookkeeping (single row, id is always 1), FEAT-14. Since v9
/// [childId], [resetEpoch] and [pendingReset] live on `children` and are no
/// longer read (FEAT-25 AD-12).
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
const syncFieldAvatar = 'avatar'; // FEAT-25 AD-7
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
  syncFieldAvatar,
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
    Children,
    TopicUnlocks,
    SyncFields,
    SyncState,
    BankFiles,
    CrashReports,
    PlusState,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'number_ninja'));

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(appSettings)
          .insert(const AppSettingsCompanion(setupStep: Value('welcome')));
      await into(pinLockout).insert(PinLockoutCompanion.insert());
      await into(syncState).insert(SyncStateCompanion.insert());
      final now = DateTime.now();
      await into(children)
          .insert(ChildrenCompanion.insert(createdAt: now, updatedAt: now));
      await seedChildFields(1, profileTime: null);
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await _from1To2(m);
      if (from < 3) await m.addColumn(appSettings, appSettings.soundOn);
      if (from < 4) {
        await m.addColumn(appSettings, appSettings.profilePending);
        await customStatement(_v8ChildProfile);
        // An updated install keeps working without a profile (PRO-02).
        await customStatement('UPDATE app_settings SET profile_pending = 0');
      }
      if (from < 5) await customStatement(_v8TopicUnlocks);
      if (from < 6) await m.addColumn(rounds, rounds.kind);
      // v8 columns first: _from6To7 rebuilds app_settings with every
      // column of the current schema, so they must exist by then.
      if (from < 8) {
        await m.addColumn(appSettings, appSettings.bankCheckedAt);
        await m.addColumn(appSettings, appSettings.bankCheckNote);
        await m.createTable(bankFiles);
      }
      // v9 columns before _from6To7 too, for the same reason.
      if (from < 9) await _v9Columns(m);
      // v10 column before _from6To7 too (code-map gotcha).
      if (from < 10) await m.addColumn(appSettings, appSettings.setupStep);
      // v11 (FEAT-24) before _from6To7 too.
      if (from < 11) {
        await m.addColumn(appSettings, appSettings.crashReports);
        await m.createTable(crashReports);
      }
      if (from < 7) await _from6To7(m);
      if (from < 9) await _from8To9(m);
      if (from < 10) await _from9To10();
      if (from < 12) await m.createTable(plusState);
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
    await customStatement(_v8SyncFields);
    await m.createTable(syncState);
    await into(syncState).insert(SyncStateCompanion.insert());
    // v8 shape: no child id yet, _from8To9 adds it.
    final profile = await customSelect(
      'SELECT updated_at FROM child_profile WHERE id = 1',
    ).getSingleOrNull();
    final profileSecs = profile?.read<int>('updated_at');
    for (final f in syncFieldNames) {
      final at = profileSyncFields.contains(f) ? profileSecs ?? 0 : 0;
      await customStatement(
        'INSERT INTO sync_fields (field, changed_at) VALUES (?, ?)',
        [f, at],
      );
    }
  }

  /// Schema v10 (FEAT-26 AD-12): an install without a PIN starts setup at
  /// Welcome, one with a PIN but no profile yet resumes at Children (behind
  /// the PIN, AD-4); a set-up install never sees the wizard (SET-07).
  /// `profile_pending` stays but is no longer read.
  Future<void> _from9To10() async {
    await customStatement('''
      UPDATE app_settings SET setup_step = CASE
        WHEN pin_hash IS NULL THEN 'welcome'
        WHEN profile_pending = 1 THEN 'children'
        ELSE NULL END
    ''');
  }

  /// Schema v9 plain columns (FEAT-25): the two `app_settings` fields and
  /// `child_id` = 1 on the rows that `_from6To7` may rebuild.
  Future<void> _v9Columns(Migrator m) async {
    await m.addColumn(appSettings, appSettings.currentChildId);
    await m.addColumn(appSettings, appSettings.switchNeedsPin);
    for (final t in ['rounds', 'attempts', 'daily_usage']) {
      await customStatement(
        'ALTER TABLE $t ADD COLUMN child_id INTEGER NOT NULL DEFAULT 1',
      );
    }
  }

  /// Schema v9 (FEAT-25, FAM-07): the v8 profile, limit, sound and sync
  /// link become child 1; the per-child tables are re-keyed with child 1.
  Future<void> _from8To9(Migrator m) async {
    await m.createTable(children);
    final p = await customSelect(
      'SELECT nickname, school_year, school_start_level, '
      'olympiad_start_level, updated_at FROM child_profile WHERE id = 1',
    ).getSingleOrNull();
    final s = await getSettings();
    final sync = await customSelect(
      'SELECT child_id, reset_epoch, pending_reset FROM sync_state '
      'WHERE id = 1',
    ).getSingleOrNull();
    final now = DateTime.now();
    final at = p == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(p.read<int>('updated_at') * 1000);
    await into(children).insert(
      ChildrenCompanion.insert(
        id: const Value(1),
        nickname: Value(p?.read<String>('nickname') ?? ''),
        schoolYear: Value(p?.read<int>('school_year') ?? 1),
        schoolStartLevel: Value(p?.readNullable<int>('school_start_level')),
        olympiadStartLevel: Value(p?.readNullable<int>('olympiad_start_level')),
        dailyLimitMin: Value(s.dailyLimitMin),
        soundOn: Value(s.soundOn),
        createdAt: at,
        updatedAt: at,
        remoteId: Value(sync?.readNullable<String>('child_id')),
        resetEpoch: Value(sync?.read<int>('reset_epoch') ?? 0),
        pendingReset: Value((sync?.read<int>('pending_reset') ?? 0) != 0),
      ),
    );
    const one = Constant<int>(1);
    // daily_usage already has child_id (from _v9Columns): rebuild for the key.
    await m.alterTable(TableMigration(dailyUsage));
    await m.alterTable(
      TableMigration(
        badgesEarned,
        newColumns: [badgesEarned.childId],
        columnTransformer: {badgesEarned.childId: one},
      ),
    );
    await m.alterTable(
      TableMigration(
        topicUnlocks,
        newColumns: [topicUnlocks.childId],
        columnTransformer: {topicUnlocks.childId: one},
      ),
    );
    await m.alterTable(
      TableMigration(
        syncFields,
        newColumns: [syncFields.childId],
        columnTransformer: {syncFields.childId: one},
      ),
    );
    await customStatement('DROP TABLE child_profile');
  }

  /// One `sync_fields` row per field for child [childId]: profile fields at
  /// [profileTime] (if any), the rest at time 0, so on a second tablet the
  /// account's values beat untouched defaults.
  Future<void> seedChildFields(
    int childId, {
    required DateTime? profileTime,
  }) async {
    final zero = DateTime.fromMillisecondsSinceEpoch(0);
    for (final f in syncFieldNames) {
      // The avatar is picked with the profile (FEAT-25 AD-7).
      final withProfile = profileSyncFields.contains(f) || f == syncFieldAvatar;
      final at = withProfile ? profileTime ?? zero : zero;
      await into(syncFields).insert(
        SyncFieldsCompanion.insert(childId: childId, field: f, changedAt: at),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  /// Records that [fields] of child [childId] changed here at [at]
  /// (FEAT-14, last change wins).
  Future<void> stampFields(
    int childId,
    Iterable<String> fields,
    DateTime at,
  ) async {
    for (final f in fields) {
      await customStatement(
        'INSERT INTO sync_fields (child_id, field, changed_at, dirty) '
        'VALUES (?, ?, ?, 1) ON CONFLICT(child_id, field) DO UPDATE SET '
        'changed_at = excluded.changed_at, dirty = dirty + 1',
        [childId, f, at.millisecondsSinceEpoch ~/ 1000],
      );
    }
    notifyUpdates({const TableUpdate('sync_fields')});
  }

  /// This install's device id (FEAT-14).
  Future<String> deviceId() async => (await getSettings()).deviceId;

  Future<AppSetting> getSettings() =>
      (select(appSettings)..where((s) => s.id.equals(1))).getSingle();

  /// Child [id]'s row (FEAT-25).
  Future<ChildRow> child(int id) =>
      (select(children)..where((c) => c.id.equals(id))).getSingle();

  /// The child playing now (FEAT-25 AD-3).
  Future<int> currentChildId() async => (await getSettings()).currentChildId;

  Stream<AppSetting> watchSettings() =>
      (select(appSettings)..where((s) => s.id.equals(1))).watchSingle();
}

/// Tables as schema v8 created them, for the steps before v9 (FEAT-25):
/// `_from8To9` turns them into their v9 shape.
const _v8ChildProfile =
    'CREATE TABLE "child_profile" ("id" INTEGER NOT NULL DEFAULT 1, '
    '"nickname" TEXT NOT NULL, "school_year" INTEGER NOT NULL, '
    '"school_start_level" INTEGER NULL, "olympiad_start_level" INTEGER NULL, '
    '"updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"))';
const _v8TopicUnlocks =
    'CREATE TABLE "topic_unlocks" ("topic_id" TEXT NOT NULL, '
    '"opened_at" INTEGER NOT NULL, PRIMARY KEY ("topic_id"))';
const _v8SyncFields =
    'CREATE TABLE "sync_fields" ("field" TEXT NOT NULL, '
    '"changed_at" INTEGER NOT NULL, "dirty" INTEGER NOT NULL DEFAULT 1, '
    'PRIMARY KEY ("field"))';
