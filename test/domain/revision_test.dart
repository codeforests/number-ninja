import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/revision.dart';
import 'package:number_ninja/domain/stats.dart';

final t0 = DateTime(2026, 11, 1, 9);
const planner = RuleRevisionPlanner();

var _n = 0;

/// [count] attempts of type [type] (questions `<type>.00i`), the first
/// [right] correct, each [ms] long, newer than earlier calls.
List<AttemptRecord> runOf(
  String type,
  int count, {
  required int right,
  int ms = 5000,
  String topic = 'p1.add',
  int questions = 3,
}) => [
  for (var i = 0; i < count; i++)
    AttemptRecord(
      questionId: '$type.${(i % questions).toString().padLeft(3, '0')}',
      topicId: topic,
      correct: i < right,
      timeMs: ms,
      answeredAt: t0.add(Duration(minutes: _n++)),
    ),
];

AttemptRecord one(
  String id, {
  required bool correct,
  String topic = 'p1.add',
  int ms = 5000,
}) => AttemptRecord(
  questionId: id,
  topicId: topic,
  correct: correct,
  timeMs: ms,
  answeredAt: t0.add(Duration(minutes: _n++)),
);

RevisionHistory hist(
  List<AttemptRecord> a, {
  Map<String, int> levels = const {},
  Set<String> recentCorrect = const {},
}) =>
    RevisionHistory(attempts: a, levels: levels, recentCorrect: recentCorrect);

Question qn(String id, String topic, int level) => Question(
  id: id,
  topic: topic,
  level: level,
  format: QuestionFormat.number,
  prompt: id,
  answer: '1',
  explanation: '',
);

/// Bank: for each type, 12 questions, levels 1..3 (4 each).
QuestionBank bankOf(Map<String, String> typeToTopic) => QuestionBank(
  version: 1,
  questions: [
    for (final MapEntry(key: type, value: topic) in typeToTopic.entries)
      for (var i = 0; i < 12; i++)
        qn('$type.${i.toString().padLeft(3, '0')}', topic, i ~/ 4 + 1),
  ],
);

