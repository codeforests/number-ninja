import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/features/revision/revision_start_screen.dart';

import '../quiz/quiz_harness.dart';
import 'revision_test.dart' show seedMistakes;

/// FEAT-11 AC-4: the revision entries on SCR-05 and SCR-02 (REV-03).
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  Future<void> playRound(WidgetTester tester, {required int wrong}) async {
    for (var i = 0; i < 10; i++) {
      h.tick(const Duration(seconds: 5));
      await h.answer(tester, right: i >= wrong);
      await h.next(tester);
    }
  }

  testWidgets('SCR-05 offers the topic after a wrong answer', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, wrong: 1);
    expect(find.byType(ResultScreen), findsOneWidget);
    await h.tap(tester, 'revise-topic');
    await tester.pumpAndSettle();
    expect(find.byType(RevisionStartScreen), findsOneWidget);
    expect(
      (tester.widget(find.byKey(const Key('revise-mistakes'))) as Text).data,
      '1 question to try again',
    );
  });

  testWidgets('SCR-05 has no revise-topic after 10/10 with no history', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, wrong: 0);
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byKey(const Key('revise-topic')), findsNothing);
  });

  testWidgets('SCR-02 shows home-revise with 3 mistakes, not with 2', (
    tester,
  ) async {
    await seedMistakes(h, numberTopic, 2);
    await h.pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('home-revise')), findsNothing);
  });

  testWidgets('home-revise opens /revise/mixed', (tester) async {
    await seedMistakes(h, numberTopic, 3);
    await h.pumpApp(tester);
    await h.tap(tester, 'home-revise');
    await tester.pumpAndSettle();
    expect(find.byType(RevisionStartScreen), findsOneWidget);
    expect(
      (tester.widget(find.byKey(const Key('revise-title'))) as Text).data,
      'Mixed revision',
    );
  });

  // Added in verify: answering every mistake right in a mixed revision round
  // takes them off the list, and SCR-02 re-reads the history on return.
  testWidgets('a revision round that fixes the mistakes removes home-revise', (
    tester,
  ) async {
    await seedMistakes(h, numberTopic, 3);
    h.tick(const Duration(hours: 1));
    await h.pumpApp(tester);
    await h.tap(tester, 'home-revise');
    await tester.pumpAndSettle();
    await h.tap(tester, 'revise-go');
    await tester.pumpAndSettle();
    await playRound(tester, wrong: 0);
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byKey(const Key('revise-topic')), findsNothing);
    await h.tap(tester, 'home');
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('home-revise')), findsNothing);
  });
}
