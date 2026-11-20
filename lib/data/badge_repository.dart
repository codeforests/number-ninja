import 'package:drift/drift.dart';

import '../domain/badges.dart';
import '../domain/clock.dart';
import 'database.dart';
import 'round_repository.dart' show roundKindRevision;
import 'stats_repository.dart';

/// Awards and lists badges (BDG-01). Rules are evaluated from scratch over
/// all finished rounds and attempts; each badge is recorded once.
class BadgeRepository {
  BadgeRepository(this.db, this.stats, {required this.clock, this.childId = 1});

  final AppDatabase db;

  /// The child whose badges these are (FEAT-25).
  final int childId;
  final StatsRepository stats;
  final Clock clock;

  /// Earned badge ids and when each was earned.
  Future<Map<String, DateTime>> earned() async => {
    for (final r in await (db.select(
      db.badgesEarned,
    )..where((b) => b.childId.equals(childId))).get())
      r.badgeId: r.earnedAt,
  };

  /// Inserts every badge whose rule now holds and isn't recorded yet,
  /// stamped with the clock, and returns those in shelf order.
  Future<List<Badge>> awardNew() async {
    final rows =
        await (db.select(db.rounds)..where(
              (r) => r.finishedAt.isNotNull() & r.childId.equals(childId),
            ))
            .get();
    final facts = BadgeFacts(
      rounds: [
        for (final r in rows)
          BadgeRound(
            topicId: r.topicId,
            stars: r.stars,
            durationMs: r.durationMs,
            finishedAt: r.finishedAt!,
            revision: r.kind == roundKindRevision,
          ),
      ],
      attempts: await stats.records(),
    );
    final holds = evaluateBadges(facts);
    final now = clock();
    return db.transaction(() async {
      final have = (await earned()).keys.toSet();
      final fresh = [
        for (final b in badges)
          if (holds.contains(b.id) && !have.contains(b.id)) b,
      ];
      for (final b in fresh) {
        await db
            .into(db.badgesEarned)
            .insert(
              BadgesEarnedCompanion.insert(
                childId: childId,
                badgeId: b.id,
                earnedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      return fresh;
    });
  }
}
