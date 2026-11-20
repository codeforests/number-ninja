// FEAT-36 AC-6 (INV-05, IC-6): tool/make_invites.dart against a running
// PocketBase (server/test/run.sh starts one), run as a process from the
// repo root, like grant_plus_test.dart.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:number_ninja_server_test/fixtures.dart';
import 'package:test/test.dart';

final root = Directory.current.parent.parent.path;

Future<ProcessResult> makeInvites(List<String> args) => Process.run(
  'dart',
  ['run', 'tool/make_invites.dart', '--server', baseUrl, ...args],
  workingDirectory: root,
  environment: {
    'PB_SUPERUSER_EMAIL':
        Platform.environment['PB_SUPERUSER_EMAIL'] ?? 'admin@test.local',
    'PB_SUPERUSER_PASSWORD':
        Platform.environment['PB_SUPERUSER_PASSWORD'] ?? 'test-password-123',
  },
);

final pretty = RegExp('[$inviteAlphabet]{4}-[$inviteAlphabet]{4}');

void main() {
  test('--print prints the codes, without it no code reaches stdout; --list '
      'and --revoke', () async {
    final note = uniq('tool');
    var r = await makeInvites(['--count', '3', '--note', note, '--print']);
    expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
    final printed = pretty.allMatches(r.stdout as String).map((m) => m[0]!);
    expect(printed.toSet(), hasLength(3));
    expect(r.stdout, contains('made 3 codes: 12 months of Plus, 5 families'));

    final quiet = uniq('quiet');
    r = await makeInvites(['--count', '2', '--note', quiet]);
    expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
    expect(r.stdout, contains('not emailed'));
    final rows = await (await superuser())
        .collection('invite_codes')
        .getFullList(filter: 'note = "$quiet"');
    expect(rows, hasLength(2));
    for (final row in rows) {
      final c = row.getStringValue('code');
      expect(r.stdout, isNot(contains(c)));
      expect(
        r.stdout,
        isNot(contains('${c.substring(0, 4)}-${c.substring(4)}')),
      );
    }

    r = await makeInvites(['--list', '--note', note]);
    expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
    for (final code in printed) {
      expect(r.stdout, contains('$code  0/5'));
    }
    expect(r.stdout, contains('3 codes'));

    final victim = printed.first;
    r = await makeInvites(['--revoke', victim.toLowerCase()]);
    expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
    expect(r.stdout, contains('revoked $victim'));
    final p = await Parent.signUp('tool-revoked');
    final res = await http.post(
      Uri.parse('$baseUrl/api/nn/invite/redeem'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': p.pb.authStore.token,
        'X-Real-IP': '10.250.${DateTime.now().millisecond % 250}.7',
      },
      body: jsonEncode({'code': victim}),
    );
    expect(res.statusCode, 400);
    expect((jsonDecode(res.body) as Map)['reason'], 'not_found');

    r = await makeInvites(['--count', '2']);
    expect(r.exitCode, 1);
    expect(r.stderr, contains('no --note'));
    r = await makeInvites(['--count', '0', '--note', 'x']);
    expect(r.exitCode, 1);
  });
}
