/// FEAT-14 AC-7 (NFR-16): sync against a real PocketBase. Skipped unless
/// SYNC_LIVE_URL is set; `server/test/run.sh` (CI job `server`) runs it
/// against the pinned local server.
library;

import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/sync_service.dart';
import 'package:number_ninja/data/sync/token_store.dart';
import 'package:pocketbase/pocketbase.dart';

final _url = Platform.environment['SYNC_LIVE_URL'];

/// A verified parent, made through the superuser.
Future<(String, String)> _parent(String base) async {
  final env = Platform.environment;
  final admin = PocketBase(base);
  await admin
      .collection('_superusers')
      .authWithPassword(
        env['PB_SUPERUSER_EMAIL'] ?? 'admin@test.local',
        env['PB_SUPERUSER_PASSWORD'] ?? 'test-password-123',
      );
  final email = 'live-${DateTime.now().microsecondsSinceEpoch}@test.local';
  const password = 'parent-password-1';
  final user = await admin
      .collection('users')
      .create(
        body: {
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'verified': true,
        },
      );
  expect(user.id, isNotEmpty);
  return (email, password);
}

class _Tablet {
  _Tablet(ServerConfig config)
    : db = AppDatabase(NativeDatabase.memory()),
      client = PocketBaseServerClient(
        config,
        store: MemoryTokenStore(),
        timeout: const Duration(seconds: 30),
      );

  final AppDatabase db;
  final PocketBaseServerClient client;
  DateTime now = DateTime(2027, 1, 5, 9);

  late final sync = SyncService(
    db: db,
    client: client,
    clock: () => now,
    forgetSession: () {},
  );

  /// [rounds] finished rounds of [answers] attempts each, in bulk.
  Future<void> seed(int rounds, int answers) async {
    final session = await db
        .into(db.playSessions)
        .insert(PlaySessionsCompanion.insert(startedAt: now));
    await db.transaction(() async {
      for (var r = 0; r < rounds; r++) {
        final at = now.add(Duration(minutes: r));
        final id = await db
            .into(db.rounds)
            .insert(
              RoundsCompanion.insert(
                sessionId: session,
                topicId: 'p1.place',
                startedAt: at,
                score: const Value(7),
                stars: const Value(2),
                finishedAt: Value(at.add(const Duration(minutes: 2))),
              ),
            );
        await db.batch((b) {
          b.insertAll(db.attempts, [
            for (var a = 0; a < answers; a++)
              AttemptsCompanion.insert(
                roundId: id,
                questionId: 'q$a',
                answerGiven: '$a',
                correct: a.isEven,
                timeMs: 4000,
                answeredAt: at.add(Duration(seconds: a)),
              ),
          ]);
        });
      }
    });
    now = now.add(Duration(minutes: rounds + 1));
  }

  Future<int> count(TableInfo<Table, Object?> t) async =>
      (await db.select(t).get()).length;
}

void main() {
  test(
    'first sync of 20,000 attempts under 60 s; then only the new round '
    '(AC-7, NFR-16)',
    () async {
      final config = ServerConfig.loopback(Uri.parse(_url!).port);
      final (email, password) = await _parent(_url!);

      final a = _Tablet(config);
      addTearDown(a.db.close);
      await a.client.signIn(email, password);
      await a.seed(1000, 20);
      final watch = Stopwatch()..start();
      final first = await a.sync.run();
      watch.stop();
      // ignore: avoid_print
      print('first sync: ${watch.elapsed}, pushed ${first.pushed}');
      expect(first.pushed['rounds'], 1000);
      expect(first.pushed['attempts'], 20000);
      expect(first.rejected, 0);
      expect(watch.elapsed, lessThan(const Duration(seconds: 60)));

      await a.seed(1, 10);
      final second = await a.sync.run();
      // ignore: avoid_print
      print('second sync: pushed ${second.pushed}, pulled ${second.pulled}');
      expect(second.pushed, {'rounds': 1, 'attempts': 10});
      // Pulls the new records plus the ones at the last cursor (`>=`).
      expect(second.pulled['rounds'], lessThanOrEqualTo(1 + 100));
      expect(second.pulled['attempts'], lessThanOrEqualTo(10 + 100));

      final b = _Tablet(config);
      addTearDown(b.db.close);
      await b.client.signIn(email, password);
      await b.sync.run();
      expect(await b.count(b.db.rounds), 1001);
      expect(await b.count(b.db.attempts), 20010);
    },
    skip: _url == null ? 'SYNC_LIVE_URL not set' : false,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
