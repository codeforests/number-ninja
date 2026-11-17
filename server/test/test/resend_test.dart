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
}
