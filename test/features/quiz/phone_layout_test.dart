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
import '../../ui/roboto.dart';
import 'quiz_harness.dart';

/// The two phone sizes (FEAT-19): the smallest common phone in both
/// orientations.
const phoneSizes = [Size(360, 640), Size(640, 360)];

/// FEAT-19 AC-1..3: on a phone, for the longest-prompt question of every
/// template, Check (or the options) and then Next are in view without
/// scrolling, and nothing overflows.
void main() {
  test('compact: phones only, not tablets', () {
    for (final s in phoneSizes) {
      expect(compact(s), isTrue, reason: '$s');
    }
    for (final s in const [Size(960, 600), Size(600, 960), Size(1280, 800)]) {
      expect(compact(s), isFalse, reason: '$s');
    }
  });

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

  for (final dp in phoneSizes) {
    group('${dp.width.toInt()} × ${dp.height.toInt()}', () {
      for (final MapEntry(key: t, value: q) in longest.entries) {
        testWidgets(t, (tester) async {
          if (!roboto) {
            markTestSkipped('Roboto not found in ${robotoDir().path}');
            return;
          }
          final h = QuizHarness(bank: QuestionBank(version: 1, questions: [q]));
          addTearDown(h.db.close);
          await h.pumpApp(
            tester,
            location: Routes.quiz(q.topic),
            size: physical(dp),
          );
          expect(find.byType(QuizScreen), findsOneWidget);
          expectNoOverlap(tester, ['prompt', 'answer-area']);
          switch (q.format) {
            case QuestionFormat.mcq:
              for (var i = 0; i < q.options!.length; i++) {
                expectInView(tester, 'option-$i');
              }
              await tester.tap(find.byKey(const Key('option-0')));
            case QuestionFormat.number:
              expectInView(tester, 'check');
              await tester.tap(find.byKey(const Key('key-1')));
              await tester.pump();
              await tester.tap(find.byKey(const Key('check')));
            case QuestionFormat.drag:
              expectInView(tester, 'check');
              for (var i = 0; i < q.drag!.slots; i++) {
                await h.tap(tester, 'chip-$i');
              }
              expectInView(tester, 'check');
              await tester.tap(find.byKey(const Key('check')));
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expectInView(tester, 'next');
        });
      }
    });
  }
}
