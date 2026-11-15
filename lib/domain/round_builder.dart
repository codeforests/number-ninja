import 'dart:math';

import 'question.dart';

/// Picks the questions for one round (PRC-02, PRC-08).
///
/// Takes the topic's questions at [level], shuffled with [random], with those
/// whose id is in [recentCorrect] last. If the level has fewer than [size],
/// fills from the nearest other level (lower first on a tie), with the same
/// preference. Never repeats a question. Returns at most [size].
List<Question> buildRound({
  required List<Question> topicQuestions,
  required int level,
  required Set<String> recentCorrect,
  required Random random,
  int size = 10,
}) {
  final byLevel = <int, List<Question>>{};
  final seen = <String>{};
  for (final q in topicQuestions) {
    if (seen.add(q.id)) (byLevel[q.level] ??= []).add(q);
  }
  final levels = byLevel.keys.toList()
    ..sort((a, b) {
      final d = (a - level).abs().compareTo((b - level).abs());
      return d != 0 ? d : a.compareTo(b);
    });

  final out = <Question>[];
  for (final l in levels) {
    if (out.length >= size) break;
    final qs = [...byLevel[l]!]..shuffle(random);
    final fresh = [
      for (final q in qs)
        if (!recentCorrect.contains(q.id)) q,
    ];
    final recent = [
      for (final q in qs)
        if (recentCorrect.contains(q.id)) q,
    ];
    for (final q in [...fresh, ...recent]) {
      if (out.length >= size) break;
      out.add(q);
    }
  }
  return out;
}
