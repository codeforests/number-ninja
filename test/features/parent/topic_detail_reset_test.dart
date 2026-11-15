import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/stats.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/parent/dashboard_screen.dart';
import 'package:number_ninja/features/parent/parent_screen.dart';
import 'package:number_ninja/features/parent/pin_entry_screen.dart';
import 'package:number_ninja/features/parent/reset_screen.dart';
import 'package:number_ninja/features/parent/topic_detail_screen.dart';

import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

void main() {
  late ParentHarness h;
  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  test('parent routes never count as screen time', () {
    for (final r in [
      Routes.dashboard,
      Routes.dashboardFor(StatsPeriod.all),
      Routes.reset,
      Routes.topicDetail('p2.money', StatsPeriod.all),
    ]) {
      expect(Routes.counts(Uri.parse(r).path), isFalse, reason: r);
    }
  });

  group('SCR-10 (AC-6, PAR-08)', () {
    testWidgets('a topic row opens its most missed and slowest questions', (
      tester,
    ) async {
      // Question 1 wrong 3×, 2 wrong 2×, 3 wrong once; 4 is slowest.
      await h.seed(numberTopic, [(1, false), (2, false), (3, false)]);
      await h.seed(numberTopic, [(1, false), (2, false), (4, true)]);
      await h.seed(numberTopic, [(1, false), (2, true)]);
      await h.seed(numberTopic, [(4, true)], ms: 60000);
      await h.openParent(tester, Routes.dashboard);
      await h.tapKey(tester, 'topic-row-$numberTopic');
      expect(find.byType(TopicDetailScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Money and change'), findsOneWidget);

      final missed = find.descendant(
        of: find.byKey(const Key('most-missed')),
        matching: find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('q-'),
        ),
      );
      final ids = [
        for (final e in missed.evaluate())
          (e.widget.key! as ValueKey<String>).value,
      ];
      expect(ids, [
        'q-$numberTopic.t.1',
        'q-$numberTopic.t.2',
        'q-$numberTopic.t.3',
      ]);
      expect(textIn('most-missed', 'wrong 3 of 3'), findsOneWidget);
      expect(textIn('most-missed', 'wrong 2 of 3'), findsOneWidget);
      expect(
        textIn('most-missed', 'How much money is there in dollars? (0)'),
        findsOneWidget,
      );
      expect(textIn('most-missed', 'Answer: 3.60'), findsNWidgets(3));

      await tester.scrollUntilVisible(find.byKey(const Key('slowest')), 200);
      final slowFirst = find.descendant(
        of: find.byKey(const Key('slowest')),
        matching: find.byKey(Key('q-$numberTopic.t.4')),
      );
      expect(slowFirst, findsOneWidget);
      expect(textIn('slowest', 'avg 32.5 s'), findsOneWidget);

      await h.tapKey(tester, 'back-dashboard');
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('the period is passed on and empty lists say so', (
      tester,
    ) async {
      await h.seed(numberTopic, [(1, false)], daysAgo: 10);
      await h.openParent(
        tester,
        Routes.topicDetail(numberTopic, StatsPeriod.days7),
      );
      expect(find.text('Last 7 days'), findsOneWidget);
      expect(find.text('No wrong answers in this period.'), findsOneWidget);
      await tester.scrollUntilVisible(find.byKey(const Key('slowest')), 200);
      expect(find.text('No answers in this period.'), findsOneWidget);
    });
  });

  group('reset (AC-7, PAR-10)', () {
    Future<void> seedProgress() async {
      await UsageRepository(h.db).setDailyLimit(30);
      await UsageRepository(h.db).addSeconds('2027-01-05', 120);
      final id = await h.repo.startRound(mcqTopic, 1);
      await h.repo.finishRound(id, score: 10, durationMs: 1, stars: 3);
      await h.seed(mcqTopic, [(1, true), (2, false)]);
    }

    Future<int> rows(String table) async =>
        (await h.db
                .customSelect('SELECT COUNT(*) AS c FROM $table')
                .getSingle())
            .read<int>('c');

    testWidgets('a wrong PIN deletes nothing; cancel returns', (tester) async {
      await seedProgress();
      await h.openParent(tester, Routes.parent);
      await h.tapKey(tester, 'reset-progress');
      expect(find.byType(ResetScreen), findsOneWidget);
      expect(find.byKey(const Key('reset-warning')), findsOneWidget);
      await h.enterPin(tester, '1111');
      expect(find.text('Wrong PIN. 4 tries left.'), findsOneWidget);
      expect(await rows('attempts'), 2);
      expect(await rows('rounds'), 2);
      await h.tapKey(tester, 'back-parent');
      expect(find.byType(ParentScreen), findsOneWidget);
    });

    testWidgets('the right PIN deletes progress, keeps PIN, limit and usage; '
        'home shows no stars and level 1', (tester) async {
      await seedProgress();
      await h.openParent(tester, '/play/school');
      expect(find.text('Level 2'), findsWidgets);
      h.container(tester).read(routerProvider).go(Routes.reset);
      await tester.pumpAndSettle();
      await h.enterPin(tester, parentPin);
      expect(find.byType(ParentScreen), findsOneWidget);
      expect(find.text('Progress reset'), findsOneWidget);

      for (final t in [
        'attempts',
        'rounds',
        'play_sessions',
        'badges_earned',
      ]) {
        expect(await rows(t), 0, reason: t);
      }
      expect(await h.pins.hasPin(), isTrue);
      final s = await UsageRepository(h.db).status('2027-01-05');
      expect(s.limitMinutes, 30);
      expect(s.usedSeconds, greaterThanOrEqualTo(120));

      await h.tapKey(tester, 'parent-done');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('track-stars-school'))).data,
        startsWith('0 /'),
      );
      h.container(tester).read(routerProvider).go('/play/school');
      await tester.pumpAndSettle();
      expect(find.text('Level 2'), findsNothing);
      expect(
        tester.widget<Text>(find.byKey(Key('topic-$mcqTopic-level'))).data,
        'Level 1',
      );

      // A new round after the reset saves fine (new play session).
      final id = await h.repo.startRound(mcqTopic, 1);
      expect(id, greaterThan(0));
    });

    testWidgets('5 wrong PINs trigger the lockout', (tester) async {
      await seedProgress();
      await h.openParent(tester, Routes.reset);
      for (var i = 0; i < 5; i++) {
        await h.enterPin(tester, '1111');
      }
      expect(find.byType(PinEntryScreen), findsOneWidget);
      expect(await h.pins.lockedUntil(), isNotNull);
      expect(await rows('attempts'), 2);
    });
  });
}
