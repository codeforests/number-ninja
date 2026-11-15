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
    expect(version.data.values.single, 2);

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
}
