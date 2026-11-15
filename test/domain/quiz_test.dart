import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/quiz.dart';

void main() {
  final t0 = DateTime(2026, 11, 15, 9);
  const number = Question(
    id: 'n',
    topic: 't',
    level: 1,
    format: QuestionFormat.number,
    prompt: '1 + 1',
    answer: '2',
    explanation: '1 + 1 = 2',
  );
  const drag = Question(
    id: 'd',
    topic: 't',
    level: 1,
    format: QuestionFormat.drag,
    prompt: 'Order',
    drag: DragSpec(items: ['1', '2', '3'], slots: 3),
    answer: ['1', '2', '3'],
    explanation: '',
  );

  test('answer → feedback → next → done with timing', () {
    var quiz = Quiz.start(const [number, drag], t0);
    expect(quiz.phase, QuizPhase.answering);
    expect(quiz.current.id, 'n');

    quiz = quiz.answer('2', t0.add(const Duration(seconds: 4)));
    expect(quiz.phase, QuizPhase.feedback);
    expect(quiz.lastResult!.correct, isTrue);
    expect(quiz.lastResult!.timeMs, 4000);
    expect(quiz.lastResult!.given, '2');

    // Feedback reading time (10 s) is not counted.
    quiz = quiz.next(t0.add(const Duration(seconds: 14)));
    expect(quiz.phase, QuizPhase.answering);
    expect(quiz.current.id, 'd');
    expect(quiz.lastResult, isNull);

    quiz = quiz.answer(['1', '3', '2'], t0.add(const Duration(seconds: 20)));
    expect(quiz.lastResult!.correct, isFalse);
    expect(quiz.lastResult!.given, '1, 3, 2');
    expect(quiz.isLast, isTrue);

    quiz = quiz.next(t0.add(const Duration(seconds: 25)));
    expect(quiz.phase, QuizPhase.done);
    expect(quiz.score, 1);
    expect(quiz.durationMs, 10000);
    expect(quiz.stars, 0);
    expect(quiz.results, hasLength(2));
  });

  test('wrong-phase calls throw', () {
    final quiz = Quiz.start(const [number], t0);
    expect(() => quiz.next(t0), throwsStateError);
    expect(() => quiz.answer('2', t0).answer('2', t0), throwsStateError);
  });

  test('answer text helpers', () {
    expect(correctAnswerText(number), '2');
    expect(correctAnswerText(drag), '1, 2, 3');
    expect(answerText(number, ' 3 '), '3');
  });
}
