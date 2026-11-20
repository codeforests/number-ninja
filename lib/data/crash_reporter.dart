import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/clock.dart';
import '../domain/crash.dart';
import 'crash_repository.dart';
import 'database.dart';
import 'sync/server_client.dart';

/// What the reporter reads from the app when it saves an error: the names
/// and email to scrub (AD-7) and the bank in use.
class CrashContext {
  const CrashContext({this.names = const [], this.email, this.bankVersion = 0});

  final List<String> names;
  final String? email;
  final int bankVersion;
}

/// Zone key marking the reporter's own saving and sending.
const _ownWork = #crashReporterOwnWork;

/// Errors held in memory before [CrashReporter.attach] (AD-11).
const crashBufferMax = 20;

/// Catches Dart errors, saves them scrubbed and grouped, and sends them
/// (FEAT-24, CRS-01..05). One per app, made in `main()`.
class CrashReporter {
  CrashReporter({required this.clock, CrashInfo? info})
    : info = info ?? const CrashInfo(appVersion: 'unknown', os: '', device: '');

  final Clock clock;

  /// Set once the device channel answers (AD-5).
  CrashInfo info;

  /// The route pattern on screen now (AD-6); `app.dart` keeps it current.
  String screen = '';

  CrashRepository? _repo;
  Future<CrashContext> Function()? _context;
  final _buffer = <CrashEntry>[];
  Future<void> _saving = Future.value();
  bool _capturing = false;
  bool _sending = false;

  /// Wraps `FlutterError.onError` (still calling the handler that was there,
  /// `FlutterError.presentError` by default) and `PlatformDispatcher.onError`
  /// (AD-11). Returns a function that puts both back (tests).
  VoidCallback install() {
    final flutterBefore = FlutterError.onError;
    final platformBefore = PlatformDispatcher.instance.onError;
    FlutterError.onError = (details) {
      capture(details.exception, details.stack);
      (flutterBefore ?? FlutterError.presentError)(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      capture(error, stack);
      platformBefore?.call(error, stack);
      return true;
    };
    return () {
      FlutterError.onError = flutterBefore;
      PlatformDispatcher.instance.onError = platformBefore;
    };
  }

  /// Gives the reporter its database and app context, and saves what was
  /// buffered before.
  Future<void> attach({
    required CrashRepository repo,
    required Future<CrashContext> Function() context,
  }) {
    _repo = repo;
    _context = context;
    // A fresh chain in this zone: a future from the zone the reporter was
    // made in would run saves outside it (widget tests' fake async).
    _saving = Future.value();
    final early = List.of(_buffer);
    _buffer.clear();
    for (final e in early) {
      _queue(e);
    }
    return _saving;
  }

  /// Records one error. Never throws; an error while capturing is dropped
  /// (AD-11).
  void capture(Object error, StackTrace? stack) {
    // Re-entry from the reporter's own work (AD-11).
    if (_capturing || Zone.current[_ownWork] == true) return;
    _capturing = true;
    try {
      final entry = CrashEntry(
        type: error.runtimeType.toString(),
        message: error.toString(),
        stack: (stack ?? StackTrace.empty).toString(),
        screen: screen,
        at: clock(),
      );
      if (_repo == null) {
        if (_buffer.length < crashBufferMax) _buffer.add(entry);
      } else {
        _queue(entry);
      }
    } on Object {
      // Dropped: the reporter must never report itself.
    } finally {
      _capturing = false;
    }
  }

  /// Completes when every captured error is saved (tests).
  Future<void> get settled => _saving;

  void _queue(CrashEntry entry) {
    _saving = _saving.then(
      (_) => runZoned(() => _save(entry), zoneValues: {_ownWork: true}),
    );
  }

  Future<void> _save(CrashEntry entry) async {
    try {
      final repo = _repo!;
      if (!await repo.enabled()) return;
      final ctx = await _context!();
      String scrub(String s) => scrubText(s, ctx.names, ctx.email);
      await repo.record(
        CrashEntry(
          type: entry.type,
          message: scrub(entry.message),
          stack: scrub(entry.stack),
          screen: entry.screen,
          at: entry.at,
        ),
        info,
        ctx.bankVersion,
      );
    } on Object {
      // Dropped (AD-11).
    }
  }

  /// Sends up to [crashSendBatch] unsent rows anonymously (AD-4, AD-9) and
  /// purges old sent ones. Errors are swallowed; the next launch retries.
  Future<void> sendPending(ServerClient client) async {
    final repo = _repo;
    if (repo == null || _sending || !client.config.isConfigured) return;
    _sending = true;
    try {
      await runZoned(() => _send(repo, client), zoneValues: {_ownWork: true});
    } finally {
      _sending = false;
    }
  }

  Future<void> _send(CrashRepository repo, ServerClient client) async {
    try {
      await _saving;
      if (!await repo.enabled()) return;
      final sent = <int>[];
      for (final CrashReport row in await repo.pending()) {
        try {
          await client.sendCrashReport(crashBody(row));
        } on Object {
          break;
        }
        sent.add(row.id);
      }
      if (sent.isNotEmpty) await repo.markSent(sent, clock());
      await repo.purge(clock());
    } on Object {
      // Next launch retries.
    }
  }
}
