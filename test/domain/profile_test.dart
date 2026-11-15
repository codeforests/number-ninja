import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/progress.dart';
import 'package:number_ninja/domain/topics.dart';

ChildProfile prof(int year, {int? school, int? olympiad}) => ChildProfile(
  nickname: 'Mia',
  schoolYear: year,
  schoolStartLevel: school,
  olympiadStartLevel: olympiad,
);

void main() {
  final p1 = topicsById['p1.place']!;
  final p2 = topicsById['p2.fractions']!;
  final oly = topicsById['oly.logic']!;

  test('no profile or unknown topic starts at level 1', () {
    for (final t in topics) {
      expect(startLevel(null, t), 1, reason: t.id);
    }
    expect(startLevel(prof(6), null), 1);
  });

  test('automatic level from school year', () {
    // year: [P1 topic, P2 topic, Olympiad topic]
    const expected = {
      1: [1, 1, 1],
      2: [2, 1, 1],
      3: [3, 2, 2],
      4: [3, 3, 3],
      5: [3, 3, 3],
      6: [3, 3, 3],
    };
    for (final MapEntry(key: year, value: levels) in expected.entries) {
      expect([
        startLevel(prof(year), p1),
        startLevel(prof(year), p2),
        startLevel(prof(year), oly),
      ], levels, reason: 'P$year');
    }
  });

  test('each override wins for its own track only', () {
    expect(startLevel(prof(1, school: 3), p1), 3);
    expect(startLevel(prof(1, school: 3), p2), 3);
    expect(startLevel(prof(1, school: 3), oly), 1);
    expect(startLevel(prof(6, olympiad: 1), oly), 1);
    expect(startLevel(prof(6, olympiad: 1), p1), 3);
    expect(startLevel(prof(2, school: 1, olympiad: 2), p1), 1);
    expect(startLevel(prof(2, school: 1, olympiad: 2), oly), 2);
  });

  test('topic years', () {
    expect(topicYear(p1), 1);
    expect(topicYear(p2), 2);
    expect(topicYear(oly), isNull);
  });

  test('nickname rules', () {
    expect(nicknameError(''), isNotNull);
    expect(nicknameError('   '), isNotNull);
    expect(nicknameError('a' * 21), isNotNull);
    expect(nicknameError('A'), isNull);
    expect(nicknameError('a' * 20), isNull);
    expect(nicknameError('  ${'a' * 20}  '), isNull);
  });

  test('fresh progress', () {
    expect(TopicProgress.none, const TopicProgress.fresh(1));
    expect(const TopicProgress.fresh(2).level, 2);
    expect(const TopicProgress.fresh(2).rounds, 0);
  });
}
