import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/question.dart';

import '../../tool/bank/bank.dart';
import '../../tool/bank/generator.dart';
import '../../tool/bank/publish.dart';

QuestionBank _with(QuestionBank b, {int? version, List<Question>? questions}) =>
    QuestionBank(
      version: version ?? b.version,
      questions: questions ?? b.questions,
    );

void main() {
  final bank = buildFor('');

  group('publishProblem (FEAT-15 AC-2, BNK-07, BNK-10)', () {
    test('a valid first bank may be published', () {
      expect(publishProblem(bank), isNull);
    });

    test('a version that is not higher is refused', () {
      for (final latest in [bank.version, bank.version + 1]) {
        expect(
          publishProblem(bank, latestVersion: latest),
          contains('not higher'),
        );
      }
      final next = _with(bank, version: bank.version + 1);
      expect(publishProblem(next, latestVersion: bank.version), isNull);
    });

    test('a dropped id is refused, a retired one is fine', () {
      final gone = bank.questions.first;
      final dropped = _with(
        bank,
        version: 9,
        questions: bank.questions.skip(1).toList(),
      );
      expect(
        publishProblem(dropped, previous: [bank]),
        allOf(contains('1 question ids'), contains(gone.id)),
      );
      final retired = _with(
        bank,
        version: 9,
        questions: [gone.asRetired(), ...bank.questions.skip(1)],
      );
      expect(publishProblem(retired, previous: [bank]), isNull);
    });

    test('a validator problem is refused', () {
      final q = bank.questions.first;
      final bad = Question(
        id: q.id,
        topic: q.topic,
        level: 7,
        format: q.format,
        prompt: q.prompt,
        answer: q.answer,
        explanation: q.explanation,
        visual: q.visual,
        options: q.options,
        drag: q.drag,
        check: q.check,
      );
      final next = _with(bank, questions: [bad, ...bank.questions.skip(1)]);
      expect(publishProblem(next), startsWith('validator:'));
    });
  });

  test('committedProblem: the published bank is the committed one', () {
    final text = encodeBank(bank);
    expect(committedProblem(text, text), isNull);
    expect(committedProblem(text, '$text\n'), contains('generate_bank'));
  });

  test('sha256Hex is lower-case hex', () {
    expect(
      sha256Hex('abc'.codeUnits),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });
}
