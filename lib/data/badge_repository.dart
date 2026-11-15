import 'package:drift/drift.dart';

import '../domain/badges.dart';
import '../domain/clock.dart';
import 'database.dart';
import 'stats_repository.dart';

/// Awards and lists badges (BDG-01). Rules are evaluated from scratch over
/// all finished rounds and attempts; each badge is recorded once.
class BadgeRepository {
  BadgeRepository(this.db, this.stats, {required this.clock});

  final AppDatabase db;
  final StatsRepository stats;
  final Clock clock;

  /// Earned badge ids and when each was earned.
  Future<Map<String, DateTime>> earned() async => {
    for (final r in await db.select(db.badgesEarned).get())
      r.badgeId: r.earnedAt,
  };

  /// Inserts every badge whose rule now holds and isn't recorded yet,
  /// stamped with the clock, and returns those in shelf order.
  Future<List<Badge>> awardNew() async {
    final rows = await (db.select(
      db.rounds,
    )..where((r) => r.finishedAt.isNotNull())).get();
    final facts = BadgeFacts(
      rounds: [
        for (final r in rows)
          BadgeRound(
            topicId: r.topicId,
            stars: r.stars,
            durationMs: r.durationMs,
            finishedAt: r.finishedAt!,
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
              BadgesEarnedCompanion.insert(badgeId: b.id, earnedAt: now),
              mode: InsertMode.insertOrIgnore,
            );
      }
      return fresh;
    });
  }
}
