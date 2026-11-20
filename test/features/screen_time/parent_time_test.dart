import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/pin.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/parent/parent_screen.dart';
import 'package:number_ninja/features/parent/pin_entry_screen.dart';
import 'package:number_ninja/features/screen_time/lock_screen.dart';
import 'package:number_ninja/providers.dart';

import '../quiz/quiz_harness.dart';

/// AC-5: a parent unlocks with extra time and changes the daily limit
/// (TIM-02, TIM-04, D5).
void main() {
  late QuizHarness h;
  setUp(() async {
    h = QuizHarness();
    final pins = PinRepository(
      h.db,
      clock: h.clock,
      hasher: PinHasher(iterations: 10),
    );
    await pins.setPin('2468');
    h.more = [pinRepositoryProvider.overrideWithValue(pins)];
  });
  tearDown(() => h.db.close());

  const day = '2027-01-05';

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    // Lay out after the scroll (FEAT-30's Plus row moved this one down).
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('AC-5: Parent, PIN, +10 min, Done shows home with 10 min left', (
    tester,
  ) async {
    await UsageRepository(h.db).addSeconds(day, 20 * 60);
    await h.pumpApp(tester);
    expect(find.byType(LockScreen), findsOneWidget);

    await tap(tester, 'lock-parent');
    expect(find.byType(PinEntryScreen), findsOneWidget);
    await enter(tester, '2468');
    expect(find.byType(ParentScreen), findsOneWidget);
    expect(text(tester, 'today-usage'), 'Today: 20 min used, 0 min left');

    await tap(tester, 'extra-10');
    expect(text(tester, 'today-usage'), 'Today: 20 min used, 10 min left');
    expect((await UsageRepository(h.db).status(day)).extraSeconds, 600);

    await tap(tester, 'parent-done');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(text(tester, 'minutes-left'), '10 min left');
  });

  testWidgets('AC-5: a wrong PIN keeps the lock', (tester) async {
    await UsageRepository(h.db).addSeconds(day, 20 * 60);
    await h.pumpApp(tester);
    await tap(tester, 'lock-parent');
    await enter(tester, '1111');
    expect(find.byType(PinEntryScreen), findsOneWidget);
    expect(find.textContaining('Wrong PIN'), findsOneWidget);

    await tap(tester, 'back-home');
    expect(find.byType(LockScreen), findsOneWidget);
  });

  testWidgets('AC-5: the limit stepper stops at 5 and 120, saves, and '
      'applies today; raising it unlocks', (tester) async {
    await UsageRepository(h.db).addSeconds(day, 20 * 60);
    await h.pumpApp(tester);
    await tap(tester, 'lock-parent');
    await enter(tester, '2468');
    expect(text(tester, 'limit-value'), '20 min');

    await tap(tester, 'limit-plus');
    expect(text(tester, 'limit-value'), '25 min');
    expect((await h.db.child(1)).dailyLimitMin, 25);
    expect(text(tester, 'today-usage'), 'Today: 20 min used, 5 min left');

    await tap(tester, 'parent-done');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(text(tester, 'minutes-left'), '5 min left');

    h.container(tester).read(appSessionProvider).unlockParent();
    h.container(tester).read(routerProvider).go('/parent');
    await tester.pumpAndSettle();
    IconButton button(String key) =>
        tester.widget<IconButton>(find.byKey(Key(key)));
    for (var i = 0; i < 30; i++) {
      if (button('limit-plus').onPressed == null) break;
      await tap(tester, 'limit-plus');
    }
    expect(text(tester, 'limit-value'), '120 min');
    expect(button('limit-plus').onPressed, isNull);
    expect((await h.db.child(1)).dailyLimitMin, 120);

    for (var i = 0; i < 30; i++) {
      if (button('limit-minus').onPressed == null) break;
      await tap(tester, 'limit-minus');
    }
    expect(text(tester, 'limit-value'), '5 min');
    expect(button('limit-minus').onPressed, isNull);
    expect((await h.db.child(1)).dailyLimitMin, 5);
    expect(text(tester, 'today-usage'), 'Today: 20 min used, 0 min left');
  });
}
