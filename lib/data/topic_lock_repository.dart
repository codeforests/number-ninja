import 'package:drift/drift.dart';

import '../domain/clock.dart';
import 'database.dart';

/// Topics the parent opened by hand (PRC-14). The PAR-10 reset keeps them.
class TopicLockRepository {
  TopicLockRepository(this.db, {required this.clock, this.childId = 1});

  final AppDatabase db;

  /// The child whose topics these are (FEAT-25).
  final int childId;
  final Clock clock;

  Future<Set<String>> opened() async => {
    for (final r in await (db.select(
      db.topicUnlocks,
    )..where((t) => t.childId.equals(childId))).get())
      r.topicId,
  };

  /// Opens [topicId]; opening it again keeps the first time.
  Future<void> open(String topicId) => db.transaction(() async {
    if (await _opened(topicId)) return;
    await db
        .into(db.topicUnlocks)
        .insert(
          TopicUnlocksCompanion.insert(
            childId: childId,
            topicId: topicId,
            openedAt: clock(),
          ),
        );
    await db.stampFields(childId, [syncFieldTopics], clock());
  });

  Future<bool> _opened(String topicId) async =>
      await (db.select(db.topicUnlocks)..where(
            (t) => t.topicId.equals(topicId) & t.childId.equals(childId),
          ))
          .getSingleOrNull() !=
      null;

  Future<void> close(String topicId) => db.transaction(() async {
    final n =
        await (db.delete(db.topicUnlocks)..where(
              (t) => t.topicId.equals(topicId) & t.childId.equals(childId),
            ))
            .go();
    if (n > 0) await db.stampFields(childId, [syncFieldTopics], clock());
  });

  /// Replaces the opened set with [topicIds] (a pull, FEAT-14): no stamp.
  Future<void> replaceAll(Set<String> topicIds) => db.transaction(() async {
    final have = await opened();
    await (db.delete(db.topicUnlocks)..where(
          (t) => t.topicId.isNotIn(topicIds) & t.childId.equals(childId),
        ))
        .go();
    for (final id in topicIds.difference(have)) {
      await db
          .into(db.topicUnlocks)
          .insert(
            TopicUnlocksCompanion.insert(
              childId: childId,
              topicId: id,
              openedAt: clock(),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  });
}
