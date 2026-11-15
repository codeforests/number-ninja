import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/profile.dart';
import 'database.dart';

/// Reads and saves the child profile (PRO-01, PRO-02).
class ProfileRepository {
  ProfileRepository(this.db, {required this.clock});

  final AppDatabase db;
  final Clock clock;

  Future<ChildProfile?> load() async => _toProfile(
    await (db.select(
      db.childProfiles,
    )..where((p) => p.id.equals(1))).getSingleOrNull(),
  );

  Stream<ChildProfile?> watch() =>
      (db.select(db.childProfiles)..where((p) => p.id.equals(1)))
          .watchSingleOrNull()
          .map(_toProfile);

  /// Whether the app must ask for the profile before play.
  Future<bool> pending() async => (await db.getSettings()).profilePending;

  /// Stores [p] (nickname trimmed) and clears the pending flag.
  Future<void> save(ChildProfile p) => db.transaction(() async {
    await db
        .into(db.childProfiles)
        .insertOnConflictUpdate(
          ChildProfilesCompanion.insert(
            id: const Value(1),
            nickname: p.nickname.trim(),
            schoolYear: p.schoolYear,
            schoolStartLevel: Value(p.schoolStartLevel),
            olympiadStartLevel: Value(p.olympiadStartLevel),
            updatedAt: clock(),
          ),
        );
    await (db.update(db.appSettings)..where((s) => s.id.equals(1))).write(
      const AppSettingsCompanion(profilePending: Value(false)),
    );
  });

  ChildProfile? _toProfile(ProfileRow? row) => row == null
      ? null
      : ChildProfile(
          nickname: row.nickname,
          schoolYear: row.schoolYear,
          schoolStartLevel: row.schoolStartLevel,
          olympiadStartLevel: row.olympiadStartLevel,
        );
}
