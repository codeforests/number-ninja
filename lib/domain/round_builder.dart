import 'dart:math';

import 'question.dart';

/// Picks the questions for one round (PRC-02, PRC-08).
///
/// Takes the topic's questions at [level], shuffled with [random], with those
/// whose id is in [recentCorrect] last. If the level has fewer than [size],
/// fills from the nearest other level (lower first on a tie), with the same
/// preference. Never repeats a question. Returns at most [size].
///
/// [mixIn] (already picked with [pickMixIn], at most 2) are added first and
/// the topic's own questions fill the rest; the whole round is then shuffled
/// so they land in random positions (design §5).
List<Question> buildRound({
  required List<Question> topicQuestions,
  required int level,
  required Set<String> recentCorrect,
  required Random random,
  int size = 10,
  List<Question> mixIn = const [],
}) {
  if (mixIn.isNotEmpty) {
    final mixed = mixIn.take(size).toList();
    final ids = {for (final q in mixed) q.id};
    final own = _pick(
      [
        for (final q in topicQuestions)
          if (!ids.contains(q.id)) q,
      ],
      level,
      recentCorrect,
      random,
      size - mixed.length,
    );
    return [...mixed, ...own]..shuffle(random);
  }
  return _pick(topicQuestions, level, recentCorrect, random, size);
}

/// Up to [count] questions of a needs-practice topic for a School round
/// (design §5), from [candidates] at [level], with the same preference as
/// [buildRound].
List<Question> pickMixIn({
  required List<Question> candidates,
  required int level,
  required Set<String> recentCorrect,
  required Random random,
  int count = 2,
}) => _pick(candidates, level, recentCorrect, random, count);

List<Question> _pick(
  List<Question> topicQuestions,
  int level,
  Set<String> recentCorrect,
  Random random,
  int size,
) {
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
