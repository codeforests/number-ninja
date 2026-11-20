import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/features/parent/dashboard_screen.dart';
import 'package:number_ninja/features/parent/day_screen.dart';
import 'package:number_ninja/features/parent/parent_screen.dart';
import 'package:number_ninja/features/parent/pin_entry_screen.dart';

import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

/// AC-5 (PAR-05..07): SCR-11 → Progress shows SCR-09.
void main() {
  late ParentHarness h;
  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  /// Money is weak (3 of 10), fractions strong, place value only 20 days
  /// ago. P2 over 30 days: 17 of 24 (71 %); over 7 days: 13 of 20 (65 %).
  Future<void> seedAll() async {
    await h.seed(numberTopic, [
      for (var i = 1; i <= 10; i++) (i, i <= 3),
    ], daysAgo: 3);
    await h.seed(mcqTopic, [
      for (var i = 1; i <= 10; i++) (i, true),
    ], daysAgo: 3);
    await h.seed(dragTopic, [
      for (var i = 1; i <= 4; i++) (i, true),
    ], daysAgo: 20);
  }

  testWidgets('Progress opens SCR-09 with tracks, rows, needs practice and '
      'charts; 7 days changes the numbers', (tester) async {
    await seedAll();
    await h.openParent(tester, '/parent');
    expect(find.byType(ParentScreen), findsOneWidget);
    await h.tapKey(tester, 'open-dashboard');
    expect(find.byType(DashboardScreen), findsOneWidget);

    // 30 days (default)
    expect(textIn('track-p2', '71 %'), findsOneWidget);
    expect(textIn('track-p2', '24 answers'), findsOneWidget);
    expect(textIn('track-p2', '5.0 s avg'), findsOneWidget);
    expect(textIn('track-p1', '–'), findsOneWidget);
    expect(textIn('track-olympiad', '– answers'), findsOneWidget);
    expect(find.byKey(const Key('needs-p2.money')), findsOneWidget);
    expect(find.byKey(const Key('needs-p2.fractions')), findsNothing);
    expect(find.byKey(const Key('trend-accuracy')), findsOneWidget);
    expect(find.byKey(const Key('trend-speed')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('topic-row-p2.place')));
    expect(textIn('topic-row-p2.place', '100 %'), findsOneWidget);
    expect(textIn('topic-row-p2.place', '4'), findsOneWidget);
    expect(textIn('topic-row-p2.money', '30 %'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('topic-row-p2.money')),
        matching: find.byKey(const Key('flag')),
      ),
      findsOneWidget,
    );
    expect(textIn('topic-row-p1.bonds', '–'), findsNWidgets(3));

    // 7 days
    await h.tapKey(tester, 'period-7');
    expect(textIn('track-p2', '65 %'), findsOneWidget);
    expect(textIn('track-p2', '20 answers'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('topic-row-p2.place')));
    expect(textIn('topic-row-p2.place', '–'), findsNWidgets(3));

    // all time equals 30 days here
    await h.tapKey(tester, 'period-all');
    expect(textIn('track-p2', '71 %'), findsOneWidget);
  });

  testWidgets('FEAT-18 AC-4: "By day" lists the 7 latest days and opens '
      'SCR-16', (tester) async {
    for (var d = 0; d <= 8; d++) {
      await h.seed(mcqTopic, [(1, true), (2, d.isEven)], daysAgo: d);
    }
    await h.openParent(tester, '/parent/dashboard');
    for (final d in [
      '2027-01-05',
      '2027-01-04',
      '2027-01-03',
      '2027-01-02',
      '2027-01-01',
      '2026-12-31',
      '2026-12-30',
    ]) {
      expect(find.byKey(Key('daily-$d')), findsOneWidget);
    }
    expect(find.byKey(const Key('daily-2026-12-29')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('daily-2027-01-04')),
        matching: find.textContaining('2 answers · 50 % right'),
      ),
      findsOneWidget,
    );
    // Newest first.
    final y5 = tester.getTopLeft(find.byKey(const Key('daily-2027-01-05'))).dy;
    final y4 = tester.getTopLeft(find.byKey(const Key('daily-2027-01-04'))).dy;
    expect(y5, lessThan(y4));

    await h.tapKey(tester, 'daily-2027-01-04');
    expect(find.byType(DayScreen), findsOneWidget);
    expect(find.text('Mon 4 Jan 2027'), findsOneWidget);
    await h.tapKey(tester, 'back-dashboard');
    expect(find.byType(DashboardScreen), findsOneWidget);
    await h.tapKey(tester, 'open-day');
    expect(find.textContaining('Today, Tue 5 Jan 2027'), findsOneWidget);
  });

  testWidgets('no needs practice below 10 answers', (tester) async {
    await h.seed(numberTopic, [for (var i = 1; i <= 9; i++) (i, false)]);
    await h.openParent(tester, '/parent/dashboard');
    expect(
      textIn('needs-practice', 'Nothing yet. Needs 10+ answers in a topic.'),
      findsOneWidget,
    );
  });

  testWidgets('no attempts: the empty state shows', (tester) async {
    await h.openParent(tester, '/parent/dashboard');
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(
      find.text('No answers yet. Stats appear after her first round.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('trend-accuracy')), findsNothing);
    await h.tapKey(tester, 'back-parent');
    expect(find.byType(ParentScreen), findsOneWidget);
  });

  testWidgets('dashboard without unlocking asks for the PIN, which lands '
      'on SCR-11', (tester) async {
    await h.pumpApp(tester, location: '/parent/dashboard');
    expect(find.byType(PinEntryScreen), findsOneWidget);
    await h.enterPin(tester, parentPin);
    expect(find.byType(ParentScreen), findsOneWidget);
  });
}
