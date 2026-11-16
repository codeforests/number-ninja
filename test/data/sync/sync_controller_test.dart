import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/sync/account_repository.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/sync_controller.dart';
import 'package:number_ninja/providers.dart';

import '../fake_server_client.dart';
import 'fake_sync_timers.dart';

final configured = ServerConfig.parse('https://api.example.test');
const account = Account(id: 'u1', email: 'parent@example.test');

void main() {
  late AppDatabase db;
  late FakeServerClient client;
  late FakeSyncTimers timers;
  late ProviderContainer c;

  ProviderContainer make({ServerConfig? config, Account? stored = account}) {
    client = FakeServerClient(config ?? configured, stored: stored);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        serverConfigProvider.overrideWithValue(config ?? configured),
        serverClientProvider.overrideWithValue(client),
        syncTimersProvider.overrideWithValue(timers),
      ],
    );
    addTearDown(container.dispose);
    container.listen(syncProvider, (_, _) {});
    return container;
  }

  int runs() => client.log.where((l) => l == 'refresh').length;

  /// Lets the account load, the start run begin and every run finish.
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await c.read(accountProvider.notifier).ready;
      await Future<void>.delayed(Duration.zero);
      await c.read(syncProvider.notifier).idle;
    }
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    timers = FakeSyncTimers();
  });
  tearDown(() => db.close());

  test('runs at start, on request (resume, round, Sync now), every 5 min '
      '(AC-4)', () async {
    c = make();
    await settle();
    expect(runs(), 1);
    final s = c.read(syncProvider);
    expect(s.active, isTrue);
    expect(s.lastSyncAt, isNotNull);
    expect(s.lastError, isNull);
    expect(timers.everys.single.duration, const Duration(minutes: 5));

    c.read(syncProvider.notifier).requestSync();
    await settle();
    expect(runs(), 2);
    timers.firePeriodic();
    await settle();
    expect(runs(), 3);
  });

  test('a request during a run makes one more run after it (AC-4)', () async {
    c = make();
    await settle();
    client.delay = const Duration(milliseconds: 20);
    final n = c.read(syncProvider.notifier);
    n.requestSync();
    await Future<void>.delayed(Duration.zero);
    expect(c.read(syncProvider).running, isTrue);
    n.requestSync();
    n.requestSync();
    await settle();
    expect(runs(), 3);
    expect(c.read(syncProvider).running, isFalse);
  });

  test(
    'failures back off 30 s, 1, 2, 4 min and reset after a success (AC-4)',
    () async {
      c = make();
      await settle();
      timers.onces.clear();
      for (var i = 0; i < 4; i++) {
        client.syncFail = const SyncException(SyncError.offline);
        if (i == 0) {
          c.read(syncProvider.notifier).requestSync();
        } else {
          timers.fireRetry();
        }
        await settle();
        expect(c.read(syncProvider).lastError, SyncError.offline);
      }
      expect(timers.retryDelays, const [
        Duration(seconds: 30),
        Duration(minutes: 1),
        Duration(minutes: 2),
        Duration(minutes: 4),
      ]);
      timers.fireRetry(); // succeeds
      await settle();
      expect(c.read(syncProvider).lastError, isNull);
      client.syncFail = const SyncException(SyncError.server, status: 503);
      c.read(syncProvider.notifier).requestSync();
      await settle();
      expect(c.read(syncProvider).lastError, SyncError.server);
      expect(timers.retryDelays.last, const Duration(seconds: 30));
      // The cap.
      expect(syncBackoff.last, const Duration(minutes: 15));
    },
  );

  test('no runs while signed out or without a server URL (AC-4)', () async {
    c = make(stored: null);
    await settle();
    c.read(syncProvider.notifier).requestSync();
    await settle();
    expect(client.syncLog, isEmpty);
    expect(c.read(syncProvider).active, isFalse);
    expect(timers.everys, isEmpty);

    c = make(config: ServerConfig.none);
    await settle();
    c.read(syncProvider.notifier).requestSync();
    await settle();
    expect(client.syncLog, isEmpty);
  });

  test('sign-out stops syncing; an expired session signs out (AC-4)', () async {
    c = make();
    await settle();
    client.fail = AuthError.expired;
    c.read(syncProvider.notifier).requestSync();
    await settle();
    final a = c.read(accountProvider);
    expect(a.signedIn, isFalse);
    expect(a.notice, AccountNotice.signInAgain);
    expect(c.read(syncProvider).active, isFalse);
    expect(timers.everys.single.isActive, isFalse);
    final before = runs();
    timers.everys.single.run();
    await settle();
    expect(runs(), before);
  });

  test('a run that changed data bumps the data version (AC-4)', () async {
    c = make();
    await settle();
    final v = c.read(syncDataVersionProvider);
    // Another device's round arrives.
    final other = FakeServerClient(
      configured,
      stored: account,
      server: client.server,
    );
    final child = client.server.of('children').single['id'];
    await other.pushBatch([
      PushOp('rounds', {
        'child': child,
        'uuid': 'aaaa',
        'topic_id': 'p1.place',
        'level': 1,
        'kind': 'normal',
        'started_at': '2027-01-05 01:00:00.000Z',
        'finished_at': '2027-01-05 01:05:00.000Z',
        'score': 7,
        'duration_ms': 1000,
        'stars': 2,
        'device_id': 'other',
      }),
    ]);
    c.read(syncProvider.notifier).requestSync();
    await settle();
    expect(c.read(syncDataVersionProvider), v + 1);
    expect((await db.select(db.rounds).get()).single.score, 7);
  });
}
