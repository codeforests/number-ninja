import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/question_bank_loader.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/ui/layout.dart';

import '../../ui/layout_checks.dart';
import 'quiz_harness.dart';

const _keys = ['prompt', 'visual-box', 'answer-area'];

/// SCR-04 at every NFR-09 size (AC-6).
void main() {
  final shipped = QuestionBank.fromJson(
    jsonDecode(File(bankAsset).readAsStringSync()) as Map<String, dynamic>,
  );

  // Per format: the longest prompt, and the longest prompt with a visual.
  final cases = <String, Question>{};
  void keep(String k, Question q) {
    final best = cases[k];
    if (best == null || q.prompt.length > best.prompt.length) cases[k] = q;
  }

  for (final q in shipped.questions) {
    keep(q.format.name, q);
    if (q.visual != null) keep('${q.format.name}+visual', q);
  }

  test('sideBySide: landscape and at least 600 dp wide', () {
    expect(sideBySide(const Size(1280, 800)), isTrue);
    expect(sideBySide(const Size(640, 360)), isTrue);
    expect(sideBySide(const Size(599, 360)), isFalse);
    expect(sideBySide(const Size(800, 1280)), isFalse);
    expect(sideBySide(const Size(700, 700)), isFalse);
  });

  Future<void> check(WidgetTester tester, Question q, Size dp) async {
    final h = QuizHarness(bank: QuestionBank(version: 1, questions: [q]));
    addTearDown(h.db.close);
    await h.pumpApp(tester, location: Routes.quiz(q.topic), size: physical(dp));
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(find.byKey(const Key('prompt')), findsOneWidget);
    expect(find.byKey(const Key('answer-area')), findsOneWidget);
    expect(
      find.byKey(const Key('visual-box')),
      q.visual != null ? findsOneWidget : findsNothing,
    );
    expectNoOverlap(tester, _keys);
    await h.answer(tester, right: false);
    expect(find.byKey(const Key('next')), findsOneWidget);
    expectNoOverlap(tester, _keys);
  }

  for (final MapEntry(key: name, value: q) in cases.entries) {
    group('AC-6 SCR-04 $name (${q.id})', () {
      for (final dp in layoutSizes) {
        testWidgets(
          '${dp.width.toInt()} × ${dp.height.toInt()}',
          (tester) => check(tester, q, dp),
        );
      }
      testWidgets('1280 × 800 at text scale $scaledText', (tester) async {
        setTextScale(tester, scaledText);
        await check(tester, q, scaledSize);
      });
    });
  }
}
