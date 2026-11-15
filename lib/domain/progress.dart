/// Topic levels and best stars, worked out from finished rounds
/// (design §5, PRC-07, PRC-09). Never stored.
library;

/// The lowest and highest difficulty level.
const minLevel = 1;
const maxLevel = 3;

/// The level after a round at [level] with [stars]: 3 stars step up,
/// 0–1 stars step down, 2 stay; kept within [minLevel]–[maxLevel].
int nextLevel(int level, int stars) {
  final next = stars >= 3
      ? level + 1
      : stars <= 1
      ? level - 1
      : level;
  return next.clamp(minLevel, maxLevel);
}

/// A round whose last answer was saved.
class FinishedRound {
  const FinishedRound({
    required this.id,
    required this.topicId,
    required this.level,
    required this.stars,
    required this.startedAt,
  });

  final int id;
  final String topicId;
  final int level;
  final int stars;
  final DateTime startedAt;
}

/// Her standing in one topic.
class TopicProgress {
  const TopicProgress({
    required this.bestStars,
    required this.level,
    required this.rounds,
  });

  /// A topic she has never finished a round of.
  static const none = TopicProgress(bestStars: 0, level: minLevel, rounds: 0);

  final int bestStars;
  final int level;
  final int rounds;

  @override
  bool operator ==(Object other) =>
      other is TopicProgress &&
      other.bestStars == bestStars &&
      other.level == level &&
      other.rounds == rounds;

  @override
  int get hashCode => Object.hash(bestStars, level, rounds);

  @override
  String toString() =>
      'TopicProgress(bestStars: $bestStars, level: $level, rounds: $rounds)';
}

/// Per topic: best stars over all its rounds, and the level that follows
/// its latest round (by start time, then id). Topics with no rounds are
/// absent; use [TopicProgress.none] for them.
Map<String, TopicProgress> progressByTopic(Iterable<FinishedRound> rounds) {
  final byTopic = <String, List<FinishedRound>>{};
  for (final r in rounds) {
    (byTopic[r.topicId] ??= []).add(r);
  }
  return {
    for (final MapEntry(key: topic, value: list) in byTopic.entries)
      topic: _progress(list),
  };
}

TopicProgress _progress(List<FinishedRound> rounds) {
  var best = 0;
  FinishedRound? latest;
  for (final r in rounds) {
    if (r.stars > best) best = r.stars;
    if (latest == null ||
        r.startedAt.isAfter(latest.startedAt) ||
        (r.startedAt == latest.startedAt && r.id > latest.id)) {
      latest = r;
    }
  }
  return TopicProgress(
    bestStars: best,
    level: nextLevel(latest!.level, latest.stars),
    rounds: rounds.length,
  );
}
