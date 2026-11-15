import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' hide Badge;
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/domain/badges.dart';
import 'package:number_ninja/features/badges/badge_shelf_screen.dart';
import 'package:number_ninja/features/quiz/quiz_controller.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';

import '../../ui/layout_checks.dart';
import '../quiz/quiz_harness.dart';

/// FEAT-08 AC-6: SCR-06, SCR-05 with three new badges and SCR-02 with a
/// latest badge at every NFR-09 size, and NFR-03 sizes on SCR-05/06.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  final cases = [
    for (final dp in layoutSizes)
      ('${dp.width.toInt()} × ${dp.height.toInt()}', dp, 1.0),
    ('1280 × 800 at text scale $scaledText', scaledSize, scaledText),
  ];

  Future<void> pump(WidgetTester tester, Size dp, double scale, String at) {
    if (scale != 1) setTextScale(tester, scale);
    return h.pumpApp(tester, location: at, size: physical(dp));
  }

  /// Half the badges earned, so both tile kinds show.
  Future<void> seed() async {
    for (final (i, b) in badges.indexed) {
      if (i.isEven) {
        await h.db
            .into(h.db.badgesEarned)
            .insert(
              BadgesEarnedCompanion.insert(
                badgeId: b.id,
                earnedAt: DateTime(2026, 11, 15 + i),
              ),
            );
      }
    }
  }

  final threeNew = RoundSummary(
    topicId: mcqTopic,
    level: 1,
    score: 10,
    total: 10,
    durationMs: 95000,
    stars: 3,
    newBadges: [
      badgesById['first-round']!,
      badgesById['perfect-10']!,
      badgesById['bar-model-builder']!,
    ],
  );

  Future<void> showResult(WidgetTester tester, Size dp, double scale) async {
    await pump(tester, dp, scale, Routes.home);
    h.container(tester).read(routerProvider).go(Routes.result, extra: threeNew);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
  }

  for (final (name, dp, scale) in cases) {
    group(name, () {
      testWidgets('SCR-06 shelf', (tester) async {
        await seed();
        await pump(tester, dp, scale, Routes.badges);
        expect(find.byType(BadgeShelfScreen), findsOneWidget);
        expectNoOverlap(tester, ['badges-back', 'badge-count']);
        for (final b in badges) {
          await tester.scrollUntilVisible(
            find.byKey(Key('badge-${b.id}')),
            100,
            scrollable: find.descendant(
              of: find.byKey(const Key('badge-shelf')),
              matching: find.byType(Scrollable),
            ),
          );
          expectNoOverlap(tester, ['badges-back', 'badge-${b.id}']);
        }
      });

      testWidgets('SCR-05 with three new badges', (tester) async {
        await showResult(tester, dp, scale);
        expectNoOverlap(tester, [
          'result-stars',
          'new-badges',
          'new-badge-first-round',
          'new-badge-perfect-10',
          'new-badge-bar-model-builder',
        ]);
        await tester.ensureVisible(find.byKey(const Key('see-badges')));
        await tester.pumpAndSettle();
        expectNoOverlap(tester, ['play-again', 'home', 'see-badges']);
      });

      testWidgets('SCR-02 with a latest badge', (tester) async {
        await seed();
        await pump(tester, dp, scale, Routes.home);
        expect(find.textContaining('Latest: '), findsOneWidget);
        expectNoOverlap(tester, [
          'parent-button',
          'badges-button',
          'track-school',
          'track-olympiad',
        ]);
      });
    });
  }

  group('AC-6: NFR-03 tap targets ≥ 64 dp and text ≥ 20 sp', () {
    for (final (name, dp, scale) in [cases.first, cases[4], cases[5]]) {
      testWidgets('SCR-06 at $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await seed();
        await pump(tester, dp, scale, Routes.badges);
        await expectChildSizes(tester);
        semantics.dispose();
      });

      testWidgets('SCR-05 with badges at $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await showResult(tester, dp, scale);
        await expectChildSizes(tester);
        semantics.dispose();
      });

      testWidgets('SCR-02 with a badge at $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await seed();
        await pump(tester, dp, scale, Routes.home);
        await expectChildSizes(tester);
        semantics.dispose();
      });
    }
  });
}
