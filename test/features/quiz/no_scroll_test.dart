import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/question_bank_loader.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';

import '../../ui/layout_checks.dart';
import 'quiz_harness.dart';

/// The SDK's bundled Roboto, so text has the widths the tablet draws
/// (the default test font, Ahem, is wider).
Directory _fonts() {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      '${Platform.environment['HOME']}/sdk/flutter';
  return Directory('$root/bin/cache/artifacts/material_fonts');
}

Future<bool> _loadRoboto() async {
  final dir = _fonts();
  if (!File('${dir.path}/Roboto-Regular.ttf').existsSync()) return false;
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold', 'Black']) {
    final bytes = File('${dir.path}/Roboto-$w.ttf').readAsBytesSync();
    roboto.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('${dir.path}/MaterialIcons-Regular.otf').readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
  return true;
}

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
  setUpAll(() async => roboto = await _loadRoboto());

  test('covers every template', () {
    expect(longest, hasLength(greaterThan(100)));
  });

  for (final MapEntry(key: t, value: q) in longest.entries) {
    testWidgets(t, (tester) async {
      if (!roboto) {
        markTestSkipped('Roboto not found in ${_fonts().path}: AC-7 needs it');
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
