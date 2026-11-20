import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/child_repository.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/sync_service.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/quiz.dart';

import '../fake_server_client.dart';

/// One tablet of a family (FEAT-25 AC-7): its own database, signed in to a
/// shared fake server.
class Tablet {
  Tablet(FakeSyncServer server) : db = AppDatabase(NativeDatabase.memory()) {
    client = FakeServerClient(
      ServerConfig.parse('https://api.example.test'),
      stored: const Account(id: 'u1', email: 'u1@example.test'),
      server: server,
    );
    family = ChildRepository(db, clock: clock);
    sync = SyncService(
      db: db,
      client: client,
      clock: clock,
      forgetSession: () {},
    );
  }

  final AppDatabase db;
  late final FakeServerClient client;
  late final ChildRepository family;
  late final SyncService sync;
  DateTime now = DateTime(2027, 1, 5, 9);

  DateTime clock() => now;

  void tick() => now = now.add(const Duration(minutes: 1));

  /// Names child 1 [nickname].
  Future<void> name1(String nickname) => ProfileRepository(
    db,
    clock: clock,
  ).save(ChildProfile(nickname: nickname, schoolYear: 2));

  Future<int> add(String nickname, {String avatar = 'owl'}) => family.add(
    ChildProfile(nickname: nickname, schoolYear: 1, avatar: avatar),
  );

  /// Child [child] plays a finished round of 2 answers in [topic].
  Future<void> play(int child, String topic) async {
    tick();
    final r = RoundRepository(db, clock: clock, childId: child);
    final id = await r.startRound(topic, 1);
    for (var i = 0; i < 2; i++) {
      await r.saveAttempt(
        id,
        AnswerResult(
          questionId: '$topic-q$i',
          given: '$i',
          correct: true,
          timeMs: 1000,
        ),
      );
    }
    await r.finishRound(id, score: 2, durationMs: 9000, stars: 1);
  }

  /// Child id by nickname (case as stored).
  Future<int> idOf(String nickname) async =>
      (await family.all()).firstWhere((c) => c.nickname == nickname).id;

  Future<List<String>> topicsOf(int child) async => [
    for (final r in await (db.select(
      db.rounds,
    )..where((r) => r.childId.equals(child))).get())
      r.topicId,
  ]..sort();

  Future<int> attemptsOf(int child) async => (await (db.select(
    db.attempts,
  )..where((a) => a.childId.equals(child))).get()).length;
}

