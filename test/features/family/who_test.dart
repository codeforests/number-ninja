import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/child_repository.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/features/family/who_screen.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/parent/pin_entry_screen.dart';
import 'package:number_ninja/features/screen_time/lock_screen.dart';
import 'package:number_ninja/providers.dart';

import '../quiz/quiz_harness.dart';

/// FEAT-25 AC-3 and AC-4: SCR-17, the home chip, the lock-screen switch,
/// the PIN option and per-child screen time.
void main() {
  late QuizHarness h;
  late int leo;
  const today = '2027-01-05';

  setUp(() async {
    h = QuizHarness();
    await ProfileRepository(
      h.db,
      clock: h.clock,
    ).save(const ChildProfile(nickname: 'Mia', schoolYear: 2));
    leo = await ChildRepository(
      h.db,
      clock: h.clock,
    ).add(const ChildProfile(nickname: 'Leo', schoolYear: 1), pickAvatar: true);
    await PinRepository(h.db, clock: h.clock).setPin('1234');
  });

  String greeting(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('greeting'))).data!;
  String minutesLeft(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('minutes-left'))).data!;

  Future<void> tap(WidgetTester tester, String key) async {
    // SCR-11 is a lazy ListView: a far-down tile may not be built yet.
    if (find.byKey(Key(key)).evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.byKey(Key(key)),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> spend(WidgetTester tester, Duration d) async {
    h.run(d);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  }

  testWidgets('AC-4: cold launch with 2 children shows SCR-17; picking Leo '
      'greets Leo; the chip reopens it', (tester) async {
    h.choosingChild = true;
    await h.pumpApp(tester);
    expect(find.byType(WhoScreen), findsOneWidget);
    expect(find.byKey(const Key('who-1')), findsOneWidget);
    expect(find.byKey(Key('who-$leo')), findsOneWidget);

    await tap(tester, 'who-$leo');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(greeting(tester), 'Hi, Leo!');
    expect(h.container(tester).read(currentChildProvider), leo);
    expect((await h.db.getSettings()).currentChildId, leo);
    expect(find.byKey(const Key('child-chip')), findsOneWidget);

    await tap(tester, 'child-chip');
    expect(find.byType(WhoScreen), findsOneWidget);
    await tap(tester, 'who-1');
    expect(greeting(tester), 'Hi, Mia!');
  });

  testWidgets('AC-4: leaving the parent area shows SCR-17', (tester) async {
    await h.pumpApp(tester);
    h.container(tester).read(appSessionProvider).unlockParent();
    h.container(tester).read(routerProvider).go(Routes.parent);
    await tester.pumpAndSettle();
    await tap(tester, 'parent-done');
    expect(find.byType(WhoScreen), findsOneWidget);
    expect(
      h.container(tester).read(appSessionProvider).parentUnlocked,
      isFalse,
    );
  });

  testWidgets('AC-4: with one child there is no chip and no picker', (
    tester,
  ) async {
    await ChildRepository(h.db, clock: h.clock).remove(leo);
    await h.pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('child-chip')), findsNothing);
    h.container(tester).read(appSessionProvider).unlockParent();
    h.container(tester).read(routerProvider).go(Routes.parent);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('switch-needs-pin')), findsNothing);
    await tap(tester, 'parent-done');
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AC-4: "Ask for PIN to change child" keeps the last child and '
      'the chip asks for the PIN', (tester) async {
    await h.pumpApp(tester);
    h.container(tester).read(appSessionProvider).unlockParent();
    h.container(tester).read(routerProvider).go(Routes.parent);
    await tester.pumpAndSettle();
    await tap(tester, 'switch-needs-pin');
    expect(await ChildRepository(h.db, clock: h.clock).switchNeedsPin(), true);
    await tap(tester, 'parent-done');
    // No picker after the parent area: the last child plays.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(greeting(tester), 'Hi, Mia!');

    await tap(tester, 'child-chip');
    expect(find.byType(PinEntryScreen), findsOneWidget);
    await enterPin(tester, '1234');
    expect(find.byType(WhoScreen), findsOneWidget);
    // The PIN for a change of child doesn't open the parent area.
    expect(
      h.container(tester).read(appSessionProvider).parentUnlocked,
      isFalse,
    );
    await tap(tester, 'who-$leo');
    expect(greeting(tester), 'Hi, Leo!');
  });

  testWidgets('AC-3: Mia locked, Leo plays with his own minutes; Mia\'s '
      'running seconds stay hers', (tester) async {
    await UsageRepository(h.db).addSeconds(today, 19 * 60 + 50);
    await UsageRepository(h.db, childId: leo).addSeconds(today, 5 * 60);
    await h.pumpApp(tester);
    expect(minutesLeft(tester), '1 min left');

    // 30 s counted for Mia before the switch, flushed to her.
    h.run(const Duration(seconds: 30));
    await tester.pump();
    expect(find.byType(LockScreen), findsNothing);
    await tap(tester, 'child-chip');
    await tap(tester, 'who-$leo');
    expect(
      (await UsageRepository(h.db).status(today)).usedSeconds,
      20 * 60 + 20,
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(minutesLeft(tester), '15 min left');

    // Back to Mia: locked; the lock screen offers a change of child.
    await tap(tester, 'child-chip');
    await tap(tester, 'who-1');
    expect(find.byType(LockScreen), findsOneWidget);
    await tap(tester, 'lock-change-child');
    expect(find.byType(WhoScreen), findsOneWidget);
    await tap(tester, 'who-$leo');
    expect(find.byType(HomeScreen), findsOneWidget);
    await spend(tester, const Duration(minutes: 1));
    expect(
      (await UsageRepository(h.db, childId: leo).status(today)).usedSeconds,
      6 * 60,
    );
  });

  testWidgets('AC-3: Mia\'s limit and extra time don\'t touch Leo', (
    tester,
  ) async {
    await UsageRepository(h.db).setDailyLimit(10);
    await UsageRepository(h.db).grantExtra(today, 5);
    await h.pumpApp(tester);
    expect(minutesLeft(tester), '15 min left');
    await tap(tester, 'child-chip');
    await tap(tester, 'who-$leo');
    expect(minutesLeft(tester), '20 min left');
  });
}
