// FEAT-31 AC-2..AC-6 (WEM-02..06): the weekly progress email
// (pb_hooks/weekly_email.pb.js, lib/weekly.js). Time is driven through the
// admin route `POST /api/nn/admin/weekly-email {now, user, preview}`, which
// runs the same job as the hourly cron. Mail goes to the SMTP sink on
// PB_SMTP_PORT (server/test/run.sh). The turn-off POST is rate limited per
// client IP (X-Real-IP, trusted proxy), so each call sends its own IP unless
// a test means to hit the limit.
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:number_ninja_server_test/fixtures.dart';
import 'package:number_ninja_server_test/mail_sink.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:test/test.dart';

final smtpPort = int.parse(Platform.environment['PB_SMTP_PORT'] ?? '2526');
final _rnd = DateTime.now().microsecondsSinceEpoch;
var _ip = 0;
String freshIp() {
  _ip++;
  return '10.${(_rnd >> 9) % 250}.${_ip ~/ 250}.${_ip % 250 + 1}';
}

// The reported week is Mon 16 – Sun 22 Nov 2026 in Singapore (tz 480):
// local Monday 23 Nov 08:00 is 00:00 UTC.
const mondayEight = '2026-11-23T00:00:00Z';

Future<Map<String, dynamic>> admin(Map<String, dynamic> body) async =>
    Map<String, dynamic>.from(
      await (await superuser()).send(
        '/api/nn/admin/weekly-email',
        method: 'POST',
        body: body,
      ) as Map,
    );

/// A verified parent with Plus and the switch on at [tz].
Future<Parent> family({int tz = 480, bool plus = true}) async {
  final p = await Parent.signUp('weekly');
  if (plus) await grant(p.id, expiresAt: forever);
  await p.pb
      .collection('users')
      .update(p.id, body: {'weekly_email': true, 'weekly_email_tz': tz});
  return p;
}

Future<RecordModel> child(Parent p, String nickname) => p.pb
    .collection('children')
    .create(body: {'owner': p.id, 'nickname': nickname, 'school_year': 2});

Future<void> usage(String child, String day, int seconds) async =>
    (await superuser())
        .collection('daily_usage')
        .create(
          body: {
            'child': child,
            'day': day,
            'device_id': uniq('device'),
            'seconds_used': seconds,
          },
        );

Future<String> round(
  String child,
  String finishedAt, {
  String kind = 'normal',
}) async {
  final uuid = uniq('round');
  await (await superuser())
      .collection('rounds')
      .create(
        body: {
          ...roundBody(child, uuid),
          'kind': kind,
          'topic_id': kind == 'revision' ? 'mixed' : 'p1.money',
          'started_at': finishedAt,
          'finished_at': finishedAt,
        },
      );
  return uuid;
}

Future<void> attempts(
  String child,
  String roundUuid,
  String questionId,
  int n,
  int right,
  String at,
) async {
  final su = await superuser();
  for (var i = 0; i < n; i++) {
    await su
        .collection('attempts')
        .create(
          body: {
            ...attemptBody(child, roundUuid),
            'question_id': questionId,
            'correct': i < right,
            'answered_at': at,
          },
        );
  }
}

Future<void> badge(String child, String id, String at) async =>
    (await superuser())
        .collection('badges')
        .create(body: {'child': child, 'badge_id': id, 'earned_at': at});

/// One practice record inside the week, so the email isn't empty.
Future<void> somePractice(String child, {String day = '2026-11-18'}) =>
    usage(child, day, 300);

Future<List<RecordModel>> logRows(String userId) async => (await superuser())
    .collection('weekly_emails')
    .getFullList(filter: 'user = "$userId"');

Future<void> settle() =>
    Future<void>.delayed(const Duration(milliseconds: 800));

