/// School topic lock (PRC-12..14, D17, FEAT-17 design). Worked out from
/// finished rounds, the profile and the parent's openings; never stored.
library;

import 'profile.dart';
import 'progress.dart';
import 'topics.dart';

/// Right answers in one finished round that pass a topic (7 of 10).
const passScore = 7;

/// Why an open topic is open.
enum OpenReason {
  olympiad,
  first,
  belowYear,
  previousPassed,
  passed,
  played,
  parent,
}

/// Whether a topic can be played.
sealed class TopicLock {
  const TopicLock();

  bool get isLocked => this is TopicLocked;
}

class TopicOpen extends TopicLock {
  const TopicOpen(this.reason);

  final OpenReason reason;

  @override
  bool operator ==(Object other) =>
      other is TopicOpen && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'TopicOpen(${reason.name})';
}

class TopicLocked extends TopicLock {
  const TopicLocked(this.passFirstId);

  /// The topic to pass first (PRC-14).
  final String passFirstId;

  @override
  bool operator ==(Object other) =>
      other is TopicLocked && other.passFirstId == passFirstId;

  @override
  int get hashCode => passFirstId.hashCode;

  @override
  String toString() => 'TopicLocked($passFirstId)';
}

/// The lock state of every topic in [topics], walked in list order per
/// school year. [schoolYear] null (no profile) counts as P1.
Map<String, TopicLock> topicLocks({
  required List<Topic> topics,
  required Iterable<FinishedRound> rounds,
  int? schoolYear,
  Set<String> opened = const {},
}) {
  final year = schoolYear ?? 1;
  final played = <String>{};
  final passed = <String>{};
  for (final r in rounds) {
    played.add(r.topicId);
    if (r.score >= passScore) passed.add(r.topicId);
  }
  final byYear = <int, List<Topic>>{};
  final result = <String, TopicLock>{};
  for (final t in topics) {
    final y = topicYear(t);
    if (y == null) {
      result[t.id] = const TopicOpen(OpenReason.olympiad);
    } else {
      (byYear[y] ??= []).add(t);
    }
  }
  final years = byYear.keys.toList()..sort();
  for (final y in years) {
    final list = byYear[y]!;
    final before = byYear[y - 1];
    final unpassedBefore = before?.where((t) => !passed.contains(t.id));
    for (var i = 0; i < list.length; i++) {
      final t = list[i];
      final TopicLock lock;
      if (passed.contains(t.id)) {
        lock = const TopicOpen(OpenReason.passed);
      } else if (y < year) {
        lock = const TopicOpen(OpenReason.belowYear);
      } else if (played.contains(t.id)) {
        lock = const TopicOpen(OpenReason.played);
      } else if (i > 0) {
        final prev = list[i - 1];
        lock = passed.contains(prev.id)
            ? const TopicOpen(OpenReason.previousPassed)
            : opened.contains(t.id)
            ? const TopicOpen(OpenReason.parent)
            : TopicLocked(prev.id);
      } else if (y <= year ||
          unpassedBefore == null ||
          unpassedBefore.isEmpty) {
        lock = const TopicOpen(OpenReason.first);
      } else {
        lock = opened.contains(t.id)
            ? const TopicOpen(OpenReason.parent)
            : TopicLocked(unpassedBefore.first.id);
      }
      result[t.id] = lock;
    }
  }
  return result;
}
