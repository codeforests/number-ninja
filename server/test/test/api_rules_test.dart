// FEAT-12 AC-2 (NFR-13): API rules keep each family's records to itself.
// Needs a running PocketBase: server/test/run.sh starts one.
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

  group('banks', () {
    test('anyone lists banks; only a superuser creates one', () async {
      final body = {'version': uniq('bank'), 'format': 1, 'min_app_build': 1};
      for (final pb in [anon, a.pb]) {
        expect(
          await statusOf(() => pb.collection('banks').create(body: body)),
          403,
        );
      }
      final su = await superuser();
      final bank = await su.collection('banks').create(body: body);
      expect(
        (await anon.collection('banks').getFullList()).map((r) => r.id),
        contains(bank.id),
      );
      expect(
        await statusOf(() => a.pb.collection('banks').delete(bank.id)),
        403,
      );
      expect(
        await statusOf(() => su.collection('banks').create(body: body)),
        400,
        reason: 'version is unique',
      );
    });
  });
}
