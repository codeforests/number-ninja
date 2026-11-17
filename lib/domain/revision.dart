/// Rule-based revision (REV-01..06, D12, ADR-06): weak question types,
/// recent mistakes and the questions of a revision round. Pure Dart; the app
/// talks to it only through [RevisionPlanner] so a smarter planner can
/// replace it later.
library;

import 'dart:math';

import 'question.dart';
import 'round_builder.dart';
import 'stats.dart';

/// `topic_id` stored for a mixed revision round (all topics).
const mixedScopeId = 'mixed';

/// Days of attempts the planner looks at (same as the mix-in, design §5).
const revisionWindow = Duration(days: 30);

/// Questions answered right this recently are picked last.
const recentCorrectWindow = Duration(days: 7);

/// A type needs at least this many of its latest attempts to be weak.
const weakMinAttempts = 5;

/// Only a type's latest attempts count.
const weakLatest = 10;

/// Accuracy below this is weak.
const weakBelow = 0.7;

/// Average time above this multiple of the topic's average is weak.
const slowFactor = 1.5;

/// At most this many recent mistakes start a round.
const maxMistakesInRound = 5;

/// Questions in a revision round.
const revisionRoundSize = 10;

/// Mixed revision is offered from this many recent mistakes (or a weak type).
const mixedMinMistakes = 3;

/// The question's type: its id without the `.nnn` suffix.
String typeOf(String questionId) {
  final i = questionId.lastIndexOf('.');
  return i < 0 ? questionId : questionId.substring(0, i);
}

/// A readable label from the template slug: `p1.place.tens-ones` → "Tens ones".
String typeLabel(String typeId) {
  final slug = typeId.substring(typeId.lastIndexOf('.') + 1);
  final words = slug.replaceAll(RegExp('[-_]+'), ' ').trim();
  if (words.isEmpty) return typeId;
  return words[0].toUpperCase() + words.substring(1);
}

/// What a revision round covers.
sealed class RevisionScope {
  const RevisionScope();

  /// The topic id, or [mixedScopeId].
  String get id;

  static RevisionScope fromId(String id) =>
      id == mixedScopeId ? const MixedScope() : TopicScope(id);
}

class TopicScope extends RevisionScope {
  const TopicScope(this.topicId);

  final String topicId;

  @override
  String get id => topicId;

  @override
  bool operator ==(Object other) =>
      other is TopicScope && other.topicId == topicId;

  @override
  int get hashCode => topicId.hashCode;
}

class MixedScope extends RevisionScope {
  const MixedScope();

  @override
  String get id => mixedScopeId;

  @override
  bool operator ==(Object other) => other is MixedScope;

  @override
  int get hashCode => mixedScopeId.hashCode;
}

/// What the planner works from.
class RevisionHistory {
  const RevisionHistory({
    required this.attempts,
    required this.levels,
    required this.recentCorrect,
  });

  static const empty = RevisionHistory(
    attempts: [],
    levels: {},
    recentCorrect: {},
  );

  /// Attempts already cut to [revisionWindow], any order.
  final List<AttemptRecord> attempts;

  /// Current level per topic id (missing = 1).
  final Map<String, int> levels;

  /// Question ids answered right within [recentCorrectWindow].
  final Set<String> recentCorrect;
}

class WeakType {
  const WeakType({
    required this.typeId,
    required this.topicId,
    required this.tally,
    required this.slow,
  });

  final String typeId;
  final String topicId;

  /// Its latest [weakLatest] attempts.
  final Tally tally;

  /// Weak because of time (average over [slowFactor] × the topic's).
  final bool slow;
}

class RevisionPlan {
  const RevisionPlan({
    required this.scope,
    required this.questions,
    required this.mistakeIds,
    required this.weakTypes,
  });

  final RevisionScope scope;
  final List<Question> questions;
  final List<String> mistakeIds;
  final List<WeakType> weakTypes;

  bool get isEmpty => questions.isEmpty;
}

abstract interface class RevisionPlanner {
  /// Weak types (REV-01), weakest first; of one topic when [topicId] is set.
  List<WeakType> weakTypes(RevisionHistory h, {String? topicId});

  /// Recent mistakes (REV-02): ids whose latest attempt is wrong, newest first.
  List<String> mistakes(RevisionHistory h, {String? topicId});

  /// Whether to offer a revision round for [s] (REV-03).
  bool offers(RevisionHistory h, RevisionScope s);

  /// The round's questions (REV-04).
  RevisionPlan plan(
    RevisionHistory h,
    QuestionBank bank,
    RevisionScope s,
    Random random,
  );
}

class RuleRevisionPlanner implements RevisionPlanner {
  const RuleRevisionPlanner();

