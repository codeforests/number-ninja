import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/screen_time/lock_screen.dart';

import '../../ui/layout_checks.dart';
import '../quiz/quiz_harness.dart';

/// AC-7: SCR-07 and SCR-02 with minutes left at every NFR-09 size and at
/// text scale 1.3, with NFR-03 tap and text sizes.
void main() {
  late QuizHarness h;
  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  final cases = [
    for (final dp in layoutSizes)
      ('${dp.width.toInt()} × ${dp.height.toInt()}', dp, 1.0),
    ('1280 × 800 at text scale $scaledText', scaledSize, scaledText),
  ];

  Future<void> pump(WidgetTester tester, Size dp, double scale) {
    if (scale != 1) setTextScale(tester, scale);
    return h.pumpApp(tester, location: Routes.home, size: physical(dp));
  }

  for (final (name, dp, scale) in cases) {
    group(name, () {
      testWidgets('SCR-07 lock', (tester) async {
        final semantics = tester.ensureSemantics();
        await UsageRepository(h.db).addSeconds('2027-01-05', 20 * 60);
        await pump(tester, dp, scale);
        expect(find.byType(LockScreen), findsOneWidget);
        expectNoOverlap(tester, ['lock-title', 'lock-parent']);
        expect(
          tester.getSize(find.byKey(const Key('lock-parent'))).height,
          greaterThanOrEqualTo(64),
        );
        await expectChildSizes(tester);
        semantics.dispose();
      });

      testWidgets('SCR-02 with minutes left', (tester) async {
        final semantics = tester.ensureSemantics();
        await UsageRepository(h.db).addSeconds('2027-01-05', 5 * 60);
        await pump(tester, dp, scale);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('15 min left'), findsOneWidget);
        expectNoOverlap(tester, [
          'parent-button',
          'minutes-left',
          'track-school',
          'track-olympiad',
        ]);
        await expectChildSizes(tester);
        semantics.dispose();
      });
    });
  }
}
