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
  Future<void> open(String topicId) => db
      .into(db.topicUnlocks)
      .insert(
        TopicUnlocksCompanion.insert(topicId: topicId, openedAt: clock()),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> close(String topicId) => (db.delete(
    db.topicUnlocks,
  )..where((t) => t.topicId.equals(topicId))).go();
}
