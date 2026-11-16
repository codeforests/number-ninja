import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/features/parent/account_screen.dart';
import 'package:number_ninja/features/parent/reset_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import '../../data/sync/fake_sync_timers.dart';
import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

final configured = ServerConfig.parse('https://api.example.test');
const account = Account(id: 'u1', email: 'parent@example.test');

/// FEAT-14 AC-4 (triggers in the app) and AC-5 (SCR-13 sync section, reset
/// note).
void main() {
  late ParentHarness h;
  late FakeServerClient client;
  late FakeSyncTimers timers;

  String? textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data;

  int runs() => client.log.where((l) => l == 'refresh').length;

  void signIn({Account? stored = account}) {
    client = FakeServerClient(configured, stored: stored);
    timers = FakeSyncTimers();
    h.more = [
      ...h.more,
      serverConfigProvider.overrideWithValue(configured),
      serverClientProvider.overrideWithValue(client),
      syncTimersProvider.overrideWithValue(timers),
    ];
  }

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
    await h.seed('p2-add-3digit', [(1, true), (2, false)]);
  });
  tearDown(() => h.db.close());

  test('error texts (AC-5)', () {
    expect(
      syncErrorText(SyncError.offline),
      'Not synced: no internet. It will try again.',
    );
    expect(
      syncErrorText(SyncError.server),
      'The server had a problem. It will try again.',
    );
    expect(
      syncErrorText(SyncError.rejected),
      "Some records weren't accepted by the server.",
    );
    final now = DateTime(2027, 1, 5, 15);
    expect(lastSyncText(null, now), 'Not synced yet');
    expect(
      lastSyncText(DateTime(2027, 1, 5, 14, 31), now),
      'Last synced: today, 2:31 pm',
    );
    expect(
      lastSyncText(DateTime(2027, 1, 4, 9, 5), now),
      'Last synced: yesterday, 9:05 am',
    );
    expect(
      lastSyncText(DateTime(2026, 12, 30, 9, 5), now),
      'Last synced: 30 Dec, 9:05 am',
    );
  });

  testWidgets('signed in: the start run shows the last sync (AC-5)', (
    tester,
  ) async {
    signIn();
    await h.openParent(tester, Routes.account);
    await tester.pumpAndSettle();
    expect(runs(), greaterThanOrEqualTo(2)); // SCR-13 refresh + the sync run
    expect(client.server.of('rounds'), hasLength(1));
    expect(
      textOf(tester, 'account-last-sync'),
      startsWith('Last synced: today'),
    );
    expect(find.byKey(const Key('account-sync-error')), findsNothing);
  });

  testWidgets('"Syncing…" while running; Sync now runs a sync (AC-5)', (
    tester,
  ) async {
    signIn();
    await h.openParent(tester, Routes.account);
    await tester.pumpAndSettle();
    final before = runs();
    client.delay = const Duration(seconds: 1);
    await tester.tap(find.byKey(const Key('account-sync-now')));
    await tester.pump();
    await tester.pump();
    expect(textOf(tester, 'account-last-sync'), 'Syncing…');
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(runs(), before + 1);
    expect(textOf(tester, 'account-last-sync'), startsWith('Last synced'));
  });

  for (final (error, text) in [
    (SyncError.offline, 'Not synced: no internet. It will try again.'),
    (SyncError.server, 'The server had a problem. It will try again.'),
  ]) {
    testWidgets('a failed run shows "$text" (AC-5)', (tester) async {
      signIn();
      client.syncFail = SyncException(error, status: 500);
      await h.openParent(tester, Routes.account);
      await tester.pumpAndSettle();
      expect(textOf(tester, 'account-sync-error'), text);
      expect(textOf(tester, 'account-last-sync'), 'Not synced yet');
      expect(timers.retryDelays, [const Duration(seconds: 30)]);
    });
  }

  testWidgets('rejected records show their line (AC-5)', (tester) async {
    signIn();
    await h.openParent(tester, Routes.account);
    await tester.pumpAndSettle();
    // The server refuses every create from now on.
    final c = h.container(tester);
    await h.seed('p2-add-3digit', [(3, true)]);
    client.beforeBatch = (_) async =>
        throw const SyncException(SyncError.rejected, status: 400);
    c.read(syncProvider.notifier).requestSync();
    await tester.pumpAndSettle();
    expect(
      textOf(tester, 'account-sync-error'),
      "Some records weren't accepted by the server.",
    );
  });

  testWidgets('an expired session signs out with "Please sign in again."', (
    tester,
  ) async {
    signIn();
    await h.openParent(tester, Routes.account);
    await tester.pumpAndSettle();
    client.fail = AuthError.expired;
    await tester.tap(find.byKey(const Key('account-sync-now')));
    await tester.pumpAndSettle();
    expect(textOf(tester, 'account-message'), 'Please sign in again.');
    expect(find.byKey(const Key('account-signin')), findsOneWidget);
  });

  testWidgets('the app syncs on resume (AC-4)', (tester) async {
    signIn();
    await h.openParent(tester, Routes.account);
    await tester.pumpAndSettle();
    final before = runs();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(runs(), before + 1);
  });

  testWidgets('reset note only when signed in; reset asks the server (AC-5)', (
    tester,
  ) async {
    signIn(stored: null);
    await h.openParent(tester, Routes.reset);
    expect(find.byType(ResetScreen), findsOneWidget);
    expect(textOf(tester, 'reset-warning'), isNot(contains(otherTabletsNote)));
  });

  testWidgets('reset while signed in clears the server too (AC-5, SYN-06)', (
    tester,
  ) async {
    signIn();
    await h.openParent(tester, Routes.reset);
    await tester.pumpAndSettle();
    expect(textOf(tester, 'reset-warning'), endsWith(otherTabletsNote));
    expect(client.server.of('rounds'), hasLength(1));
    await h.enterPin(tester, parentPin);
    await tester.pumpAndSettle();
    expect(client.syncLog, contains('resetChild'));
    expect(client.server.of('rounds'), isEmpty);
    expect(client.server.of('children').single['reset_epoch'], 1);
  });

  testWidgets('a round finishes with no wait while a sync is slow (AC-4)', (
    tester,
  ) async {
    final q = QuizHarness();
    addTearDown(q.db.close);
    client = FakeServerClient(configured, stored: account)
      ..delay = const Duration(minutes: 1);
    q.more = [
      serverConfigProvider.overrideWithValue(configured),
      serverClientProvider.overrideWithValue(client),
      syncTimersProvider.overrideWithValue(FakeSyncTimers()),
    ];
    await q.pumpApp(tester, location: Routes.quiz(numberTopic));
    for (var i = 0; i < 10; i++) {
      await q.answer(tester, right: true);
      await q.next(tester);
    }
    await tester.pump();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect((await q.db.select(q.db.rounds).getSingle()).finishedAt, isNotNull);
    // The slow syncs finish later.
    client.delay = null;
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(minutes: 1));
    }
    await tester.pumpAndSettle();
    expect(client.server.of('rounds'), hasLength(1));
  });
}
