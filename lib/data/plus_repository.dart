import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/clock.dart';
import '../domain/plus.dart';
import 'database.dart';
import 'sync/account_repository.dart';
import 'sync/server_client.dart';
import 'sync/sync_controller.dart';

/// The cached row, or null (also read by `main.dart` before the app runs).
Future<PlusCache?> readPlusCache(AppDatabase db) async {
  final r = await (db.select(
    db.plusState,
  )..where((t) => t.id.equals(1))).getSingleOrNull();

  if (r == null) return null;
  return PlusCache(
    plus: r.plus,
    until: r.until?.toUtc(),
    source: r.source,
    status: r.status,
    willRenew: r.willRenew,
    endedAt: r.endedAt?.toUtc(),
    serverCheckedAt: r.serverCheckedAt.toUtc(),
    deviceCheckedAt: r.deviceCheckedAt,
    accountId: r.accountId,
  );
}

/// What a [PlusRepository.refresh] did (FEAT-30 PD-5).
enum PlusRefresh { updated, kept, cleared }

/// The cached Plus answer in `plus_state` (FEAT-30 PD-3, PD-5).
class PlusRepository {
  PlusRepository(this._db, {required this.client, required this.clock});

  final AppDatabase _db;
  final ServerClient client;
  final Clock clock;

  Future<PlusCache?> cached() => readPlusCache(_db);

  /// Asks the server for [accountId]'s Plus. Another account's cache is
  /// cleared first; offline or a server error keeps the cache (the grace
  /// runs on); a 401 clears it.
  Future<PlusRefresh> refresh(String accountId) async {
    final old = await cached();
    if (old != null && old.accountId != accountId) await clear();
    final Entitlement e;
    try {
      e = await client.entitlement();
    } on SyncException catch (x) {
      if (x.error == SyncError.expired || x.status == 401) {
        await clear();
        return PlusRefresh.cleared;
      }
      return PlusRefresh.kept;
    }
    await _store(accountId, e);
    return PlusRefresh.updated;
  }

  /// Caches [e] for [accountId] as [refresh] would, e.g. the answer of a
  /// redeemed invitation code (FEAT-36 IC-11).
  Future<void> storeEntitlement(String accountId, Entitlement e) async {
    final old = await cached();
    if (old != null && old.accountId != accountId) await clear();
    await _store(accountId, e);
  }

  Future<void> _store(String accountId, Entitlement e) => _db
      .into(_db.plusState)
      .insertOnConflictUpdate(
        PlusStateCompanion.insert(
          id: const Value(1),
          plus: e.plus,
          until: Value(e.until),
          source: Value(e.source),
          status: Value(e.status),
          willRenew: Value(e.willRenew),
          endedAt: Value(e.endedAt),
          serverCheckedAt: e.checkedAt,
          deviceCheckedAt: clock(),
          accountId: accountId,
        ),
      );

  Future<void> clear() => _db.delete(_db.plusState).go();
}

/// Keeps the Plus cache in step with the account and sync (PD-5): clears it
/// when signed out (or the account is deleted), refreshes it when signed in
/// (launch and sign-in) and after each successful sync run. `app.dart`
/// keeps it alive.
class PlusController extends Notifier<int> {
  PlusController({
    required this.repository,
    required this.account,
    required this.sync,
    required this.onChanged,
  });

  final Provider<PlusRepository> repository;
  final NotifierProvider<AccountRepository, AccountState> account;
  final NotifierProvider<SyncController, SyncStatus> sync;

  /// Called after the cache changed (invalidates the cache provider).
  final void Function(Ref ref) onChanged;

  Future<void> _work = Future.value();

  /// Completes when the queued refresh or clear is done (tests).
  Future<void> get idle => _work;

  @override
  int build() {
    ref.listen(account, (_, s) => _onAccount(s), fireImmediately: true);
    ref.listen(sync, (before, now) {
      final ok = now.lastError == null && !now.running;
      if (ok && now.lastSyncAt != before?.lastSyncAt) check();
    });
    return 0;
  }

  void _onAccount(AccountState s) {
    if (!s.loaded || s.busy) return;
    final id = s.account?.id;
    if (id == _last) return;
    _last = id;
    if (id == null) {
      _queue(() => ref.read(repository).clear());
    } else {
      check();
    }
  }

  String? _last;

  /// Refreshes now when signed in ("Check again" on SCR-20).
  Future<void> check() {
    final id = ref.read(account).account?.id;
    if (id == null) return _work;
    return _queue(() => ref.read(repository).refresh(id));
  }

  Future<void> _queue(Future<Object?> Function() body) {
    _work = _work.then((_) async {
      try {
        await body();
      } on Object {
        // A failed write leaves the cache as it was.
      }
      if (ref.mounted) {
        onChanged(ref);
        state++;
      }
    });
    return _work;
  }
}
