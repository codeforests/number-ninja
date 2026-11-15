import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/features/quiz/quiz_controller.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';

import 'quiz_harness.dart';

/// SCR-04 tests for AC-2, AC-3, AC-4 and AC-8.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  String feedback() =>
      (find.byKey(const Key('feedback-title')).evaluate().single.widget as Text)
          .data!;

  for (final (name, topic) in [
    ('MCQ', mcqTopic),
    ('number', numberTopic),
    ('drag', dragTopic),
  ]) {
    testWidgets('AC-2/AC-4: $name answered right then wrong on SCR-04', (
      tester,
    ) async {
      await h.pumpApp(tester, location: Routes.quiz(topic));
      expect(find.byType(QuizScreen), findsOneWidget);

      await h.answer(tester, right: true);
      expect(feedback(), 'Right!');
      expect(find.byKey(const Key('feedback-answer')), findsNothing);
      expect(h.round(tester).quiz!.results.single.correct, isTrue);

      await h.next(tester);
      final q = h.current(tester);
      await h.answer(tester, right: false);
      expect(feedback(), 'Not quite');
      expect(
        find.text('The answer is ${correctAnswerText(q)}'),
        findsOneWidget,
      );
      expect(find.text(q.explanation), findsOneWidget);
      expect(h.round(tester).quiz!.results.last.correct, isFalse);
    });
  }

  testWidgets('AC-2: drag by dragging a chip on SCR-04', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(dragTopic));
    final q = h.current(tester);
    final want = q.answer as List<String>;
    for (var s = 0; s < want.length; s++) {
      final chip = find.byKey(Key('chip-${q.drag!.items.indexOf(want[s])}'));
      final slot = find.byKey(Key('slot-$s'));
      await tester.drag(chip, tester.getCenter(slot) - tester.getCenter(chip));
      await tester.pumpAndSettle();
    }
    await h.tap(tester, 'check');
    await tester.pumpAndSettle();
    expect(feedback(), 'Right!');
  });

  testWidgets('AC-3: the attempt is saved before Next shows', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    final q = h.current(tester);
    h.tick(const Duration(milliseconds: 4200));
    for (final k in ['3', 'dot', '6']) {
      await h.tap(tester, 'key-$k');
    }
    h.repo.gate = Completer<void>(); // hold the write
    await h.tap(tester, 'check');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('next')), findsNothing);
    expect(find.byKey(const Key('feedback-title')), findsNothing);
    expect(await h.db.select(h.db.attempts).get(), isEmpty);

    h.repo.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('next')), findsOneWidget);
    final row = await h.db.select(h.db.attempts).getSingle();
    expect(row.questionId, q.id);
    expect(row.answerGiven, '3.6');
    expect(row.correct, isTrue);
    expect(row.timeMs, 4200);
    // Drift stores dates to the second.
    expect(
      h.now.difference(row.answeredAt),
      lessThan(const Duration(seconds: 1)),
    );
  });

  testWidgets('AC-3: leaving mid-round keeps every answered attempt', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.quiz(mcqTopic));
    for (var i = 0; i < 3; i++) {
      await h.answer(tester, right: i != 1);
      if (i < 2) await h.next(tester);
    }
    await tester.pumpWidget(const SizedBox()); // the app is killed
    final attempts = await h.db.select(h.db.attempts).get();
    expect(attempts.map((a) => a.correct), [true, false, true]);
    final round = await h.db.select(h.db.rounds).getSingle();
    expect(round.score, 0);
  });

  testWidgets('quit goes home without a dialog', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(mcqTopic));
    await h.tap(tester, 'quit');
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsNothing);
    expect(find.byKey(const Key('track-school')), findsOneWidget);
  });

  test('AC-8: Next completes synchronously with no I/O', () async {
    final container = ProviderContainer(overrides: h.overrides);
    addTearDown(container.dispose);
    final sub = container.listen(quizControllerProvider, (_, _) {});
    addTearDown(sub.close);
    final controller = container.read(quizControllerProvider.notifier);

    await controller.start(numberTopic);
    final first = container.read(quizControllerProvider).quiz!;
    await controller.check('3.60');
    expect(
      container.read(quizControllerProvider).quiz!.phase,
      QuizPhase.feedback,
    );

    final calls = h.repo.calls;
    h.tick(const Duration(seconds: 5));
    controller.next(); // returns void: nothing to await
    final after = container.read(quizControllerProvider).quiz!;
    expect(after.phase, QuizPhase.answering);
    expect(after.index, 1);
    expect(after.current.id, isNot(first.current.id));
    expect(after.shownAt, h.now);
    expect(h.repo.calls, calls);
  });
}