void main() {
  test('typeOf and typeLabel (AC-1)', () {
    expect(typeOf('p1.place.tens.004'), 'p1.place.tens');
    expect(typeLabel('p1.place.tens-ones'), 'Tens ones');
    expect(typeLabel('p1.add.make_ten'), 'Make ten');
  });

  group('weakTypes (AC-1, REV-01)', () {
    test('5/10 is weak, 7/10 is not, 4 attempts at 0% is too few', () {
      final h = hist([
        ...runOf('p1.add.a', 10, right: 5),
        ...runOf('p1.add.b', 10, right: 7),
        ...runOf('p1.add.c', 4, right: 0),
      ]);
      expect(planner.weakTypes(h).map((w) => w.typeId), ['p1.add.a']);
      expect(planner.weakTypes(h).single.tally.correct, 5);
    });

    test('only the latest 10 attempts of a type count', () {
      // 10 wrong, then 10 right: latest 10 are all right.
      final h = hist([
        ...runOf('p1.add.a', 10, right: 0),
        ...runOf('p1.add.a', 10, right: 10),
      ]);
      expect(planner.weakTypes(h), isEmpty);
    });

    test('1.6x slower than the topic average at 90% is weak, 1.4x is not', () {
      // Type a: 10 at 16 s; many others at 10 s pull the average close to 10.
      List<AttemptRecord> base() =>
          runOf('p1.add.base', 200, right: 200, ms: 10000);
      final slow = hist([
        ...base(),
        ...runOf('p1.add.a', 10, right: 9, ms: 16000),
      ]);
      final w = planner.weakTypes(slow);
      expect(w.map((e) => e.typeId), ['p1.add.a']);
      expect(w.single.slow, isTrue);
      final ok = hist([
        ...base(),
        ...runOf('p1.add.a', 10, right: 9, ms: 14000),
      ]);
      expect(planner.weakTypes(ok), isEmpty);
    });

    test('ordered lowest accuracy first; topicId filters', () {
      final h = hist([
        ...runOf('p1.add.a', 10, right: 6),
        ...runOf('p1.add.b', 10, right: 2),
        ...runOf('p1.sub.c', 10, right: 4, topic: 'p1.sub'),
      ]);
      expect(planner.weakTypes(h).map((w) => w.typeId), [
        'p1.add.b',
        'p1.sub.c',
        'p1.add.a',
      ]);
      expect(planner.weakTypes(h, topicId: 'p1.sub').map((w) => w.typeId), [
        'p1.sub.c',
      ]);
    });
  });

  group('mistakes (AC-1, REV-02)', () {
    test('latest wrong, a later right removes it, newest first', () {
      final h = hist([
        one('p1.add.a.001', correct: false),
        one('p1.add.a.002', correct: false),
        one('p1.add.a.001', correct: true),
        one('p1.add.a.003', correct: true),
        one('p1.add.a.003', correct: false),
      ]);
      expect(planner.mistakes(h), ['p1.add.a.003', 'p1.add.a.002']);
    });
  });

  group('offers (AC-1, REV-03)', () {
    test('topic with one mistake; mixed needs 3 mistakes or a weak type', () {
      final one1 = hist([one('p1.add.a.001', correct: false)]);
      expect(planner.offers(one1, const TopicScope('p1.add')), isTrue);
      expect(planner.offers(one1, const TopicScope('p1.sub')), isFalse);
      final two = hist([
        one('p1.add.a.001', correct: false),
        one('p1.sub.a.001', correct: false, topic: 'p1.sub'),
      ]);
      expect(planner.offers(two, const MixedScope()), isFalse);
      final three = hist([
        ...two.attempts,
        one('p1.add.a.002', correct: false),
      ]);
      expect(planner.offers(three, const MixedScope()), isTrue);
      final weak = hist(runOf('p1.add.a', 10, right: 3));
      expect(planner.offers(weak, const MixedScope()), isTrue);
      expect(
        planner.offers(RevisionHistory.empty, const MixedScope()),
        isFalse,
      );
    });
  });

  group('plan (AC-1, REV-04)', () {
    test('mistakes first (at most 5), then weak types round-robin', () {
      final bank = bankOf({
        'p1.add.m': 'p1.add',
        'p1.add.n': 'p1.add',
        'p1.add.w1': 'p1.add',
        'p1.add.w2': 'p1.add',
      });
      final h = hist(
        [
          // Weak w1 (0/5) and w2 (2/5) on questions 004..008 (level 2).
          for (final t in ['p1.add.w1', 'p1.add.w2'])
            for (var i = 0; i < 5; i++)
              one('$t.00${i + 4}', correct: t == 'p1.add.w2' && i < 2),
          // 7 newer mistakes, too few per type to make m or n weak.
          for (final i in [0, 1, 2, 3]) one('p1.add.m.00$i', correct: false),
          for (final i in [8, 9, 10])
            one('p1.add.n.${i.toString().padLeft(3, '0')}', correct: false),
        ],
        levels: {'p1.add': 2},
      );
      final p = planner.plan(h, bank, const TopicScope('p1.add'), Random(1));
      final ids = p.questions.map((q) => q.id).toList();
      expect(ids, hasLength(10));
      expect(ids.toSet(), hasLength(10));
      final mistakes = planner.mistakes(h, topicId: 'p1.add');
      // The 5 newest mistakes are in, the other 2 are not (more weak first).
      expect(mistakes.take(5), [
        'p1.add.n.010',
        'p1.add.n.009',
        'p1.add.n.008',
        'p1.add.m.003',
        'p1.add.m.002',
      ]);
      expect(
        ids.where((id) => id.contains('.m.') || id.contains('.n.')).toSet(),
        {...mistakes.take(5)},
      );
      // 5 more: weak types round-robin, w1 first (weaker), so 3 of w1, 2 of w2,
      // at the topic's level 2 (ids 004..007).
      final w1 = ids.where((id) => id.startsWith('p1.add.w1.')).toList();
      final w2 = ids.where((id) => id.startsWith('p1.add.w2.')).toList();
      expect(w1, hasLength(3));
      expect(w2, hasLength(2));
      for (final id in [...w1, ...w2]) {
        expect(bank.questions.firstWhere((q) => q.id == id).level, 2);
      }
    });

    test('prefers questions not answered right recently (AC-1)', () {
      final bank = QuestionBank(
        version: 1,
        questions: [
          for (var i = 0; i < 20; i++)
            qn('p1.add.w.${i.toString().padLeft(3, '0')}', 'p1.add', 1),
        ],
      );
      final h = hist(
        [for (var i = 0; i < 5; i++) one('p1.add.w.000', correct: false)],
        recentCorrect: {
          for (var i = 1; i < 16; i++)
            'p1.add.w.${i.toString().padLeft(3, '0')}',
        },
      );
      final p = planner.plan(h, bank, const TopicScope('p1.add'), Random(2));
      final ids = p.questions.map((q) => q.id).toSet();
      expect(ids, hasLength(10));
      expect(
        ids,
        containsAll(['p1.add.w.000', 'p1.add.w.016', 'p1.add.w.017']),
      );
      expect(ids, containsAll(['p1.add.w.018', 'p1.add.w.019']));
    });

    test('siblings of mistakes fill when there is no weak type', () {
      final bank = bankOf({'p1.add.m': 'p1.add', 'p1.add.x': 'p1.add'});
      final h = hist([one('p1.add.m.000', correct: false)]);
      final p = planner.plan(h, bank, const TopicScope('p1.add'), Random(3));
      expect(p.questions, hasLength(10));
      expect(p.questions.every((q) => q.id.startsWith('p1.add.m.')), isTrue);
      expect(p.questions.map((q) => q.id), contains('p1.add.m.000'));
    });

    test('topic scope never contains another topic; mixed spans topics', () {
      final bank = bankOf({'p1.add.m': 'p1.add', 'p1.sub.m': 'p1.sub'});
      final h = hist([
        one('p1.add.m.000', correct: false),
        one('p1.sub.m.000', correct: false, topic: 'p1.sub'),
      ]);
      final t = planner.plan(h, bank, const TopicScope('p1.sub'), Random(4));
      expect(t.questions.every((q) => q.topic == 'p1.sub'), isTrue);
      final m = planner.plan(h, bank, const MixedScope(), Random(4));
      expect(m.questions.map((q) => q.topic).toSet(), {'p1.add', 'p1.sub'});
      expect(m.scope.id, mixedScopeId);
    });

    test('empty history gives an empty plan', () {
      final bank = bankOf({'p1.add.m': 'p1.add'});
      final p = planner.plan(
        RevisionHistory.empty,
        bank,
        const MixedScope(),
        Random(5),
      );
      expect(p.isEmpty, isTrue);
    });
  });
}
