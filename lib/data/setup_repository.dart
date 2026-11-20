import 'package:drift/drift.dart';

import '../domain/setup.dart';
import 'database.dart';

/// The saved first-run setup step (FEAT-26 AD-1, AD-3).
class SetupRepository {
  SetupRepository(this._db);

  final AppDatabase _db;

  /// The step to resume at, or null when setup is finished.
  Future<SetupStep?> step() async =>
      parseStep((await _db.getSettings()).setupStep);

  /// Saves [to] as the current step, in one transaction with [write] (the
  /// step's own data), so a kill never leaves one without the other (AD-3).
  Future<void> advance(SetupStep to, {Future<void> Function()? write}) =>
      _db.transaction(() async {
        if (write != null) await write();
        await _save(to.name);
      });

  /// Setup is done: launch goes the usual way from now on (AD-11).
  Future<void> finish() => _save(null);

  Future<void> _save(String? name) =>
      (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
        AppSettingsCompanion(setupStep: Value(name)),
      );
}
