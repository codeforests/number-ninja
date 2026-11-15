import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/question_bank_loader.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/ui/theme.dart';
import 'package:number_ninja/ui/visuals/question_visual.dart';

import 'quiz_harness.dart';

const landscape = Size(2560, 1600); // 1280 × 800 dp at dpr 2
const portrait = Size(1600, 2560); // 800 × 1280 dp

/// SCR-04 layout over the shipped bank (AC-6) and child-screen sizes (AC-7).
void main() {
  final shipped = QuestionBank.fromJson(
    jsonDecode(File(bankAsset).readAsStringSync()) as Map<String, dynamic>,
  );

  // The longest-prompt question of each template (id up to the counter).
  final longest = <String, Question>{};
  for (final q in shipped.questions) {
    final t = q.id.substring(0, q.id.lastIndexOf('.'));
    final best = longest[t];
    if (best == null || q.prompt.length > best.prompt.length) longest[t] = q;
  }

  /// Plays [q] alone on SCR-04 at [size], then answers it wrongly so the
  /// feedback panel (answer and explanation) is laid out too.
  Future<void> render(WidgetTester tester, Question q, Size size) async {
    final h = QuizHarness(bank: QuestionBank(version: 1, questions: [q]));
    addTearDown(h.db.close);
    await h.pumpApp(tester, location: Routes.quiz(q.topic), size: size);
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(h.current(tester).id, q.id);
    if (q.visual != null) {
      expect(find.byType(QuestionVisual), findsOneWidget);
    }
    await h.answer(tester, right: false);
    expect(find.byKey(const Key('next')), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  group('AC-6: longest prompt per template at 1280 × 800', () {
    test('covers every template and every visual kind', () {
      expect(longest, hasLength(greaterThan(100)));
      final kinds = {
        for (final q in shipped.questions)
          if (q.visual != null) q.visual!['kind'],
      };
      expect(kinds, hasLength(9));
    });

    for (final MapEntry(key: t, value: q) in longest.entries) {
      testWidgets(t, (tester) => render(tester, q, landscape));
    }
  });

  group('AC-6: a sample at 800 × 1280', () {
    // The longest prompt per visual kind, and per format without a visual.
    final sample = <String, Question>{};
    for (final q in longest.values) {
      final k = q.visual?['kind'] as String? ?? q.format.name;
      final best = sample[k];
      if (best == null || q.prompt.length > best.prompt.length) sample[k] = q;
    }
    for (final MapEntry(key: k, value: q) in sample.entries) {
      testWidgets('$k: ${q.id}', (tester) => render(tester, q, portrait));
    }
  });

  group('AC-7: tap targets ≥ 64 dp and text ≥ 20 sp', () {
    late QuizHarness h;

    setUp(() => h = QuizHarness());
    tearDown(() => h.db.close());

    const tapTargets = MinimumTapTargetGuideline(
      size: Size(AppSizes.minTap, AppSizes.minTap),
      link: 'NFR-03',
    );

    /// Every laid-out text outside the drawn visual (which scales its own
    /// 20 sp labels to fit its box, handoff AC-7 note). Icons are glyphs,
    /// not text, and are left out.
    void expectTextSizes(WidgetTester tester) {
      final skip = {
        ...find.byType(QuestionVisual).evaluate(),
        ...find.byType(Icon).evaluate(),
      };
      final paragraphs = tester.allElements.where(
        (e) =>
            e.renderObject is RenderParagraph &&
            !skip.any((v) => _isAncestor(v, e)),
      );
      expect(paragraphs, isNotEmpty);
      for (final e in paragraphs) {
        final p = e.renderObject! as RenderParagraph;
        p.text.visitChildren((span) {
          final size = span.style?.fontSize ?? 14;
          expect(
            p.textScaler.scale(size),
            greaterThanOrEqualTo(AppText.small),
            reason: '"${span.toPlainText()}" is $size sp',
          );
          return true;
        });
      }
    }

    Future<void> expectSizes(WidgetTester tester) async {
      await expectLater(tester, meetsGuideline(tapTargets));
      expectTextSizes(tester);
    }

    for (final topic in [mcqTopic, numberTopic, dragTopic]) {
      testWidgets('SCR-04 $topic, answering and feedback', (tester) async {
        final semantics = tester.ensureSemantics();
        await h.pumpApp(tester, location: Routes.quiz(topic));
        await expectSizes(tester);
        if (topic == dragTopic) {
          await h.tap(tester, 'chip-0'); // a filled box is tappable too
          await expectSizes(tester);
        }
        await h.answer(tester, right: false);
        await expectSizes(tester);
        semantics.dispose();
      });
    }

    testWidgets('SCR-05', (tester) async {
      final semantics = tester.ensureSemantics();
      await h.pumpApp(tester, location: Routes.quiz(mcqTopic));
      for (var i = 0; i < 10; i++) {
        await h.answer(tester, right: i.isEven);
        await h.next(tester);
      }
      expect(find.byType(ResultScreen), findsOneWidget);
      await expectSizes(tester);
      semantics.dispose();
    });
  });
}

bool _isAncestor(Element ancestor, Element e) {
  var found = false;
  e.visitAncestorElements((a) {
    if (a == ancestor) found = true;
    return !found;
  });
  return found;
}