void main() {
  late FakeSyncServer server;
  late Tablet one;
  late Tablet two;
  late int leo;

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() async {
    server = FakeSyncServer();
    one = Tablet(server);
    two = Tablet(server);
    two.now = DateTime(2027, 1, 5, 9, 30);
    await one.name1('Mia');
    leo = await one.add('Leo', avatar: 'frog');
    await one.play(1, 'p2.times');
    await one.play(leo, 'p1.bonds');
    await one.play(leo, 'p1.place');
    await one.sync.run();
  });
  tearDown(() async {
    await one.db.close();
    await two.db.close();
  });

  String remoteOf(String nickname) =>
      server.of('children').firstWhere((c) => c['nickname'] == nickname)['id']
          as String;

  List<Map<String, dynamic>> recordsOf(String collection, String nickname) => [
    for (final r in server.of(collection))
      if (r['child'] == remoteOf(nickname)) r,
  ];

  test('each child is her own server record with her own rounds', () {
    expect(server.of('children'), hasLength(2));
    expect(recordsOf('rounds', 'Mia'), hasLength(1));
    expect(recordsOf('rounds', 'Leo'), hasLength(2));
    expect(recordsOf('attempts', 'Leo'), hasLength(4));
    expect(
      server.of('children').firstWhere((c) => c['nickname'] == 'Leo')['avatar'],
      'frog',
    );
  });

  test('a second tablet with "mia": Mia merges, Leo is added with his rounds '
      '(AC-7)', () async {
    await two.name1('mia');
    await two.play(1, 'p2.money');
    await two.sync.run();

    expect(server.of('children'), hasLength(2));
    final kids = await two.family.all();
    expect(kids, hasLength(2));
    final twoLeo = kids.firstWhere((c) => c.nickname == 'Leo');
    expect((twoLeo.schoolYear, twoLeo.avatar), (1, 'frog'));
    expect(await two.topicsOf(twoLeo.id), ['p1.bonds', 'p1.place']);
    expect(await two.attemptsOf(twoLeo.id), 4);
    expect(await two.topicsOf(1), ['p2.money', 'p2.times']);
    expect(recordsOf('rounds', 'Leo'), hasLength(2));

    await one.sync.run();
    expect(await one.topicsOf(1), ['p2.money', 'p2.times']);
    expect(await one.topicsOf(leo), ['p1.bonds', 'p1.place']);
  });

  test("a field change syncs for that child only (AC-7)", () async {
    await two.sync.run();
    final twoLeo = await two.idOf('Leo');
    one.tick();
    await UsageRepository(
      one.db,
      clock: one.clock,
      childId: leo,
    ).setDailyLimit(40);
    await one.sync.run();
    await two.sync.run();
    expect((await two.db.child(twoLeo)).dailyLimitMin, 40);
    expect((await two.db.child(1)).dailyLimitMin, 20);
  });

  test("resetting Leo clears only Leo, on the server and the other tablet "
      '(AC-7, AD-11)', () async {
    await two.sync.run();
    final twoLeo = await two.idOf('Leo');
    server.time = DateTime(2027, 1, 5, 11).toUtc();
    await one.db.transaction(() async {
      await (one.db.delete(
        one.db.attempts,
      )..where((a) => a.childId.equals(leo))).go();
      await (one.db.delete(
        one.db.rounds,
      )..where((r) => r.childId.equals(leo))).go();
    });
    await one.sync.markPendingReset(leo);
    await one.sync.run();
    expect(recordsOf('rounds', 'Leo'), isEmpty);
    expect(recordsOf('rounds', 'Mia'), hasLength(1));

    final out = await two.sync.run();
    expect(out.changed, isTrue);
    expect(await two.topicsOf(twoLeo), isEmpty);
    expect(await two.topicsOf(1), ['p2.times']);
  });

  test('removing Leo removes him on the other tablet after its sync '
      '(AC-7, AD-10)', () async {
    await two.sync.run();
    final twoLeo = await two.idOf('Leo');
    await one.family.remove(leo);
    await one.sync.run();
    expect(server.of('children'), hasLength(1));
    expect(
      server.of('rounds').where((r) => r['child'] != remoteOf('Mia')),
      isEmpty,
    );
    expect(await one.family.all(), hasLength(1));
    expect(await one.db.select(one.db.children).get(), hasLength(1));

    final out = await two.sync.run();
    expect(out.changed, isTrue);
    expect((await two.family.all()).map((c) => c.nickname), ['Mia']);
    expect(await two.topicsOf(twoLeo), isEmpty);
    expect(await two.attemptsOf(twoLeo), 0);
    expect(await two.topicsOf(1), ['p2.times']);
  });

  test(
    'a removal made offline waits for the next sync (AC-7, AD-10)',
    () async {
      await one.family.remove(leo);
      expect(await one.family.all(), hasLength(1));
      one.client.syncFail = const SyncException(SyncError.offline);
      await expectLater(one.sync.run(), throwsA(isA<SyncException>()));
      expect(server.of('children'), hasLength(2));
      final hidden = await one.db.select(one.db.children).get();
      expect(hidden.where((c) => c.pendingDelete), hasLength(1));

      await one.sync.run();
      expect(server.of('children'), hasLength(1));
      expect(await one.db.select(one.db.children).get(), hasLength(1));
    },
  );

  test('one child each side with different nicknames merge (AD-9)', () async {
    final fresh = FakeSyncServer();
    final a = Tablet(fresh);
    final b = Tablet(fresh);
    addTearDown(() async {
      await a.db.close();
      await b.db.close();
    });
    await a.name1('Mia');
    await a.play(1, 'p2.times');
    await a.sync.run();
    await b.name1('Mimi');
    await b.play(1, 'p2.money');
    await b.sync.run();
    expect(fresh.of('children'), hasLength(1));
    expect(await b.family.all(), hasLength(1));
    expect(await b.topicsOf(1), ['p2.money', 'p2.times']);
  });

  test(
    'a new child on the second tablet goes up as her own record (AC-7)',
    () async {
      await two.name1('Mia');
      final ana = await two.add('Ana');
      await two.play(ana, 'p1.bonds');
      await two.sync.run();
      expect(server.of('children'), hasLength(3));
      expect(recordsOf('rounds', 'Ana'), hasLength(1));
      await one.sync.run();
      final oneAna = await one.idOf('Ana');
      expect(await one.topicsOf(oneAna), ['p1.bonds']);
      expect(await one.family.all(), hasLength(3));
    },
  );
}
