import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/child_repository.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/domain/family.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/features/family/who_screen.dart';
import 'package:number_ninja/features/parent/children_screen.dart';
import 'package:number_ninja/features/profile/profile_screen.dart';
import 'package:number_ninja/providers.dart';

import '../../ui/layout_checks.dart';
import '../quiz/quiz_harness.dart';

/// FEAT-25 AC-9 (NFR-09, NFR-17): SCR-17, SCR-18, SCR-12 with the avatar
/// row and the parent switcher at the six sizes and text scale 1.3, with
/// the longest nicknames and the most children.
void main() {
  late QuizHarness h;
  late int last;

  setUp(() async {
    h = QuizHarness();
    await ProfileRepository(
      h.db,
      clock: h.clock,
    ).save(ChildProfile(nickname: 'W' * maxNicknameLength, schoolYear: 2));
    final kids = ChildRepository(h.db, clock: h.clock);
    for (var i = 1; i < maxChildren; i++) {
      last = await kids.add(
        ChildProfile(nickname: 'M' * maxNicknameLength, schoolYear: 1),
        pickAvatar: true,
      );
    }
  });
  tearDown(() => h.db.close());

  final cases = [
    for (final dp in layoutSizes)
      ('${dp.width.toInt()} × ${dp.height.toInt()}', dp, 1.0),
    ('1280 × 800 at text scale $scaledText', scaledSize, scaledText),
  ];

  Future<void> scrollAll(WidgetTester tester) async {
    for (var n = 0; n < 8; n++) {
      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, -300),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  }

  Future<void> openParent(
    WidgetTester tester,
    Size dp,
    double scale,
    String location,
  ) async {
    if (scale != 1) setTextScale(tester, scale);
    await h.pumpApp(tester, size: physical(dp));
    h.container(tester).read(appSessionProvider).unlockParent();
    h.container(tester).read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }

  for (final (name, dp, scale) in cases) {
    testWidgets('SCR-17 with $maxChildren children at $name', (tester) async {
      h.choosingChild = true;
      if (scale != 1) setTextScale(tester, scale);
      final semantics = tester.ensureSemantics();
      await h.pumpApp(tester, size: physical(dp));
      expect(find.byType(WhoScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectChildSizes(tester);
      await scrollAll(tester);
      semantics.dispose();
    });

    testWidgets('SCR-18 at $name', (tester) async {
      await openParent(tester, dp, scale, Routes.children);
      expect(find.byType(ChildrenScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('add-child')), findsNothing);
      await scrollAll(tester);
    });

    testWidgets('SCR-12 with the avatar row and remove at $name', (
      tester,
    ) async {
      await openParent(tester, dp, scale, Routes.childProfile(last));
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byKey(const Key('avatar-tiger')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await scrollAll(tester);
      expect(find.byKey(const Key('remove-child')), findsOneWidget);
      expectNoOverlap(tester, ['profile-save', 'remove-child']);
    });

    testWidgets('the parent switcher on SCR-09 and SCR-11 at $name', (
      tester,
    ) async {
      await openParent(tester, dp, scale, Routes.dashboard);
      expect(find.byKey(const Key('parent-child-switch')), findsOneWidget);
      expect(tester.takeException(), isNull);
      expectNoOverlap(tester, ['parent-child-switch', 'export-pdf']);
      h.container(tester).read(routerProvider).go(Routes.parent);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expectNoOverlap(tester, ['parent-child-switch', 'parent-done']);
    });
  }
}
