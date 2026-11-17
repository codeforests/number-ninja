import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show AssetBundle;

import '../domain/question.dart';
import 'database.dart';
import 'question_bank_loader.dart';
import 'sync/server_client.dart';

enum BankSource { bundled, downloaded }

/// The bank in use and where it came from (SCR-11, BNK-12).
class ActiveBank {
  const ActiveBank(this.bank, this.source);
  final QuestionBank bank;
  final BankSource source;
}

/// Last bank check, for SCR-11 (BNK-12).
class BankCheckState {
  const BankCheckState({this.checkedAt, this.note});
  final DateTime? checkedAt;
  final String? note;
}

/// Downloaded banks on the device (FEAT-15 D7, D8): files under [dir],
/// one `bank_files` row each. The bundled bank is the fallback (BNK-09).
class BankStore {
  BankStore(this._db, {required this.bundle, required this.dir});

  final AppDatabase _db;
  final AssetBundle bundle;

  /// The banks directory (created when needed).
  final Future<Directory> Function() dir;

  QuestionBank? _bundled;

  Future<QuestionBank> bundled() async => _bundled ??= await loadBank(bundle);

  /// The highest version among the bundled bank and each downloaded file
  /// that exists, matches its sha256 and parses. A file that fails, or is
  /// not newer than the bundled bank, is deleted with its row.
  Future<ActiveBank> loadActive() async {
    final base = await bundled();
    final rows = await (_db.select(
      _db.bankFiles,
    )..orderBy([(t) => OrderingTerm.desc(t.version)])).get();
    ActiveBank? best;
    final d = await dir();
    for (final row in rows) {
      final bank = best == null && row.version > base.version
          ? await _read(File('${d.path}/${row.path}'), row)
          : null;
      if (bank != null) {
        best = ActiveBank(bank, BankSource.downloaded);
      } else if (best == null) {
        await _forget(row, d);
      }
    }
    return best ?? ActiveBank(base, BankSource.bundled);
  }

  Future<QuestionBank?> _read(File f, BankFileRow row) async {
    try {
      if (!f.existsSync()) return null;
      final bytes = await f.readAsBytes();
      if (sha256.convert(bytes).toString() != row.sha256) return null;
      final bank = QuestionBank.fromJson(
        jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
      );
      if (bank.version != row.version || bank.format > bankFormatSupported) {
        return null;
      }
      return bank;
    } on Object {
      return null;
    }
  }

  Future<void> _forget(BankFileRow row, Directory d) async {
    await (_db.delete(
      _db.bankFiles,
    )..where((t) => t.version.equals(row.version))).go();
    final f = File('${d.path}/${row.path}');
    if (f.existsSync()) await f.delete();
  }

  /// Keeps a checked download (BNK-08) and deletes older ones.
  Future<void> save(BankInfo info, List<int> bytes, DateTime now) async {
    final d = await dir();
    if (!d.existsSync()) await d.create(recursive: true);
    final name = 'bank_v${info.version}.json';
    final tmp = File('${d.path}/$name.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename('${d.path}/$name');
    await _db
        .into(_db.bankFiles)
        .insertOnConflictUpdate(
          BankFilesCompanion.insert(
            version: Value(info.version),
            format: info.format,
            sha256: info.sha256,
            path: name,
            downloadedAt: now,
          ),
        );
    final older = await (_db.select(
      _db.bankFiles,
    )..where((t) => t.version.isSmallerThanValue(info.version))).get();
    for (final row in older) {
      await _forget(row, d);
    }
  }

  Future<BankCheckState> checkState() async {
    final s = await _db.select(_db.appSettings).getSingle();
    return BankCheckState(checkedAt: s.bankCheckedAt, note: s.bankCheckNote);
  }

  /// Records a check attempt; [checkedAt] only when it succeeded.
  Future<void> recordCheck(String note, {DateTime? checkedAt}) => _db
      .update(_db.appSettings)
      .write(
        AppSettingsCompanion(
          bankCheckNote: Value(note),
          bankCheckedAt: checkedAt == null
              ? const Value.absent()
              : Value(checkedAt),
        ),
      );
}
