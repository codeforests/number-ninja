import '../domain/clock.dart';
import '../domain/revision.dart';
import 'round_repository.dart';
import 'stats_repository.dart';

/// Gathers what the revision planner works from (REV-01, REV-02).
class RevisionRepository {
  RevisionRepository(this.stats, this.rounds, {required this.clock});

  final StatsRepository stats;
  final RoundRepository rounds;
  final Clock clock;

  /// Attempts of the last [revisionWindow] (rounds of any kind, quit rounds
  /// included), the current level per played topic and the ids answered
  /// right in the last [recentCorrectWindow].
  Future<RevisionHistory> history() async {
    final now = clock();
    final attempts = await stats.records(since: now.subtract(revisionWindow));
    final recentSince = now.subtract(recentCorrectWindow);
    final progress = await rounds.progress();
    return RevisionHistory(
      attempts: attempts,
      levels: {
        for (final MapEntry(key: id, value: p) in progress.entries) id: p.level,
      },
      recentCorrect: {
        for (final a in attempts)
          if (a.correct && !a.answeredAt.isBefore(recentSince)) a.questionId,
      },
    );
  }
}
