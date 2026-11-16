import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/features/quiz/quiz_controller.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/features/revision/revision_start_screen.dart';

import '../../ui/layout_checks.dart';
import '../quiz/quiz_harness.dart';
import 'revision_test.dart' show seedMistakes;

/// FEAT-11 AC-6 (NFR-03, NFR-09): SCR-14, SCR-02 with `home-revise` and
/// SCR-05 with `revise-topic` at the six sizes and at text scale 1.3.
void main() {
  late QuizHarness h;

  setUp(() async {
    h = QuizHarness();
    await seedMistakes(h, mcqTopic, 6);
  });
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

  Future<void> result(WidgetTester tester) async {
    h
        .container(tester)
        .read(routerProvider)
        .go(
          Routes.result,
          extra: const RoundSummary(
            topicId: mcqTopic,
            level: 1,
            score: 10,
            total: 10,
            durationMs: 95000,
            stars: 3,
          ),
        );
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byKey(const Key('revise-topic')), findsOneWidget);
  }

  for (final (name, dp, scale) in cases) {
    group(name, () {
      for (final scope in [mcqTopic, 'mixed']) {
        testWidgets('SCR-14 $scope', (tester) async {
          await pump(tester, dp, scale, Routes.revise(scope));
          expect(find.byType(RevisionStartScreen), findsOneWidget);
          expectNoOverlap(tester, [
            'back-home',
            'revise-title',
            'revise-mistakes',
            'revise-types',
            'revise-go',
          ]);
        });
      }

      testWidgets('SCR-02 with home-revise', (tester) async {
        await pump(tester, dp, scale, Routes.home);
        await tester.ensureVisible(find.byKey(const Key('home-revise')));
        await tester.pumpAndSettle();
        expectNoOverlap(tester, [
          'parent-button',
          'track-school',
          'track-olympiad',
          'home-revise',
        ]);
      });

      testWidgets('SCR-05 with revise-topic', (tester) async {
        await pump(tester, dp, scale, Routes.home);
        await result(tester);
        expectNoOverlap(tester, [
          'result-stars',
          'level-up',
          'result-score',
          'result-time',
        ]);
        expectNoOverlap(tester, ['play-again', 'revise-topic', 'home']);
      });
    });
  }

  group('NFR-03 tap targets ≥ 64 dp and text ≥ 20 sp', () {
    for (final (name, dp, scale) in [
      cases.first,
      cases[4],
      cases[5],
      cases[6],
    ]) {
      testWidgets('SCR-14 at $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, dp, scale, Routes.revise(mcqTopic));
        await expectChildSizes(tester);
        semantics.dispose();
      });

      testWidgets('SCR-02 with home-revise at $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, dp, scale, Routes.home);
        expect(find.byKey(const Key('home-revise')), findsOneWidget);
        await expectChildSizes(tester);
        semantics.dispose();
      });

      testWidgets('SCR-05 with revise-topic at $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, dp, scale, Routes.home);
        await result(tester);
        await expectChildSizes(tester);
        semantics.dispose();
      });
    }
  });
}
