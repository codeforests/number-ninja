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
}
