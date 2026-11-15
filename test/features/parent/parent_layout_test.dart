import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/stats.dart';
import 'package:number_ninja/features/parent/dashboard_screen.dart';
import 'package:number_ninja/features/parent/reset_screen.dart';
import 'package:number_ninja/features/parent/topic_detail_screen.dart';

import '../../ui/layout_checks.dart';
import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

/// AC-8 (NFR-09): SCR-09, SCR-10 and the reset screen at the six sizes and
/// at text scale 1.3: no layout exception or overflow anywhere on the page.
/// The child-screen 64 dp / 20 sp checks don't apply to parent screens.
void main() {
  late ParentHarness h;
  setUp(() async {
    h = ParentHarness();
    await h.setUp();
    await h.seed(numberTopic, [for (var i = 1; i <= 12; i++) (i, i <= 4)]);
    await h.seed(mcqTopic, [
      for (var i = 1; i <= 12; i++) (i, true),
    ], daysAgo: 9);
    await h.seed(dragTopic, [(1, false), (2, true)], daysAgo: 40, ms: 90000);
  });
  tearDown(() => h.db.close());

  final cases = [
    for (final dp in layoutSizes)
      ('${dp.width.toInt()} × ${dp.height.toInt()}', dp, 1.0),
    ('1280 × 800 at text scale $scaledText', scaledSize, scaledText),
  ];

  /// Scrolls every scrollable to its end, checking for exceptions on the way.
  Future<void> scrollAll(WidgetTester tester) async {
    expect(tester.takeException(), isNull);
    final scrollables = find.byType(Scrollable);
    for (var i = 0; i < scrollables.evaluate().length; i++) {
      final s = scrollables.at(i);
      for (var n = 0; n < 12; n++) {
        await tester.drag(s, const Offset(0, -400), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }
  }

  for (final (name, dp, scale) in cases) {
    group(name, () {
      Future<void> open(WidgetTester tester, String location) async {
        if (scale != 1) setTextScale(tester, scale);
        tester.view.physicalSize = physical(dp);
        tester.view.devicePixelRatio = 2;
        await h.openParent(tester, location);
      }

      testWidgets('SCR-09 dashboard', (tester) async {
        await open(tester, Routes.dashboard);
        expect(find.byType(DashboardScreen), findsOneWidget);
        expectNoOverlap(tester, ['track-p1', 'track-p2', 'track-olympiad']);
        expectNoOverlap(tester, ['needs-practice', 'trend-accuracy']);
        await scrollAll(tester);
      });

      testWidgets('SCR-09 all time', (tester) async {
        await open(tester, Routes.dashboardFor(StatsPeriod.all));
        await scrollAll(tester);
      });

      testWidgets('SCR-10 topic detail', (tester) async {
        await open(tester, Routes.topicDetail(numberTopic, StatsPeriod.all));
        expect(find.byType(TopicDetailScreen), findsOneWidget);
        expectNoOverlap(tester, ['topic-tally', 'trend-accuracy']);
        await scrollAll(tester);
      });

      testWidgets('reset screen', (tester) async {
        await open(tester, Routes.reset);
        expect(find.byType(ResetScreen), findsOneWidget);
        expectNoOverlap(tester, ['reset-warning', 'pin-dots', 'pin-0']);
        await scrollAll(tester);
      });
    });
  }
}
