/// FEAT-15 AC-6 (BNK-08): publish with tool/publish_bank.dart to a real
/// PocketBase, then the app's updater (signed in as a parent with Plus,
/// FEAT-29) downloads and the store loads it.
/// Skipped unless SYNC_LIVE_URL is set; `server/test/run.sh` runs it.
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/bank_store.dart';
import 'package:number_ninja/data/bank_updater.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/token_store.dart';
import 'package:pocketbase/pocketbase.dart';

final _url = Platform.environment['SYNC_LIVE_URL'];
String get _base => _url!;

void main() {
  test(
    'a published bank reaches the app',
    () async {
      final env = Platform.environment;
      final admin = PocketBase(_url!);
      await admin
          .collection('_superusers')
          .authWithPassword(
            env['PB_SUPERUSER_EMAIL'] ?? 'admin@test.local',
            env['PB_SUPERUSER_PASSWORD'] ?? 'test-password-123',
          );
      for (final b in await admin.collection('banks').getFullList()) {
        await admin.collection('banks').delete(b.id);
      }

      final tmp = Directory.systemTemp.createTempSync('nn-live-bank');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final committed = jsonDecode(
        File('assets/questions/bank.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      // One above the bundled bank, so the app takes it.
      final next = (committed['version'] as int) + 1;
      final file = File('${tmp.path}/bank_v$next.json')
        ..writeAsStringSync(jsonEncode({...committed, 'version': next}));
      final pub = await Process.run(
        'dart',
        [
          'run',
          'tool/publish_bank.dart',
          '--server',
          _base,
          '--bank-file',
          file.path,
        ],
        environment: {
          'PB_SUPERUSER_EMAIL': env['PB_SUPERUSER_EMAIL'] ?? 'admin@test.local',
          'PB_SUPERUSER_PASSWORD':
              env['PB_SUPERUSER_PASSWORD'] ?? 'test-password-123',
        },
      );
      expect(pub.exitCode, 0, reason: '${pub.stdout}${pub.stderr}');

      // FEAT-29 (BNK-13): only a signed-in parent with Plus sees the bank.
      final email =
          'bank-live-${DateTime.now().microsecondsSinceEpoch}@test.local';
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
      await admin
          .collection('entitlements')
          .create(
            body: {
              'user': user.id,
              'plan': 'plus',
              'source': 'complimentary',
              'status': 'active',
              'expires_at': '2099-12-31 23:59:59.000Z',
            },
          );
      final client = PocketBaseServerClient(
        ServerConfig.loopback(Uri.parse(_base).port),
        store: MemoryTokenStore(),
        timeout: const Duration(seconds: 30),
      );
      await client.signIn(email, password);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final store = BankStore(
        db,
        bundle: _FileBundle(),
        dir: () async => Directory('${tmp.path}/banks'),
      );
      final updater = BankUpdater(
        client: client,
        store: store,
        clock: () => DateTime(2027, 1, 5, 9),
      );
      expect(await updater.check(), BankCheck.downloaded);
      final active = await store.loadActive();
      expect(active.source, BankSource.downloaded);
      expect(active.bank.version, next);
      expect(
        active.bank.questions.length,
        (committed['questions'] as List).length,
      );
      expect(await updater.check(force: true), BankCheck.upToDate);
    },
    skip: _url == null ? 'SYNC_LIVE_URL not set' : false,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

/// The bundled bank read from disk: TestWidgetsFlutterBinding (needed for
/// rootBundle) would block real HTTP.
class _FileBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      File(key).readAsString();

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}
