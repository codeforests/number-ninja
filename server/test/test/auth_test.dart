// FEAT-13 AC-2 and AC-3 (ACC-01..03, ACC-07, NFR-14): accounts against the
// pinned PocketBase with a local SMTP sink. server/test/run.sh starts
// PocketBase with SMTP_HOST=127.0.0.1, SMTP_PORT=$PB_SMTP_PORT,
// SERVER_HOSTNAME=$PB_TEST_HOST and dummy Google secrets.
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:number_ninja_server_test/fixtures.dart';
import 'package:number_ninja_server_test/mail_sink.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:test/test.dart';

final host = Platform.environment['PB_TEST_HOST'] ?? 'api.example.test';
final smtpPort = int.parse(Platform.environment['PB_SMTP_PORT'] ?? '2526');
const password = 'first-password-1';

Future<RecordModel> createUser(PocketBase pb, String email, String pw) => pb
    .collection('users')
    .create(body: {'email': email, 'password': pw, 'passwordConfirm': pw});

void main() {
  late MailSink sink;

  setUpAll(() async => sink = await MailSink.start(smtpPort));
  tearDownAll(() => sink.close());

  test(
    'sign-up: verify by the emailed link, then sign in (ACC-01, ACC-02)',
    () async {
      final email = '${uniq('new')}@test.local';
      final pb = anonymous();
      final user = await createUser(pb, email, password);
      await pb.collection('users').requestVerification(email);
      final mail = await sink.waitFor(email);
      expect(mail.text, contains('confirm your email'));
      final token = MailSink.linkToken(mail, host, 'verify.html');
      expect(token, isNotNull, reason: mail.text);

      // Before confirming: signed in but unverified, can't hold child data.
      await signIn(pb, 'users', email, password);
      expect(pb.authStore.record!.getBoolValue('verified'), isFalse);
      final status = await statusOf(
        () => pb
            .collection('children')
            .create(body: {'owner': user.id, 'nickname': 'Mei'}),
      );
      expect(status, anyOf(400, 403));

      await anonymous().collection('users').confirmVerification(token!);
      final again = anonymous();
      await signIn(again, 'users', email, password);
      expect(again.authStore.record!.getBoolValue('verified'), isTrue);
      await again
          .collection('children')
          .create(body: {'owner': user.id, 'nickname': 'Mei'});
    },
  );

  test('forgot password: reset by the emailed link (ACC-03)', () async {
    final p = await Parent.signUp('reset');
    const newPassword = 'second-password-2';
    final before = sink.mails.length;
    await anonymous().collection('users').requestPasswordReset(p.email);
    final mail = await sink.waitFor(p.email, after: before);
    final token = MailSink.linkToken(mail, host, 'reset.html');
    expect(token, isNotNull, reason: mail.text);
    await anonymous()
        .collection('users')
        .confirmPasswordReset(token!, newPassword, newPassword);

    expect(
      await statusOf(() => signIn(anonymous(), 'users', p.email, p.password)),
      400,
    );
    await signIn(anonymous(), 'users', p.email, newPassword);
  });

  test('a 7-character password is refused (ACC-01)', () async {
    final email = '${uniq('short')}@test.local';
    try {
      await createUser(anonymous(), email, 'abc1234');
      fail('created');
    } on ClientException catch (e) {
      expect(e.statusCode, 400);
      expect((e.response['data'] as Map).containsKey('password'), isTrue);
    }
  });

  for (final page in ['verify.html', 'reset.html']) {
    test('$page is served with no external resources (NFR-14)', () async {
      final r = await http.get(Uri.parse('$baseUrl/$page'));
      expect(r.statusCode, 200);
      expect(r.headers['content-type'], contains('text/html'));
      expect(
        RegExp(r'''(src|href)\s*=\s*["']?(https?:)?//''').hasMatch(r.body),
        isFalse,
      );
      expect(r.body, contains('noindex'));
    });
  }

  test('Google is offered when its secrets are set', () async {
    final methods = await anonymous().collection('users').listAuthMethods();
    expect(methods.oauth2.providers.map((p) => p.name), contains('google'));
  });

  test(
    "deleting parent A removes all of A's server data, not B's (ACC-07)",
    () async {
      final a = await Parent.signUp('del-a');
      final b = await Parent.signUp('del-b');
      final aData = await ChildData.create(a);
      final bData = await ChildData.create(b);
      await a.pb.collection('users').delete(a.id);

      final su = await superuser();
      final c = aData.child.id;
      expect(
        (await su.collection('children').getList(filter: 'owner = "${a.id}"'))
            .items,
        isEmpty,
      );
      for (final name in aData.perChild.keys) {
        expect(
          (await su.collection(name).getList(filter: 'child = "$c"')).items,
          isEmpty,
          reason: name,
        );
      }
      expect(await statusOf(() => su.collection('users').getOne(a.id)), 404);

      await su.collection('children').getOne(bData.child.id);
      for (final MapEntry(key: name, value: r) in bData.perChild.entries) {
        await su.collection(name).getOne(r.id);
      }
    },
  );
}
