import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/progress.dart';
import 'package:number_ninja/domain/topic_lock.dart';
import 'package:number_ninja/domain/topics.dart';

var _id = 0;
FinishedRound r(String topic, int score) => FinishedRound(
  id: ++_id,
  topicId: topic,
  level: 1,
  stars: 0,
  score: score,
  startedAt: DateTime(2026, 11, 16, 9, _id % 60),
);

Iterable<String> ids(Track t) =>
    topics.where((x) => x.track == t).map((x) => x.id);

Map<String, TopicLock> locks(
  List<FinishedRound> rounds, {
  int? year,
  Set<String> opened = const {},
}) => topicLocks(
  topics: topics,
  rounds: rounds,
  schoolYear: year,
  opened: opened,
);

const open = TopicOpen.new;

void main() {
  test('nothing played, no profile: only p1.place and Olympiad open', () {
    final l = locks([]);
    expect(l['p1.place'], open(OpenReason.first));
    for (final id in ids(Track.olympiad)) {
      expect(l[id], open(OpenReason.olympiad), reason: id);
    }
    expect(l['p1.bonds'], const TopicLocked('p1.place'));
    expect(l['p1.groups'], const TopicLocked('p1.bonds'));
    expect(l['p2.place'], const TopicLocked('p1.place'));
    expect(l['p2.regroup'], const TopicLocked('p2.place'));
    expect(l.length, topics.length);
  });

  test('7 of 10 passes and opens the next topic; 6 does not', () {
    var l = locks([r('p1.place', 7)]);
    expect(l['p1.place'], open(OpenReason.passed));
    expect(l['p1.bonds'], open(OpenReason.previousPassed));
    expect(l['p1.groups'], const TopicLocked('p1.bonds'));
    l = locks([r('p1.place', 6)]);
    expect(l['p1.place'], open(OpenReason.played));
    expect(l['p1.bonds'], const TopicLocked('p1.place'));
  });

  test('a pass in any earlier round counts', () {
    final l = locks([r('p1.place', 9), r('p1.place', 2)]);
    expect(l['p1.place'], open(OpenReason.passed));
    expect(l['p1.bonds'], open(OpenReason.previousPassed));
  });

  test('every P1 topic passed opens p2.place only', () {
    final l = locks([for (final id in ids(Track.p1)) r(id, 8)]);
    expect(l['p2.place'], open(OpenReason.first));
    expect(l['p2.regroup'], const TopicLocked('p2.place'));
  });

  test('pass-first for a year is the first unpassed topic before it', () {
    final l = locks([
      for (final id in ids(Track.p1))
        if (id != 'p1.graphs') r(id, 10),
    ]);
    expect(l['p1.graphs'], open(OpenReason.previousPassed));
    expect(l['p2.place'], const TopicLocked('p1.graphs'));
  });

  test('profile P2: P1 below her year, p2.place open, rest of P2 in order', () {
    final l = locks([], year: 2);
    for (final id in ids(Track.p1)) {
      expect(l[id], open(OpenReason.belowYear), reason: id);
    }
    expect(l['p2.place'], open(OpenReason.first));
    expect(l['p2.regroup'], const TopicLocked('p2.place'));
  });

  test('profile P3 opens all of P1 and P2', () {
    final l = locks([], year: 3);
    for (final id in [...ids(Track.p1), ...ids(Track.p2)]) {
      expect(l[id], isNot(isA<TopicLocked>()), reason: id);
    }
  });

  test('a played topic stays open but does not open the next', () {
    final l = locks([
      r('p1.place', 7),
      r('p1.bonds', 7),
      r('p1.groups', 7),
      r('p1.money', 3),
    ]);
    expect(l['p1.money'], open(OpenReason.played));
    expect(l['p1.time'], const TopicLocked('p1.money'));
  });

  test('played P2 topics stay open when the profile year is lowered', () {
    final l = locks([r('p2.times', 4)], year: 1);
    expect(l['p2.times'], open(OpenReason.played));
    expect(l['p2.divide'], const TopicLocked('p2.times'));
  });

  test('parent opening opens a topic but not the next one', () {
    final l = locks([], opened: {'p1.money', 'p2.place'});
    expect(l['p1.money'], open(OpenReason.parent));
    expect(l['p1.time'], const TopicLocked('p1.money'));
    expect(l['p2.place'], open(OpenReason.parent));
    expect(l['p2.regroup'], const TopicLocked('p2.place'));
  });

  test('isLocked', () {
    expect(const TopicLocked('x').isLocked, isTrue);
    expect(open(OpenReason.first).isLocked, isFalse);
  });
}
