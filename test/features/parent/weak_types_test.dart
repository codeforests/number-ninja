import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/stats.dart';

import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

/// FEAT-11 AC-5: weak question types on SCR-10 (REV-05).
void main() {
  late ParentHarness h;
  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  String textIn(WidgetTester tester, Finder of) => [
    for (final e
        in find.descendant(of: of, matching: find.byType(Text)).evaluate())
      (e.widget as Text).data ?? '',
  ].join('\n');

  testWidgets('a seeded weak type shows its row, a clean topic does not', (
    tester,
  ) async {
    // 2 of 6 right; the latest answered is question 6.
    await h.seed(numberTopic, [for (var i = 1; i <= 6; i++) (i, i <= 2)]);
    await h.seed(mcqTopic, [for (var i = 1; i <= 6; i++) (i, true)]);
    await h.openParent(
      tester,
      Routes.topicDetail(numberTopic, StatsPeriod.all),
    );

    final card = find.byKey(const Key('weak-types'));
    expect(card, findsOneWidget);
    final row = find.byKey(const Key('weak-$numberTopic.t'));
    await tester.ensureVisible(row);
    final text = textIn(tester, row);
    expect(text, contains('T: 2/6 right · 5.0 s'));
    expect(text, contains('How much money is there in dollars? (5)'));
    expect(textIn(tester, card), contains('Last 30 days'));

    h
        .container(tester)
        .read(routerProvider)
        .go(Routes.topicDetail(mcqTopic, StatsPeriod.all));
    await tester.pumpAndSettle();
    expect(
      textIn(tester, find.byKey(const Key('weak-types'))),
      contains('No weak types'),
    );
  });
}
