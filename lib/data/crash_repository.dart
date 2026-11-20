import 'package:drift/drift.dart';

import '../domain/crash.dart';
import 'database.dart';

/// Crash rows on the device (FEAT-24 AD-3, AD-8, AD-9).
class CrashRepository {
  CrashRepository(this._db);

  final AppDatabase _db;

  /// Whether the parent left "Send crash reports" on (AD-2).
  Future<bool> enabled() async => (await _db.getSettings()).crashReports;

  /// Turning it off also deletes the unsent rows (AD-9).
  Future<void> setEnabled(bool on) => _db.transaction(() async {
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
      AppSettingsCompanion(crashReports: Value(on)),
    );
    if (!on) {
      await (_db.delete(
        _db.crashReports,
      )..where((r) => r.sentAt.isNull())).go();
    }
  });

  /// Saves [entry] (already scrubbed), grouping it with an unsent row of the
  /// same signature and app version (AD-8), and keeps at most
  /// [crashMaxUnsent] unsent rows (oldest dropped).
  Future<void> record(CrashEntry entry, CrashInfo info, int bankVersion) =>
      _db.transaction(() async {
        final type = trimText(entry.type);
        final stack = trimStack(entry.stack);
        final signature = crashSignature(type, stack);
        final appVersion = trimText(info.appVersion);
        final same =
            await (_db.select(_db.crashReports)
                  ..where(
                    (r) =>
                        r.sentAt.isNull() &
                        r.signature.equals(signature) &
                        r.appVersion.equals(appVersion),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (same != null) {
          await (_db.update(
            _db.crashReports,
          )..where((r) => r.id.equals(same.id))).write(
            CrashReportsCompanion(
              count: Value(same.count + 1),
              lastAt: Value(entry.at),
            ),
          );
          return;
        }
        await _db
            .into(_db.crashReports)
            .insert(
              CrashReportsCompanion.insert(
                signature: signature,
                appVersion: appVersion,
                bankVersion: bankVersion,
                os: trimText(info.os),
                device: trimText(info.device),
                screen: trimText(entry.screen),
                errorType: type,
                message: trimMessage(entry.message),
                stack: stack,
                firstAt: entry.at,
                lastAt: entry.at,
              ),
            );
        final unsent =
            await (_db.select(_db.crashReports)
                  ..where((r) => r.sentAt.isNull())
                  ..orderBy([
                    (r) => OrderingTerm.desc(r.lastAt),
                    (r) => OrderingTerm.desc(r.id),
                  ]))
                .get();
        if (unsent.length > crashMaxUnsent) {
          final drop = unsent.skip(crashMaxUnsent).map((r) => r.id).toList();
          await (_db.delete(
            _db.crashReports,
          )..where((r) => r.id.isIn(drop))).go();
        }
      });

  /// Up to [limit] unsent rows, oldest first.
  Future<List<CrashReport>> pending([int limit = crashSendBatch]) =>
      (_db.select(_db.crashReports)
            ..where((r) => r.sentAt.isNull())
            ..orderBy([(r) => OrderingTerm.asc(r.id)])
            ..limit(limit))
          .get();

  Future<void> markSent(List<int> ids, DateTime at) =>
      (_db.update(_db.crashReports)..where((r) => r.id.isIn(ids))).write(
        CrashReportsCompanion(sentAt: Value(at)),
      );

  /// Deletes rows sent more than [crashKeepSent] before [now].
  Future<void> purge(DateTime now) =>
      (_db.delete(_db.crashReports)..where(
            (r) => r.sentAt.isSmallerThanValue(now.subtract(crashKeepSent)),
          ))
          .go();

  Future<List<CrashReport>> all() => _db.select(_db.crashReports).get();
}

/// The body posted for [row] (AD-4): no account, child or device id.
Map<String, dynamic> crashBody(CrashReport row) => {
  'signature': row.signature,
  'app_version': row.appVersion,
  'bank_version': row.bankVersion,
  'os': row.os,
  'device': row.device,
  'screen': row.screen,
  'error_type': row.errorType,
  'message': row.message,
  'stack': row.stack,
  'count': row.count,
  'first_at': row.firstAt.toUtc().toIso8601String(),
  'last_at': row.lastAt.toUtc().toIso8601String(),
};
