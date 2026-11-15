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
