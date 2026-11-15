import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/badges.dart';
import 'package:number_ninja/domain/stats.dart';
import 'package:number_ninja/domain/topics.dart';

final day0 = DateTime(2026, 11, 18, 15);

BadgeRound round(
  String topic, {
  int stars = 1,
  int ms = 300000,
  DateTime? at,
}) => BadgeRound(
  topicId: topic,
  stars: stars,
  durationMs: ms,
  finishedAt: at ?? day0,
);

/// [n] attempts in [topic], oldest first; the oldest [correct] are right, or
/// the newest [correct] with [newestCorrect].
List<AttemptRecord> attempts(
  String topic,
  int n, {
  int? correct,
  bool newestCorrect = false,
  DateTime? from,
}) {
  final start = from ?? day0;
  final c = correct ?? n;
  return [
    for (var i = 0; i < n; i++)
      AttemptRecord(
        questionId: '$topic-$i',
        topicId: topic,
        correct: newestCorrect ? i >= n - c : i < c,
        timeMs: 5000,
        answeredAt: start.add(Duration(seconds: i)),
      ),
  ];
}

Set<String> eval({
  List<BadgeRound> rounds = const [],
  List<AttemptRecord> atts = const [],
}) => evaluateBadges(BadgeFacts(rounds: rounds, attempts: atts));

List<BadgeRound> onDays(List<DateTime> days) => [
  for (final d in days) round('p1.bonds', at: d),
];

