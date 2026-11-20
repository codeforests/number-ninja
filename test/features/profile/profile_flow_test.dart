import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/data/setup_repository.dart';
import 'package:number_ninja/domain/pin.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/setup.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/parent/parent_screen.dart';
import 'package:number_ninja/features/profile/profile_screen.dart';
import 'package:number_ninja/features/screen_time/screen_time_controller.dart';
import 'package:number_ninja/features/setup/children_step.dart';
import 'package:number_ninja/features/setup/time_step.dart';
import 'package:number_ninja/providers.dart';

/// FEAT-10 AC-3: the child profile at first run (since FEAT-26 the setup
/// Children step, SCR-19) and SCR-12 from SCR-11.
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

  /// Starts the app as main() does: setup step and PIN from the database.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    session = AppSession(
      setupStep: await SetupRepository(db).step(),
      pinSet: await pins().hasPin(),
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

  bool saveEnabled(WidgetTester tester, [String key = 'profile-save']) =>
      tester.widget<FilledButton>(find.byKey(Key(key))).onPressed != null;

  /// A fresh install just past the setup PIN step (FEAT-26).
  Future<void> pastPin() async {
    await pins().setPin('2468');
    await SetupRepository(db).advance(SetupStep.children);
  }

  testWidgets('a fresh install asks for the profile after the PIN', (
    tester,
  ) async {
    await pastPin();
    await pumpApp(tester);
    // Resuming past the PIN asks for it first (FEAT-26 AD-4).
    await enter(tester, '2468');
    expect(find.byType(ChildrenStep), findsOneWidget);
    expect(find.byKey(const Key('back-parent')), findsNothing);
    // Starting levels are folded under "More options" here (AD-8).
    await tap(tester, 'child-more-options');

    expect(saveEnabled(tester, 'setup-save-child'), isFalse);
    await tester.enterText(find.byKey(const Key('profile-nickname')), '  ');
    await tester.pump();
    await tap(tester, 'year-2');
    expect(
      saveEnabled(tester, 'setup-save-child'),
      isFalse,
      reason: 'blank nickname',
    );
    await tester.enterText(find.byKey(const Key('profile-nickname')), 'Mia');
    await tester.pump();
    expect(saveEnabled(tester, 'setup-save-child'), isTrue);
    expect(
      tester.widget<Text>(find.byKey(const Key('profile-summary'))).data,
      'P2 topics start at level 1, P1 topics at level 2, '
      'Olympiad at level 1.',
    );
    await tap(tester, 'start-olympiad-3');
    await tap(tester, 'setup-save-child');
    await tap(tester, 'setup-next');

    expect(find.byType(TimeStep), findsOneWidget);
    expect(
      await profiles().load(),
      const ChildProfile(nickname: 'Mia', schoolYear: 2, olympiadStartLevel: 3),
    );
    expect(await SetupRepository(db).step(), SetupStep.time);
  });

  testWidgets('closing the app before the profile asks again', (tester) async {
    await pastPin();
    await pumpApp(tester);
    await enter(tester, '2468');
    expect(find.byType(ChildrenStep), findsOneWidget);
  });

  testWidgets(
    'an updated install opens home and offers the profile in SCR-11',
    (tester) async {
      await pins().setPin('2468');
      // Updated installs have setup finished (FEAT-26 AD-12).
      await SetupRepository(db).finish();
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

  test('redirects: unfinished setup comes before everything', () {
    final s = AppSession(setupStep: SetupStep.children, clock: clock);
    for (final loc in [
      Routes.home,
      Routes.play('school'),
      Routes.parent,
      Routes.pinEntry,
      Routes.badges,
      Routes.profile,
    ]) {
      expect(redirectFor(s, false, loc), Routes.setup, reason: loc);
    }
    expect(redirectFor(s, false, Routes.setup), isNull);
    s.setupFinished();
    expect(redirectFor(s, false, Routes.setup), Routes.home);
    expect(redirectFor(s, false, Routes.home), isNull);
    expect(redirectFor(s, false, Routes.profile), Routes.pinEntry);
    expect(Routes.counts(Routes.setup), isFalse);
    expect(Routes.counts(Routes.profile), isFalse);
  });
}
