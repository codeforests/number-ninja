/// FEAT-14 AC-6: the reset route and the batch API.
library;

import 'package:pocketbase/pocketbase.dart';
import 'package:test/test.dart';

import 'package:number_ninja_server_test/fixtures.dart';

Future<Map<String, dynamic>> reset(PocketBase pb, String child) async =>
    await pb.send<Map<String, dynamic>>(
      '/api/nn/children/$child/reset',
      method: 'POST',
    );

Future<int> count(PocketBase pb, String collection, String child) async =>
    (await pb
            .collection(collection)
            .getList(perPage: 1, filter: 'child = "$child"'))
        .totalItems;

void main() {
  late Parent a;
  late Parent b;
  late ChildData data;

  setUpAll(() async {
    a = await Parent.signUp('sync-a');
    b = await Parent.signUp('sync-b');
    data = await ChildData.create(a);
  });

  test("B can't reset A's child; anonymous gets 401", () async {
    final c = data.child.id;
    expect(await statusOf(() => reset(b.pb, c)), 403);
    expect(await statusOf(() => reset(anonymous(), c)), 401);
    expect(await count(a.pb, 'rounds', c), 1);
  });

  test(
    'reset clears rounds, attempts, badges; keeps usage; bumps epoch',
    () async {
      final c = data.child.id;
      final out = await reset(a.pb, c);
      expect(out['reset_epoch'], 1);
      expect(out['reset_at'], isNotEmpty);
      for (final name in ['rounds', 'attempts', 'badges']) {
        expect(await count(a.pb, name, c), 0, reason: name);
      }
      expect(await count(a.pb, 'daily_usage', c), 1);
      final child = await a.pb.collection('children').getOne(c);
      expect(child.getIntValue('reset_epoch'), 1);
      expect(child.getStringValue('reset_at'), out['reset_at']);
      expect((await reset(a.pb, c))['reset_epoch'], 2);
    },
  );

  test('a batch of 100 creates works; one duplicate uuid fails it', () async {
    final c = data.child.id;
    final batch = a.pb.createBatch();
    final uuids = [for (var i = 0; i < 100; i++) uniq('batch-round')];
    for (final u in uuids) {
      batch.collection('rounds').create(body: roundBody(c, u));
    }
    final results = await batch.send();
    expect(results, hasLength(100));
    expect(results.every((r) => r.status == 200), isTrue);

    final bad = a.pb.createBatch();
    final fresh = uniq('batch-round');
    bad.collection('rounds').create(body: roundBody(c, fresh));
    bad.collection('rounds').create(body: roundBody(c, uuids.first));
    expect(await statusOf(bad.send), 400);
    final found = await a.pb
        .collection('rounds')
        .getList(filter: 'uuid = "$fresh"');
    expect(found.totalItems, 0, reason: 'the whole batch rolls back');
  });
}
