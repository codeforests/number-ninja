import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/domain/pin.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/parent/parent_screen.dart';
import 'package:number_ninja/features/parent/pin_entry_screen.dart';
import 'package:number_ninja/features/screen_time/screen_time_controller.dart';
import 'package:number_ninja/features/setup/setup_pin_screen.dart';
import 'package:number_ninja/providers.dart';

/// Widget tests for AC-1..AC-4 on a 12-inch landscape tablet size, an
/// in-memory database and a fake clock (AC-7).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late DateTime now;
  DateTime clock() => now;
  PinRepository repo() =>
      PinRepository(db, clock: clock, hasher: PinHasher(iterations: 10));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2027, 1, 5, 9);
  });
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final hasPin = await repo().hasPin();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          pinRepositoryProvider.overrideWithValue(repo()),
          elapsedProvider.overrideWithValue(() => Duration.zero),
          appSessionProvider.overrideWithValue(
            AppSession(hasPin: hasPin, clock: clock),
          ),
        ],
        child: const NumberNinjaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  String message(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('screen-message'))).data!;

  testWidgets('AC-1: fresh install opens PIN setup; mismatch saves nothing', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(SetupPinScreen), findsOneWidget);

    await enter(tester, '2468');
    expect(find.text('Enter the PIN again'), findsOneWidget);
    await enter(tester, '1357');
    expect(message(tester), "PINs don't match. Try again.");
    expect(find.byType(SetupPinScreen), findsOneWidget);
    expect(await repo().hasPin(), isFalse);
  });

  testWidgets('AC-1: matching PINs save a salted hash and open home', (
    tester,
  ) async {
    await pumpApp(tester);
    await enter(tester, '2468');
    await enter(tester, '2468');

    expect(find.byType(HomeScreen), findsOneWidget);
    final s = await db.select(db.appSettings).getSingle();
    expect(s.pinHash, isNotNull);
    expect(s.pinHash, isNot(contains('2468')));
    expect(s.pinSalt, isNotNull);
  });

  testWidgets('AC-2: parent button asks for the PIN; wrong then right', (
    tester,
  ) async {
    await repo().setPin('2468');
    await pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('parent-button')));
    await tester.pumpAndSettle();
    expect(find.byType(PinEntryScreen), findsOneWidget);

    await enter(tester, '1111');
    expect(message(tester), 'Wrong PIN. 4 tries left.');
    await enter(tester, '2468');
    expect(find.byType(ParentScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('parent-done')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('parent-button')));
    await tester.pumpAndSettle();
    expect(find.byType(PinEntryScreen), findsOneWidget);
  });

  testWidgets('AC-3: five wrong PINs block entry with a countdown', (
    tester,
  ) async {
    await repo().setPin('2468');
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('parent-button')));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await enter(tester, '0000');
    }
    expect(message(tester), 'Too many tries. Try again in 60 s.');
    final key = tester.widget<FilledButton>(find.byKey(const Key('pin-2')));
    expect(key.onPressed, isNull);

    now = now.add(const Duration(seconds: 45));
    await tester.pump(const Duration(seconds: 1));
    expect(message(tester), 'Too many tries. Try again in 15 s.');

    now = now.add(const Duration(seconds: 15));
    await tester.pump(const Duration(seconds: 1));
    expect(message(tester), 'Enter your 4-digit PIN.');
    await enter(tester, '2468');
    expect(find.byType(ParentScreen), findsOneWidget);
  });

  testWidgets('AC-3: the lockout is still shown after an app restart', (
    tester,
  ) async {
    final r = repo();
    await r.setPin('2468');
    for (var i = 0; i < 5; i++) {
      await r.verify('0000');
    }
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('parent-button')));
    await tester.pumpAndSettle();
    expect(message(tester), 'Too many tries. Try again in 60 s.');
    // Let the ticker run out so no timer is left pending.
    now = now.add(const Duration(seconds: 60));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('AC-4: change PIN needs the current one; new PIN replaces old', (
    tester,
  ) async {
    await repo().setPin('2468');
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('parent-button')));
    await tester.pumpAndSettle();
    await enter(tester, '2468');
    // SCR-11 is a lazy list; scroll the tile into view first (code-map).
    await tester.scrollUntilVisible(
      find.byKey(const Key('change-pin')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(const Key('change-pin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('change-pin')));
    await tester.pumpAndSettle();

    expect(find.text('Current PIN'), findsOneWidget);
    await enter(tester, '1111');
    expect(message(tester), 'Wrong PIN. 4 tries left.');
    await enter(tester, '2468');
    expect(find.text('New PIN'), findsOneWidget);
    await enter(tester, '1357');
    await enter(tester, '9999');
    expect(message(tester), "PINs don't match. Try again.");
    await enter(tester, '1357');
    await enter(tester, '1357');
    expect(find.byType(ParentScreen), findsOneWidget);
    expect(find.text('PIN changed'), findsOneWidget);

    expect(await repo().verify('1357'), isA<PinOk>());
    expect(await repo().verify('2468'), isA<PinWrong>());
  });

  test('redirects: setup until a PIN exists, parent routes need unlock', () {
    final session = AppSession(hasPin: false, clock: clock);
    expect(redirectFor(session, false, Routes.home), Routes.setup);
    expect(redirectFor(session, false, Routes.parent), Routes.setup);
    expect(redirectFor(session, false, Routes.setup), isNull);

    session.pinCreated();
    expect(redirectFor(session, false, Routes.setup), Routes.home);
    expect(redirectFor(session, false, Routes.home), isNull);
    expect(redirectFor(session, false, Routes.parent), Routes.pinEntry);
    expect(redirectFor(session, false, Routes.changePin), Routes.pinEntry);
    expect(redirectFor(session, false, Routes.pinEntry), isNull);

    session.unlockParent();
    expect(redirectFor(session, false, Routes.parent), isNull);
    now = now.add(AppSession.unlockFor);
    expect(redirectFor(session, false, Routes.parent), Routes.pinEntry);
  });
}
