import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/bank_validator.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/topics.dart';

const _topic = Topic('p2.times', Track.p2, 'Times tables');

Question _q(
  int n, {
  String? id,
  String? prompt,
  String answer = '',
  String? check,
  QuestionFormat format = QuestionFormat.number,
  List<String>? options,
  int? level,
}) {
  final a = 2 + n % 9, b = 3 + n ~/ 9;
  return Question(
    id: id ?? 'p2.times.facts.${(n + 1).toString().padLeft(3, '0')}',
    topic: 'p2.times',
    level: level ?? 1 + n % 3,
    format: format,
    prompt: prompt ?? '$a × $b = ?',
    options: options,
    answer: answer.isEmpty ? '${a * b}' : answer,
    check: check ?? '$a*$b',
    explanation: '$a groups of $b.',
  );
}

List<String> _validate(List<Question> qs) =>
    validateBank(QuestionBank(version: 1, questions: qs), topicList: [_topic]);

void main() {
  final good = [for (var n = 0; n < 40; n++) _q(n)];

  test('a valid bank has no problems', () {
    expect(_validate(good), isEmpty);
  });

  test('a wrong check result is rejected (AC-3)', () {
    final p = _validate([...good.skip(1), _q(0, answer: '99')]);
    expect(p.single, contains('check'));
  });

  test('a check that does not parse is rejected', () {
    final p = _validate([...good.skip(1), _q(0, check: '2x3')]);
    expect(p.single, contains('does not parse'));
  });

  test('a duplicate id is rejected (AC-3)', () {
    final p = _validate([
      ...good,
      _q(40, id: 'p2.times.facts.001', prompt: 'new prompt', check: '6*4'),
    ]);
    expect(p, contains('p2.times.facts.001: duplicate id'));
  });

  test('an mcq with zero or two correct options is rejected (AC-3)', () {
    final none = _q(
      40,
      format: QuestionFormat.mcq,
      prompt: 'Pick',
      options: ['1', '2', '3'],
      answer: '4',
    );
    final two = _q(
      41,
      format: QuestionFormat.mcq,
      prompt: 'Pick again',
      options: ['4', '4', '3'],
      answer: '4',
    );
    final p = _validate([
      ...good,
      Question.fromJson({...none.toJson()}..remove('check')),
      Question.fromJson({...two.toJson()}..remove('check')),
    ]);
    expect(p, contains('p2.times.facts.041: mcq has 0 correct options'));
    expect(p, contains('p2.times.facts.042: mcq has 2 correct options'));
  });

  test('a duplicate prompt in one topic is rejected (AC-3)', () {
    final p = _validate([
      ...good,
      _q(40, prompt: good.first.prompt, check: '6*7'),
    ]);
    expect(p.single, contains('duplicate prompt'));
  });

  test('a topic under 40 questions is rejected (AC-3)', () {
    final p = _validate(good.take(39).toList());
    expect(p.single, 'p2.times: 39 questions, needs 40');
  });

  test('a topic missing a level is rejected', () {
    final p = _validate([for (var n = 0; n < 40; n++) _q(n, level: 1)]);
    expect(p, contains('p2.times: no level 2 questions'));
  });

  test('ids must match <topic>.<template>.<nnn>', () {
    final p = _validate([...good.skip(1), _q(0, id: 'p2.times.facts.1')]);
    expect(p.single, contains('does not match'));
  });

  test('drag answers must use the listed items', () {
    final d = Question(
      id: 'p2.times.order.001',
      topic: 'p2.times',
      level: 1,
      format: QuestionFormat.drag,
      prompt: 'Order',
      drag: const DragSpec(items: ['6', '12'], slots: 2),
      answer: const ['6', '18'],
      explanation: 'x',
    );
    final p = _validate([...good, d]);
    expect(p.single, contains('"18" not in items'));
  });

  group('retired questions (FEAT-15 AC-1)', () {
    test('a retired duplicate is allowed and checked otherwise', () {
      final p = _validate([
        ...good,
        _q(40, prompt: good.first.prompt, check: '6*7').asRetired(),
        // Still checked: its check doesn't match its answer.
        _q(41, check: '1*1').asRetired(),
      ]);
      expect(p.single, contains('check 1*1'));
    });

    test('retired questions do not count toward the minimum', () {
      final qs = [...good.take(39), good.last.asRetired()];
      expect(_validate(qs).single, 'p2.times: 39 questions, needs 40');
    });

    test('missingIds lists ids the newer bank dropped (BNK-10)', () {
      final prev = QuestionBank(version: 1, questions: good);
      final next = QuestionBank(
        version: 2,
        questions: [for (final q in good.skip(2)) q, good[1].asRetired()],
      );
      expect(missingIds(prev, next), [good.first.id]);
      expect(missingIds(prev, prev), isEmpty);
    });
  });

  test('byTopic serves active questions, byId keeps retired ones', () {
    final bank = QuestionBank(
      version: 3,
      questions: [good[0].asRetired(), good[1]],
    );
    expect(bank.byTopic['p2.times']!.map((q) => q.id), [good[1].id]);
    expect(bank.byId[good[0].id]!.retired, isTrue);
    final back = QuestionBank.fromJson(bank.toJson());
    expect(back.format, bankFormatSupported);
    expect(back.byId[good[0].id]!.retired, isTrue);
    expect(back.byId[good[1].id]!.retired, isFalse);
    expect(good[1].toJson().containsKey('retired'), isFalse);
  });
}
