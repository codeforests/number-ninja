import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/round_builder.dart';

Question q(String id, int level) => Question(
  id: id,
  topic: 't',
  level: level,
  format: QuestionFormat.number,
  prompt: id,
  answer: '1',
  explanation: '',
);

List<Question> make(int level, int n) => [
  for (var i = 0; i < n; i++) q('L$level-$i', level),
];

void main() {
  mixInTests();

  test('10 distinct questions from the level (AC-1)', () {
    final pool = [...make(1, 15), ...make(2, 15)];
    final r = buildRound(
      topicQuestions: pool,
      level: 1,
      recentCorrect: const {},
      random: Random(1),
    );
    expect(r, hasLength(10));
    expect(r.map((e) => e.id).toSet(), hasLength(10));
    expect(r.every((e) => e.level == 1), isTrue);
  });

  test('recent-correct questions come only after the others (AC-1)', () {
    final pool = make(1, 12);
    final recent = {for (var i = 0; i < 5; i++) 'L1-$i'};
    final r = buildRound(
      topicQuestions: pool,
      level: 1,
      recentCorrect: recent,
      random: Random(2),
    );
    expect(r, hasLength(10));
    // 7 fresh first, then 3 recent.
    expect(r.take(7).any((e) => recent.contains(e.id)), isFalse);
    expect(r.skip(7).every((e) => recent.contains(e.id)), isTrue);
  });

  test('all recent questions are skipped when enough fresh ones exist', () {
    final pool = make(1, 20);
    final recent = {for (var i = 0; i < 10; i++) 'L1-$i'};
    final r = buildRound(
      topicQuestions: pool,
      level: 1,
      recentCorrect: recent,
      random: Random(3),
    );
    expect(r.any((e) => recent.contains(e.id)), isFalse);
  });

  test('too few at the level fills from the nearest level (AC-1)', () {
    final pool = [...make(1, 6), ...make(2, 3), ...make(3, 20)];
    final r = buildRound(
      topicQuestions: pool,
      level: 2,
      recentCorrect: const {},
      random: Random(4),
    );
    expect(r, hasLength(10));
    expect(r.take(3).every((e) => e.level == 2), isTrue);
    // Levels 1 and 3 are equally near: the lower one is used first.
    expect(r.skip(3).take(6).every((e) => e.level == 1), isTrue);
    expect(r.last.level, 3);
    expect(r.map((e) => e.id).toSet(), hasLength(10));
  });

  test('same seed gives the same round (AC-1)', () {
    final pool = make(1, 30);
    List<String> ids(int seed) => buildRound(
      topicQuestions: pool,
      level: 1,
      recentCorrect: const {'L1-3'},
      random: Random(seed),
    ).map((e) => e.id).toList();
    expect(ids(7), ids(7));
    expect(ids(7), isNot(ids(8)));
  });

  test('a small topic returns all it has, without repeats', () {
    final pool = [...make(1, 4), ...make(1, 4)]; // duplicate ids
    final r = buildRound(
      topicQuestions: pool,
      level: 1,
      recentCorrect: const {},
      random: Random(5),
    );
    expect(r, hasLength(4));
  });
}

Question tq(String topic, String id) => Question(
  id: id,
  topic: topic,
  level: 1,
  format: QuestionFormat.number,
  prompt: id,
  answer: '1',
  explanation: '',
);

void mixInTests() {
  group('mix-in (AC-4)', () {
    final own = [for (var i = 0; i < 15; i++) tq('own', 'own-$i')];
    final weak = [for (var i = 0; i < 15; i++) tq('weak', 'weak-$i')];

    test('2 from the needs-practice topic, 8 own, no repeats', () {
      final random = Random(9);
      final mix = pickMixIn(
        candidates: weak,
        level: 1,
        recentCorrect: const {},
        random: random,
      );
      expect(mix, hasLength(2));
      final r = buildRound(
        topicQuestions: own,
        level: 1,
        recentCorrect: const {},
        random: random,
        mixIn: mix,
      );
      expect(r, hasLength(10));
      expect(r.where((q) => q.topic == 'weak'), hasLength(2));
      expect(r.where((q) => q.topic == 'own'), hasLength(8));
      expect(r.map((q) => q.id).toSet(), hasLength(10));
    });

    test('mixed-in questions land in random positions', () {
      final positions = <int>{};
      for (var seed = 0; seed < 20; seed++) {
        final random = Random(seed);
        final r = buildRound(
          topicQuestions: own,
          level: 1,
          recentCorrect: const {},
          random: random,
          mixIn: pickMixIn(
            candidates: weak,
            level: 1,
            recentCorrect: const {},
            random: random,
          ),
        );
        for (var i = 0; i < r.length; i++) {
          if (r[i].topic == 'weak') positions.add(i);
        }
      }
      expect(positions.length, greaterThan(5));
    });

    test('mix-in prefers not-recently-correct questions', () {
      final recent = {for (var i = 0; i < 13; i++) 'weak-$i'};
      final mix = pickMixIn(
        candidates: weak,
        level: 1,
        recentCorrect: recent,
        random: Random(1),
      );
      expect(mix.map((q) => q.id).toSet(), {'weak-13', 'weak-14'});
    });

    test('a short mix-in topic: own topic fills up to 10', () {
      final mix = pickMixIn(
        candidates: weak.take(1).toList(),
        level: 1,
        recentCorrect: const {},
        random: Random(1),
      );
      final r = buildRound(
        topicQuestions: own,
        level: 1,
        recentCorrect: const {},
        random: Random(1),
        mixIn: mix,
      );
      expect(r, hasLength(10));
      expect(r.where((q) => q.topic == 'own'), hasLength(9));
    });

    test('no mix-in leaves the round unchanged', () {
      List<String> ids(List<Question> mixIn) => buildRound(
        topicQuestions: own,
        level: 1,
        recentCorrect: const {},
        random: Random(3),
        mixIn: mixIn,
      ).map((q) => q.id).toList();
      expect(ids(const []), hasLength(10));
      expect(ids(const []).every((id) => id.startsWith('own')), isTrue);
    });
  });
}
