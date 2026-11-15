import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/domain/pin.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/parent/parent_screen.dart';
import 'package:number_ninja/features/profile/profile_screen.dart';
import 'package:number_ninja/features/screen_time/screen_time_controller.dart';
import 'package:number_ninja/providers.dart';

/// FEAT-10 AC-3: SCR-12 after first-run PIN setup and from SCR-11.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late DateTime now;
  late AppSession session;
  DateTime clock() => now;
  PinRepository pins() =>
      PinRepository(db, clock: clock, hasher: PinHasher(iterations: 10));
  ProfileRepository profiles() => ProfileRepository(db, clock: clock);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2027, 1, 5, 9);
  });
  tearDown(() => db.close());

  /// Starts the app as main() does: PIN and pending flag from the database.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    session = AppSession(
      hasPin: await pins().hasPin(),
      profilePending: await profiles().pending(),
      clock: clock,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          pinRepositoryProvider.overrideWithValue(pins()),
          elapsedProvider.overrideWithValue(() => Duration.zero),
          appSessionProvider.overrideWithValue(session),
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

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(find.byKey(const Key('profile-save')))
          .onPressed !=
      null;

  testWidgets('a fresh install asks for the profile after the PIN', (
    tester,
  ) async {
    await pumpApp(tester);
    await enter(tester, '2468');
    await enter(tester, '2468');
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byKey(const Key('back-parent')), findsNothing);

    expect(saveEnabled(tester), isFalse);
    await tester.enterText(find.byKey(const Key('profile-nickname')), '  ');
    await tester.pump();
    await tap(tester, 'year-2');
    expect(saveEnabled(tester), isFalse, reason: 'blank nickname');
    await tester.enterText(find.byKey(const Key('profile-nickname')), 'Mia');
    await tester.pump();
    expect(saveEnabled(tester), isTrue);
    expect(
      tester.widget<Text>(find.byKey(const Key('profile-summary'))).data,
      'P2 topics start at level 1, P1 topics at level 2, '
      'Olympiad at level 1.',
    );
    await tap(tester, 'start-olympiad-3');
    await tap(tester, 'profile-save');

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      await profiles().load(),
      const ChildProfile(nickname: 'Mia', schoolYear: 2, olympiadStartLevel: 3),
    );
    expect(await profiles().pending(), isFalse);
    expect(session.profilePending, isFalse);
  });

  testWidgets('closing the app before the profile asks again', (tester) async {
    await pins().setPin('2468');
    await pumpApp(tester);
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets(
    'an updated install opens home and offers the profile in SCR-11',
    (tester) async {
      await pins().setPin('2468');
      await (db.update(db.appSettings))
          .write(const AppSettingsCompanion(profilePending: Value(false)));
      await pumpApp(tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      session.unlockParent();
      await tap(tester, 'parent-button');
      expect(find.byType(ParentScreen), findsOneWidget);
      expect(find.text('Not set yet'), findsOneWidget);

      await tap(tester, 'open-profile');
      expect(find.byType(ProfileScreen), findsOneWidget);
      await tester.enterText(find.byKey(const Key('profile-nickname')), 'Bee');
      await tap(tester, 'year-1');
      await tap(tester, 'start-school-2');
      await tap(tester, 'profile-save');
      expect(find.byType(ParentScreen), findsOneWidget);
      expect(find.text('Bee · P1'), findsOneWidget);

      await tap(tester, 'open-profile');
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('profile-nickname')))
            .controller!
            .text,
        'Bee',
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('start-school-2')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      await tap(tester, 'back-parent');
      expect(find.byType(ParentScreen), findsOneWidget);
    },
  );

  test('redirects: pending profile comes before everything', () {
    final s = AppSession(hasPin: true, profilePending: true, clock: clock);
    for (final loc in [
      Routes.home,
      Routes.play('school'),
      Routes.parent,
      Routes.pinEntry,
      Routes.badges,
      Routes.setup,
    ]) {
      expect(redirectFor(s, false, loc), Routes.setupProfile, reason: loc);
    }
    expect(redirectFor(s, false, Routes.setupProfile), isNull);
    final noPin = AppSession(hasPin: false, profilePending: true, clock: clock);
    expect(redirectFor(noPin, false, Routes.setupProfile), Routes.setup);
    s.profileSaved();
    expect(redirectFor(s, false, Routes.setupProfile), Routes.home);
    expect(redirectFor(s, false, Routes.home), isNull);
    expect(redirectFor(s, false, Routes.profile), Routes.pinEntry);
    expect(Routes.counts(Routes.setupProfile), isFalse);
    expect(Routes.counts(Routes.profile), isFalse);
  });
}
