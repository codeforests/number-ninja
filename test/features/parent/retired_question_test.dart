import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/question.dart';

import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

void main() {
  testWidgets('SCR-10 still shows a retired question from her history '
      '(FEAT-15 AC-1)', (tester) async {
    final base = fakeBank();
    final retiredId = '$numberTopic.t.1';
    final h = ParentHarness(
      bank: QuestionBank(
        version: 2,
        questions: [
          for (final q in base.questions) q.id == retiredId ? q.asRetired() : q,
        ],
      ),
    );
    addTearDown(h.db.close);
    await h.setUp();
    await h.seed(numberTopic, [(1, false), (2, true)]);
    await h.openParent(tester, Routes.dashboard);
    await h.tapKey(tester, 'topic-row-$numberTopic');
    expect(
      find.descendant(
        of: find.byKey(const Key('most-missed')),
        matching: find.byKey(Key('q-$retiredId')),
      ),
      findsOneWidget,
    );
    expect(textIn('most-missed', 'Answer: 3.60'), findsOneWidget);
  });
}
