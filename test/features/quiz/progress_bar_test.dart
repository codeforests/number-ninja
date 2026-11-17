import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/ui/theme.dart';

import '../../ui/layout_checks.dart';
import 'quiz_harness.dart';

/// FEAT-16: the progress steps always fit the width and show "n/10", and
/// the keypad keys are white "candy" keys with an orange delete key.
void main() {
  for (final dp in const [Size(360, 720), Size(1280, 800)]) {
    testWidgets('progress steps fit at $dp and count up', (tester) async {
      final h = QuizHarness();
      addTearDown(h.db.close);
      await h.pumpApp(
        tester,
        location: Routes.quiz(numberTopic),
        size: physical(dp),
      );
      final count = find.byKey(const Key('progress-count'));
      expect(tester.widget<Text>(count).data, '1/10');
      final steps = tester.getRect(find.byKey(const Key('progress-dots')));
      expect(steps.right, lessThanOrEqualTo(dp.width));
      expect(tester.getRect(count).right, lessThanOrEqualTo(dp.width));
      await h.answer(tester, right: true);
      await h.next(tester);
      expect(tester.widget<Text>(count).data, '2/10');
    });
  }

  testWidgets('keypad: white digit keys, orange delete key (AC-7)', (
    tester,
  ) async {
    final h = QuizHarness();
    addTearDown(h.db.close);
    await h.pumpApp(
      tester,
      location: Routes.quiz(numberTopic),
      size: physical(const Size(360, 720)),
    );
    ButtonStyle style(String k) =>
        tester.widget<FilledButton>(find.byKey(Key('key-$k'))).style!;
    for (final k in ['1', '5', '0']) {
      expect(style(k).backgroundColor!.resolve({}), AppColors.keyFace);
      expect(style(k).foregroundColor!.resolve({}), AppColors.ninja);
    }
    expect(style('back').backgroundColor!.resolve({}), AppColors.keyDelete);
    expect(style('back').foregroundColor!.resolve({}), AppColors.keyDeleteInk);
  });
}
