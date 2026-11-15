import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/topics.dart';
import 'package:number_ninja/features/quiz/quiz_controller.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/features/topics/topic_map_screen.dart';

import '../ui/layout_checks.dart';
import 'quiz/quiz_harness.dart';

/// SCR-02, SCR-03 and SCR-05 at every NFR-09 size (AC-6), and NFR-03 tap
/// and text sizes on SCR-02 and SCR-03.
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

  /// Some stars and levels, so tiles show filled stars and level 2.
  Future<void> seed() async {
    for (final (topic, level, stars) in [
      ('p1.place', 1, 3),
      ('p2.regroup', 2, 2),
      ('oly.logic', 1, 1),
    ]) {
      h.tick(const Duration(minutes: 1));
      final id = await h.repo.startRound(topic, level);
      await h.repo.finishRound(id, score: 0, durationMs: 1, stars: stars);
    }
  }

  for (final (name, dp, scale) in cases) {
    group(name, () {
      testWidgets('SCR-02 home', (tester) async {
        await seed();
        await pump(tester, dp, scale, Routes.home);
        expect(find.byKey(const Key('track-stars-school')), findsOneWidget);
        expectNoOverlap(tester, [
          'parent-button',
          'track-school',
          'track-olympiad',
        ]);
      });

      for (final track in [TrackSlug.school, TrackSlug.olympiad]) {
        testWidgets('SCR-03 $track', (tester) async {
          await seed();
          await pump(tester, dp, scale, Routes.play(track));
          expect(find.byType(TopicMapScreen), findsOneWidget);
          final ids = [
            for (final t in topics)
              if (TrackSlug.tracks(track).contains(t.track)) t.id,
          ];
          // Every tile, scrolled into view, lays out without overflow and
          // within the screen's width.
          for (final id in ids) {
            await tester.scrollUntilVisible(
              find.byKey(Key('topic-$id')),
              100,
              scrollable: find.descendant(
                of: find.byKey(const Key('topic-map')),
                matching: find.byType(Scrollable),
              ),
            );
            expectNoOverlap(tester, ['back', 'topic-$id']);
          }
        });
      }

      testWidgets('SCR-05 result with level up', (tester) async {
        await pump(tester, dp, scale, Routes.home);
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
        expect(find.byKey(const Key('level-up')), findsOneWidget);
        expectNoOverlap(tester, [
          'result-stars',
          'level-up',
          'result-score',
          'result-time',
        ]);
        expectNoOverlap(tester, ['play-again', 'home']);
      });
    });
  }

  group('AC-6: NFR-03 tap targets ≥ 64 dp and text ≥ 20 sp', () {
    for (final (name, dp, scale) in [cases.first, cases[4], cases[5]]) {
      testWidgets('SCR-02 at $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await seed();
        await pump(tester, dp, scale, Routes.home);
        await expectChildSizes(tester);
        semantics.dispose();
      });

      for (final track in [TrackSlug.school, TrackSlug.olympiad]) {
        testWidgets('SCR-03 $track at $name', (tester) async {
          final semantics = tester.ensureSemantics();
          await seed();
          await pump(tester, dp, scale, Routes.play(track));
          await expectChildSizes(tester);
          semantics.dispose();
        });
      }

      testWidgets('SCR-05 at $name', (tester) async {
        final semantics = tester.ensureSemantics();
        await pump(tester, dp, scale, Routes.home);
        h
            .container(tester)
            .read(routerProvider)
            .go(
              Routes.result,
              extra: const RoundSummary(
                topicId: mcqTopic,
                level: 2,
                score: 10,
                total: 10,
                durationMs: 1000,
                stars: 3,
              ),
            );
        await tester.pumpAndSettle();
        await expectChildSizes(tester);
        semantics.dispose();
      });
    }
  });
}
