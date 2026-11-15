import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/features/badges/badge_shelf_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/providers.dart';

import 'quiz_harness.dart';

/// FEAT-08 AC-3 (BDG-02): new badges on SCR-05.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  Future<void> playRound(WidgetTester tester, {required int right}) async {
    for (var i = 0; i < 10; i++) {
      h.tick(const Duration(seconds: 5));
      await h.answer(tester, right: i < right);
      await h.next(tester);
    }
  }

  testWidgets('a first 10/10 round shows its badges; the next shows none', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, right: 10);

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byKey(const Key('new-badges')), findsOneWidget);
    expect(find.text('New badges!'), findsOneWidget);
    expect(find.byKey(const Key('new-badge-first-round')), findsOneWidget);
    expect(find.byKey(const Key('new-badge-perfect-10')), findsOneWidget);
    expect(find.text('Perfect 10'), findsOneWidget);
    expect(await h.db.select(h.db.badgesEarned).get(), isNotEmpty);

    await h.tap(tester, 'play-again');
    await tester.pumpAndSettle();
    await playRound(tester, right: 10);
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byKey(const Key('result-score')), findsOneWidget);
    expect(find.byKey(const Key('new-badges')), findsNothing);
    expect(find.byKey(const Key('see-badges')), findsNothing);
  });

  testWidgets('one new badge says "New badge!" and pops in', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    for (var i = 0; i < 10; i++) {
      h.tick(const Duration(seconds: 5));
      await h.answer(tester, right: i < 6);
      if (i < 9) await h.next(tester);
    }
    await tester.tap(find.byKey(const Key('next')));
    await tester.pump();
    await tester.pump();
    final scale = tester.widget<Transform>(
      find
          .descendant(
            of: find.byKey(const Key('new-badge-first-round')),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(scale.transform.entry(0, 0), lessThan(1), reason: 'still popping');
    await tester.pumpAndSettle();
    expect(find.text('New badge!'), findsOneWidget);
    expect(find.byKey(const Key('new-badge-first-round')), findsOneWidget);
  });

  testWidgets('a badge failure still shows SCR-05 with score and stars', (
    tester,
  ) async {
    h.more = [
      badgeRepositoryProvider.overrideWith(
        (ref) async => throw StateError('broken'),
      ),
    ];
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, right: 10);

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.text('10 / 10'), findsOneWidget);
    expect(find.byKey(const Key('result-stars')), findsOneWidget);
    expect(find.byKey(const Key('new-badges')), findsNothing);
    expect(await h.db.select(h.db.rounds).get(), hasLength(1));
  });

  testWidgets('"My badges" opens SCR-06', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, right: 10);
    await h.tap(tester, 'see-badges');
    await tester.pumpAndSettle();
    expect(find.byType(BadgeShelfScreen), findsOneWidget);
  });
}
