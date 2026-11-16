import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'server_client.dart';
import 'sync_service.dart';

/// What SCR-13 shows about sync (SYN-07).
class SyncStatus {
  const SyncStatus({
    this.active = false,
    this.running = false,
    this.lastSyncAt,
    this.lastError,
  });

  /// Signed in with a server set: syncing runs.
  final bool active;
  final bool running;
  final DateTime? lastSyncAt;
  final SyncError? lastError;

  SyncStatus copyWith({
    bool? running,
    DateTime? lastSyncAt,
    SyncError? Function()? lastError,
  }) => SyncStatus(
    active: active,
    running: running ?? this.running,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    lastError: lastError == null ? this.lastError : lastError(),
  );
}

/// Timers for [SyncController]; tests pass fakes they fire by hand (NFR-08).
abstract class SyncTimers {
  Timer once(Duration after, void Function() run);
  Timer every(Duration period, void Function() run);
}

class RealSyncTimers implements SyncTimers {
  const RealSyncTimers();

  @override
  Timer once(Duration after, void Function() run) => Timer(after, run);

  @override
  Timer every(Duration period, void Function() run) =>
      Timer.periodic(period, (_) => run());
}

/// Counts sync runs that changed local data; screens' providers watch it
/// and reload (FEAT-14). A round in progress keeps its own state.
class SyncDataVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Delays after a failed run: 30 s, 1, 2, 4, 8, then 15 min (SYN-05).
const syncBackoff = [
  Duration(seconds: 30),
  Duration(minutes: 1),
  Duration(minutes: 2),
  Duration(minutes: 4),
  Duration(minutes: 8),
  Duration(minutes: 15),
];
const syncEvery = Duration(minutes: 5);

/// Runs [SyncService] while the parent is signed in (SYN-05): at start, on
/// [requestSync] (resume, a finished round, "Sync now") and every 5 minutes;
/// failures retry with [syncBackoff]. Runs are serial: a request during a
/// run makes one more run afterwards. Nothing here blocks the UI (SYN-01).
class SyncController extends Notifier<SyncStatus> {
  SyncController({
    required this.account,
    required this.service,
    required this.timers,
    required this.dataVersion,
    required this.onExpired,
  });

  /// The signed-in account id while syncing is possible (server set), or
  /// null.
  final Provider<String?> account;
  final Provider<SyncService> service;
  final Provider<SyncTimers> timers;
  final NotifierProvider<SyncDataVersion, int> dataVersion;

  /// Signs out with "Please sign in again." (FEAT-13).
  final void Function(Ref ref) onExpired;

  Timer? _periodic;
  Timer? _retry;
  int _failures = 0;
  bool _running = false;
  bool _again = false;
  Future<void> _idle = Future.value();

  /// Completes when the current run (and any queued one) is done.
  Future<void> get idle => _idle;

  @override
  SyncStatus build() {
    final id = ref.watch(account);
    _stop();
    ref.onDispose(_stop);
    if (id == null) return const SyncStatus();
    final t = ref.read(timers);
    _periodic = t.every(syncEvery, requestSync);
    unawaited(_loadSaved());
    scheduleMicrotask(requestSync);
    return const SyncStatus(active: true);
  }

  void _stop() {
    _periodic?.cancel();
    _retry?.cancel();
    _periodic = null;
    _retry = null;
    _failures = 0;
    _again = false;
  }

  Future<void> _loadSaved() async {
    final s = await ref.read(service).savedStatus();
    if (!ref.mounted || !state.active) return;
    state = state.copyWith(
      lastSyncAt: s.lastSyncAt,
      lastError: () => state.lastError ?? s.lastError,
    );
  }

  /// Starts a run now, or one more after the current run.
  void requestSync() {
    if (!ref.mounted || !state.active) return;
    if (_running) {
      _again = true;
      return;
    }
    _idle = _loop();
  }

  Future<void> _loop() async {
    _running = true;
    do {
      _again = false;
      await _runOnce();
    } while (_again && ref.mounted && state.active);
    _running = false;
  }

  Future<void> _runOnce() async {
    _retry?.cancel();
    state = state.copyWith(running: true);
    final svc = ref.read(service);
    try {
      final out = await svc.run();
      if (!ref.mounted) return;
      _failures = 0;
      final error = out.rejected > 0 ? SyncError.rejected : null;
      if (error != null) await svc.recordError(error);
      if (!ref.mounted) return;
      state = state.copyWith(
        running: false,
        lastSyncAt: (await svc.savedStatus()).lastSyncAt,
        lastError: () => error,
      );
      if (out.changed) ref.read(dataVersion.notifier).bump();
    } on SyncException catch (e) {
      if (!ref.mounted) return;
      await svc.recordError(e.error);
      if (!ref.mounted) return;
      state = state.copyWith(running: false, lastError: () => e.error);
      if (e.error == SyncError.expired) {
        _again = false;
        onExpired(ref);
        return;
      }
      final delay = syncBackoff[_failures.clamp(0, syncBackoff.length - 1)];
      _failures++;
      _retry = ref.read(timers).once(delay, requestSync);
    }
  }
}
