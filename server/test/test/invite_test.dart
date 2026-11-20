// FEAT-36 AC-2..AC-6 (INV-02..INV-05): redeeming invitation codes and the
// superuser endpoint that makes them. Needs the main PocketBase of
// server/test/run.sh (mail goes to the sink on PB_SMTP_PORT).
//
// Redeem calls are rate limited per client IP (IC-5: 5 per 60 s). PocketBase
// takes the client IP from X-Real-IP (trustedProxy, FEAT-12), so each call
// sends its own random IP unless a test means to hit the limit.
import 'dart:convert';
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
  return '10.${(_rnd >> 8) % 250}.${_ip ~/ 250}.${_ip % 250 + 1}';
}

/// POST /api/nn/invite/redeem as [token] (none = a guest).
Future<http.Response> redeem(String? token, String code, {String? ip}) =>
    http.post(
      Uri.parse('$baseUrl/api/nn/invite/redeem'),
      headers: {
        'Content-Type': 'application/json',
        'X-Real-IP': ip ?? freshIp(),
        'Authorization': ?token,
      },
      body: jsonEncode({'code': code}),
    );

Map<String, dynamic> json(http.Response r) =>
    jsonDecode(r.body) as Map<String, dynamic>;

/// Expects a 400 with [reason].
Future<void> fails(Parent p, String code, String reason) async {
  final r = await redeem(p.pb.authStore.token, code);
  expect(r.statusCode, 400, reason: r.body);
  expect(json(r)['reason'], reason);
}

/// Calendar months in UTC, day clamped (IC-4), as the server does it.
DateTime addMonths(DateTime d, int months) {
  final last = DateTime.utc(d.year, d.month + months + 1, 0).day;
  return DateTime.utc(
    d.year,
    d.month + months,
    d.day < last ? d.day : last,
    d.hour,
    d.minute,
    d.second,
    d.millisecond,
  );
}

DateTime pbParse(String s) => DateTime.parse(s.replaceFirst(' ', 'T'));
String pbFormat(DateTime d) =>
    d.toUtc().toIso8601String().replaceFirst('T', ' ');

Future<RecordModel> reload(RecordModel code) async =>
    (await superuser()).collection('invite_codes').getOne(code.id);

Future<List<RecordModel>> redemptions(String userId) async =>
    (await superuser())
        .collection('invite_redemptions')
        .getFullList(filter: 'user = "$userId"');

Future<List<RecordModel>> entitlements(String userId) async =>
    (await superuser())
        .collection('entitlements')
        .getFullList(filter: 'user = "$userId"');

