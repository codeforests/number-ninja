import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/features/parent/day_screen.dart';

import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

/// FEAT-18 AC-3 (PAR-11): SCR-16 shows one day.
void main() {
  late ParentHarness h;
  const today = '2027-01-05'; // the harness clock's day
  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  /// Today: a finished money round, 3 of 4 right (q2 wrong, given '9').
  /// Two days ago: a fractions round, 2 of 2 right. 12 min screen time today
  /// over two devices.
  Future<int> seedDays() async {
    final id = await h.repo.startRound(numberTopic, 2);
    for (final n in [1, 2, 3, 4]) {
      await h.repo.saveAttempt(
        id,
        AnswerResult(
          questionId: '$numberTopic.t.$n',
          given: n == 2 ? '9' : 'x',
          correct: n != 2,
          timeMs: 4000,
        ),
      );
    }
    await h.repo.finishRound(id, score: 3, durationMs: 200000, stars: 1);
    await h.seed(mcqTopic, [(1, true), (2, true)], daysAgo: 2);
    for (final (device, secs) in [('a', 420), ('b', 300)]) {
      await h.db
          .into(h.db.dailyUsage)
          .insert(
            DailyUsageCompanion.insert(
              day: today,
              deviceId: device,
              secondsUsed: Value(secs),
            ),
          );
    }
    return id;
  }

  Future<void> press(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  testWidgets('shows the day, its topics, rounds and answers', (tester) async {
    final id = await seedDays();
    await h.openParent(tester, Routes.day(today));
    expect(find.byType(DayScreen), findsOneWidget);
    expect(find.textContaining('Today, Tue 5 Jan 2027'), findsOneWidget);
    expect(text(tester, 'day-answers'), '4');
    expect(text(tester, 'day-right'), '75 %');
    expect(text(tester, 'day-speed'), '4.0 s');
    expect(text(tester, 'day-minutes'), '12 min');
    expect(text(tester, 'day-round-count'), '1');
    expect(find.byKey(Key('day-topic-$numberTopic')), findsOneWidget);
    expect(find.byKey(Key('day-topic-$mcqTopic')), findsNothing);
    expect(find.textContaining('3 right'), findsOneWidget);
    expect(find.textContaining('Level 2'), findsOneWidget);
    expect(find.textContaining('3 min 20 s'), findsOneWidget);

    await press(tester, 'day-round-$id');
    expect(find.byKey(const Key('day-answer-3')), findsOneWidget);
    expect(find.text('Her answer: 9'), findsOneWidget);
    expect(find.textContaining('Right answer:'), findsOneWidget);
  });

  testWidgets('arrows step days; next is off on today; the picker opens', (
    tester,
  ) async {
    await seedDays();
    // Screen time on a day with no answers still shows (AC-3).
    await h.db
        .into(h.db.dailyUsage)
        .insert(
          DailyUsageCompanion.insert(
            day: '2027-01-04',
            deviceId: 'a',
            secondsUsed: const Value(120),
          ),
        );
    await h.openParent(tester, Routes.day(today));
    final next = tester.widget<IconButton>(find.byKey(const Key('day-next')));
    expect(next.onPressed, isNull);

    await press(tester, 'day-prev');
    expect(find.text('Mon 4 Jan 2027'), findsOneWidget);
    expect(find.byKey(const Key('day-empty')), findsOneWidget);
    expect(text(tester, 'day-minutes'), '2 min');

    await press(tester, 'day-prev');
    expect(find.text('Sun 3 Jan 2027'), findsOneWidget);
    expect(text(tester, 'day-answers'), '2');
    expect(find.byKey(Key('day-topic-$mcqTopic')), findsOneWidget);

    await press(tester, 'day-next');
    expect(find.text('Mon 4 Jan 2027'), findsOneWidget);

    await press(tester, 'day-pick');
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Mon 4 Jan 2027'), findsOneWidget);

    await press(tester, 'back-dashboard');
    expect(find.byType(DayScreen), findsNothing);
  });

  testWidgets('no day or a bad one opens today', (tester) async {
    await h.openParent(tester, '/parent/day?d=nope');
    expect(find.textContaining('Today, Tue 5 Jan 2027'), findsOneWidget);
    expect(find.byKey(const Key('day-empty')), findsOneWidget);
  });
}
