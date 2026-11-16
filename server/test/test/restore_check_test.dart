// FEAT-12 AC-3 (NFR-15), part 2: run by server/test/run.sh against a fresh
// PocketBase restored from backup_test.dart's zip with server/restore.sh.
import 'dart:convert';
import 'dart:io';

import 'package:number_ninja_server_test/fixtures.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:test/test.dart';

void main() {
  final marker = Platform.environment['PB_RESTORE_MARKER'];

  test(
    "the restored server has the parent's records and the settings",
    () async {
      final m = jsonDecode(File(marker!).readAsStringSync()) as Map;
      final pb = PocketBase(baseUrl);
      await signIn(pb, 'users', m['email'] as String, m['password'] as String);
      expect(
        (await pb.collection('children').getOne(m['child'] as String)).id,
        m['child'],
      );
      for (final MapEntry(:key, :value) in (m['records'] as Map).entries) {
        final r = await pb.collection(key as String).getOne(value as String);
        expect(r.getStringValue('child'), m['child'], reason: key);
      }
      final s = await (await superuser()).settings.getAll();
      expect(s['backups']['cron'], '0 19 * * *');
      expect(s['backups']['cronMaxKeep'], 14);
    },
    skip: marker == null ? 'run by server/test/run.sh after a restore' : false,
  );
}
