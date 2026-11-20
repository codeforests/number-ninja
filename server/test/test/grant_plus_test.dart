// FEAT-29 AC-6 (ENT-05): tool/grant_plus.dart against a running PocketBase
// (server/test/run.sh starts one), run as a process from the repo root.
import 'dart:io';

import 'package:number_ninja_server_test/fixtures.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:test/test.dart';

final root = Directory.current.parent.parent.path;

Future<ProcessResult> grantPlus(List<String> args) => Process.run(
  'dart',
  ['run', 'tool/grant_plus.dart', '--server', baseUrl, ...args],
  workingDirectory: root,
  environment: {
    'PB_SUPERUSER_EMAIL':
        Platform.environment['PB_SUPERUSER_EMAIL'] ?? 'admin@test.local',
    'PB_SUPERUSER_PASSWORD':
        Platform.environment['PB_SUPERUSER_PASSWORD'] ?? 'test-password-123',
  },
);

void main() {
  test('forever, until, revoke on one record; unknown email refused; the '
      'email is never printed', () async {
    final p = await Parent.signUp('grant');
    Future<List<RecordModel>> records() async => (await superuser())
        .collection('entitlements')
        .getFullList(filter: 'user = "${p.id}"');
    void ok(ProcessResult r, String out) {
      expect(r.exitCode, 0, reason: '${r.stdout}${r.stderr}');
      expect(r.stdout as String, contains(out));
      expect('${r.stdout}${r.stderr}', isNot(contains(p.email)));
    }

    ok(
      await grantPlus(['--email', p.email, '--forever', '--note', 'friend']),
      'plus until 2099-12-31',
    );
    var rs = await records();
    expect(rs.single.getStringValue('source'), 'complimentary');
    expect(rs.single.getStringValue('expires_at'), startsWith('2099-12-31'));
    expect(rs.single.getStringValue('note'), 'friend');

    ok(
      await grantPlus(['--email', p.email, '--until', '2027-06-30']),
      'plus until 2027-06-30',
    );
    rs = await records();
    expect(rs, hasLength(1), reason: 'the same record');
    expect(
      rs.single.getStringValue('expires_at'),
      startsWith('2027-06-30 23:59:59'),
    );

    ok(await grantPlus(['--email', p.email, '--revoke']), 'plus revoked');
    rs = await records();
    expect(rs.single.getStringValue('status'), 'revoked');
    final ended = DateTime.parse(rs.single.getStringValue('expires_at'));
    expect(ended.isAfter(DateTime.now()), isFalse);

    final unknown = await grantPlus([
      '--email',
      'nobody-${uniq('x')}@test.local',
      '--forever',
    ]);
    expect(unknown.exitCode, 1);
    expect(unknown.stderr as String, contains('no account'));
    expect(await records(), hasLength(1), reason: 'nothing written');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
