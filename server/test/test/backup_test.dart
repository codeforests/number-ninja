// FEAT-12 AC-3 (NFR-15), part 1: settings and a backup through the API.
// server/test/run.sh restores the backup into a second PocketBase and runs
// restore_check_test.dart against it.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:number_ninja_server_test/fixtures.dart';
import 'package:test/test.dart';

void main() {
  test('backups run daily at 03:00 SGT and keep 14', () async {
    final su = await superuser();
    final s = await su.settings.getAll();
    expect(s['backups']['cron'], '0 19 * * *');
    expect(s['backups']['cronMaxKeep'], 14);
    expect(s['rateLimits']['enabled'], isTrue);
    // FEAT-14 turned the batch API on for sync (100 requests per batch).
    expect(s['batch']['enabled'], isTrue);
    expect(s['batch']['maxRequests'], 100);
  });

  test('a backup made through the API downloads as a zip', () async {
    final parent = await Parent.signUp('backup');
    final data = await ChildData.create(parent);
    final su = await superuser();
    final name = '${uniq('ci')}.zip';
    await su.backups.create(name);
    final token = await su.files.getToken();
    final res = await http.get(su.backups.getDownloadURL(token, name));
    expect(res.statusCode, 200);
    expect(res.bodyBytes.take(2), [0x50, 0x4b], reason: 'zip magic');

    final out = Platform.environment['PB_BACKUP_OUT'];
    if (out == null) return;
    File(out).writeAsBytesSync(res.bodyBytes);
    File('$out.json').writeAsStringSync(
      jsonEncode({
        'email': parent.email,
        'password': parent.password,
        'child': data.child.id,
        'records': {for (final e in data.perChild.entries) e.key: e.value.id},
      }),
    );
  });
}
