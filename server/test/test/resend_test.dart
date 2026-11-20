// Email through Resend's HTTPS API (mail.pb.js). server/test/run.sh starts a
// PocketBase with RESEND_API_KEY=test-key, RESEND_API_URL pointing at the sink
// below on PB_RESEND_PORT, and SMTP settings that would fail if used.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:number_ninja_server_test/fixtures.dart';
import 'package:test/test.dart';

final host = Platform.environment['PB_TEST_HOST'] ?? 'api.example.test';
final port = int.parse(Platform.environment['PB_RESEND_PORT'] ?? '2527');
const password = 'first-password-1';

class Sent {
  Sent(this.auth, this.body);
  final String? auth;
  final Map<String, dynamic> body;
}

void main() {
  late HttpServer sink;
  final sent = <Sent>[];

  setUpAll(() async {
    sink = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    sink.listen((req) async {
      final body =
          jsonDecode(await utf8.decodeStream(req)) as Map<String, dynamic>;
      sent.add(Sent(req.headers.value('authorization'), body));
      req.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write('{"id":"m${sent.length}"}');
      await req.response.close();
    });
  });
  tearDownAll(() => sink.close(force: true));

  Future<Sent> waitFor(String email) async {
    for (var i = 0; i < 100; i++) {
      final hit = sent.where((s) => (s.body['to'] as List).contains(email));
      if (hit.isNotEmpty) return hit.last;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    fail('no Resend call for $email');
  }

  String? token(Sent s, String page) =>
      RegExp('https://${RegExp.escape(host)}/$page\\?token=([A-Za-z0-9._-]+)')
          .firstMatch(s.body['html'] as String)?[1];

  test(
    'verification mail goes to Resend with the key and a working link',
    () async {
      final email = '${uniq('resend')}@test.local';
      final pb = anonymous();
      await pb
          .collection('users')
          .create(
            body: {
              'email': email,
              'password': password,
              'passwordConfirm': password,
            },
          );
      await pb.collection('users').requestVerification(email);
      final s = await waitFor(email);
      expect(s.auth, 'Bearer test-key');
      expect(s.body['to'], [email]);
      expect(s.body['from'], contains('noreply@example.test'));
      expect(s.body['subject'], isNotEmpty);
      final t = token(s, 'verify.html');
      expect(t, isNotNull, reason: s.body['html'] as String);
      await anonymous().collection('users').confirmVerification(t!);
      final again = anonymous();
      await signIn(again, 'users', email, password);
      expect(again.authStore.record!.getBoolValue('verified'), isTrue);
    },
  );

  test('forgot-password mail goes to Resend too', () async {
    final email = '${uniq('resend-reset')}@test.local';
    final pb = anonymous();
    await pb
        .collection('users')
        .create(
          body: {
            'email': email,
            'password': password,
            'passwordConfirm': password,
          },
        );
    await pb.collection('users').requestPasswordReset(email);
    final s = await waitFor(email);
    expect(token(s, 'reset.html'), isNotNull, reason: s.body['html'] as String);
  });

  // FEAT-24 AC-7 (CRS-07): this server has no CRASH_DIGEST_TO, so the
  // digest sends nothing even with reports present.
  test('no digest address: the crash digest sends no mail', () async {
    final su = await superuser();
    await su
        .collection('crash_reports')
        .create(
          body: {
            'signature': uniq('sig'),
            'app_version': '2.2.0+22',
            'error_type': 'StateError',
            'count': 1,
          },
        );
    final before = sent.length;
    await su.crons.run('crash_digest');
    await Future<void>.delayed(const Duration(seconds: 2));
    expect(sent.skip(before), isEmpty);
    expect(
      (await su.collection('crash_reports').getList(perPage: 1)).totalItems,
      greaterThan(0),
      reason: 'kept for 90 days',
    );
  });

  // FEAT-31 AC-5 (WE-10): the weekly email's List-Unsubscribe headers reach
  // Resend.
  test('weekly email headers go to Resend', () async {
    final p = await Parent.signUp('weekly');
    await grant(p.id, expiresAt: forever);
    await p.pb
        .collection('users')
        .update(p.id, body: {'weekly_email': true, 'weekly_email_tz': 480});
    final child = await p.pb
        .collection('children')
        .create(body: {'owner': p.id, 'nickname': 'Mei', 'school_year': 2});
    await p.pb
        .collection('daily_usage')
        .create(body: {...usageBody(child.id), 'day': '2026-11-18'});
    final su = await superuser();
    final r = await su.send(
      '/api/nn/admin/weekly-email',
      method: 'POST',
      body: {'now': '2026-11-23T00:00:00Z', 'user': p.id},
    );
    expect((r as Map)['sent'], 1);
    final s = await waitFor(p.email);
    final headers = Map<String, dynamic>.from(s.body['headers'] as Map);
    expect(
      headers['List-Unsubscribe'],
      matches(
        RegExp(
          '^<https://${RegExp.escape(host)}/api/nn/weekly-email/off\\?u=${p.id}&t=[A-Za-z0-9]{32}>\$',
        ),
      ),
    );
    expect(headers['List-Unsubscribe-Post'], 'List-Unsubscribe=One-Click');
  });
}
