import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/family.dart';
import '../domain/profile.dart';
import 'database.dart';

/// The family's children (FEAT-25, FAM-01): list, add, remove and which one
/// plays now (AD-3). A child's profile is saved through `ProfileRepository`
/// for her id.
class ChildRepository {
  ChildRepository(this.db, {required this.clock});

  final AppDatabase db;
  final Clock clock;

  /// Children in the order they were added; a child removed while offline
  /// (pending delete) is left out (AD-10).
  Future<List<FamilyChild>> all() async => [
    for (final r in await _visible().get())
      FamilyChild(
        id: r.id,
        nickname: r.nickname,
        schoolYear: r.schoolYear,
        avatar: r.avatar,
      ),
  ];

  SimpleSelectStatement<$ChildrenTable, ChildRow> _visible() =>
      db.select(db.children)
        ..where((c) => c.pendingDelete.equals(false))
        ..orderBy([(c) => OrderingTerm.asc(c.id)]);

  /// Adds a child with profile [p] and returns her id. Her avatar is [p]'s,
  /// or the first unused one when [pickAvatar] (AD-7). Throws [StateError]
  /// at [maxChildren].
  Future<int> add(ChildProfile p, {bool pickAvatar = false}) =>
      db.transaction(() async {
        final have = await all();
        if (have.length >= maxChildren) {
          throw StateError('At most $maxChildren children');
        }
        final now = clock();
        final avatar = pickAvatar
            ? nextAvatar(have.map((c) => c.avatar))
            : p.avatar;
        final id = await db
            .into(db.children)
            .insert(
              ChildrenCompanion.insert(
                nickname: Value(p.nickname.trim()),
                schoolYear: Value(p.schoolYear),
                schoolStartLevel: Value(p.schoolStartLevel),
                olympiadStartLevel: Value(p.olympiadStartLevel),
                avatar: Value(avatar),
                createdAt: now,
                updatedAt: now,
              ),
            );
        // Her profile is new here; limit, sound and topics stay at time 0
        // until changed, like a fresh install (FEAT-14).
        await db.seedChildFields(id, profileTime: now);
        return id;
      });

  /// Deletes child [id] and all her rows (AD-10). A child linked to the
  /// server stays as a hidden pending-delete row until sync removes the
  /// server record. The last child can't be removed ([StateError]). If she
  /// was playing, the first remaining child becomes current.
  Future<void> remove(int id) => db.transaction(() async {
    final have = await all();
    if (!have.any((c) => c.id == id)) return;
    if (have.length <= 1) throw StateError('The last child stays');
    await deleteRows(id);
    final row = await (db.select(
      db.children,
    )..where((c) => c.id.equals(id))).getSingle();
    if (row.remoteId == null) {
      await (db.delete(db.children)..where((c) => c.id.equals(id))).go();
    } else {
      await (db.update(db.children)..where((c) => c.id.equals(id))).write(
        const ChildrenCompanion(pendingDelete: Value(true)),
      );
    }
    if (await _savedCurrent() == id) {
      await setCurrent(have.firstWhere((c) => c.id != id).id);
    }
  });

  /// Empties child [id]'s profile, back to a fresh install's blank child
  /// (FEAT-25 AD-2): first-run setup removing its only child (FEAT-26 AD-8).
  Future<void> blank(int id) =>
      (db.update(db.children)..where((c) => c.id.equals(id))).write(
        ChildrenCompanion(nickname: const Value(''), updatedAt: Value(clock())),
      );

  /// Deletes every row of child [id] except her `children` row.
  Future<void> deleteRows(int id) async {
    for (final t in [
      'attempts',
      'rounds',
      'daily_usage',
      'badges_earned',
      'topic_unlocks',
      'sync_fields',
    ]) {
      await db.customStatement('DELETE FROM $t WHERE child_id = ?', [id]);
    }
    await db.customStatement(
      'DELETE FROM play_sessions WHERE id NOT IN '
      '(SELECT session_id FROM rounds)',
    );
  }

  Future<int> _savedCurrent() async => (await db.getSettings()).currentChildId;

  /// The child playing now: the saved one if she still exists, else the
  /// first child (a sync may have removed her, AD-10).
  Future<int> current() async {
    final saved = await _savedCurrent();
    final have = await all();
    if (have.any((c) => c.id == saved)) return saved;
    final first = have.first.id;
    await setCurrent(first);
    return first;
  }

  /// Saves [id] as the child playing now (AD-3).
  Future<void> setCurrent(int id) =>
      (db.update(db.appSettings)..where((s) => s.id.equals(1))).write(
        AppSettingsCompanion(currentChildId: Value(id)),
      );

  /// "Ask for PIN to change child" (AD-4).
  Future<bool> switchNeedsPin() async =>
      (await db.getSettings()).switchNeedsPin;

  Future<void> setSwitchNeedsPin(bool on) =>
      (db.update(db.appSettings)..where((s) => s.id.equals(1))).write(
        AppSettingsCompanion(switchNeedsPin: Value(on)),
      );
}
