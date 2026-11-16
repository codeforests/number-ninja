import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/domain/topics.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/features/revision/revision_start_screen.dart';

import '../quiz/quiz_harness.dart';

/// Seeds a quit round of [topic] with wrong answers to questions 1..[n].
Future<void> seedMistakes(QuizHarness h, String topic, int n) async {
  final id = await h.repo.startRound(topic, 1);
  for (var i = 1; i <= n; i++) {
    await h.repo.saveAttempt(
      id,
      AnswerResult(
        questionId: '$topic.t.$i',
        given: 'x',
        correct: false,
        timeMs: 4000,
      ),
    );
  }
}

/// FEAT-11 AC-3: SCR-14 and a revision round on SCR-04/SCR-05.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  String text(String key) =>
      (find.byKey(Key(key)).evaluate().single.widget as Text).data!;

  testWidgets('SCR-14 shows title, mistakes and tricky kinds; Go plays a '
      'revision round that changes no level', (tester) async {
    await seedMistakes(h, numberTopic, 5);
    h.tick(const Duration(hours: 1));
    await h.pumpApp(tester, location: Routes.revise(numberTopic));

    expect(find.byType(RevisionStartScreen), findsOneWidget);
    expect(text('revise-title'), topicsById[numberTopic]!.name);
    expect(text('revise-mistakes'), '5 questions to try again');
    expect(text('revise-types'), 'Tricky kinds: T');

    await h.tap(tester, 'revise-go');
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(text('quiz-revision'), 'Revision: ${topicsById[numberTopic]!.name}');
    final qs = h.round(tester).quiz!.questions;
    expect(qs, hasLength(10));
    expect(qs.every((q) => q.topic == numberTopic), isTrue);
    expect(
      qs.map((q) => q.id),
      containsAll([for (var i = 1; i <= 5; i++) '$numberTopic.t.$i']),
    );

    for (var i = 0; i < 10; i++) {
      h.tick(const Duration(seconds: 5));
      await h.answer(tester, right: true);
      await h.next(tester);
    }
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(text('result-score'), '10 / 10');
    expect(find.byKey(const Key('result-stars')), findsOneWidget);
    expect(find.byKey(const Key('level-up')), findsNothing);
    expect(find.byKey(const Key('play-again')), findsNothing);

    final rounds = await h.db.select(h.db.rounds).get();
    final rev = rounds.singleWhere((r) => r.kind == roundKindRevision);
    expect(rev.topicId, numberTopic);
    expect(rev.score, 10);
    expect(rev.finishedAt, isNotNull);
    expect(await h.db.select(h.db.attempts).get(), hasLength(15));
    expect(await h.repo.levelFor(numberTopic), 1);
    expect(await h.repo.progress(), isEmpty);
  });

  testWidgets('a mixed round says Revision and stores topic mixed', (
    tester,
  ) async {
    await seedMistakes(h, numberTopic, 2);
    await seedMistakes(h, mcqTopic, 2);
    await h.pumpApp(tester, location: Routes.revise('mixed'));
    expect(text('revise-title'), 'Mixed revision');
    expect(text('revise-mistakes'), '4 questions to try again');
    await h.tap(tester, 'revise-go');
    await tester.pumpAndSettle();
    expect(text('quiz-revision'), 'Revision');
    expect(h.round(tester).quiz!.questions.map((q) => q.topic).toSet(), {
      numberTopic,
      mcqTopic,
    });
    final rev = (await h.db.select(h.db.rounds).get()).last;
    expect(rev.topicId, 'mixed');
    expect(rev.kind, roundKindRevision);
    expect(rev.level, 1);
  });

  testWidgets('nothing to revise: message and Home, no Go', (tester) async {
    await h.pumpApp(tester, location: Routes.revise('mixed'));
    expect(find.byKey(const Key('revise-nothing')), findsOneWidget);
    expect(find.byKey(const Key('revise-go')), findsNothing);
    await h.tap(tester, 'home');
    await tester.pumpAndSettle();
    expect(find.byType(RevisionStartScreen), findsNothing);
  });

  testWidgets('a stale revision quiz link goes home', (tester) async {
    await h.pumpApp(tester, location: Routes.reviseQuiz('mixed'));
    expect(find.byType(QuizScreen), findsNothing);
    expect(await h.db.select(h.db.rounds).get(), isEmpty);
  });

  test('revision routes count as screen time (TIM-01)', () {
    expect(Routes.counts(Routes.revise('mixed')), isTrue);
    expect(Routes.counts(Routes.reviseQuiz('p1.place')), isTrue);
  });

  test('tricky kinds text shows 3 then "and N more"', () {
    expect(
      RevisionStartScreen.trickyText(['A', 'B', 'C', 'D', 'E']),
      'Tricky kinds: A, B, C and 2 more',
    );
  });
}
