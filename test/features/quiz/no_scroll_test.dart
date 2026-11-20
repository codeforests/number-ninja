import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/question_bank_loader.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';

import '../../ui/layout_checks.dart';
import '../../ui/roboto.dart';
import 'quiz_harness.dart';

/// AC-7 (NFR-02): on the 1280 × 800 dp tablet, the longest-prompt question
/// of every template fits SCR-04 with nothing to scroll.
void main() {
  final shipped = QuestionBank.fromJson(
    jsonDecode(File(bankAsset).readAsStringSync()) as Map<String, dynamic>,
  );
  final longest = <String, Question>{};
  for (final q in shipped.questions) {
    final t = q.id.substring(0, q.id.lastIndexOf('.'));
    final best = longest[t];
    if (best == null || q.prompt.length > best.prompt.length) longest[t] = q;
  }

  var roboto = false;
  setUpAll(() async => roboto = await loadRoboto());

  test('covers every template', () {
    expect(longest, hasLength(greaterThan(100)));
  });

  for (final MapEntry(key: t, value: q) in longest.entries) {
    testWidgets(t, (tester) async {
      if (!roboto) {
        markTestSkipped(
          'Roboto not found in ${robotoDir().path}: AC-7 needs it',
        );
        return;
      }
      final h = QuizHarness(bank: QuestionBank(version: 1, questions: [q]));
      addTearDown(h.db.close);
      await h.pumpApp(
        tester,
        location: Routes.quiz(q.topic),
        size: physical(scaledSize),
      );
      expect(find.byType(QuizScreen), findsOneWidget);
      expectNoOverlap(tester, ['prompt', 'visual-box', 'answer-area']);
      final scrollables = find.descendant(
        of: find.byType(QuizScreen),
        matching: find.byType(Scrollable),
      );
      expect(scrollables, findsWidgets);
      for (final e in scrollables.evaluate()) {
        final pos = (e as StatefulElement).state as ScrollableState;
        expect(
          pos.position.maxScrollExtent,
          0,
          reason: '${q.id} scrolls by ${pos.position.maxScrollExtent} dp',
        );
      }
    });
  }
}
