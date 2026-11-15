import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/domain/screen_time.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/features/screen_time/lock_screen.dart';

import '../quiz/quiz_harness.dart';

/// AC-4: the 2-minute warning and finishing the current question (TIM-03).
void main() {
  late QuizHarness h;
  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  const day = '2027-01-05';
  final warning = find.byKey(const Key('time-warning'));

  Future<void> leave(int secondsLeft) =>
      UsageRepository(h.db).addSeconds(day, 20 * 60 - secondsLeft);

  /// Lets [d] of foreground time pass and the flush timer fire.
  Future<void> spend(WidgetTester tester, Duration d) async {
    h.run(d);
    await tester.pump(flushEvery);
    await tester.pumpAndSettle();
  }

  Future<int> attempts() async =>
      (await h.db.select(h.db.attempts).get()).length;

  testWidgets('AC-4: crossing 2 minutes left shows the warning once', (
    tester,
  ) async {
    await leave(130);
    await h.pumpApp(tester);
    expect(warning, findsNothing);

    await spend(tester, const Duration(seconds: 10)); // 120 s left
    expect(warning, findsOneWidget);
    expect(find.text('2 minutes left! Finish this question.'), findsOneWidget);
    final text = tester.widget<Text>(
      find.text('2 minutes left! Finish this question.'),
    );
    expect(text.style!.fontSize, greaterThanOrEqualTo(22));

    await tester.pump(const Duration(seconds: 7)); // shown for 6 s
    await tester.pumpAndSettle();
    expect(warning, findsNothing);

    for (var i = 0; i < 3; i++) {
      await spend(tester, const Duration(seconds: 10));
      expect(warning, findsNothing);
    }
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AC-4: time running out mid-question: she answers it, sees '
      'feedback, and Next shows SCR-07', (tester) async {
    await leave(180);
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await h.answer(tester, right: true);
    await h.next(tester); // question 2

    await spend(tester, const Duration(minutes: 3)); // time is up
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(h.round(tester).quiz!.index, 1);

    await h.answer(tester, right: true);
    expect(h.round(tester).quiz!.phase, QuizPhase.feedback);
    expect(await attempts(), 2);

    await h.next(tester);
    expect(find.byType(LockScreen), findsOneWidget);
    expect(await attempts(), 2);
    final round = await h.db.select(h.db.rounds).getSingle();
    expect(round.finishedAt, isNull); // a quit round
  });

  testWidgets('AC-4: on the 10th question Next shows SCR-05, then Home shows '
      'SCR-07', (tester) async {
    await leave(180);
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    for (var i = 0; i < 9; i++) {
      await h.answer(tester, right: true);
      await h.next(tester);
    }
    await spend(tester, const Duration(minutes: 3));
    await h.answer(tester, right: true);
    await h.next(tester);
    expect(find.byType(ResultScreen), findsOneWidget);

    await spend(tester, const Duration(seconds: 30)); // still on SCR-05
    expect(find.byType(ResultScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('home')));
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);
    final round = await h.db.select(h.db.rounds).getSingle();
    expect(round.finishedAt, isNotNull);
  });

  testWidgets('AC-4: SCR-05 Play again also goes to SCR-07', (tester) async {
    await leave(180);
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    for (var i = 0; i < 9; i++) {
      await h.answer(tester, right: true);
      await h.next(tester);
    }
    await spend(tester, const Duration(minutes: 3));
    await h.answer(tester, right: true);
    await h.next(tester);
    await tester.tap(find.byKey(const Key('play-again')));
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);
    expect(await h.db.select(h.db.rounds).get(), hasLength(1));
  });

  testWidgets('AC-4: a question left open locks once graceCap has passed', (
    tester,
  ) async {
    await leave(180);
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await spend(tester, const Duration(minutes: 3)); // time is up
    expect(find.byType(QuizScreen), findsOneWidget);

    await spend(tester, graceCap - const Duration(seconds: 10));
    expect(find.byType(QuizScreen), findsOneWidget);

    await spend(tester, const Duration(seconds: 10));
    expect(find.byType(LockScreen), findsOneWidget);
  });

  testWidgets('AC-4: Quit during the grace goes to SCR-07', (tester) async {
    await leave(180);
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await spend(tester, const Duration(minutes: 3));
    await tester.tap(find.byKey(const Key('quit')));
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);
  });
}
