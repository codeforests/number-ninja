import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/screen_time/lock_screen.dart';
import 'package:number_ninja/providers.dart';

import '../quiz/quiz_harness.dart';

/// AC-3 and AC-6: counting, the lock and what doesn't count.
void main() {
  late QuizHarness h;
  setUp(() => h = QuizHarness());

  String minutesLeft(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('minutes-left'))).data!;

  Future<int> used(String day) async =>
      (await UsageRepository(h.db).status(day)).usedSeconds;

  /// Lets [d] of foreground time pass and the flush timer fire.
  Future<void> spend(WidgetTester tester, Duration d) async {
    h.run(d);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, String location) async {
    h.container(tester).read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }

  testWidgets('AC-3: the lock comes after the limit, stays on every child '
      'route and lifts the next day', (tester) async {
    await UsageRepository(h.db).addSeconds('2027-01-05', 19 * 60 + 50);
    await h.pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(minutesLeft(tester), '1 min left');

    await spend(tester, const Duration(seconds: 10));
    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.text("Time's up for today!"), findsOneWidget);

    for (final loc in ['/', '/play/school', '/quiz/$numberTopic']) {
      await go(tester, loc);
      expect(find.byType(LockScreen), findsOneWidget, reason: loc);
    }

    // The next morning.
    h.now = DateTime(2027, 1, 6, 8);
    await spend(tester, Duration.zero);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(minutesLeft(tester), '20 min left');
    expect(await used('2027-01-05'), 20 * 60);
  });

  testWidgets('AC-3: the lock screen has no way back and the Parent button '
      'opens PIN entry', (tester) async {
    await UsageRepository(h.db).addSeconds('2027-01-05', 20 * 60);
    await h.pumpApp(tester);
    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('lock-parent')));
    await tester.pumpAndSettle();
    expect(
      h.container(tester).read(routerProvider).state.matchedLocation,
      Routes.pinEntry,
    );
  });

  testWidgets('AC-6: PIN entry, the parent area and a hidden app are not '
      'counted', (tester) async {
    await h.pumpApp(tester);
    await spend(tester, const Duration(seconds: 30));
    expect(await used('2027-01-05'), 30);

    await go(tester, Routes.pinEntry);
    await spend(tester, const Duration(minutes: 3));
    expect(await used('2027-01-05'), 30);

    h.container(tester).read(appSessionProvider).unlockParent();
    await go(tester, Routes.parent);
    await spend(tester, const Duration(minutes: 3));
    expect(await used('2027-01-05'), 30);

    await go(tester, Routes.home);
    await spend(tester, const Duration(seconds: 20));
    expect(await used('2027-01-05'), 50);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await spend(tester, const Duration(minutes: 5));
    expect(await used('2027-01-05'), 50);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await spend(tester, const Duration(seconds: 15));
    expect(await used('2027-01-05'), 65);
    expect(minutesLeft(tester), '19 min left');
  });

  test('redirects: a lock sends child routes to SCR-07, never parent ones', () {
    final session = AppSession(hasPin: true, clock: () => DateTime(2027));
    for (final loc in [Routes.home, '/play/school', '/quiz/x', Routes.result]) {
      expect(redirectFor(session, true, loc), Routes.locked, reason: loc);
      expect(redirectFor(session, false, loc), isNull, reason: loc);
    }
    expect(redirectFor(session, true, Routes.locked), isNull);
    expect(redirectFor(session, false, Routes.locked), Routes.home);
    expect(redirectFor(session, true, Routes.pinEntry), isNull);
    expect(redirectFor(session, true, Routes.parent), Routes.pinEntry);
    session.unlockParent();
    expect(redirectFor(session, true, Routes.parent), isNull);
    expect(redirectFor(session, true, Routes.changePin), isNull);
  });
}
