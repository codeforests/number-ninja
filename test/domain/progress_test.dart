import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/progress.dart';

FinishedRound round(
  int id,
  String topic, {
  required int level,
  required int stars,
  required int minute,
}) => FinishedRound(
  id: id,
  topicId: topic,
  level: level,
  stars: stars,
  startedAt: DateTime(2026, 11, 15, 9, minute),
);

void main() {
  group('nextLevel (AC-1)', () {
    const expected = {
      // level: [stars 0, 1, 2, 3]
      1: [1, 1, 1, 2],
      2: [1, 1, 2, 3],
      3: [2, 2, 3, 3],
    };
    for (final MapEntry(key: level, value: next) in expected.entries) {
      for (var stars = 0; stars <= 3; stars++) {
        test('level $level, $stars stars -> ${next[stars]}', () {
          expect(nextLevel(level, stars), next[stars]);
        });
      }
    }
  });

  group('progressByTopic (AC-1)', () {
    test('no rounds gives an empty map', () {
      expect(progressByTopic([]), isEmpty);
    });

    test('level follows the latest round by startedAt, not by id', () {
      final p = progressByTopic([
        round(2, 't', level: 2, stars: 3, minute: 1),
        round(1, 't', level: 1, stars: 0, minute: 5),
      ]);
      expect(p['t'], const TopicProgress(bestStars: 3, level: 1, rounds: 2));
    });

    test('same startedAt: the higher id is the latest', () {
      final p = progressByTopic([
        round(7, 't', level: 2, stars: 3, minute: 1),
        round(6, 't', level: 2, stars: 0, minute: 1),
      ]);
      expect(p['t']!.level, 3);
    });

    test('best stars count every level; topics are kept apart', () {
      final p = progressByTopic([
        round(1, 'a', level: 1, stars: 3, minute: 1),
        round(2, 'a', level: 2, stars: 1, minute: 2),
        round(3, 'b', level: 1, stars: 2, minute: 3),
      ]);
      expect(p['a'], const TopicProgress(bestStars: 3, level: 1, rounds: 2));
      expect(p['b'], const TopicProgress(bestStars: 2, level: 1, rounds: 1));
    });

    test('none is 0 stars at level 1', () {
      expect(
        TopicProgress.none,
        const TopicProgress(bestStars: 0, level: 1, rounds: 0),
      );
    });
  });
}
