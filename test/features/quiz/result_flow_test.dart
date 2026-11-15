import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';

import 'quiz_harness.dart';

/// SCR-05 and the full round, AC-5 and AC-9.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  String text(String key) =>
      (find.byKey(Key(key)).evaluate().single.widget as Text).data!;

  int filledStars(WidgetTester tester) => [
    for (var i = 0; i < 3; i++)
      (tester.widget(find.byKey(Key('star-$i'))) as Icon).icon,
  ].where((icon) => icon == Icons.star).length;

  /// Plays a round of 10 from the current SCR-04, right on [right] of them;
  /// question i takes 5 + i seconds to answer and 30 s to read feedback.
  Future<void> playRound(WidgetTester tester, Set<int> right) async {
    for (var i = 0; i < 10; i++) {
      h.tick(Duration(seconds: 5 + i));
      await h.answer(tester, right: right.contains(i));
      h.tick(const Duration(seconds: 30)); // reading feedback is not counted
      await h.next(tester);
    }
  }

  test('formatMinSec shows m:ss rounded down', () {
    expect(formatMinSec(0), '0:00');
    expect(formatMinSec(9999), '0:09');
    expect(formatMinSec(95000), '1:35');
    expect(formatMinSec(600500), '10:00');
  });

  testWidgets('AC-5: a full round ends on SCR-05 with score, time, stars', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, {0, 1, 2, 4, 5, 7, 9}); // 7 right

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(text('result-score'), '7 / 10');
    expect(text('result-time'), '1:35'); // 5 + 6 + … + 14 = 95 s
    expect(filledStars(tester), 1);

    final round = await h.db.select(h.db.rounds).getSingle();
    expect(round.topicId, numberTopic);
    expect(round.score, 7);
    expect(round.durationMs, 95000);
    expect(round.stars, 1);
    expect(await h.db.select(h.db.attempts).get(), hasLength(10));
  });

  for (final (right, stars) in [
    ({for (var i = 0; i < 10; i++) i}, 3),
    ({0, 1, 2, 3, 4, 5, 6, 7, 8}, 2),
    (<int>{}, 0),
  ]) {
    testWidgets('AC-5: ${right.length} right shows $stars stars', (
      tester,
    ) async {
      await h.pumpApp(tester, location: Routes.quiz(mcqTopic));
      await playRound(tester, right);
      expect(text('result-score'), '${right.length} / 10');
      expect(filledStars(tester), stars);
      expect((await h.db.select(h.db.rounds).getSingle()).stars, stars);
    });
  }

  testWidgets('AC-9: home → School → topic → round → Play again', (
    tester,
  ) async {
    await h.pumpApp(tester);
    await h.tap(tester, 'track-school');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('topic-$dragTopic')));
    await h.tap(tester, 'topic-$dragTopic');
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(h.current(tester).topic, dragTopic);

    await playRound(tester, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9});
    expect(find.byType(ResultScreen), findsOneWidget);

    await h.tap(tester, 'play-again');
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
    final again = h.round(tester);
    expect(again.topicId, dragTopic);
    expect(again.quiz!.index, 0);
    expect(again.quiz!.results, isEmpty);
    final rounds = await h.db.select(h.db.rounds).get();
    expect(rounds.map((r) => r.topicId), [dragTopic, dragTopic]);
  });

  testWidgets('AC-9: Home on SCR-05 returns to SCR-02', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(mcqTopic));
    await playRound(tester, {0});
    await h.tap(tester, 'home');
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsNothing);
    expect(find.byKey(const Key('track-school')), findsOneWidget);
  });

  testWidgets('/result without a round goes home', (tester) async {
    await h.pumpApp(tester, location: Routes.result);
    expect(find.byType(ResultScreen), findsNothing);
    expect(find.byKey(const Key('track-school')), findsOneWidget);
  });

  group('AC-3: difficulty steps', () {
    /// The fake bank plus 12 level-2 questions of [numberTopic].
    QuestionBank withLevel2() => QuestionBank(
      version: 1,
      questions: [
        ...fakeBank().questions,
        for (var i = 0; i < 12; i++)
          Question(
            id: '$numberTopic.t2.${i + 1}',
            topic: numberTopic,
            level: 2,
            format: QuestionFormat.number,
            prompt: 'What is 12 + $i?',
            answer: '${12 + i}',
            explanation: '',
          ),
      ],
    );

    setUp(() => h = QuizHarness(bank: withLevel2()));

    Future<List<int>> levels() async => [
      for (final r in await (h.db.select(
        h.db.rounds,
      )..orderBy([(r) => .asc(r.id)])).get())
        r.level,
    ];

    testWidgets('3 stars at level 1 levels up; Play again is level 2', (
      tester,
    ) async {
      await h.pumpApp(tester, location: Routes.quiz(numberTopic));
      await playRound(tester, {for (var i = 0; i < 10; i++) i});
      expect(text('level-up'), 'Level up! Now level 2');

      await h.tap(tester, 'play-again');
      await tester.pumpAndSettle();
      expect(h.round(tester).level, 2);
      expect(h.round(tester).quiz!.questions.map((q) => q.level).toSet(), {2});
      expect(await levels(), [1, 2]);

      // 0 stars at level 2: no banner, and the next round is level 1.
      await playRound(tester, {});
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.byKey(const Key('level-up')), findsNothing);
      await h.tap(tester, 'play-again');
      await tester.pumpAndSettle();
      expect(h.round(tester).level, 1);
      expect(await levels(), [1, 2, 1]);
    });

    testWidgets('2 stars shows no banner', (tester) async {
      await h.pumpApp(tester, location: Routes.quiz(numberTopic));
      await playRound(tester, {0, 1, 2, 3, 4, 5, 6, 7});
      expect(filledStars(tester), 2);
      expect(find.byKey(const Key('level-up')), findsNothing);
    });
  });
}
