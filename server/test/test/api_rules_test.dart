// FEAT-12 AC-2 (NFR-13): API rules keep each family's records to itself.
// Needs a running PocketBase: server/test/run.sh starts one.
import 'package:http/http.dart' as http;
import 'package:number_ninja_server_test/fixtures.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:test/test.dart';

void main() {
  late Parent a;
  late Parent b;
  late ChildData data;
  late RecordModel bChild;
  final anon = anonymous();

  setUpAll(() async {
    a = await Parent.signUp('a');
    b = await Parent.signUp('b');
    data = await ChildData.create(a);
    bChild = await b.pb
        .collection('children')
        .create(body: {'owner': b.id, 'nickname': 'Bo'});
  });

  final strangers = <String, PocketBase Function()>{
    'parent B': () => b.pb,
    'anonymous': () => anon,
  };

  group('strangers', () {
    for (final MapEntry(key: who, value: pbOf) in strangers.entries) {
      test("$who can't list or view A's child", () async {
        final pb = pbOf();
        expect(
          (await pb.collection('children').getFullList()).map((r) => r.id),
          isNot(contains(data.child.id)),
        );
        expect(
          await statusOf(() => pb.collection('children').getOne(data.child.id)),
          404,
        );
        expect(
          await statusOf(
            () => pb
                .collection('children')
                .update(data.child.id, body: {'nickname': 'X'}),
          ),
          404,
        );
      });

      for (final name in ['rounds', 'attempts', 'badges', 'daily_usage']) {
        test("$who can't list, view, update or create A's $name", () async {
          final pb = pbOf();
          final record = data.perChild[name]!;
          final listed = await pb.collection(name).getFullList();
          expect(listed.map((r) => r.id), isNot(contains(record.id)));
          expect(
            await statusOf(() => pb.collection(name).getOne(record.id)),
            404,
          );
          expect(
            await statusOf(
              () => pb
                  .collection(name)
                  .update(record.id, body: {'device_id': 'x'}),
            ),
            anyOf(403, 404),
          );
          expect(
            await statusOf(
              () => pb
                  .collection(name)
                  .create(body: bodyFor(name, data.child.id)),
            ),
            anyOf(400, 403),
          );
        });
      }
    }

    test("anonymous can't read users; B can't read A's user", () async {
      expect(await anon.collection('users').getFullList(), isEmpty);
      expect(await statusOf(() => b.pb.collection('users').getOne(a.id)), 404);
    });
  });

  group('owner', () {
    test('A lists and views all their own records', () async {
      expect(
        (await a.pb.collection('children').getOne(data.child.id)).id,
        data.child.id,
      );
      for (final MapEntry(key: name, value: record) in data.perChild.entries) {
        final listed = await a.pb.collection(name).getFullList();
        expect(listed.map((r) => r.id), contains(record.id), reason: name);
        expect((await a.pb.collection(name).getOne(record.id)).id, record.id);
      }
    });

    test('A updates a round, a badge, usage and the child', () async {
      await a.pb.collection('rounds').update(data.round.id, body: {'stars': 3});
      await a.pb
          .collection('badges')
          .update(
            data.badge.id,
            body: {'earned_at': '2026-11-16 04:00:00.000Z'},
          );
      await a.pb
          .collection('daily_usage')
          .update(data.usage.id, body: {'seconds_used': 900});
      await a.pb
          .collection('children')
          .update(data.child.id, body: {'nickname': 'Mei Mei'});
    });

    test("A can't update or delete an attempt (append-only)", () async {
      expect(
        await statusOf(
          () => a.pb
              .collection('attempts')
              .update(data.attempt.id, body: {'correct': false}),
        ),
        403,
      );
      expect(
        await statusOf(
          () => a.pb.collection('attempts').delete(data.attempt.id),
        ),
        403,
      );
    });

    test('only a superuser deletes rounds, badges and usage', () async {
      for (final name in ['rounds', 'badges', 'daily_usage']) {
        expect(
          await statusOf(
            () => a.pb.collection(name).delete(data.perChild[name]!.id),
          ),
          403,
          reason: name,
        );
      }
      final su = await superuser();
      final spare = await a.pb
          .collection('rounds')
          .create(body: roundBody(data.child.id, uniq('round')));
      await su.collection('rounds').delete(spare.id);
    });

    test("A can't move a round to B's child", () async {
      expect(
        await statusOf(
          () => a.pb
              .collection('rounds')
              .update(data.round.id, body: {'child': bChild.id}),
        ),
        anyOf(400, 403, 404),
      );
      expect(
        (await a.pb.collection('rounds').getOne(data.round.id))
            .getStringValue('child'),
        data.child.id,
      );
    });

    test("A can't move their child to B", () async {
      expect(
        await statusOf(
          () => a.pb
              .collection('children')
              .update(data.child.id, body: {'owner': b.id}),
        ),
        anyOf(400, 403, 404),
      );
    });

    test("A can't create a child owned by B", () async {
      expect(
        await statusOf(
          () => a.pb
              .collection('children')
              .create(body: {'owner': b.id, 'nickname': 'X'}),
        ),
        anyOf(400, 403),
      );
    });

    test("anonymous can't create a child", () async {
      expect(
        await statusOf(
          () => anon
              .collection('children')
              .create(body: {'owner': a.id, 'nickname': 'X'}),
        ),
        anyOf(400, 403),
      );
    });

    test('a duplicate attempt uuid is rejected', () async {
      final body = attemptBody(data.child.id, uniq('round'))
        ..['uuid'] = data.attempt.getStringValue('uuid');
      expect(
        await statusOf(() => a.pb.collection('attempts').create(body: body)),
        400,
      );
    });

    test('a duplicate round uuid and badge per child are rejected', () async {
      final round = roundBody(data.child.id, data.round.getStringValue('uuid'));
      expect(
        await statusOf(() => a.pb.collection('rounds').create(body: round)),
        400,
      );
      expect(
        await statusOf(
          () => a.pb
              .collection('badges')
              .create(
                body: {'child': data.child.id, 'badge_id': 'first-round'},
              ),
        ),
        400,
      );
    });

    test(
      'deleting the user removes the child and its records (ACC-07)',
      () async {
        final c = await Parent.signUp('c');
        final cData = await ChildData.create(c);
        await c.pb.collection('users').delete(c.id);
        final su = await superuser();
        expect(
          await statusOf(
            () => su.collection('children').getOne(cData.child.id),
          ),
          404,
        );
        for (final MapEntry(key: name, value: r) in cData.perChild.entries) {
          expect(
            await statusOf(() => su.collection(name).getOne(r.id)),
            404,
            reason: name,
          );
        }
      },
    );
  });

  // FEAT-25 AC-8: siblings are several children of one owner.
  group('siblings', () {
    test('A creates and lists 2 children and writes records for each; the '
        'avatar is stored', () async {
      final mei = await ChildData.create(a);
      final leo = await ChildData.create(a);
      await a.pb
          .collection('children')
          .update(leo.child.id, body: {'nickname': 'Leo', 'avatar': 'frog'});
      final mine = await a.pb
          .collection('children')
          .getFullList(filter: 'owner = "${a.id}"');
      expect(mine.map((c) => c.id), containsAll([mei.child.id, leo.child.id]));
      final got = await a.pb.collection('children').getOne(leo.child.id);
      expect(got.getStringValue('avatar'), 'frog');
      for (final d in [mei, leo]) {
        final rounds = await a.pb
            .collection('rounds')
            .getFullList(filter: 'child = "${d.child.id}"');
        expect(rounds.map((r) => r.id), [d.round.id]);
      }
    });

    test("B can't read or write A's second child", () async {
      final leo = await ChildData.create(a);
      expect(
        await statusOf(() => b.pb.collection('children').getOne(leo.child.id)),
        404,
      );
      expect(
        await statusOf(
          () => b.pb
              .collection('children')
              .update(leo.child.id, body: {'nickname': 'X'}),
        ),
        404,
      );
      expect(
        await statusOf(
          () => b.pb
              .collection('rounds')
              .create(body: roundBody(leo.child.id, uniq('round'))),
        ),
        anyOf(400, 403),
      );
      expect(
        await statusOf(() => b.pb.collection('children').delete(leo.child.id)),
        404,
      );
    });

    test("deleting a child removes her records, not her sibling's", () async {
      final mei = await ChildData.create(a);
      final leo = await ChildData.create(a);
      await a.pb.collection('children').delete(leo.child.id);
      final su = await superuser();
      for (final MapEntry(key: name, value: r) in leo.perChild.entries) {
        expect(
          await statusOf(() => su.collection(name).getOne(r.id)),
          404,
          reason: name,
        );
      }
      for (final MapEntry(key: name, value: r) in mei.perChild.entries) {
        expect((await su.collection(name).getOne(r.id)).id, r.id);
      }
    });
  });

  // FEAT-29 AC-2, AC-3 (BNK-13): the server bank needs active Plus.
  group('banks', () {
    test('only a superuser creates a bank', () async {
      // FEAT-15: version is a number; a high one no publish test uses.
      final body = {
        'version': 900000 + DateTime.now().microsecond,
        'format': 1,
        'min_app_build': 1,
      };
      for (final pb in [anon, a.pb]) {
        expect(
          await statusOf(() => pb.collection('banks').create(body: body)),
          403,
        );
      }
      final su = await superuser();
      final bank = await su.collection('banks').create(body: body);
      expect(
        await statusOf(() => a.pb.collection('banks').delete(bank.id)),
        403,
      );
      expect(
        await statusOf(() => su.collection('banks').create(body: body)),
        400,
        reason: 'version is unique',
      );
      await su.collection('banks').delete(bank.id);
    });

    test('a guest and a free parent list none; Plus lists and downloads '
        'with a file token; expiry ends it', () async {
      final su = await superuser();
      final bank = await su
          .collection('banks')
          .create(
            body: {
              'version': 800000 + DateTime.now().microsecond,
              'format': 1,
              'min_app_build': 1,
              'sha256': 'x',
            },
            files: [
              http.MultipartFile.fromString(
                'file',
                '{"bank":1}',
                filename: 'bank.json',
              ),
            ],
          );
      addTearDown(() => su.collection('banks').delete(bank.id));
      final p = await Parent.signUp('plus');
      Future<List<String>> ids(PocketBase pb) async => [
        for (final r in await pb.collection('banks').getFullList()) r.id,
      ];

      expect(await ids(anon), isNot(contains(bank.id)));
      expect(await ids(p.pb), isEmpty, reason: 'no entitlement');

      final e = await grant(p.id);
      expect(await ids(p.pb), contains(bank.id));
      final file = bank.getStringValue('file');
      final token = await p.pb.files.getToken();
      final withToken = await http.get(
        p.pb.files.getURL(bank, file, token: token),
      );
      expect(withToken.statusCode, 200);
      expect(withToken.body, '{"bank":1}');
      final bare = await http.get(p.pb.files.getURL(bank, file));
      expect(bare.statusCode, isNot(200), reason: 'the file is protected');
      final freeParent = await Parent.signUp('free');
      final freeToken = await freeParent.pb.files.getToken();
      final free = await http.get(
        freeParent.pb.files.getURL(bank, file, token: freeToken),
      );
      expect(free.statusCode, isNot(200), reason: "a free parent's token");

      await su
          .collection('entitlements')
          .update(
            e.id,
            body: {'expires_at': pbDateIn(const Duration(minutes: -1))},
          );
      expect(await ids(p.pb), isEmpty, reason: 'expired');
    });

    test("one parent's active record doesn't open the bank for another "
        '(AC-3)', () async {
      final su = await superuser();
      final bank = await su
          .collection('banks')
          .create(
            body: {
              'version': 700000 + DateTime.now().microsecond,
              'format': 1,
              'min_app_build': 1,
            },
          );
      addTearDown(() => su.collection('banks').delete(bank.id));
      final pa = await Parent.signUp('expired');
      final pb = await Parent.signUp('active');
      await grant(pa.id, expiresAt: pbDateIn(const Duration(days: -1)));
      await grant(pb.id);
      expect(await pa.pb.collection('banks').getFullList(), isEmpty);
      expect(
        (await pb.pb.collection('banks').getFullList()).map((r) => r.id),
        contains(bank.id),
      );
    });
  });

  // FEAT-29 AC-1 (ENT-01, ENT-02): own entitlements, read-only.
  group('entitlements', () {
    test('a parent reads only their own; a guest none', () async {
      final mine = await grant(a.id, source: 'invite');
      final theirs = await grant(b.id, source: 'invite');
      final listed = await a.pb.collection('entitlements').getFullList();
      expect(listed.map((r) => r.id), contains(mine.id));
      expect(listed.map((r) => r.id), isNot(contains(theirs.id)));
      expect(
        await statusOf(() => a.pb.collection('entitlements').getOne(theirs.id)),
        404,
      );
      expect(await anon.collection('entitlements').getFullList(), isEmpty);
      expect(
        await statusOf(() => anon.collection('entitlements').getOne(mine.id)),
        404,
      );
    });

    test(
      "parents can't create, update or delete one; a superuser can",
      () async {
        final mine = await grant(a.id, source: 'google_play');
        final body = {
          'user': a.id,
          'plan': 'plus',
          'source': 'app_store',
          'status': 'active',
          'expires_at': forever,
        };
        for (final pb in [a.pb, b.pb, anon]) {
          final c = pb.collection('entitlements');
          expect(await statusOf(() => c.create(body: body)), 403);
          expect(
            await statusOf(
              () => c.update(mine.id, body: {'expires_at': forever}),
            ),
            anyOf(403, 404),
          );
          expect(await statusOf(() => c.delete(mine.id)), anyOf(403, 404));
        }
        final su = (await superuser()).collection('entitlements');
        await su.update(mine.id, body: {'status': 'cancelled'});
        expect(
          await statusOf(
            () => su.create(body: {...body, 'source': 'google_play'}),
          ),
          400,
          reason: '(user, source) is unique',
        );
        await su.delete(mine.id);
      },
    );

    test("deleting the user deletes their entitlements", () async {
      final p = await Parent.signUp('gone');
      final e = await grant(p.id);
      final su = await superuser();
      await su.collection('users').delete(p.id);
      expect(
        await statusOf(() => su.collection('entitlements').getOne(e.id)),
        404,
      );
    });
  });

  // FEAT-24 AC-6 (CRS-06, NFR-13): create-only crash reports.
  group('crash_reports', () {
    Map<String, dynamic> report([Map<String, dynamic> over = const {}]) => {
      'signature': uniq('sig'),
      'app_version': '2.2.0+22',
      'bank_version': 3,
      'os': 'Android 14 (SDK 34)',
      'device': 'samsung SM-X200',
      'screen': '/quiz/:topicId',
      'error_type': 'StateError',
      'message': 'Bad state: x',
      'stack': '#0 f (a.dart:1)',
      'count': 1,
      ...over,
    };

    test('a guest and a signed-in parent create; only a superuser reads, '
        'changes or deletes', () async {
      final mine = await anon
          .collection('crash_reports')
          .create(body: report());
      await a.pb.collection('crash_reports').create(body: report());
      for (final pb in [anon, a.pb, b.pb]) {
        final col = pb.collection('crash_reports');
        expect(await statusOf(() => col.getList()), 403);
        expect(await statusOf(() => col.getOne(mine.id)), anyOf(403, 404));
        expect(
          await statusOf(() => col.update(mine.id, body: {'count': 2})),
          anyOf(403, 404),
        );
        expect(await statusOf(() => col.delete(mine.id)), anyOf(403, 404));
      }
      final su = await superuser();
      expect(
        (await su.collection('crash_reports').getOne(mine.id)).id,
        mine.id,
      );
      await su.collection('crash_reports').delete(mine.id);
    });

    test('oversized or malformed fields are refused', () async {
      final su = await superuser();
      final col = su.collection('crash_reports');
      for (final bad in <Map<String, dynamic>>[
        {'message': 'm' * 1001},
        {'stack': 's' * 8001},
        {'device': 'd' * 129},
        {'count': 0},
        {'count': 100001},
        {'signature': ''},
      ]) {
        expect(
          await statusOf(() => col.create(body: report(bad))),
          400,
          reason: '$bad',
        );
      }
    });

    test('the 11th create in 60 s from one IP gets 429', () async {
      final col = anonymous().collection('crash_reports');
      final codes = <int>[];
      for (var i = 0; i < 11; i++) {
        codes.add(await statusOf(() => col.create(body: report())));
      }
      // The earlier tests in this group spent part of the 10.
      expect(codes, contains(429));
      expect(codes.where((c) => c != 200 && c != 429), isEmpty);
      expect(codes.first, 200);
    });
  });

  // FEAT-36 AC-1 (INV-01, IC-2, IC-3): codes and redemptions are superuser only.
  group('invites', () {
    test("guests and parents can't read or write codes or redemptions; "
        'a superuser can', () async {
      final code = await inviteCode();
      final su = await superuser();
      final red = await su
          .collection('invite_redemptions')
          .create(
            body: {
              'code': code.id,
              'user': a.id,
              'plus_until': pbDateIn(const Duration(days: 365)),
            },
          );
      final bodies = {
        'invite_codes': {
          'code': randomCode(),
          'months': 12,
          'max_uses': 5,
          'redeem_by': forever,
        },
        'invite_redemptions': {
          'code': code.id,
          'user': b.id,
          'plus_until': forever,
        },
      };
      final ids = {'invite_codes': code.id, 'invite_redemptions': red.id};
      for (final pb in [a.pb, b.pb, anon]) {
        for (final name in bodies.keys) {
          final c = pb.collection(name);
          expect(
            await statusOf(() => c.getFullList()),
            anyOf(200, 403),
            reason: name,
          );
          final listed = await c.getFullList().catchError(
            (_) => <RecordModel>[],
          );
          expect(listed, isEmpty, reason: name);
          expect(await statusOf(() => c.getOne(ids[name]!)), anyOf(403, 404));
          expect(await statusOf(() => c.create(body: bodies[name]!)), 403);
          expect(
            await statusOf(() => c.update(ids[name]!, body: {'uses': 4})),
            anyOf(403, 404),
          );
          expect(await statusOf(() => c.delete(ids[name]!)), anyOf(403, 404));
        }
      }
      expect(
        (await su.collection('invite_codes').getOne(code.id))
            .get<String>('code'),
        code.get<String>('code'),
      );
      expect(
        await statusOf(() => inviteCode(code: code.get<String>('code'))),
        400,
        reason: 'code is unique',
      );
      expect(
        await statusOf(() => inviteCode(code: 'ABCD0OI1')),
        400,
        reason: 'only alphabet characters',
      );
      expect(
        await statusOf(
          () => su
              .collection('invite_redemptions')
              .create(
                body: {'code': code.id, 'user': a.id, 'plus_until': forever},
              ),
        ),
        400,
        reason: '(code, user) is unique',
      );
    });

    test('deleting a user deletes their redemptions, not the code', () async {
      final p = await Parent.signUp('gone-invite');
      final code = await inviteCode(uses: 1);
      final su = await superuser();
      final red = await su
          .collection('invite_redemptions')
          .create(body: {'code': code.id, 'user': p.id, 'plus_until': forever});
      await su.collection('users').delete(p.id);
      expect(
        await statusOf(
          () => su.collection('invite_redemptions').getOne(red.id),
        ),
        404,
      );
      final kept = await su.collection('invite_codes').getOne(code.id);
      expect(kept.get<int>('uses'), 1);
    });
  });

  group('weekly_email', () {
    test('a parent reads and changes only their own switch; the token '
        'never shows; the send log is closed to parents', () async {
      await a.pb
          .collection('users')
          .update(a.id, body: {'weekly_email': true, 'weekly_email_tz': 480});
      final own = await a.pb.collection('users').getOne(a.id);
      expect(own.get<bool>('weekly_email'), isTrue);
      expect(own.get<int>('weekly_email_tz'), 480);
      expect(own.data.containsKey('email_token'), isFalse);
      expect(
        await statusOf(
          () => b.pb
              .collection('users')
              .update(a.id, body: {'weekly_email': false}),
        ),
        404,
      );
      expect(
        await statusOf(
          () => a.pb
              .collection('users')
              .update(a.id, body: {'weekly_email_tz': 900}),
        ),
        400,
        reason: 'offset range',
      );
      final su = await superuser();
      await su
          .collection('users')
          .update(a.id, body: {'email_token': 'x' * 32});
      final again = await a.pb.collection('users').getOne(a.id);
      expect(again.data.containsKey('email_token'), isFalse);
      for (final pb in [a.pb, b.pb]) {
        final list = await pb.collection('users').getFullList();
        expect(list.every((r) => !r.data.containsKey('email_token')), isTrue);
      }
      final row = await su
          .collection('weekly_emails')
          .create(
            body: {
              'user': a.id,
              'week': '2026-11-16',
              'status': 'sent',
              'children': 1,
            },
          );
      for (final pb in [a.pb, b.pb, anon]) {
        final c = pb.collection('weekly_emails');
        final listed = await c.getFullList().catchError((_) => <RecordModel>[]);
        expect(listed, isEmpty);
        expect(await statusOf(() => c.getOne(row.id)), anyOf(403, 404));
        expect(
          await statusOf(
            () => c.create(
              body: {'user': a.id, 'week': '2026-11-23', 'status': 'sent'},
            ),
          ),
          403,
        );
        expect(
          await statusOf(() => c.update(row.id, body: {'children': 2})),
          anyOf(403, 404),
        );
        expect(await statusOf(() => c.delete(row.id)), anyOf(403, 404));
      }
      expect(
        await statusOf(
          () => su
              .collection('weekly_emails')
              .create(
                body: {'user': a.id, 'week': '2026-11-16', 'status': 'sent'},
              ),
        ),
        400,
        reason: 'one row per account and week',
      );
    });
  });
}
