import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/answers.dart';
import 'package:number_ninja/domain/question.dart';

void main() {
  const money = Question(
    id: 'p2.money.change.001',
    topic: 'p2.money',
    level: 2,
    format: QuestionFormat.number,
    prompt: 'Change from \$10 for \$6.40?',
    answer: '3.60',
    explanation: '\$10 − \$6.40 = \$3.60',
  );
  const mcq = Question(
    id: 'p2.fractions.cmp.001',
    topic: 'p2.fractions',
    level: 1,
    format: QuestionFormat.mcq,
    prompt: 'Which is bigger?',
    options: ['1/3', '1/5', 'They are equal'],
    answer: '1/3',
    explanation: 'Thirds are bigger pieces than fifths.',
  );
  const drag = Question(
    id: 'p2.place.order.001',
    topic: 'p2.place',
    level: 1,
    format: QuestionFormat.drag,
    prompt: 'Smallest first',
    drag: DragSpec(items: ['508', '85', '580'], slots: 3),
    answer: ['85', '508', '580'],
    explanation: '…',
  );

  test('number answers compare as numbers (AC-6)', () {
    expect(isCorrect(money, '3.6'), isTrue);
    expect(isCorrect(money, '3.60'), isTrue);
    expect(isCorrect(money, ' 3.60 '), isTrue);
    expect(isCorrect(money, '3.06'), isFalse);
    expect(isCorrect(money, ''), isFalse);
    expect(isCorrect(money, 'abc'), isFalse);
  });

  test('mcq answers compare by option text (AC-6)', () {
    expect(isCorrect(mcq, '1/3'), isTrue);
    expect(isCorrect(mcq, '1/5'), isFalse);
  });

  test('drag answers must be in the right order (AC-6)', () {
    expect(isCorrect(drag, ['85', '508', '580']), isTrue);
    expect(isCorrect(drag, ['508', '85', '580']), isFalse);
    expect(isCorrect(drag, ['85', '508']), isFalse);
  });
}
