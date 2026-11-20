import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/domain/setup.dart';
import 'package:number_ninja/features/family/who_screen.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/parent/parent_screen.dart';
import 'package:number_ninja/features/setup/account_step.dart';
import 'package:number_ninja/features/setup/children_step.dart';
import 'package:number_ninja/features/setup/done_step.dart';
import 'package:number_ninja/features/setup/pin_step.dart';
import 'package:number_ninja/features/setup/setup_frame.dart';
import 'package:number_ninja/features/setup/time_step.dart';
import 'package:number_ninja/features/setup/welcome_step.dart';

import '../../data/fake_server_client.dart';
import 'setup_harness.dart';

/// FEAT-26 AC-1..AC-4: first-run setup (SCR-19).
void main() {
  late SetupHarness h;

  setUp(() => h = SetupHarness());
  tearDown(() => h.db.close());

  SetupStep dots(WidgetTester tester) =>
      tester.widget<SetupDots>(find.byType(SetupDots)).step;

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  bool enabled(WidgetTester tester, String key) =>
      tester.widget<FilledButton>(find.byKey(Key(key))).onPressed != null;

  testWidgets('AC-1: the whole path from a fresh install to home', (
    tester,
  ) async {
    await h.start(tester);
    expect(find.byType(WelcomeStep), findsOneWidget);
    expect(dots(tester), SetupStep.welcome);
    for (var i = 0; i < 3; i++) {
      expect(find.byKey(Key('setup-welcome-card-$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('setup-back')), findsNothing);
    await h.tapKey(tester, 'setup-next');

    // PIN, entered twice; a mismatch says so and starts again.
    expect(find.byType(PinStep), findsOneWidget);
    expect(dots(tester), SetupStep.pin);
    expect(enabled(tester, 'setup-next'), isFalse);
    await h.enter(tester, '2468');
    await h.enter(tester, '1357');
    expect(text(tester, 'setup-pin-message'), "PINs don't match. Try again.");
    await h.enter(tester, '2468');
    await h.enter(tester, '2468');
    expect(find.byType(AccountStep), findsOneWidget);

    // Back never makes a new PIN by itself (AD-5).
    await h.tapKey(tester, 'setup-back');
    expect(find.byKey(const Key('setup-pin-set')), findsOneWidget);
    expect(find.byKey(const Key('setup-change-pin')), findsOneWidget);
    expect(await h.pins().verify('2468'), isA<PinOk>());
    await h.tapKey(tester, 'setup-next');
    expect(dots(tester), SetupStep.account);

    await h.tapKey(tester, 'setup-skip-account');
    expect(find.byType(ChildrenStep), findsOneWidget);
    await h.addChild(tester, 'Mia');
    expect(find.byKey(const Key('setup-child-1')), findsOneWidget);
    await h.tapKey(tester, 'setup-next');

    expect(find.byType(TimeStep), findsOneWidget);
    expect(text(tester, 'setup-limit-1-value'), '20 min');
    await h.tapKey(tester, 'setup-limit-1-plus');
    await h.tapKey(tester, 'setup-limit-1-plus');
    expect(text(tester, 'setup-limit-1-value'), '30 min');
    await h.tapKey(tester, 'setup-sound');
    await h.tapKey(tester, 'setup-next');

    expect(find.byType(DoneStep), findsOneWidget);
    expect(find.text('BrainBubblz is ready for Mia.'), findsOneWidget);
    expect(find.byKey(const Key('setup-parent-button-hint')), findsOneWidget);
    // Back and forward again keep what was saved.
    await h.tapKey(tester, 'setup-back');
    expect(text(tester, 'setup-limit-1-value'), '30 min');
    await h.tapKey(tester, 'setup-next');
    await h.tapKey(tester, 'setup-start');

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hi, Mia!'), findsOneWidget);
    final mia = await h.db.child(1);
    expect([mia.dailyLimitMin, mia.soundOn, mia.avatar], [30, false, 'owl']);
    expect(await h.setup.step(), isNull);

    await h.tapKey(tester, 'parent-button');
    await h.enter(tester, '2468');
    expect(find.byType(ParentScreen), findsOneWidget);
  });

  testWidgets('AC-2: a kill at each step reopens there, PIN first', (
    tester,
  ) async {
    await h.start(tester);
    await h.start(tester);
    expect(find.byType(WelcomeStep), findsOneWidget);
    await h.tapKey(tester, 'setup-next');
    await h.start(tester);
    expect(find.byType(PinStep), findsOneWidget, reason: 'no PIN yet');

    await h.enter(tester, '2468');
    await h.enter(tester, '2468');
    await h.start(tester);
    expect(find.byKey(const Key('setup-resume-pin')), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    await h.enter(tester, '1111');
    expect(text(tester, 'setup-resume-message'), 'Wrong PIN. 4 tries left.');
    expect(find.byType(AccountStep), findsNothing);
    await h.enter(tester, '2468');
    expect(find.byType(AccountStep), findsOneWidget);

    await h.tapKey(tester, 'setup-skip-account');
    await h.addChild(tester, 'Mia');
    await h.start(tester);
    await h.enter(tester, '2468');
    expect(find.byType(ChildrenStep), findsOneWidget);
    expect(find.byKey(const Key('setup-child-1')), findsOneWidget);
    expect((await h.named()).map((c) => c.nickname), ['Mia']);

    await h.tapKey(tester, 'setup-next');
    await h.start(tester);
    await h.enter(tester, '2468');
    expect(find.byType(TimeStep), findsOneWidget);
    await h.tapKey(tester, 'setup-next');
    await h.start(tester);
    await h.enter(tester, '2468');
    expect(find.byType(DoneStep), findsOneWidget);
    await h.tapKey(tester, 'setup-start');
    expect(find.byType(HomeScreen), findsOneWidget);

    await h.start(tester);
    expect(find.byType(HomeScreen), findsOneWidget, reason: 'setup done');
    expect((await h.named()).map((c) => c.nickname), ['Mia']);
  });

  testWidgets('AC-2: five wrong PINs on resume lock it as PAR-03', (
    tester,
  ) async {
    await h.pastPin(SetupStep.time);
    await h.start(tester);
    for (var i = 0; i < 5; i++) {
      await h.enter(tester, '0000');
    }
    expect(
      text(tester, 'setup-resume-message'),
      'Too many tries. Try again in 60 s.',
    );
    expect(find.byType(TimeStep), findsNothing);
    h.tick(const Duration(seconds: 60));
    await tester.pump(const Duration(seconds: 1));
    await h.enter(tester, '2468');
    expect(find.byType(TimeStep), findsOneWidget);
  });

  testWidgets('AC-3: signing in brings the family back', (tester) async {
    final server = FakeSyncServer();
    await familyOnServer(server, ['Mia', 'Leo']);
    h.useServer(server);
    await h.pastPin(SetupStep.account);
    await h.start(tester);
    await h.enter(tester, '2468');
    expect(find.byType(AccountStep), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('account-email')),
      'parent@example.test',
    );
    await tester.enterText(
      find.byKey(const Key('account-password')),
      'secret123',
    );
    await tester.tap(find.byKey(const Key('account-signin')));
    await tester.pumpAndSettle();

    expect(find.byType(DoneStep), findsOneWidget, reason: 'skips 2 steps');
    expect(find.text('BrainBubblz is ready for Mia and Leo.'), findsOneWidget);
    final kids = await h.named();
    expect(kids.map((c) => c.nickname), ['Mia', 'Leo']);
    expect(kids.last.dailyLimitMin, 45);

    await h.tapKey(tester, 'setup-start');
    expect(find.byType(WhoScreen), findsOneWidget);
  });

  testWidgets('AC-3: an account with no children goes on to Children', (
    tester,
  ) async {
    h.useServer(FakeSyncServer());
    await h.pastPin(SetupStep.account);
    await h.start(tester);
    await h.enter(tester, '2468');
    await tester.enterText(find.byKey(const Key('account-email')), 'a@b.co');
    await tester.enterText(find.byKey(const Key('account-password')), 'x' * 8);
    await h.tapKey(tester, 'account-signin');
    expect(find.byType(ChildrenStep), findsOneWidget);
    expect(find.byKey(const Key('setup-save-child')), findsOneWidget);
  });

  testWidgets('AC-3: a server that never answers goes on to Children', (
    tester,
  ) async {
    final server = FakeSyncServer();
    await familyOnServer(server, ['Mia']);
    h.useServer(server);
    h.client.delay = restoreWait + const Duration(seconds: 10);
    await h.pastPin(SetupStep.account);
    await h.start(tester);
    await h.enter(tester, '2468');
    await tester.enterText(find.byKey(const Key('account-email')), 'a@b.co');
    await tester.enterText(find.byKey(const Key('account-password')), 'x' * 8);
    await tester.tap(find.byKey(const Key('account-signin')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('setup-restoring')), findsOneWidget);
    await tester.pump(restoreWait + const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(ChildrenStep), findsOneWidget);
    // Let the slow call finish so no timer is left.
    h.client.delay = null;
    for (var i = 0; i < 3; i++) {
      await tester.pump(restoreWait);
    }
    await tester.pumpAndSettle();
  });

  testWidgets('AC-3: a one-off server error is retried (verify)', (
    tester,
  ) async {
    final server = FakeSyncServer();
    await familyOnServer(server, ['Mia']);
    h.useServer(server);
    h.client.syncFail = const SyncException(SyncError.server, status: 500);
    await h.pastPin(SetupStep.account);
    await h.start(tester);
    await h.enter(tester, '2468');
    await tester.enterText(find.byKey(const Key('account-email')), 'a@b.co');
    await tester.enterText(find.byKey(const Key('account-password')), 'x' * 8);
    await h.tapKey(tester, 'account-signin');
    expect(h.client.syncLog.take(2), ['listChildren', 'listChildren']);
    expect(find.byType(DoneStep), findsOneWidget);
    expect((await h.named()).map((c) => c.nickname), ['Mia']);
  });

  testWidgets('AC-1: Back works on every step (verify)', (tester) async {
    await h.start(tester);
    await h.tapKey(tester, 'setup-next');
    await h.tapKey(tester, 'setup-back');
    expect(find.byType(WelcomeStep), findsOneWidget);
    await h.tapKey(tester, 'setup-next');
    await h.enter(tester, '2468');
    await h.enter(tester, '2468');
    await h.tapKey(tester, 'setup-skip-account');
    await h.addChild(tester, 'Mia');
    await h.tapKey(tester, 'setup-next');
    await h.tapKey(tester, 'setup-back');
    expect(find.byType(ChildrenStep), findsOneWidget);
    expect(find.byKey(const Key('setup-child-1')), findsOneWidget);
    await h.tapKey(tester, 'setup-back');
    expect(find.byType(AccountStep), findsOneWidget);
    // Back from PIN to Welcome after the PIN is set keeps that PIN.
    await h.tapKey(tester, 'setup-back');
    await h.tapKey(tester, 'setup-back');
    expect(find.byType(WelcomeStep), findsOneWidget);
    await h.tapKey(tester, 'setup-next');
    expect(find.byKey(const Key('setup-pin-set')), findsOneWidget);
    expect(await h.pins().verify('2468'), isA<PinOk>());
    expect((await h.named()).map((c) => c.nickname), ['Mia']);
  });

  testWidgets('AC-1: Back on an empty Children step (verify)', (tester) async {
    // A parent who skipped the Account step by mistake must be able to go
    // back and sign in before adding a child.
    await h.pastPin(SetupStep.children);
    await h.start(tester, unlocked: true);
    expect(find.byKey(const Key('setup-save-child')), findsOneWidget);
    await h.tapKey(tester, 'setup-back');
    expect(find.byType(AccountStep), findsOneWidget);
  });

  testWidgets('FEAT-30 AC-4: one child on free, more with Plus', (
    tester,
  ) async {
    h.plus = false;
    await h.pastPin(SetupStep.children);
    await h.start(tester);
    await h.enter(tester, '2468');
    await h.addChild(tester, 'Mia');
    expect(find.byKey(const Key('setup-add-child')), findsNothing);
    expect(find.byKey(const Key('setup-more-with-plus')), findsOneWidget);
    h.setPlus(tester, true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('setup-add-child')), findsOneWidget);
    expect(find.byKey(const Key('setup-more-with-plus')), findsNothing);
  });

  testWidgets('AC-4: add up to 4, edit, remove; Next needs a child', (
    tester,
  ) async {
    await h.pastPin(SetupStep.children);
    await h.start(tester);
    await h.enter(tester, '2468');
    expect(enabled(tester, 'setup-next'), isFalse);
    await h.addChild(tester, 'Mia');
    expect(enabled(tester, 'setup-next'), isTrue);
    for (final n in ['Leo', 'Ava', 'Zac']) {
      await h.tapKey(tester, 'setup-add-child');
      await h.addChild(tester, n, avatar: 'cat');
    }
    expect(find.byKey(const Key('setup-add-child')), findsNothing);
    expect((await h.named()), hasLength(4));

    final leo = (await h.named()).firstWhere((c) => c.nickname == 'Leo');
    await h.tapKey(tester, 'setup-edit-${leo.id}');
    await tester.enterText(find.byKey(const Key('profile-nickname')), 'Leon');
    await h.tapKey(tester, 'setup-save-child');
    expect(find.text('Leon · P2'), findsOneWidget);

    await h.tapKey(tester, 'setup-remove-${leo.id}');
    expect((await h.named()).map((c) => c.nickname), ['Mia', 'Ava', 'Zac']);
    expect(find.byKey(const Key('setup-add-child')), findsOneWidget);
    for (final c in await h.named()) {
      await h.tapKey(tester, 'setup-remove-${c.id}');
    }
    expect(await h.named(), isEmpty);
    expect(enabled(tester, 'setup-next'), isFalse);
  });

  test('names on the Done page', () {
    expect(namesText(['Mia']), 'Mia');
    expect(namesText(['Mia', 'Leo']), 'Mia and Leo');
    expect(namesText(['Mia', 'Leo', 'Ava']), 'Mia, Leo and Ava');
  });
}
