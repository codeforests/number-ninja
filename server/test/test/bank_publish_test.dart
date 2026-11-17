// FEAT-15 AC-2 (BNK-07, BNK-10): tool/publish_bank.dart against a running
// PocketBase (server/test/run.sh starts one). Runs the script as a process
// from the repo root with --bank-file, so it never touches the real server.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:number_ninja_server_test/fixtures.dart';
import 'package:test/test.dart';

final root = Directory.current.parent.parent.path;
final work = Directory('$root/build/server-test/banks')
  ..createSync(recursive: true);
final committed = jsonDecode(
  File('$root/assets/questions/bank.json').readAsStringSync(),
) as Map<String, dynamic>;

/// The committed bank as version [version], with [edit] applied.
String bankFile(
  int version, {
  void Function(List<Map<String, dynamic>> qs)? edit,
}) {
  final qs = [
    for (final q in committed['questions'] as List)
      Map<String, dynamic>.from(q as Map),
  ];
  edit?.call(qs);
  final f = File('${work.path}/bank_$version-${uniq('b')}.json')
    ..writeAsStringSync(
      jsonEncode({'version': version, 'format': 1, 'questions': qs}),
    );
  return f.path;
}

Future<ProcessResult> publish(String file, {bool dryRun = false}) =>
    Process.run(
      'dart',
      [
        'run',
        'tool/publish_bank.dart',
        '--server',
        baseUrl,
        '--bank-file',
        file,
        if (dryRun) '--dry-run',
      ],
      workingDirectory: root,
      environment: {
        'PB_SUPERUSER_EMAIL':
            Platform.environment['PB_SUPERUSER_EMAIL'] ?? 'admin@test.local',
        'PB_SUPERUSER_PASSWORD':
            Platform.environment['PB_SUPERUSER_PASSWORD'] ??
            'test-password-123',
      },
    );

Future<List<Map<String, dynamic>>> banks() async {
  final r = await http.get(
    Uri.parse('$baseUrl/api/collections/banks/records?sort=-version'),
  );
  return [
    for (final i in (jsonDecode(r.body) as Map)['items'] as List)
      (i as Map).cast<String, dynamic>(),
  ];
}

void expectRefused(ProcessResult r, String why) {
  expect(r.exitCode, 1, reason: '${r.stdout}${r.stderr}');
  expect(r.stderr as String, contains(why));
}

void main() {
  setUpAll(() async {
    final su = await superuser();
    for (final b in await su.collection('banks').getFullList()) {
      await su.collection('banks').delete(b.id);
    }
  });

  test('publishes, then refuses what BNK-07 and BNK-10 forbid', () async {
    final v2 = bankFile(2);

    final dry = await publish(v2, dryRun: true);
    expect(dry.exitCode, 0, reason: '${dry.stdout}${dry.stderr}');
    expect(dry.stdout as String, contains('dry run'));
    expect(await banks(), isEmpty, reason: 'a dry run uploads nothing');

    final first = await publish(v2);
    expect(first.exitCode, 0, reason: '${first.stdout}${first.stderr}');
    final list = await banks();
    expect(list.single['version'], 2);
    expect(list.single['format'], 1);
    final file = await http.get(
      Uri.parse(
        '$baseUrl/api/files/banks/${list.single['id']}/'
        '${list.single['file']}',
      ),
    );
    expect(file.statusCode, 200, reason: 'anyone downloads');
    final bytes = File(v2).readAsBytesSync();
    expect(file.bodyBytes, bytes);
    expect(list.single['sha256'], sha256.convert(bytes).toString());

    expectRefused(await publish(bankFile(2)), 'not higher');
    expectRefused(await publish(bankFile(1)), 'not higher');

    final gone = (committed['questions'] as List).first['id'] as String;
    expectRefused(
      await publish(bankFile(3, edit: (qs) => qs.removeAt(0))),
      gone,
    );
    expectRefused(
      await publish(bankFile(3, edit: (qs) => qs.first['level'] = 7)),
      'validator',
    );
    expect(await banks(), hasLength(1), reason: 'nothing else uploaded');

    final retired = await publish(
      bankFile(3, edit: (qs) => qs.first['retired'] = true),
    );
    expect(retired.exitCode, 0, reason: '${retired.stdout}${retired.stderr}');
    expect((await banks()).first['version'], 3);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
