import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/features/revision/revision_start_screen.dart';

import '../quiz/quiz_harness.dart';
import 'revision_test.dart' show seedMistakes;

/// FEAT-30 AC-3 (child half) and AC-5: revision on the free tier.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness()..plus = false);
  tearDown(() => h.db.close());

  testWidgets('SCR-05 offers no revision and shows no lock', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    for (var i = 0; i < 10; i++) {
      h.tick(const Duration(seconds: 5));
      await h.answer(tester, right: i >= 3);
      await h.next(tester);
    }
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byKey(const Key('revise-topic')), findsNothing);
    expect(find.byKey(const Key('home-revise-locked')), findsNothing);
    expect(find.byIcon(Icons.lock), findsNothing);
  });

  testWidgets('/revise/mixed goes home', (tester) async {
    await seedMistakes(h, numberTopic, 3);
    await h.pumpApp(tester, location: Routes.revise('mixed'));
    expect(find.byType(RevisionStartScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('SCR-02: lock card, ask-a-grown-up sheet with one OK (AC-5)', (
    tester,
  ) async {
    await seedMistakes(h, numberTopic, 3);
    await h.pumpApp(tester);
    expect(find.byKey(const Key('home-revise')), findsNothing);
    await h.tap(tester, 'home-revise-locked');
    await tester.pumpAndSettle();
    final sheet = find.byKey(const Key('revise-ask-sheet'));
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(
        of: sheet,
        matching: find.text(
          'Revision is part of BrainBubblz Plus. Ask a grown-up to have a look.',
        ),
      ),
      findsOneWidget,
    );
    // One button, no price or link.
    expect(
      find.descendant(of: sheet, matching: find.byType(FilledButton)),
      findsOneWidget,
    );
    // The message and "OK" are the only texts.
    expect(
      find.descendant(of: sheet, matching: find.byType(Text)),
      findsNWidgets(2),
    );
    expect(find.textContaining(r'$'), findsNothing);
    await h.tap(tester, 'revise-ask-ok');
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('no lock card when no revision is due', (tester) async {
    await seedMistakes(h, numberTopic, 2);
    await h.pumpApp(tester);
    expect(find.byKey(const Key('home-revise-locked')), findsNothing);
  });

  testWidgets('Plus back on: the revision card returns', (tester) async {
    await seedMistakes(h, numberTopic, 3);
    await h.pumpApp(tester);
    h.setPlus(tester, true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-revise')), findsOneWidget);
    expect(find.byKey(const Key('home-revise-locked')), findsNothing);
  });
}
