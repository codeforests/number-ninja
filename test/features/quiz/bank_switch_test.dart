import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/features/quiz/quiz_controller.dart';
import 'package:number_ninja/providers.dart';

import 'quiz_harness.dart';

/// FEAT-15 AC-4 (BNK-09): a downloaded bank never changes a running round;
/// the next round uses it.
void main() {
  test('a bank downloaded mid-round applies at the next round', () async {
    final h = QuizHarness()..useBankStore = true;
    final tmp = Directory.systemTemp.createTempSync('nn-switch');
    h.banksDir = Directory('${tmp.path}/banks');
    final c = ProviderContainer(overrides: h.overrides);
    addTearDown(() async {
      c.dispose();
      await h.db.close();
      tmp.deleteSync(recursive: true);
    });
    final sub = c.listen(quizControllerProvider, (_, _) {});
    addTearDown(sub.close);

    await c.read(quizControllerProvider.notifier).start(numberTopic);
    final first = c.read(quizControllerProvider).quiz!.questions;
    expect(first.any((q) => q.prompt.startsWith('v2 ')), isFalse);

    // A check downloads version 2 while the round runs.
    final v2 = QuestionBank(
      version: 2,
      questions: [
        for (final q in h.bank.questions)
          Question.fromJson({...q.toJson(), 'prompt': 'v2 ${q.prompt}'}),
      ],
    );
    final bytes = utf8.encode(jsonEncode(v2.toJson()));
    await c
        .read(bankStoreProvider)
        .save(
          BankInfo(
            version: 2,
            format: 1,
            sha256: sha256.convert(bytes).toString(),
            fileUrl: Uri.parse('https://fake/2'),
          ),
          bytes,
          h.now,
        );
    c.read(bankPendingProvider.notifier).set();

    expect(c.read(quizControllerProvider).quiz!.questions, same(first));
    expect((await c.read(bankProvider.future)).version, 1);

    await c.read(quizControllerProvider.notifier).start(numberTopic);
    final next = c.read(quizControllerProvider).quiz!.questions;
    expect(next, isNotEmpty);
    expect(next.every((q) => q.prompt.startsWith('v2 ')), isTrue);
    expect((await c.read(bankProvider.future)).version, 2);
    expect(c.read(bankPendingProvider), isFalse);
  });
}