void main() {
  late MailSink sink;
  setUpAll(() async => sink = await MailSink.start(smtpPort));
  tearDownAll(() => sink.close());

  List<Mail> mailTo(String email) =>
      sink.mails.where((m) => m.to.contains(email)).toList();

  group('content', () {
    late Parent p;
    setUpAll(() async {
      p = await family();
      final mei = (await child(p, 'Mei')).id;
      await child(p, '<b>Kai</b>'); // idle sibling; nickname must be escaped
      await usage(mei, '2026-11-16', 600);
      await usage(mei, '2026-11-18', 3000);
      await usage(mei, '2026-11-18', 720); // a second device, same day
      await usage(mei, '2026-11-23', 999); // next week
      await usage(mei, '2026-11-15', 999); // week before
      final r1 = await round(mei, '2026-11-16 03:00:00.000Z');
      await round(mei, '2026-11-19 03:00:00.000Z');
      final rev = await round(
        mei,
        '2026-11-21 03:00:00.000Z',
        kind: 'revision',
      );
      // Sunday 23:59:59 local the week before, and next Monday 00:00 local.
      final before = await round(mei, '2026-11-15 15:59:59.000Z');
      await round(mei, '2026-11-22 16:00:00.000Z');
      await attempts(
        mei,
        r1,
        'p1.money.coins.001',
        8,
        5,
        '2026-11-16 03:01:00.000Z',
      );
      await attempts(
        mei,
        rev,
        'p2.time.clock.002',
        6,
        4,
        '2026-11-21 03:01:00.000Z',
      );
      await attempts(
        mei,
        rev,
        'p2.times.x3.003',
        10,
        10,
        '2026-11-21 03:02:00.000Z',
      );
      await attempts(
        mei,
        before,
        'p1.money.coins.004',
        10,
        8,
        '2026-11-15 15:59:59.000Z',
      );
      await attempts(
        mei,
        before,
        'p1.money.coins.005',
        3,
        0,
        '2026-11-22 16:00:00.000Z',
      );
      await badge(mei, 'perfect-10', '2026-11-17 01:00:00.000Z');
      await badge(mei, 'streak-3', '2026-11-18 01:00:00.000Z');
      await badge(mei, 'first-round', '2026-11-14 01:00:00.000Z');
    });

    test('AC-4: preview shows each child\'s week, counts only the week, '
        'escapes nicknames, and sends and logs nothing', () async {
      final before = sink.mails.length;
      final r = await admin({
        'now': mondayEight,
        'user': p.id,
        'preview': true,
      });
      final html = r['html'] as String;
      expect(r['subject'], "BrainBubblz: your children's week (16–22 Nov)");
      expect(r['empty'], isFalse);
      expect(r['children'], 2);
      expect(
        html,
        contains('<h2 style="font-size:18px;margin:20px 0 6px">Mei</h2>'),
      );
      expect(html, contains('Practised 1 h 12 min on 2 days'));
      expect(html, contains('3 rounds (1 revision)'));
      expect(html, contains('24 questions, 79% right (80% the week before)'));
      expect(html, contains('Topics to practise: Money (63%), Time (67%)'));
      expect(html, contains('New badges: Perfect 10, 3-Day Streak'));
      expect(html, contains('&lt;b&gt;Kai&lt;/b&gt;'));
      expect(html, isNot(contains('<b>Kai')));
      expect(html, contains('No practice this week.'));
      expect(
        html,
        contains(
          'https://api.example.test/api/nn/weekly-email/off?u=${p.id}&amp;t=',
        ),
      );
      expect(html, isNot(contains('<img')));
      await settle();
      expect(sink.mails.length, before);
      expect(await logRows(p.id), isEmpty);
    });

    test('AC-6: the admin route refuses parents and guests', () async {
      for (final pb in [p.pb, anonymous()]) {
        expect(
          await statusOf(
            () => pb.send(
              '/api/nn/admin/weekly-email',
              method: 'POST',
              body: {'now': mondayEight, 'user': p.id, 'preview': true},
            ),
          ),
          anyOf(401, 403),
        );
      }
    });
  });

  group('when it is sent', () {
    test(
      'AC-2: not before Monday 08:00 local, then once, never twice',
      () async {
        final p = await family();
        await somePractice((await child(p, 'Mei')).id);
        expect(await admin({'now': '2026-11-22T23:59:00Z', 'user': p.id}), {
          'sent': 0,
          'skipped': 0,
          'failed': 0,
          'notDue': 1,
        });
        expect(await admin({'now': mondayEight, 'user': p.id}), {
          'sent': 1,
          'skipped': 0,
          'failed': 0,
          'notDue': 0,
        });
        await settle();
        final mails = mailTo(p.email);
        expect(mails, hasLength(1));
        expect(mails.single.text, contains('Monday to Sunday, 16'));
        expect(mails.single.text, contains('>Mei</h2>'));
        final rows = await logRows(p.id);
        expect(rows.single.get<String>('week'), '2026-11-16');
        expect(rows.single.get<String>('status'), 'sent');
        expect(
          (await admin({'now': '2026-11-23T05:00:00Z', 'user': p.id}))['sent'],
          0,
        );
        await settle();
        expect(mailTo(p.email), hasLength(1));
      },
    );

    test('AC-2: a week not sent by Wednesday 08:00 local is dropped', () async {
      final p = await family();
      await somePractice((await child(p, 'Mei')).id);
      expect(
        (await admin({
          'now': '2026-11-24T23:59:00Z',
          'user': p.id,
          'preview': false,
        }))['sent'],
        1,
        reason: 'Tuesday night still catches up',
      );
      final q = await family();
      await somePractice((await child(q, 'Mei')).id);
      expect(
        (await admin({'now': '2026-11-25T00:00:00Z', 'user': q.id}))['notDue'],
        1,
      );
    });

    test('AC-2: a failed send logs nothing and the next run sends', () async {
      final p = await family();
      await somePractice((await child(p, 'Mei')).id);
      await sink.close();
      try {
        expect((await admin({'now': mondayEight, 'user': p.id}))['failed'], 1);
        expect(await logRows(p.id), isEmpty);
      } finally {
        sink = await MailSink.start(smtpPort);
      }
      expect(
        (await admin({'now': '2026-11-23T01:07:00Z', 'user': p.id}))['sent'],
        1,
      );
      await settle();
      expect(mailTo(p.email), hasLength(1));
    });

    test('AC-3: switch off, unverified or no Plus get nothing; an idle '
        'family is skipped', () async {
      final off = await family();
      await somePractice((await child(off, 'Mei')).id);
      await off.pb
          .collection('users')
          .update(off.id, body: {'weekly_email': false});
      final unverified = await family();
      await somePractice((await child(unverified, 'Mei')).id);
      await (await superuser())
          .collection('users')
          .update(unverified.id, body: {'verified': false});
      final free = await family(plus: false);
      await grant(free.id, expiresAt: pbDateIn(const Duration(days: -1)));
      await somePractice((await child(free, 'Mei')).id);
      final idle = await family();
      await child(idle, 'Mei');
      await somePractice((await child(idle, 'Kai')).id, day: '2026-11-23');

      for (final u in [off, unverified]) {
        expect((await admin({'now': mondayEight, 'user': u.id}))['sent'], 0);
      }
      expect((await admin({'now': mondayEight, 'user': free.id}))['notDue'], 1);
      expect(
        (await admin({'now': mondayEight, 'user': idle.id}))['skipped'],
        1,
      );
      expect((await logRows(idle.id)).single.get<String>('status'), 'skipped');
      await settle();
      for (final u in [off, unverified, free, idle]) {
        expect(mailTo(u.email), isEmpty);
      }
    });

    test(
      "AC-3: a family at tz -300 gets it at their own Monday 08:00",
      () async {
        final p = await family(tz: -300);
        await somePractice((await child(p, 'Ana')).id, day: '2026-11-20');
        expect((await admin({'now': mondayEight, 'user': p.id}))['notDue'], 1);
        expect(
          (await admin({
            'now': '2026-11-23T12:59:00Z',
            'user': p.id,
          }))['notDue'],
          1,
        );
        expect(
          (await admin({'now': '2026-11-23T13:00:00Z', 'user': p.id}))['sent'],
          1,
        );
        expect((await logRows(p.id)).single.get<String>('week'), '2026-11-16');
      },
    );
  });

  group('turn-off link', () {
    late Parent p;
    late Uri link;
    setUpAll(() async {
      p = await family();
      await somePractice((await child(p, 'Mei')).id);
      await admin({'now': mondayEight, 'user': p.id});
      await settle();
      final mail = mailTo(p.email).single;
      expect(
        mail.raw,
        contains('List-Unsubscribe-Post: List-Unsubscribe=One-Click'),
      );
      final header = RegExp(
        r'List-Unsubscribe: <https://api\.example\.test(/api/nn/weekly-email/off\?u=[^&>]+&t=[A-Za-z0-9]{32})>',
      ).firstMatch(mail.raw);
      expect(header, isNotNull, reason: mail.raw);
      link = Uri.parse('$baseUrl${header![1]}');
      expect(mail.text, contains('turn off weekly emails'));
    });

    Future<bool> on() async =>
        (await (await superuser()).collection('users').getOne(p.id))
            .get<bool>('weekly_email');

    Future<http.Response> post(Uri uri, {String? ip}) =>
        http.post(uri, headers: {'X-Real-IP': ip ?? freshIp()});

    test('AC-5: GET only shows the button; a wrong token or user changes '
        'nothing; the right link turns it off', () async {
      final page = await http.get(link);
      expect(page.statusCode, 200);
      expect(page.body, contains('<form method="post">'));
      expect(await on(), isTrue);

      final token = link.queryParameters['t']!;
      final wrong = link.replace(
        queryParameters: {
          'u': p.id,
          't': token.replaceRange(0, 1, token[0] == 'a' ? 'b' : 'a'),
        },
      );
      expect((await post(wrong)).statusCode, 400);
      final other = await family();
      final otherUser = link.replace(
        queryParameters: {'u': other.id, 't': token},
      );
      expect((await post(otherUser)).statusCode, 400);
      expect(await on(), isTrue);

      final done = await post(link);
      expect(done.statusCode, 200);
      expect(done.body, contains('Weekly emails are off'));
      expect(await on(), isFalse);
      expect(
        (await other.pb.collection('users').getOne(other.id))
            .get<bool>('weekly_email'),
        isTrue,
      );
    });

    test('AC-5: turn-off posts are rate limited', () async {
      final ip = freshIp();
      final codes = [
        for (var i = 0; i < 11; i++) (await post(link, ip: ip)).statusCode,
      ];
      expect(codes.take(10), everyElement(isNot(429)));
      expect(codes.last, 429);
    });
  });
}