void main() {
  test('20 badges with unique ids; empty facts give none (AC-1)', () {
    expect(badges, hasLength(20));
    expect(badges.map((b) => b.id).toSet(), hasLength(20));
    expect(eval(), isEmpty);
  });

  test('first-round needs a finished round; quit-round attempts alone '
      'award no round badge', () {
    expect(eval(atts: attempts('p1.bonds', 5)), isNot(contains('first-round')));
    expect(eval(rounds: [round('p1.bonds')]), contains('first-round'));
  });

  test('perfect-10: 2 stars no, 3 stars yes', () {
    expect(
      eval(rounds: [round('p1.bonds', stars: 2)]),
      isNot(contains('perfect-10')),
    );
    expect(eval(rounds: [round('p1.bonds', stars: 3)]), contains('perfect-10'));
  });

  group('streaks', () {
    test('2 vs 3 consecutive days across a month boundary', () {
      final two = onDays([
        DateTime(2026, 10, 31, 9),
        DateTime(2026, 11, 1, 20),
      ]);
      expect(eval(rounds: two), isNot(contains('streak-3')));
      final three = [...two, round('p1.bonds', at: DateTime(2026, 11, 2, 7))];
      expect(eval(rounds: three), contains('streak-3'));
    });

    test('a gap breaks the run; any run counts, not only ending today', () {
      final gap = onDays([
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 4),
      ]);
      expect(eval(rounds: gap), isNot(contains('streak-3')));
      final old = onDays([
        DateTime(2026, 9, 1),
        DateTime(2026, 9, 2),
        DateTime(2026, 9, 3),
        DateTime(2026, 11, 18),
      ]);
      expect(eval(rounds: old), contains('streak-3'));
    });

    test('several rounds on one day count once', () {
      final r = onDays([
        DateTime(2026, 11, 1, 8),
        DateTime(2026, 11, 1, 9),
        DateTime(2026, 11, 2, 9),
      ]);
      expect(longestStreak(r.map((x) => x.finishedAt)), 2);
    });

    List<BadgeRound> run(int n) =>
        onDays([for (var i = 0; i < n; i++) DateTime(2026, 3, 20 + i, 10)]);

    test('6 vs 7 days (across a DST-sized month)', () {
      expect(eval(rounds: run(6)), isNot(contains('streak-7')));
      expect(eval(rounds: run(7)), contains('streak-7'));
    });

    test('29 vs 30 days', () {
      expect(eval(rounds: run(29)), isNot(contains('streak-30')));
      expect(eval(rounds: run(30)), contains('streak-30'));
    });

    test('longestStreak of nothing is 0', () {
      expect(longestStreak(const []), 0);
    });
  });

  test('questions-100 and questions-500 count all attempts', () {
    expect(
      eval(atts: attempts('p1.bonds', 99)),
      isNot(contains('questions-100')),
    );
    expect(eval(atts: attempts('p1.bonds', 100)), contains('questions-100'));
    expect(
      eval(atts: attempts('p1.bonds', 499)),
      isNot(contains('questions-500')),
    );
    expect(eval(atts: attempts('p1.bonds', 500)), contains('questions-500'));
  });

  test('speedy: 3 stars under 120 s; 120 s or 2 stars is not enough', () {
    expect(
      eval(rounds: [round('p1.bonds', stars: 3, ms: 119900)]),
      contains('speedy'),
    );
    expect(
      eval(rounds: [round('p1.bonds', stars: 3, ms: 120000)]),
      isNot(contains('speedy')),
    );
    expect(
      eval(rounds: [round('p1.bonds', stars: 2, ms: 60000)]),
      isNot(contains('speedy')),
    );
  });

  group('mastery', () {
    const cases = {
      'times-hero': ['p2.times'],
      'division-dojo': ['p2.divide'],
      'fraction-friend': ['p2.fractions'],
      'money-master': ['p1.money', 'p2.money'],
      'time-keeper': ['p1.time', 'p2.time'],
      'shape-spotter': ['p1.shapes', 'p2.shapes'],
      'pattern-finder': ['oly.patterns'],
    };
    for (final MapEntry(key: id, value: ts) in cases.entries) {
      test('$id: 26 vs 27 of the last 30 in ${ts.join(' + ')}', () {
        // Split the 30 across the listed topics, newest last.
        List<AttemptRecord> make(int correct) {
          final all = attempts(
            ts.first,
            30,
            correct: correct,
            newestCorrect: true,
          );
          if (ts.length == 1) return all;
          return [
            for (var i = 0; i < all.length; i++)
              AttemptRecord(
                questionId: all[i].questionId,
                topicId: ts[i % ts.length],
                correct: all[i].correct,
                timeMs: all[i].timeMs,
                answeredAt: all[i].answeredAt,
              ),
          ];
        }

        expect(eval(atts: make(26)), isNot(contains(id)));
        expect(eval(atts: make(27)), contains(id));
      });
    }

    test('older wrong answers are ignored', () {
      final old = attempts(
        'p2.times',
        20,
        correct: 0,
        from: DateTime(2026, 1, 1),
      );
      final recent = attempts('p2.times', 30, correct: 27, newestCorrect: true);
      expect(mastered([...old, ...recent], {'p2.times'}), isTrue);
    });

    test('29 attempts are not enough even if all correct', () {
      expect(mastered(attempts('p2.times', 29), {'p2.times'}), isFalse);
      expect(mastered(attempts('p2.times', 30), {'p2.times'}), isTrue);
    });

    test('other topics do not count', () {
      expect(mastered(attempts('p2.divide', 30), {'p2.times'}), isFalse);
    });
  });

  group('olympiad puzzles', () {
    const cases = {
      'puzzle-master': 'oly.logic',
      'counting-star': 'oly.counting',
      'bar-model-builder': 'oly.models',
    };
    for (final MapEntry(key: id, value: t) in cases.entries) {
      test('$id: 19 vs 20 correct $t (wrong ones do not count)', () {
        expect(eval(atts: attempts(t, 25, correct: 19)), isNot(contains(id)));
        expect(eval(atts: attempts(t, 25, correct: 20)), contains(id));
      });
    }
  });

  test('quit-round attempts count towards attempt rules', () {
    // No rounds at all: attempts come from quit rounds.
    final got = eval(atts: attempts('oly.logic', 100));
    expect(got, containsAll(['questions-100', 'puzzle-master']));
    expect(got, isNot(contains('first-round')));
  });

  test('school-explorer: 18 vs 19 School topics; Olympiad does not count', () {
    final school = [
      for (final t in topics)
        if (t.track != Track.olympiad) t.id,
    ];
    expect(school, hasLength(19));
    final some = [
      for (final t in school.skip(1)) round(t, stars: 0),
      for (final t in topics.where((t) => t.track == Track.olympiad))
        round(t.id),
    ];
    expect(eval(rounds: some), isNot(contains('school-explorer')));
    expect(
      eval(rounds: [...some, round(school.first, stars: 0)]),
      contains('school-explorer'),
    );
    expect(
      eval(rounds: [for (final t in school) round(t, stars: 0)]),
      contains('school-explorer'),
      reason: 'no Olympiad round needed',
    );
  });

  test('ninja-master: 22 vs 23 topics at 3 stars (best of each)', () {
    final rs = [
      for (final t in topics) ...[round(t.id, stars: 3), round(t.id, stars: 1)],
    ];
    expect(eval(rounds: rs), contains('ninja-master'));
    final missing = rs.where((r) => r.topicId != 'oly.models' || r.stars != 3);
    expect(eval(rounds: missing.toList()), isNot(contains('ninja-master')));
    final twoStars = [...missing, round('oly.models', stars: 2)];
    expect(eval(rounds: twoStars), isNot(contains('ninja-master')));
  });
}
