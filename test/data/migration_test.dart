import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';

/// The schema v1 tables, as Drift created them in FEAT-01..03.
const _v1 = [
  'CREATE TABLE "app_settings" ("id" INTEGER NOT NULL DEFAULT 1, "pin_hash" TEXT NULL, "pin_salt" TEXT NULL, "daily_limit_min" INTEGER NOT NULL DEFAULT 20, "bank_version" INTEGER NOT NULL DEFAULT 1, PRIMARY KEY ("id"))',
  'CREATE TABLE "play_sessions" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "started_at" INTEGER NOT NULL, "ended_at" INTEGER NULL)',
  'CREATE TABLE "rounds" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "session_id" INTEGER NOT NULL REFERENCES play_sessions (id), "topic_id" TEXT NOT NULL, "level" INTEGER NOT NULL DEFAULT 1, "started_at" INTEGER NOT NULL, "score" INTEGER NOT NULL DEFAULT 0, "duration_ms" INTEGER NOT NULL DEFAULT 0, "stars" INTEGER NOT NULL DEFAULT 0)',
  'CREATE TABLE "attempts" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "round_id" INTEGER NOT NULL REFERENCES rounds (id), "question_id" TEXT NOT NULL, "answer_given" TEXT NOT NULL, "correct" INTEGER NOT NULL CHECK ("correct" IN (0, 1)), "time_ms" INTEGER NOT NULL, "answered_at" INTEGER NOT NULL)',
  'CREATE TABLE "daily_usage" ("day" TEXT NOT NULL, "seconds_used" INTEGER NOT NULL DEFAULT 0, "extra_seconds_granted" INTEGER NOT NULL DEFAULT 0, PRIMARY KEY ("day"))',
  'CREATE TABLE "badges_earned" ("badge_id" TEXT NOT NULL, "earned_at" INTEGER NOT NULL, PRIMARY KEY ("badge_id"))',
  'CREATE TABLE "pin_lockout" ("id" INTEGER NOT NULL DEFAULT 1, "failed_count" INTEGER NOT NULL DEFAULT 0, "locked_until" INTEGER NULL, PRIMARY KEY ("id"))',
];

