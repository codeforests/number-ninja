import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/features/quiz/quiz_controller.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';

import '../../ui/layout_checks.dart';
import '../quiz/quiz_harness.dart';

/// FEAT-09 AC-5 (NFR-02, NFR-03, NFR-09): SCR-05 while the confetti and
/// the star pops are still running, at every size and at text scale 1.3.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  final cases = [
    for (final dp in layoutSizes)
      ('${dp.width.toInt()} × ${dp.height.toInt()}', dp, 1.0),
    ('1280 × 800 at text scale $scaledText', scaledSize, scaledText),
  ];

  const summary = RoundSummary(
    topicId: 'oly.logic',
    level: 1,
    score: 10,
    total: 10,
    durationMs: 95000,
    stars: 3,
  );

  for (final (name, dp, scale) in cases) {
    testWidgets('$name: SCR-05 mid-celebration', (tester) async {
      if (scale != 1) setTextScale(tester, scale);
      await h.pumpApp(tester, location: Routes.home, size: physical(dp));
      h
          .container(tester)
          .read(routerProvider)
          .go(Routes.result, extra: summary);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.byKey(const Key('celebration')), findsOneWidget);
      expectNoOverlap(tester, ['result-stars', 'result-score']);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await expectChildSizes(tester);
    });
  }
}