void main() {
  group('redeem', () {
    test('a verified parent with no Plus gets 12 months (AC-2)', () async {
      final p = await Parent.signUp('invite-ok');
      final code = await inviteCode(note: 'school friends');
      final raw = code.get<String>('code').toLowerCase();
      final typed = ' ${raw.substring(0, 4)} - ${raw.substring(4)} ';
      final before = DateTime.now().toUtc();
      final r = await redeem(p.pb.authStore.token, typed);
      final after = DateTime.now().toUtc();
      expect(r.statusCode, 200, reason: r.body);
      final body = json(r);
      expect(body['plus'], isTrue);
      expect(body['source'], 'invite');
      final until = pbParse(body['until'] as String);
      expect(
        until.isBefore(addMonths(before, 12)),
        isFalse,
        reason: '$until vs ${addMonths(before, 12)}',
      );
      expect(until.isAfter(addMonths(after, 12)), isFalse);

      expect((await reload(code)).get<int>('uses'), 1);
      final reds = await redemptions(p.id);
      expect(reds, hasLength(1));
      expect(reds.single.get<String>('plus_until'), body['until']);
      final ent = await p.pb.send<Map<String, dynamic>>('/api/nn/entitlement');
      expect(ent['plus'], isTrue);
      expect(ent['until'], body['until']);
      final record = (await entitlements(p.id)).single;
      expect(record.get<String>('note'), contains('school friends'));

      final su = await superuser();
      final all = (await su.collection('banks').getList(perPage: 1)).totalItems;
      final seen = (await p.pb.collection('banks').getList(perPage: 1));
      expect(seen.totalItems, all, reason: 'Plus opens the bank (BNK-13)');
    });

    test('failures write nothing (AC-3)', () async {
      final guest = await redeem(null, randomCode());
      expect(guest.statusCode, 401);

      final email = '${uniq('unverified')}@test.local';
      const pw = 'parent-password-1';
      final un = PocketBase(baseUrl);
      await un
          .collection('users')
          .create(
            body: {'email': email, 'password': pw, 'passwordConfirm': pw},
          );
      await signIn(un, 'users', email, pw);
      final code = await inviteCode(maxUses: 2);
      final unverified = await redeem(un.authStore.token, code.get('code'));
      expect(unverified.statusCode, 403);
      expect(json(unverified)['reason'], 'unverified');

      final p = await Parent.signUp('invite-fail');
      await fails(p, randomCode(), 'not_found');
      await fails(p, 'ABC', 'not_found');
      final revoked = await inviteCode(revoked: true);
      await fails(p, revoked.get('code'), 'not_found');
      final expired = await inviteCode(
        redeemBy: pbDateIn(const Duration(minutes: -1)),
      );
      await fails(p, expired.get('code'), 'expired');

      final f1 = await Parent.signUp('invite-f1');
      final f2 = await Parent.signUp('invite-f2');
      for (final f in [f1, f2]) {
        expect(
          (await redeem(f.pb.authStore.token, code.get('code'))).statusCode,
          200,
        );
      }
      await fails(p, code.get('code'), 'used_up');
      expect((await reload(code)).get<int>('uses'), 2);

      final once = await inviteCode();
      expect(
        (await redeem(f1.pb.authStore.token, once.get('code'))).statusCode,
        200,
      );
      await fails(f1, once.get('code'), 'already_used');
      expect((await reload(once)).get<int>('uses'), 1);

      final gift = await Parent.signUp('invite-gift');
      await grant(gift.id, expiresAt: forever);
      final store = await Parent.signUp('invite-store');
      await grant(store.id, source: 'google_play');
      for (final f in [gift, store]) {
        await fails(f, once.get('code'), 'already_plus');
        expect(await redemptions(f.id), isEmpty);
        expect(await entitlements(f.id), hasLength(1));
      }
      expect((await reload(once)).get<int>('uses'), 1);
      for (final c in [revoked, expired]) {
        expect((await reload(c)).get<int>('uses'), 0);
      }
      expect(await redemptions(p.id), isEmpty);
      expect(await entitlements(p.id), isEmpty);
    });

    test(
      'a second code extends an invitation, never a past one (AC-4)',
      () async {
        final p = await Parent.signUp('invite-extend');
        final oldEnd = pbDateIn(const Duration(days: 60));
        await grant(p.id, source: 'invite', expiresAt: oldEnd);
        final three = await inviteCode(months: 3);
        final r = await redeem(p.pb.authStore.token, three.get('code'));
        expect(r.statusCode, 200, reason: r.body);
        expect(json(r)['until'], pbFormat(addMonths(pbParse(oldEnd), 3)));

        final q = await Parent.signUp('invite-lapsed');
        await grant(
          q.id,
          source: 'invite',
          status: 'expired',
          expiresAt: pbDateIn(const Duration(days: -30)),
        );
        final two = await inviteCode(months: 2);
        final before = DateTime.now().toUtc();
        final r2 = await redeem(q.pb.authStore.token, two.get('code'));
        final after = DateTime.now().toUtc();
        expect(r2.statusCode, 200, reason: r2.body);
        final until = pbParse(json(r2)['until'] as String);
        expect(until.isBefore(addMonths(before, 2)), isFalse);
        expect(until.isAfter(addMonths(after, 2)), isFalse);
        expect(
          (await entitlements(q.id)).single.get<String>('status'),
          'active',
        );

        final c = await Parent.signUp('invite-clamp');
        await grant(
          c.id,
          source: 'invite',
          expiresAt: '2099-01-31 12:00:00.000Z',
        );
        final one = await inviteCode(months: 1);
        final r3 = await redeem(c.pb.authStore.token, one.get('code'));
        expect(json(r3)['until'], '2099-02-28 12:00:00.000Z');
      },
    );

    test('the 6th call in 60 s from one client gets 429 (AC-5)', () async {
      final p = await Parent.signUp('invite-limit');
      final ip = freshIp();
      final codes = <int>[];
      for (var i = 0; i < 6; i++) {
        codes.add(
          (await redeem(p.pb.authStore.token, 'WRONGXYZ', ip: ip)).statusCode,
        );
      }
      expect(codes.take(5), everyElement(400));
      expect(codes.last, 429);
    });
  });

  group('admin', () {
    late MailSink sink;
    setUpAll(() async => sink = await MailSink.start(smtpPort));
    tearDownAll(() => sink.close());

    Future<http.Response> make(String? token, Map<String, Object?> body) =>
        http.post(
          Uri.parse('$baseUrl/api/nn/admin/invites'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': ?token,
          },
          body: jsonEncode(body),
        );

    test('only a superuser makes codes (AC-6)', () async {
      final p = await Parent.signUp('invite-admin');
      expect((await make(null, {'count': 1})).statusCode, 401);
      expect(
        (await make(p.pb.authStore.token, {'count': 1})).statusCode,
        anyOf(401, 403),
      );
      final su = await superuser();
      expect((await make(su.authStore.token, {'count': 0})).statusCode, 400);
      expect((await make(su.authStore.token, {'count': 101})).statusCode, 400);

      final note = uniq('batch');
      final before = DateTime.now().toUtc();
      final r = await make(su.authStore.token, {
        'count': 10,
        'months': 6,
        'max_uses': 3,
        'redeem_by_days': 30,
        'note': note,
      });
      expect(r.statusCode, 200, reason: r.body);
      final body = json(r);
      final codes = (body['codes'] as List).cast<String>();
      expect(codes, hasLength(10));
      expect(codes.toSet(), hasLength(10));
      for (final c in codes) {
        expect(c, matches(RegExp('^[$inviteAlphabet]{8}\$')));
      }
      final rows = await su
          .collection('invite_codes')
          .getFullList(filter: 'note = "$note"');
      expect(rows.map((r) => r.get<String>('code')).toSet(), codes.toSet());
      final by = before.add(const Duration(days: 30));
      for (final row in rows) {
        expect(row.get<int>('months'), 6);
        expect(row.get<int>('max_uses'), 3);
        expect(row.get<int>('uses'), 0);
        final d = pbParse(row.get<String>('redeem_by'));
        expect(d.difference(by).inSeconds.abs(), lessThan(60));
      }
    });

    test('with send_to the codes go by email only (AC-6)', () async {
      final su = await superuser();
      final to = '${uniq('ken')}@test.local';
      final note = uniq('mailed');
      final before = sink.mails.length;
      final r = await make(su.authStore.token, {
        'count': 10,
        'note': note,
        'send_to': to,
      });
      expect(r.statusCode, 200, reason: r.body);
      expect(json(r)['emailed'], isTrue);
      expect(json(r).containsKey('codes'), isFalse);
      final rows = await su
          .collection('invite_codes')
          .getFullList(filter: 'note = "$note"');
      expect(rows, hasLength(10));
      for (final row in rows) {
        expect(row.get<int>('months'), 12);
        expect(row.get<int>('max_uses'), 5);
        expect(r.body, isNot(contains(row.get<String>('code'))));
      }
      final mail = await sink.waitFor(to, after: before);
      for (final row in rows) {
        final c = row.get<String>('code');
        expect(mail.text, contains('${c.substring(0, 4)}-${c.substring(4)}'));
      }
      expect(
        sink.mails.skip(before).where((m) => m.to.contains(to)),
        hasLength(1),
      );
    });
  });
}
