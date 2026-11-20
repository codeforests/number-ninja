import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/sync_service.dart';
import 'package:number_ninja/data/topic_lock_repository.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/quiz.dart';

import '../fake_server_client.dart';

const day = '2027-01-05';

/// One tablet: its own database, signed in to a shared fake server.
class Device {
  Device(FakeSyncServer server, {String account = 'u1'})
    : db = AppDatabase(NativeDatabase.memory()) {
    client = FakeServerClient(
      ServerConfig.parse('https://api.example.test'),
      stored: Account(id: account, email: '$account@example.test'),
      server: server,
    );
    rounds = RoundRepository(db, clock: clock);
    usage = UsageRepository(db, clock: clock);
    profiles = ProfileRepository(db, clock: clock);
    topics = TopicLockRepository(db, clock: clock);
    sync = SyncService(
      db: db,
      client: client,
      clock: clock,
      forgetSession: rounds.forgetSession,
    );
  }

  final AppDatabase db;
  late final FakeServerClient client;
  late final RoundRepository rounds;
  late final UsageRepository usage;
  late final ProfileRepository profiles;
  late final TopicLockRepository topics;
  late final SyncService sync;
  DateTime now = DateTime(2027, 1, 5, 9);

  DateTime clock() => now;

  void tick([Duration d = const Duration(minutes: 1)]) => now = now.add(d);

  /// Plays a round of [answers] answers; returns its local id.
  Future<int> play(String topic, {int answers = 3, bool finish = true}) async {
    tick();
    final id = await rounds.startRound(topic, 1);
    for (var i = 0; i < answers; i++) {
      await rounds.saveAttempt(
        id,
        AnswerResult(
          questionId: '$topic-q$i',
          given: '$i',
          correct: i.isEven,
          timeMs: 1000 + i,
        ),
      );
    }
    if (finish) await finishRound(id);
    return id;
  }

  Future<void> finishRound(int id) =>
      rounds.finishRound(id, score: 2, durationMs: 9000, stars: 1);

  Future<void> earn(String badge) => db
      .into(db.badgesEarned)
      .insert(
        BadgesEarnedCompanion.insert(childId: 1, badgeId: badge, earnedAt: now),
      );

  Future<int> count(TableInfo<Table, Object?> t) async =>
      (await db.select(t).get()).length;

  Future<Map<String, DateTime>> badges() async => {
    for (final b in await db.select(db.badgesEarned).get())
      b.badgeId: b.earnedAt,
  };

  Future<List<Round>> allRounds() => db.select(db.rounds).get();
}

