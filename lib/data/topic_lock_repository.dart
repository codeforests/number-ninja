import 'package:drift/drift.dart';

import '../domain/clock.dart';
import 'database.dart';

/// Topics the parent opened by hand (PRC-14). The PAR-10 reset keeps them.
class TopicLockRepository {
  TopicLockRepository(this.db, {required this.clock});

  final AppDatabase db;
  final Clock clock;

  Future<Set<String>> opened() async => {
    for (final r in await db.select(db.topicUnlocks).get()) r.topicId,
  };

  /// Opens [topicId]; opening it again keeps the first time.
  Future<void> open(String topicId) => db.transaction(() async {
    if (await _opened(topicId)) return;
    await db
        .into(db.topicUnlocks)
        .insert(
          TopicUnlocksCompanion.insert(topicId: topicId, openedAt: clock()),
        );
    await db.stampFields([syncFieldTopics], clock());
  });

  Future<bool> _opened(String topicId) async =>
      await (db.select(
        db.topicUnlocks,
      )..where((t) => t.topicId.equals(topicId))).getSingleOrNull() !=
      null;

  Future<void> close(String topicId) => db.transaction(() async {
    final n = await (db.delete(
      db.topicUnlocks,
    )..where((t) => t.topicId.equals(topicId))).go();
    if (n > 0) await db.stampFields([syncFieldTopics], clock());
  });

  /// Replaces the opened set with [topicIds] (a pull, FEAT-14): no stamp.
  Future<void> replaceAll(Set<String> topicIds) => db.transaction(() async {
    final have = await opened();
    await (db.delete(
      db.topicUnlocks,
    )..where((t) => t.topicId.isNotIn(topicIds))).go();
    for (final id in topicIds.difference(have)) {
      await db
          .into(db.topicUnlocks)
          .insert(
            TopicUnlocksCompanion.insert(topicId: id, openedAt: clock()),
            mode: InsertMode.insertOrIgnore,
          );
    }
  });
}
