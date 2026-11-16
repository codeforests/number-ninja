import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/features/profile/profile_screen.dart';
import 'package:number_ninja/providers.dart';

import '../../ui/layout_checks.dart';
import '../quiz/quiz_harness.dart';

/// FEAT-10 AC-6 (NFR-03, NFR-09): SCR-12 at the six sizes and text scale
/// 1.3 with no overflow; SCR-02 with a 20-character nickname still passes
/// the child-screen checks.
void main() {
  late QuizHarness h;

  setUp(() async {
    h = QuizHarness();
    await ProfileRepository(h.db, clock: h.clock).save(
      ChildProfile(
        nickname: 'W' * maxNicknameLength,
        schoolYear: 2,
        schoolStartLevel: 3,
      ),
    );
  });
  tearDown(() => h.db.close());

  final cases = [
    for (final dp in layoutSizes)
      ('${dp.width.toInt()} × ${dp.height.toInt()}', dp, 1.0),
    ('1280 × 800 at text scale $scaledText', scaledSize, scaledText),
  ];

  Future<void> pump(WidgetTester tester, Size dp, double scale) async {
    if (scale != 1) setTextScale(tester, scale);
    await h.pumpApp(tester, size: physical(dp));
  }

  for (final (name, dp, scale) in cases) {
    testWidgets('SCR-12 at $name', (tester) async {
      await pump(tester, dp, scale);
      h.container(tester).read(appSessionProvider).unlockParent();
      h.container(tester).read(routerProvider).go(Routes.profile);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (var n = 0; n < 8; n++) {
        await tester.drag(
          find.byType(Scrollable).first,
          const Offset(0, -300),
          warnIfMissed: false,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.byKey(const Key('profile-save')), findsOneWidget);
      expectNoOverlap(tester, ['profile-summary', 'profile-save']);
    });

    testWidgets('SCR-02 with a long nickname at $name', (tester) async {
      await pump(tester, dp, scale);
      expect(find.byKey(const Key('greeting')), findsOneWidget);
      expectNoOverlap(tester, [
        'greeting',
        'parent-button',
        'track-school',
        'track-olympiad',
      ]);
    });
  }

  for (final (name, dp, scale) in [cases.first, cases[4], cases[5]]) {
    testWidgets('SCR-02 child sizes with a long nickname at $name', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, dp, scale);
      await expectChildSizes(tester);
      semantics.dispose();
    });
  }
}