void main() {
  late FakeSyncServer server;
  late Device a;
  late Device b;

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() {
    server = FakeSyncServer();
    a = Device(server);
    b = Device(server);
    b.now = DateTime(2027, 1, 5, 9, 30);
  });
  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  test("A's progress, profile and settings appear on B (AC-3)", () async {
    await a.profiles.save(const ChildProfile(nickname: 'Mei', schoolYear: 2));
    await a.play('p1.place');
    await a.play('p1.money', answers: 2);
    await a.earn('first-round');
    a.tick();
    await a.usage.setDailyLimit(35);
    await a.usage.setSoundOn(false);
    await a.topics.open('p2.fractions');
    await a.usage.addSeconds(day, 300);
    await a.usage.grantExtra(day, 10);
    await a.sync.run();
    await b.sync.run();

    expect(await b.count(b.db.rounds), 2);
    expect(await b.count(b.db.attempts), 5);
    expect((await b.badges()).keys, ['first-round']);
    final profile = await b.profiles.load();
    expect(profile?.nickname, 'Mei');
    expect(profile?.schoolYear, 2);
    expect(await b.profiles.pending(), isFalse);
    final settings = await b.db.child(1);
    expect(settings.dailyLimitMin, 35);
    expect(settings.soundOn, isFalse);
    expect(await b.topics.opened(), {'p2.fractions'});
    final st = await b.usage.status(day);
    expect([st.usedSeconds, st.extraSeconds, st.limitMinutes], [300, 600, 35]);
    final r = (await b.allRounds()).first;
    expect([r.topicId, r.score, r.stars, r.dirty], ['p1.place', 2, 1, 0]);
    expect(r.finishedAt, isNotNull);
    // A second run changes nothing anywhere.
    final writes = {...server.writes};
    final again = await b.sync.run();
    expect(again.changed, isFalse);
    expect((await a.sync.run()).changed, isFalse);
    expect(server.writes, writes);
  });

  test(
    'B with its own progress before sign-in ends with the union (AC-3)',
    () async {
      await a.play('p1.place');
      await a.earn('first-round');
      await a.sync.run();
      await b.play('p1.money');
      await b.play('p1.shapes');
      b.now = DateTime(2027, 1, 5, 8); // B earned it earlier
      await b.earn('first-round');
      await b.earn('three-stars');
      await b.sync.run();
      await a.sync.run();
      await b.sync.run();

      for (final d in [a, b]) {
        expect(await d.count(d.db.rounds), 3);
        expect(await d.count(d.db.attempts), 9);
        expect((await d.badges()).keys.toSet(), {'first-round', 'three-stars'});
        expect((await d.badges())['first-round'], DateTime(2027, 1, 5, 8));
      }
      expect(server.of('rounds'), hasLength(3));
      expect(server.of('attempts'), hasLength(9));
      expect(server.of('badges'), hasLength(2));
      expect(server.of('children'), hasLength(1));
    },
  );

  test(
    'a round finished on A after a push arrives finished on B (AC-3)',
    () async {
      final id = await a.play('p1.place', finish: false);
      await a.sync.run();
      await b.sync.run();
      expect((await b.allRounds()).single.finishedAt, isNull);
      await a.finishRound(id);
      await a.sync.run();
      await b.sync.run();
      final r = (await b.allRounds()).single;
      expect(r.finishedAt, isNotNull);
      expect(r.score, 2);
      // B's unfinished push never clears it.
      await b.sync.run();
      await a.sync.run();
      expect((await a.allRounds()).single.finishedAt, isNotNull);
    },
  );

  test(
    'a later limit change on B wins on A; ties keep the server (AC-3)',
    () async {
      await a.usage.setDailyLimit(30);
      await a.sync.run();
      await b.sync.run();
      expect((await b.db.child(1)).dailyLimitMin, 30);
      b.now = a.now.add(const Duration(hours: 1));
      await b.usage.setDailyLimit(45);
      await b.sync.run();
      await a.sync.run();
      expect((await a.db.child(1)).dailyLimitMin, 45);
    },
  );

  test('screen time on A and B adds up on both (AC-3)', () async {
    await a.usage.addSeconds(day, 400);
    await b.usage.addSeconds(day, 500);
    await b.usage.grantExtra(day, 5);
    await a.sync.run();
    await b.sync.run();
    await a.sync.run();
    for (final d in [a, b]) {
      final s = await d.usage.status(day);
      expect([s.usedSeconds, s.extraSeconds], [900, 300]);
    }
    await a.usage.addSeconds(day, 100);
    await a.sync.run();
    await b.sync.run();
    expect((await b.usage.status(day)).usedSeconds, 1000);
  });

  test('the PIN and lockout never leave the device (AC-3, SYN-02)', () async {
    await (a.db.update(a.db.appSettings)..where((s) => s.id.equals(1))).write(
      const AppSettingsCompanion(
        pinHash: Value('secret-hash-xyz'),
        pinSalt: Value('secret-salt-xyz'),
      ),
    );
    await (a.db.update(a.db.pinLockout)..where((s) => s.id.equals(1))).write(
      const PinLockoutCompanion(failedCount: Value(4)),
    );
    await a.profiles.save(const ChildProfile(nickname: 'Mei', schoolYear: 2));
    await a.play('p1.place');
    await a.usage.addSeconds(day, 60);
    await a.sync.run();
    expect(server.sent, isNotEmpty);
    for (final body in server.sent) {
      expect(body, isNot(contains('secret-')));
      expect(body.toLowerCase(), isNot(contains('pin')));
      expect(body, isNot(contains('failed_count')));
      expect(body, isNot(contains('locked_until')));
    }
  });

  group('reset (AC-3, SYN-06)', () {
    Future<void> shared() async {
      await a.play('p1.place');
      await a.earn('first-round');
      await b.play('p1.money');
      await a.sync.run();
      await b.sync.run();
      await a.sync.run();
      expect(await b.count(b.db.rounds), 2);
    }

    Future<void> localReset(Device d) async {
      await d.db.transaction(() async {
        await d.db.delete(d.db.attempts).go();
        await d.db.delete(d.db.rounds).go();
        await d.db.delete(d.db.playSessions).go();
        await d.db.delete(d.db.badgesEarned).go();
      });
      await d.sync.markPendingReset();
    }

    test('online: clears the server and B at its next sync', () async {
      await shared();
      server.time = DateTime(2027, 1, 5, 11).toUtc();
      await localReset(a);
      await a.sync.run();
      expect(server.of('rounds'), isEmpty);
      expect(server.of('attempts'), isEmpty);
      expect(server.of('badges'), isEmpty);
      expect(server.of('children').single['reset_epoch'], 1);
      final out = await b.sync.run();
      expect(out.changed, isTrue);
      expect(await b.count(b.db.rounds), 0);
      expect(await b.count(b.db.attempts), 0);
      expect(await b.badges(), isEmpty);
      // Nothing comes back from B, and the epoch doesn't repeat.
      await b.sync.run();
      await a.sync.run();
      expect(await a.count(a.db.rounds), 0);
      expect(server.of('rounds'), isEmpty);
    });

    test("offline then online: B's newer rounds stay", () async {
      await shared();
      await localReset(a);
      a.client.syncFail = const SyncException(SyncError.offline);
      await expectLater(a.sync.run(), throwsA(isA<SyncException>()));
      expect(server.of('rounds'), hasLength(2));
      // A comes back online; the server resets "now".
      server.time = DateTime(2027, 1, 5, 12).toUtc();
      await a.sync.run();
      // B played on after the reset time.
      b.now = DateTime(2027, 1, 5, 12, 30);
      await b.play('p1.shapes');
      await b.sync.run();
      expect((await b.allRounds()).map((r) => r.topicId), ['p1.shapes']);
      expect(await b.count(b.db.attempts), 3);
      await a.sync.run();
      expect((await a.allRounds()).map((r) => r.topicId), ['p1.shapes']);
    });

    Future<void> resetBeforeFirstSync(void Function() failFirstRun) async {
      await b.play('p1.money');
      await b.sync.run();
      expect(server.of('rounds'), hasLength(1));
      failFirstRun();
      await expectLater(a.sync.run(), throwsA(isA<SyncException>()));
      await localReset(a);
      server.time = DateTime(2027, 1, 5, 11).toUtc();
      await a.sync.run();
      await a.sync.run();
      await b.sync.run();
      expect(server.of('rounds'), isEmpty);
      expect(server.of('children').single['reset_epoch'], 1);
      expect(await a.count(a.db.rounds), 0);
      expect(await a.count(a.db.attempts), 0);
      expect(await b.count(b.db.rounds), 0);
    }

    test('before the first sync reached the child: all clear (rework)', () {
      return resetBeforeFirstSync(
        () => a.client.syncFail = const SyncException(SyncError.offline),
      );
    });

    test('before the first sync linked the account: all clear (rework)', () {
      return resetBeforeFirstSync(() => a.client.fail = AuthError.offline);
    });
  });

  test(
    "a different account on this device merges into that account's (AC-3)",
    () async {
      await a.play('p1.place');
      await a.sync.run();
      final other = Device(server, account: 'u9');
      addTearDown(other.db.close);
      await other.play('p1.money');
      await other.sync.run();
      // A signs in to u9.
      a.client.stored = const Account(id: 'u9', email: 'u9@example.test');
      await a.sync.run();
      await other.sync.run();
      expect(server.of('children'), hasLength(2));
      final u9 = server.of('children').firstWhere((c) => c['owner'] == 'u9');
      expect(
        server.of('rounds').where((r) => r['child'] == u9['id']),
        hasLength(2),
      );
      expect(await other.count(other.db.rounds), 2);
      expect(await a.count(a.db.rounds), 2);
    },
  );

  test('a failed batch with one duplicate goes row by row (AC-3)', () async {
    await a.play('p1.place', answers: 5);
    final dup = (await a.db.select(a.db.attempts).get())[2];
    await a.sync.run();
    // Pretend the server lost the reply for one attempt: mark all unsent.
    await a.db.customStatement('UPDATE attempts SET dirty = 1');
    await b.play('p1.money', answers: 4);
    await a.play('p1.shapes', answers: 4);
    a.client.syncLog.clear();
    final out = await a.sync.run();
    expect(a.client.syncLog, contains('pushBatch:attempts:9'));
    expect(a.client.syncLog, contains('pushBatch:attempts:1'));
    expect(out.rejected, 0);
    expect(server.of('attempts'), hasLength(9));
    expect(
      server.of('attempts').where((x) => x['uuid'] == dup.uuid),
      hasLength(1),
    );
    expect(
      await a.db.customSelect('SELECT 1 FROM attempts WHERE dirty > 0').get(),
      isEmpty,
    );
  });

  test('a round finished during a push is sent next run (AC-3)', () async {
    final id = await a.play('p1.place', finish: false);
    var done = false;
    a.client.beforeBatch = (ops) async {
      if (!done && ops.first.collection == 'rounds') {
        done = true;
        await a.finishRound(id);
      }
    };
    await a.sync.run();
    expect(server.of('rounds').single['finished_at'], '');
    expect((await a.allRounds()).single.dirty, greaterThan(0));
    await a.sync.run();
    expect(server.of('rounds').single['finished_at'], isNotEmpty);
    expect((await a.allRounds()).single.dirty, 0);
  });

  test('an expired session stops the run (AC-3)', () async {
    a.client.fail = AuthError.expired;
    await expectLater(
      a.sync.run(),
      throwsA(
        isA<SyncException>().having((e) => e.error, 'error', SyncError.expired),
      ),
    );
  });
}
