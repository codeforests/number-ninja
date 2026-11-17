import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../domain/bank_validator.dart';
import '../domain/clock.dart';
import '../domain/question.dart';
import 'bank_store.dart';
import 'sync/server_client.dart';

enum BankCheck { skipped, upToDate, downloaded, failed }

/// Checks the server for a newer bank and keeps it (FEAT-15 D9, BNK-08,
/// BNK-11). Any failure keeps the current bank.
class BankUpdater {
  BankUpdater({required this.client, required this.store, required this.clock});

  final ServerClient client;
  final BankStore store;
  final Clock clock;

  /// Checks at most this often unless forced.
  static const interval = Duration(hours: 24);

  Future<BankCheck>? _running;

  bool get running => _running != null;

  /// One check at a time: a second call while one runs gets its result.
  Future<BankCheck> check({bool force = false}) =>
      _running ??= _check(force).whenComplete(() => _running = null);

  Future<BankCheck> _check(bool force) async {
    if (!client.config.isConfigured) return BankCheck.skipped;
    final last = (await store.checkState()).checkedAt;
    final now = clock();
    if (!force && last != null && now.difference(last) < interval) {
      return BankCheck.skipped;
    }
    String? why;
    try {
      final current = (await store.loadActive()).bank;
      final info = await client.latestBank(maxFormat: bankFormatSupported);
      if (info == null || info.version <= current.version) {
        await store.recordCheck('up to date', checkedAt: now);
        return BankCheck.upToDate;
      }
      final bytes = await client.downloadBank(info);
      why = _problem(bytes, info, current);
      if (why == null) {
        await store.save(info, bytes, now);
        await store.recordCheck(
          'downloaded version ${info.version}',
          checkedAt: now,
        );
        return BankCheck.downloaded;
      }
    } on SyncException catch (e) {
      why = e.error == SyncError.offline ? 'offline' : 'server error';
    } on Object {
      why = 'failed';
    }
    await store.recordCheck(why);
    return BankCheck.failed;
  }

  /// Why the downloaded [bytes] can't replace [current], or null.
  static String? _problem(
    List<int> bytes,
    BankInfo info,
    QuestionBank current,
  ) {
    if (sha256.convert(bytes).toString() != info.sha256) {
      return 'rejected: checksum';
    }
    final QuestionBank bank;
    try {
      bank = QuestionBank.fromJson(
        jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
      );
    } on Object {
      return 'rejected: does not parse';
    }
    if (bank.version != info.version || bank.format > bankFormatSupported) {
      return 'rejected: version or format';
    }
    final problems = validateBank(bank);
    if (problems.isNotEmpty) return 'rejected: ${problems.length} problems';
    if (missingIds(current, bank).isNotEmpty) return 'rejected: drops ids';
    return null;
  }
}
