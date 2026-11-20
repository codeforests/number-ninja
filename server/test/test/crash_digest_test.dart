// FEAT-24 AC-7 (CRS-07): the daily crash digest (pb_hooks/crash_digest.pb.js).
// server/test/run.sh starts the main PocketBase with CRASH_DIGEST_TO and
// CRASH_KEEP_DAYS=0 (so the run also deletes what it read) and SMTP on the
// sink below; resend_test.dart checks that a server without the address
// sends nothing.
import 'dart:io';

import 'package:number_ninja_server_test/fixtures.dart';
import 'package:number_ninja_server_test/mail_sink.dart';
import 'package:test/test.dart';

final smtpPort = int.parse(Platform.environment['PB_SMTP_PORT'] ?? '2526');
final digestTo =
    Platform.environment['CRASH_DIGEST_TO'] ?? 'crashes@example.test';

Map<String, dynamic> report(String signature, int count, String message) => {
  'signature': signature,
  'app_version': '2.2.0+22',
  'bank_version': 3,
  'os': 'Android 14 (SDK 34)',
  'device': 'samsung SM-X200',
  'screen': '/quiz/:topicId',
  'error_type': 'StateError',
  'message': message,
  'stack': '#0 f (package:number_ninja/a.dart:1)',
  'count': count,
};

void main() {
  late MailSink sink;
  setUpAll(() async => sink = await MailSink.start(smtpPort));
  tearDownAll(() => sink.close());

  Future<int> reports() async =>
      (await (await superuser())
              .collection('crash_reports')
              .getList(perPage: 1))
          .totalItems;

  test('one mail lists the last day by signature, then old rows go', () async {
    final su = await superuser();
    final a = 'a' * 40;
    final b = 'b' * 40;
    for (final body in [
      report(a, 3, 'Bad state: first'),
      report(a, 2, 'Bad state: first'),
      report(b, 1, 'Bad state: second'),
    ]) {
      await su.collection('crash_reports').create(body: body);
    }
    final before = sink.mails.length;
    await su.crons.run('crash_digest');
    final mail = await sink.waitFor(digestTo, after: before);
    final text = mail.text;
    expect(text, contains('signature ${'a' * 12}'));
    expect(text, contains('signature ${'b' * 12}'));
    expect(text, contains('5 times'));
    expect(text, contains('Bad state: second'));
    expect(
      sink.mails.skip(before).where((m) => m.to.contains(digestTo)),
      hasLength(1),
    );

    // CRASH_KEEP_DAYS=0: everything is past the keep time now.
    for (var i = 0; i < 50 && await reports() > 0; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(await reports(), 0);
  });

  test('no reports: no mail', () async {
    final su = await superuser();
    expect(await reports(), 0);
    final before = sink.mails.length;
    await su.crons.run('crash_digest');
    await Future<void>.delayed(const Duration(seconds: 2));
    expect(
      sink.mails.skip(before).where((m) => m.to.contains(digestTo)),
      isEmpty,
    );
  });
}
