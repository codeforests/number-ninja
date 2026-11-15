import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/expr.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/topics.dart';

void main() {
  test('23 topics with unique ids across the three tracks', () {
    expect(topics, hasLength(23));
    expect(topicsById, hasLength(23));
    expect(topics.where((t) => t.track == Track.p1), hasLength(8));
    expect(topics.where((t) => t.track == Track.p2), hasLength(11));
    expect(topics.where((t) => t.track == Track.olympiad), hasLength(4));
  });

  test('questions round-trip through JSON for every format', () {
    final bank = QuestionBank(
      version: 1,
      questions: const [
        Question(
          id: 'p2.times.facts.001',
          topic: 'p2.times',
          level: 1,
          format: QuestionFormat.number,
          prompt: '7 × 4 = ?',
          answer: '28',
          check: '7*4',
          explanation: '7 groups of 4 make 28.',
        ),
        Question(
          id: 'p1.time.read.001',
          topic: 'p1.time',
          level: 1,
          format: QuestionFormat.mcq,
          prompt: 'What time is it?',
          visual: {'kind': 'clock', 'h': 3, 'm': 30},
          options: ['3:30', '6:15', '3:00'],
          answer: '3:30',
          explanation: 'The short hand is past 3, the long hand points at 6.',
        ),
        Question(
          id: 'p2.place.order.001',
          topic: 'p2.place',
          level: 2,
          format: QuestionFormat.drag,
          prompt: 'Put these in order, smallest first.',
          drag: DragSpec(items: ['508', '85', '580'], slots: 3),
          answer: ['85', '508', '580'],
          explanation: '85 has no hundreds; 508 < 580.',
        ),
      ],
    );
    final again = QuestionBank.fromJson(
      jsonDecode(jsonEncode(bank.toJson())) as Map<String, dynamic>,
    );
    expect(jsonEncode(again.toJson()), jsonEncode(bank.toJson()));
    expect(again.byTopic['p2.place']!.single.answer, ['85', '508', '580']);
    expect(again.questions[1].visual, {'kind': 'clock', 'h': 3, 'm': 30});
  });

  group('evaluate', () {
    test('follows precedence and brackets', () {
      expect(evaluate('(456+278)'), 734);
      expect(evaluate('24/4*3'), 18);
      expect(evaluate('2+3*4'), 14);
      expect(evaluate('(2+3)*4'), 20);
      expect(evaluate('10-2-3'), 5);
      expect(evaluate('-3+5'), 2);
      expect(evaluate('1000-367'), 633);
      expect(evaluate('3.6+0.4'), closeTo(4, 1e-9));
    });
    test('rejects junk', () {
      for (final bad in ['', '2+', '(3', '3)', '2x3', '1/0']) {
        expect(() => evaluate(bad), throwsFormatException, reason: bad);
      }
    });
  });
}
