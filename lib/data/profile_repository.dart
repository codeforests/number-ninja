import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/profile.dart';
import 'database.dart';

/// Reads and saves one child's profile (PRO-01, PRO-02): a view of her
/// `children` row (FEAT-25). An empty nickname means not filled in yet.
class ProfileRepository {
  ProfileRepository(this.db, {required this.clock, this.childId = 1});

  final AppDatabase db;
  final Clock clock;
  final int childId;

  SimpleSelectStatement<$ChildrenTable, ChildRow> get _row =>
      db.select(db.children)..where((c) => c.id.equals(childId));

  Future<ChildProfile?> load() async => profileOf(await _row.getSingleOrNull());

  Stream<ChildProfile?> watch() => _row.watchSingleOrNull().map(profileOf);

  /// Whether the app must ask for the profile before play.
  Future<bool> pending() async => (await db.getSettings()).profilePending;

  /// Stores [p] (nickname trimmed) and clears the pending flag.
  /// Stamps the fields that changed for sync (FEAT-14).
  Future<void> save(ChildProfile p) => db.transaction(() async {
    final before = await load();
    final now = clock();
    await db.stampFields(childId, [
      if (before?.nickname != p.nickname.trim()) syncFieldNickname,
      if (before?.schoolYear != p.schoolYear) syncFieldSchoolYear,
      if (before == null || before.schoolStartLevel != p.schoolStartLevel)
        syncFieldStartSchool,
      if (before == null || before.olympiadStartLevel != p.olympiadStartLevel)
        syncFieldStartOlympiad,
      if (before?.avatar != p.avatar) syncFieldAvatar,
    ], now);
    await (db.update(db.children)..where((c) => c.id.equals(childId))).write(
      ChildrenCompanion(
        nickname: Value(p.nickname.trim()),
        schoolYear: Value(p.schoolYear),
        schoolStartLevel: Value(p.schoolStartLevel),
        olympiadStartLevel: Value(p.olympiadStartLevel),
        avatar: Value(p.avatar),
        updatedAt: Value(now),
      ),
    );
    await (db.update(db.appSettings)..where((s) => s.id.equals(1))).write(
      const AppSettingsCompanion(profilePending: Value(false)),
    );
  });
}

/// [row]'s profile, or null while its nickname is empty (FEAT-25 AD-2).
ChildProfile? profileOf(ChildRow? row) => row == null || row.nickname.isEmpty
    ? null
    : ChildProfile(
        nickname: row.nickname,
        schoolYear: row.schoolYear,
        schoolStartLevel: row.schoolStartLevel,
        olympiadStartLevel: row.olympiadStartLevel,
        avatar: row.avatar,
      );