  @override
  List<WeakType> weakTypes(RevisionHistory h, {String? topicId}) {
    final byTopic = <String, List<AttemptRecord>>{};
    for (final a in h.attempts) {
      if (topicId == null || a.topicId == topicId) {
        (byTopic[a.topicId] ??= []).add(a);
      }
    }
    final out = <WeakType>[];
    for (final MapEntry(key: topic, value: rows) in byTopic.entries) {
      final topicAvg = overall(rows).avgSeconds!;
      final byType = <String, List<AttemptRecord>>{};
      for (final a in rows) {
        (byType[typeOf(a.questionId)] ??= []).add(a);
      }
      for (final MapEntry(key: type, value: list) in byType.entries) {
        final latest = _newestFirst(list).take(weakLatest).toList();
        if (latest.length < weakMinAttempts) continue;
        final t = overall(latest);
        final slow = t.avgSeconds! > slowFactor * topicAvg;
        if (t.accuracy! < weakBelow || slow) {
          out.add(WeakType(typeId: type, topicId: topic, tally: t, slow: slow));
        }
      }
    }
    out.sort((a, b) {
      final acc = a.tally.accuracy!.compareTo(b.tally.accuracy!);
      if (acc != 0) return acc;
      final time = b.tally.avgSeconds!.compareTo(a.tally.avgSeconds!);
      if (time != 0) return time;
      return a.typeId.compareTo(b.typeId);
    });
    return out;
  }

  @override
  List<String> mistakes(RevisionHistory h, {String? topicId}) {
    final latest = <String, AttemptRecord>{};
    for (final a in h.attempts) {
      if (topicId != null && a.topicId != topicId) continue;
      final seen = latest[a.questionId];
      if (seen == null || a.answeredAt.isAfter(seen.answeredAt)) {
        latest[a.questionId] = a;
      }
    }
    final wrong = [
      for (final a in latest.values)
        if (!a.correct) a,
    ];
    return [for (final a in _newestFirst(wrong)) a.questionId];
  }

  @override
  bool offers(RevisionHistory h, RevisionScope s) => switch (s) {
    TopicScope(:final topicId) =>
      weakTypes(h, topicId: topicId).isNotEmpty ||
          mistakes(h, topicId: topicId).isNotEmpty,
    MixedScope() =>
      weakTypes(h).isNotEmpty || mistakes(h).length >= mixedMinMistakes,
  };

  @override
  RevisionPlan plan(
    RevisionHistory h,
    QuestionBank bank,
    RevisionScope s,
    Random random,
  ) {
    final topicId = switch (s) {
      TopicScope(:final topicId) => topicId,
      MixedScope() => null,
    };
    final weak = weakTypes(h, topicId: topicId);
    final mistakeIds = mistakes(h, topicId: topicId);
    final pool = topicId == null
        ? [
            for (final q in bank.questions)
              if (!q.retired) q,
          ]
        : bank.byTopic[topicId] ?? const <Question>[];
    final byId = {for (final q in pool) q.id: q};
    final byType = <String, List<Question>>{};
    for (final q in pool) {
      (byType[typeOf(q.id)] ??= []).add(q);
    }

    final out = <Question>[];
    final used = <String>{};
    void add(Question q) {
      if (out.length < revisionRoundSize && used.add(q.id)) out.add(q);
    }

    // 1. Recent mistakes, the exact questions.
    for (final id in mistakeIds) {
      if (out.length >= maxMistakesInRound) break;
      if (byId[id] case final q?) add(q);
    }
    // 2. Weak types, round-robin; 3. siblings of the mistakes.
    _roundRobin([for (final w in weak) w.typeId], byType, h, random, used, add);
    final mistakeTypes = <String>[];
    for (final id in mistakeIds) {
      final t = typeOf(id);
      if (!mistakeTypes.contains(t)) mistakeTypes.add(t);
    }
    _roundRobin(mistakeTypes, byType, h, random, used, add);

    out.shuffle(random);
    return RevisionPlan(
      scope: s,
      questions: out,
      mistakeIds: mistakeIds,
      weakTypes: weak,
    );
  }

  void _roundRobin(
    List<String> types,
    Map<String, List<Question>> byType,
    RevisionHistory h,
    Random random,
    Set<String> used,
    void Function(Question) add,
  ) {
    final queues = <List<Question>>[];
    for (final type in types) {
      final qs = byType[type];
      if (qs == null || qs.isEmpty) continue;
      final level = h.levels[qs.first.topic] ?? 1;
      queues.add(
        _pickAll(
          [
            for (final q in qs)
              if (!used.contains(q.id)) q,
          ],
          level,
          h.recentCorrect,
          random,
        ),
      );
    }
    var i = 0;
    while (used.length < revisionRoundSize && queues.any((q) => q.isNotEmpty)) {
      final queue = queues[i % queues.length];
      i++;
      while (queue.isNotEmpty) {
        final q = queue.removeAt(0);
        if (!used.contains(q.id)) {
          add(q);
          break;
        }
      }
    }
  }
}

/// Every question in [qs], ordered as [buildRound] would pick them.
List<Question> _pickAll(
  List<Question> qs,
  int level,
  Set<String> recentCorrect,
  Random random,
) => buildRound(
  topicQuestions: qs,
  level: level,
  recentCorrect: recentCorrect,
  random: random,
  size: qs.length,
);

List<AttemptRecord> _newestFirst(List<AttemptRecord> list) =>
    [...list]..sort((a, b) {
      final d = b.answeredAt.compareTo(a.answeredAt);
      return d != 0 ? d : a.questionId.compareTo(b.questionId);
    });