/// Unix seconds, as Drift v1 stored DateTimes.
int _secs(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

void main() {
  test('v1 -> v2 adds rounds.finished_at and backfills it (AC-2)', () async {
    final start = DateTime(2026, 11, 15, 9);
    final last = start.add(const Duration(minutes: 2));
    final executor = NativeDatabase.memory(
      setup: (raw) {
        for (final sql in _v1) {
          raw.execute(sql);
        }
        raw.execute('INSERT INTO app_settings (id, pin_hash) VALUES (1, ?)', [
          'h',
        ]);
        raw.execute('INSERT INTO pin_lockout (id) VALUES (1)');
        raw.execute(
          'INSERT INTO play_sessions (id, started_at) VALUES (1, ?)',
          [_secs(start)],
        );
        // Round 1 finished (10 answers), round 2 quit after 3.
        raw.execute(
          "INSERT INTO rounds (id, session_id, topic_id, level, started_at, score, stars) "
          "VALUES (1, 1, 'p2.times', 1, ?, 10, 3), (2, 1, 'p2.times', 2, ?, 0, 0)",
          [_secs(start), _secs(start)],
        );
        for (var i = 0; i < 10; i++) {
          final at = i == 9 ? last : start.add(Duration(seconds: i));
          raw.execute(
            'INSERT INTO attempts (round_id, question_id, answer_given, correct, time_ms, answered_at) '
            "VALUES (1, 'q$i', '1', 1, 1000, ?)",
            [_secs(at)],
          );
        }
        for (var i = 0; i < 3; i++) {
          raw.execute(
            'INSERT INTO attempts (round_id, question_id, answer_given, correct, time_ms, answered_at) '
            "VALUES (2, 'r$i', '1', 0, 1000, ?)",
            [_secs(start)],
          );
        }
        raw.execute('PRAGMA user_version = 1');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);

    final rounds = await (db.select(
      db.rounds,
    )..orderBy([(r) => .asc(r.id)])).get();
    expect(rounds, hasLength(2));
    expect(rounds[0].finishedAt, last);
    expect(rounds[1].finishedAt, isNull);
    // Existing data survives.
    expect((await db.getSettings()).pinHash, 'h');
    expect(await db.select(db.attempts).get(), hasLength(13));
    final cols = await db
        .customSelect(
          "SELECT name FROM pragma_table_info('rounds') WHERE name = ?",
          variables: [Variable.withString('finished_at')],
        )
        .get();
    expect(cols, hasLength(1));
  });

  test('v2 -> v3 adds app_settings.sound_on = true (FEAT-09 AC-2)', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        for (final sql in _v1) {
          raw.execute(sql);
        }
        raw.execute('ALTER TABLE rounds ADD COLUMN finished_at INTEGER NULL');
        raw.execute(
          'INSERT INTO app_settings (id, pin_hash, daily_limit_min) '
          'VALUES (1, ?, 35)',
          ['h'],
        );
        raw.execute('INSERT INTO pin_lockout (id) VALUES (1)');
        raw.execute('PRAGMA user_version = 2');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
    final settings = await db.getSettings();
    expect(settings.soundOn, isTrue);
    expect(settings.pinHash, 'h');
    expect(settings.dailyLimitMin, 35);
  });

  test('v3 -> v4 adds child_profile, not pending (FEAT-10 AC-2)', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        for (final sql in _v1) {
          raw.execute(sql);
        }
        raw.execute('ALTER TABLE rounds ADD COLUMN finished_at INTEGER NULL');
        raw.execute(
          'ALTER TABLE app_settings ADD COLUMN sound_on INTEGER NOT NULL '
          'DEFAULT 1 CHECK ("sound_on" IN (0, 1))',
        );
        raw.execute(
          'INSERT INTO app_settings (id, pin_hash, sound_on) VALUES (1, ?, 0)',
          ['h'],
        );
        raw.execute('INSERT INTO pin_lockout (id) VALUES (1)');
        raw.execute('INSERT INTO play_sessions (started_at) VALUES (1)');
        raw.execute(
          'INSERT INTO rounds (session_id, topic_id, started_at, finished_at) '
          "VALUES (1, 'p1.place', 1, 2)",
        );
        raw.execute('PRAGMA user_version = 3');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
    final settings = await db.getSettings();
    expect(settings.profilePending, isFalse);
    expect(settings.soundOn, isFalse);
    expect(settings.pinHash, 'h');
    expect(await db.select(db.childProfiles).get(), isEmpty);
    expect(await db.select(db.rounds).get(), hasLength(1));
  });

  test('v4 -> v5 adds an empty topic_unlocks (FEAT-17 AC-2)', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        for (final sql in _v1) {
          raw.execute(sql);
        }
        raw.execute('ALTER TABLE rounds ADD COLUMN finished_at INTEGER NULL');
        raw.execute(
          'ALTER TABLE app_settings ADD COLUMN sound_on INTEGER NOT NULL '
          'DEFAULT 1 CHECK ("sound_on" IN (0, 1))',
        );
        raw.execute(
          'ALTER TABLE app_settings ADD COLUMN profile_pending INTEGER NOT NULL '
          'DEFAULT 1 CHECK ("profile_pending" IN (0, 1))',
        );
        raw.execute(
          'CREATE TABLE "child_profile" ("id" INTEGER NOT NULL DEFAULT 1, '
          '"nickname" TEXT NOT NULL, "school_year" INTEGER NOT NULL, '
          '"school_start_level" INTEGER NULL, '
          '"olympiad_start_level" INTEGER NULL, '
          '"updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"))',
        );
        raw.execute(
          'INSERT INTO app_settings (id, pin_hash, profile_pending) '
          'VALUES (1, ?, 0)',
          ['h'],
        );
        raw.execute('INSERT INTO pin_lockout (id) VALUES (1)');
        raw.execute(
          'INSERT INTO child_profile (nickname, school_year, updated_at) '
          "VALUES ('Mia', 2, 1)",
        );
        raw.execute('INSERT INTO play_sessions (started_at) VALUES (1)');
        raw.execute(
          'INSERT INTO rounds (session_id, topic_id, started_at, score, '
          "finished_at) VALUES (1, 'p1.place', 1, 8, 2)",
        );
        raw.execute('PRAGMA user_version = 4');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
    expect(await db.select(db.topicUnlocks).get(), isEmpty);
    expect((await db.select(db.childProfiles).getSingle()).nickname, 'Mia');
    expect((await db.select(db.rounds).getSingle()).score, 8);
    expect((await db.getSettings()).pinHash, 'h');
  });

  test('v5 -> v6 adds rounds.kind = normal (FEAT-11 AC-2)', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        for (final sql in _v1) {
          raw.execute(sql);
        }
        raw.execute('ALTER TABLE rounds ADD COLUMN finished_at INTEGER NULL');
        raw.execute(
          'ALTER TABLE app_settings ADD COLUMN sound_on INTEGER NOT NULL '
          'DEFAULT 1 CHECK ("sound_on" IN (0, 1))',
        );
        raw.execute(
          'ALTER TABLE app_settings ADD COLUMN profile_pending INTEGER NOT NULL '
          'DEFAULT 1 CHECK ("profile_pending" IN (0, 1))',
        );
        raw.execute(
          'CREATE TABLE "child_profile" ("id" INTEGER NOT NULL DEFAULT 1, '
          '"nickname" TEXT NOT NULL, "school_year" INTEGER NOT NULL, '
          '"school_start_level" INTEGER NULL, '
          '"olympiad_start_level" INTEGER NULL, '
          '"updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"))',
        );
        raw.execute(
          'INSERT INTO app_settings (id, pin_hash, profile_pending) '
          'VALUES (1, ?, 0)',
          ['h'],
        );
        raw.execute('INSERT INTO pin_lockout (id) VALUES (1)');
        raw.execute(
          'INSERT INTO child_profile (nickname, school_year, updated_at) '
          "VALUES ('Mia', 2, 1)",
        );
        raw.execute('INSERT INTO play_sessions (started_at) VALUES (1)');
        raw.execute(
          'INSERT INTO rounds (session_id, topic_id, started_at, score, '
          "finished_at) VALUES (1, 'p1.place', 1, 8, 2)",
        );
        raw.execute(
          'CREATE TABLE "topic_unlocks" ("topic_id" TEXT NOT NULL, '
          '"opened_at" INTEGER NOT NULL, PRIMARY KEY ("topic_id"))',
        );
        raw.execute('PRAGMA user_version = 5');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
    final round = await db.select(db.rounds).getSingle();
    expect(round.kind, 'normal');
    expect(round.score, 8);
    expect((await db.select(db.childProfiles).getSingle()).nickname, 'Mia');
  });

  test('v6 -> v7 adds sync ids, dirty flags, per-device usage (FEAT-14 AC-1)', () async {
    final executor = NativeDatabase.memory(
      setup: (raw) {
        for (final sql in _v1) {
          raw.execute(sql);
        }
        raw.execute('ALTER TABLE rounds ADD COLUMN finished_at INTEGER NULL');
        raw.execute(
          'ALTER TABLE app_settings ADD COLUMN sound_on INTEGER NOT NULL '
          'DEFAULT 1 CHECK ("sound_on" IN (0, 1))',
        );
        raw.execute(
          'ALTER TABLE app_settings ADD COLUMN profile_pending INTEGER NOT NULL '
          'DEFAULT 1 CHECK ("profile_pending" IN (0, 1))',
        );
        raw.execute(
          'CREATE TABLE "child_profile" ("id" INTEGER NOT NULL DEFAULT 1, '
          '"nickname" TEXT NOT NULL, "school_year" INTEGER NOT NULL, '
          '"school_start_level" INTEGER NULL, '
          '"olympiad_start_level" INTEGER NULL, '
          '"updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"))',
        );
        raw.execute(
          'CREATE TABLE "topic_unlocks" ("topic_id" TEXT NOT NULL, '
          '"opened_at" INTEGER NOT NULL, PRIMARY KEY ("topic_id"))',
        );
        raw.execute(
          "ALTER TABLE rounds ADD COLUMN kind TEXT NOT NULL DEFAULT 'normal'",
        );
        raw.execute(
          'INSERT INTO app_settings (id, pin_hash, profile_pending) '
          'VALUES (1, ?, 0)',
          ['h'],
        );
        raw.execute('INSERT INTO pin_lockout (id) VALUES (1)');
        raw.execute(
          'INSERT INTO child_profile (nickname, school_year, updated_at) '
          "VALUES ('Mia', 2, 1000)",
        );
        raw.execute('INSERT INTO play_sessions (started_at) VALUES (1)');
        for (final t in ['p1.place', 'p1.money']) {
          raw.execute(
            'INSERT INTO rounds (session_id, topic_id, started_at, score, '
            "finished_at) VALUES (1, '$t', 1, 8, 2)",
          );
        }
        for (final r in [1, 1, 2]) {
          raw.execute(
            'INSERT INTO attempts (round_id, question_id, answer_given, '
            "correct, time_ms, answered_at) VALUES ($r, 'q', '1', 1, 5, 2)",
          );
        }
        raw.execute(
          'INSERT INTO daily_usage (day, seconds_used, extra_seconds_granted) '
          "VALUES ('2027-01-05', 300, 60)",
        );
        raw.execute(
          "INSERT INTO badges_earned (badge_id, earned_at) VALUES ('first', 2)",
        );
        raw.execute('PRAGMA user_version = 6');
      },
    );
    final db = AppDatabase(executor);
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
    final hex32 = RegExp(r'^[0-9a-f]{32}$');
    final device = await db.deviceId();
    expect(device, matches(hex32));

    final rounds = await db.select(db.rounds).get();
    final attempts = await db.select(db.attempts).get();
    final ids = [...rounds.map((r) => r.uuid), ...attempts.map((a) => a.uuid)];
    expect(ids, everyElement(matches(hex32)));
    expect(ids.toSet(), hasLength(5));
    expect(attempts.map((a) => a.roundId), [1, 1, 2]);
    expect(rounds.map((r) => r.topicId), ['p1.place', 'p1.money']);
    expect([
      ...rounds.map((r) => r.dirty),
      ...attempts.map((a) => a.dirty),
    ], everyElement(1));
    expect(rounds.map((r) => r.remoteId), everyElement(isNull));

    final usage = await db.select(db.dailyUsage).getSingle();
    expect(
      [usage.day, usage.deviceId, usage.secondsUsed, usage.extraSecondsGranted],
      ['2027-01-05', device, 300, 60],
    );
    expect(usage.dirty, 1);
    final badge = await db.select(db.badgesEarned).getSingle();
    expect([badge.badgeId, badge.dirty, badge.remoteId], ['first', 1, null]);

    final fields = {
      for (final f in await db.select(db.syncFields).get()) f.field: f,
    };
    expect(fields.keys.toSet(), syncFieldNames.toSet());
    for (final f in syncFieldNames) {
      final secs = fields[f]!.changedAt.millisecondsSinceEpoch ~/ 1000;
      expect(secs, profileSyncFields.contains(f) ? 1000 : 0, reason: f);
    }
    final state = await db.select(db.syncState).getSingle();
    expect([state.accountId, state.resetEpoch, state.cursors], [null, 0, '{}']);
    expect((await db.getSettings()).pinHash, 'h');
    // The uuid index is unique.
    await expectLater(
      db.customStatement('UPDATE attempts SET uuid = ? WHERE id = 2', [
        attempts.first.uuid,
      ]),
      throwsA(anything),
    );
  });

  test(
    'a fresh v7 install has a device id and sync rows (FEAT-14 AC-1)',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      expect(await db.deviceId(), matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(await db.select(db.syncFields).get(), hasLength(7));
      expect(await db.select(db.syncState).get(), hasLength(1));
    },
  );

  test(
    'v7 -> v8 adds bank_files and the bank check fields (FEAT-15 AC-7)',
    () async {
      final tmp = Directory.systemTemp.createTempSync('mig8');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final file = File('${tmp.path}/db.sqlite');
      final fresh = AppDatabase(NativeDatabase(file));
      await fresh.select(fresh.appSettings).get();
      await fresh.close();

      // Take the v8 additions away again: a v7 database.
      final db = AppDatabase(
        NativeDatabase(
          file,
          setup: (raw) {
            if (raw.userVersion != 8) return;
            raw.execute('DROP TABLE bank_files');
            raw.execute('ALTER TABLE app_settings DROP COLUMN bank_checked_at');
            raw.execute('ALTER TABLE app_settings DROP COLUMN bank_check_note');
            raw.execute("UPDATE app_settings SET pin_hash = 'h'");
            raw.userVersion = 7;
          },
        ),
      );
      addTearDown(db.close);
      final settings = await db.select(db.appSettings).getSingle();
      expect(settings.pinHash, 'h');
      expect(settings.bankCheckedAt, isNull);
      expect(settings.bankCheckNote, isNull);
      expect(await db.select(db.bankFiles).get(), isEmpty);
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 8);
    },
  );
}
