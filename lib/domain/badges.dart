import 'stats.dart';
import 'topics.dart';

/// One of the 20 badges of design §7 (BDG-01). Ids are permanent.
class Badge {
  const Badge(this.id, this.name, this.hint);

  final String id;
  final String name;

  /// What to do to earn it, shown on SCR-06 while not earned.
  final String hint;
}

/// All badges in shelf order (FEAT-08 design, rule table).
const badges = <Badge>[
  Badge('first-round', 'First Round', 'Finish your first round'),
  Badge('perfect-10', 'Perfect 10', 'Get 10 out of 10'),
  Badge('streak-3', '3-Day Streak', 'Play 3 days in a row'),
  Badge('streak-7', '7-Day Streak', 'Play 7 days in a row'),
  Badge('streak-30', '30-Day Streak', 'Play 30 days in a row'),
  Badge('questions-100', '100 Questions', 'Answer 100 questions'),
  Badge('questions-500', '500 Questions', 'Answer 500 questions'),
  Badge('speedy', 'Speedy', 'Get 10 out of 10 in under 2 minutes'),
  Badge(
    'times-hero',
    'Times Table Hero',
    'Get 27 of your last 30 times table answers right',
  ),
  Badge(
    'division-dojo',
    'Division Dojo',
    'Get 27 of your last 30 division answers right',
  ),
  Badge(
    'fraction-friend',
    'Fraction Friend',
    'Get 27 of your last 30 fraction answers right',
  ),
  Badge(
    'money-master',
    'Money Master',
    'Get 27 of your last 30 money answers right',
  ),
  Badge(
    'time-keeper',
    'Time Keeper',
    'Get 27 of your last 30 time answers right',
  ),
  Badge(
    'shape-spotter',
    'Shape Spotter',
    'Get 27 of your last 30 shape answers right',
  ),
  Badge(
    'pattern-finder',
    'Pattern Finder',
    'Get 27 of your last 30 pattern answers right',
  ),
  Badge('puzzle-master', 'Puzzle Master', 'Solve 20 logic puzzles'),
  Badge('counting-star', 'Counting Star', 'Solve 20 counting puzzles'),
  Badge(
    'bar-model-builder',
    'Bar Model Builder',
    'Solve 20 bar model questions',
  ),
  Badge(
    'school-explorer',
    'School Explorer',
    'Finish a round in every School topic',
  ),
  Badge('ninja-master', 'Ninja Master', 'Get 3 stars in every topic'),
];

final badgesById = {for (final b in badges) b.id: b};

/// A finished round, as the badge rules need it.
class BadgeRound {
  const BadgeRound({
    required this.topicId,
    required this.stars,
    required this.durationMs,
    required this.finishedAt,
    this.revision = false,
  });

  final String topicId;

  /// A revision round (REV-04): counts for round rules, not topic-map ones.
  final bool revision;
  final int stars;
  final int durationMs;
  final DateTime finishedAt;
}

/// Everything the rules look at: all finished rounds and all attempts
/// (including those of quit rounds).
class BadgeFacts {
  const BadgeFacts({required this.rounds, required this.attempts});

  static const empty = BadgeFacts(rounds: [], attempts: []);

  final List<BadgeRound> rounds;
  final List<AttemptRecord> attempts;
}

const masteryWindow = 30;
const masteryCorrect = 27;
const puzzleTarget = 20;
const speedyLimitMs = 120000;

/// Mastery: at least 30 attempts in [topicIds], and at least 27 correct
/// among the latest 30 by answer time (ties by question id).
bool mastered(Iterable<AttemptRecord> attempts, Set<String> topicIds) {
  final list = [
    for (final a in attempts)
      if (topicIds.contains(a.topicId)) a,
  ];
  if (list.length < masteryWindow) return false;
  list.sort((a, b) {
    final c = b.answeredAt.compareTo(a.answeredAt);
    return c != 0 ? c : b.questionId.compareTo(a.questionId);
  });
  return list.take(masteryWindow).where((a) => a.correct).length >=
      masteryCorrect;
}

/// The longest run of consecutive local calendar days among [days].
/// Days are stepped with `DateTime(y, m, d + 1)` so DST can't break a run.
int longestStreak(Iterable<DateTime> days) {
  final dates = {for (final d in days) DateTime(d.year, d.month, d.day)};
  var best = 0;
  for (final d in dates) {
    if (dates.contains(DateTime(d.year, d.month, d.day - 1))) continue;
    var len = 1;
    var next = DateTime(d.year, d.month, d.day + 1);
    while (dates.contains(next)) {
      len++;
      next = DateTime(next.year, next.month, next.day + 1);
    }
    if (len > best) best = len;
  }
  return best;
}

/// Every badge id whose rule holds over [f] (BDG-01), evaluated from scratch.
Set<String> evaluateBadges(BadgeFacts f) {
  final rounds = f.rounds;
  final attempts = f.attempts;
  final earned = <String>{};
  void award(String id, bool when) {
    if (when) earned.add(id);
  }

  final streak = longestStreak(rounds.map((r) => r.finishedAt));
  final bestStars = <String, int>{};
  for (final r in rounds) {
    if (r.revision) continue;
    final s = bestStars[r.topicId];
    if (s == null || r.stars > s) bestStars[r.topicId] = r.stars;
  }
  int correctIn(String topic) =>
      attempts.where((a) => a.topicId == topic && a.correct).length;
  final school = [
    for (final t in topics)
      if (t.track != Track.olympiad) t.id,
  ];

  award('first-round', rounds.isNotEmpty);
  award('perfect-10', rounds.any((r) => r.stars == 3));
  award('streak-3', streak >= 3);
  award('streak-7', streak >= 7);
  award('streak-30', streak >= 30);
  award('questions-100', attempts.length >= 100);
  award('questions-500', attempts.length >= 500);
  award(
    'speedy',
    rounds.any((r) => r.stars == 3 && r.durationMs < speedyLimitMs),
  );
  award('times-hero', mastered(attempts, {'p2.times'}));
  award('division-dojo', mastered(attempts, {'p2.divide'}));
  award('fraction-friend', mastered(attempts, {'p2.fractions'}));
  award('money-master', mastered(attempts, {'p1.money', 'p2.money'}));
  award('time-keeper', mastered(attempts, {'p1.time', 'p2.time'}));
  award('shape-spotter', mastered(attempts, {'p1.shapes', 'p2.shapes'}));
  award('pattern-finder', mastered(attempts, {'oly.patterns'}));
  award('puzzle-master', correctIn('oly.logic') >= puzzleTarget);
  award('counting-star', correctIn('oly.counting') >= puzzleTarget);
  award('bar-model-builder', correctIn('oly.models') >= puzzleTarget);
  award('school-explorer', school.every(bestStars.containsKey));
  award('ninja-master', topics.every((t) => (bestStars[t.id] ?? 0) == 3));
  return earned;
}
