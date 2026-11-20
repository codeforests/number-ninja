/// FEAT-24 AC-4/AC-6: the app's crash upload against a real PocketBase:
/// the body it posts fits the `crash_reports` schema, signed out, and a
/// superuser reads the row. Skipped unless SYNC_LIVE_URL is set;
/// `server/test/run.sh` runs it.
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/crash_repository.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/token_store.dart';
import 'package:number_ninja/domain/crash.dart';
import 'package:pocketbase/pocketbase.dart';

final _url = Platform.environment['SYNC_LIVE_URL'];

void main() {
  test(
    'a recorded crash posts to the server and a superuser reads it',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = CrashRepository(db);
      final message =
          'Bad state: live ${DateTime.now().microsecondsSinceEpoch}';
      await repo.record(
        CrashEntry(
          type: 'StateError',
          message: message,
          stack: '#0 f (package:number_ninja/a.dart:1:2)',
          screen: '/quiz/:topicId',
          at: DateTime.now(),
        ),
        const CrashInfo(appVersion: '2.2.0+22', os: 'test', device: 'live'),
        3,
      );
      final client = PocketBaseServerClient(
        ServerConfig.loopback(Uri.parse(_url!).port),
        store: MemoryTokenStore(),
      );
      final body = crashBody((await repo.pending()).single);
      // api_rules_test.dart spends the 10-per-minute create limit.
      for (var i = 0; ; i++) {
        try {
          await client.sendCrashReport(body);
          break;
        } on SyncException catch (e) {
          if (e.status != 429 || i == 12) rethrow;
          await Future<void>.delayed(const Duration(seconds: 5));
        }
      }

      final env = Platform.environment;
      final admin = PocketBase(_url!);
      await admin
          .collection('_superusers')
          .authWithPassword(
            env['PB_SUPERUSER_EMAIL'] ?? 'admin@test.local',
            env['PB_SUPERUSER_PASSWORD'] ?? 'test-password-123',
          );
      final rows = await admin
          .collection('crash_reports')
          .getFullList(filter: admin.filter('message = {:m}', {'m': message}));
      expect(rows, hasLength(1));
      final r = rows.single;
      expect(r.getStringValue('screen'), '/quiz/:topicId');
      expect(r.getIntValue('count'), 1);
      expect(r.getIntValue('bank_version'), 3);
      expect(r.getStringValue('signature'), body['signature']);
    },
    skip: _url == null ? 'SYNC_LIVE_URL not set' : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
