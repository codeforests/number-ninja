import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:number_ninja/domain/question.dart';

import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';

/// A [ServerClient] that answers from fields and records calls (FEAT-12/13).
class FakeServerClient implements ServerClient {
  FakeServerClient(
    this.config, {
    this.result = ServerHealth.ok,
    this.stored,
    this.google = false,
    FakeSyncServer? server,
  }) : server = server ?? FakeSyncServer();

  /// The records "on the server"; two clients can share one (FEAT-14).
  final FakeSyncServer server;

  @override
  final ServerConfig config;
  ServerHealth result;
  int calls = 0;

  /// The session "on the tablet".
  Account? stored;
  bool google;

  /// Next account call throws this, then it's cleared.
  AuthError? fail;

  /// Every account call, by name, e.g. `signIn:a@b.co`.
  final log = <String>[];

  /// Accounts that exist but aren't verified.
  final unverified = <String>{};

  @override
  Future<ServerHealth> health() async {
    calls++;
    return config.isConfigured ? result : ServerHealth.notConfigured;
  }

  @override
  Account? get currentAccount => config.isConfigured ? stored : null;

  @override
  Future<Account?> loadSession() async => currentAccount;

  Future<void> _step(String name) async {
    log.add(name);
    if (!config.isConfigured) {
      throw const AuthException(AuthError.notConfigured);
    }
    final error = fail;
    if (error != null) {
      fail = null;
      throw AuthException(error);
    }
  }

  @override
  Future<AuthMethods> authMethods() async {
    // Doesn't use [fail]: SCR-13 asks for it on open, before other calls.
    log.add('authMethods');
    if (!config.isConfigured) {
      throw const AuthException(AuthError.notConfigured);
    }
    return AuthMethods(google: google);
  }

  @override
  Future<void> signUp(String email, String password) async {
    await _step('signUp:$email');
    unverified.add(email);
  }

  @override
  Future<Account> signIn(String email, String password) async {
    await _step('signIn:$email');
    if (unverified.contains(email)) {
      throw const AuthException(AuthError.notVerified);
    }
    return stored = Account(id: 'u1', email: email);
  }

  @override
  Future<Account> signInWithGoogle(UrlLauncher launch) async {
    await _step('google');
    await launch(Uri.parse('https://accounts.google.com/o/oauth2/auth'));
    return stored = const Account(
      id: 'u2',
      email: 'parent@gmail.com',
      viaGoogle: true,
    );
  }

  @override
  Future<void> requestVerification(String email) =>
      _step('requestVerification:$email');

  @override
  Future<void> requestPasswordReset(String email) =>
      _step('requestPasswordReset:$email');

  @override
  Future<Account> refresh() async {
    try {
      await _step('refresh');
    } on AuthException catch (e) {
      if (e.error == AuthError.expired) stored = null;
      rethrow;
    }
    return stored!;
  }

  @override
  Future<void> signOut() async {
    log.add('signOut');
    stored = null;
  }

  @override
  Future<void> deleteAccount() async {
    await _step('delete');
    stored = null;
  }

  // Record calls (FEAT-14), answered by [server] for the stored account.

  /// Next record call throws this, then it's cleared.
  SyncException? syncFail;

  /// Every record call waits this long first (AC-4).
  Duration? delay;

  /// Runs before each batch reaches the server (a round finished mid-push).
  Future<void> Function(List<PushOp> ops)? beforeBatch;

  /// Record calls, by name, e.g. `pushBatch:rounds:100`.
  final syncLog = <String>[];

  Future<String> _owner(String name) async {
    syncLog.add(name);
    if (delay != null) await Future<void>.delayed(delay!);
    final e = syncFail;
    if (e != null) {
      syncFail = null;
      throw e;
    }
    final id = currentAccount?.id;
    if (id == null) throw const SyncException(SyncError.expired);
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> listChildren() async {
    final o = await _owner('listChildren');
    return [
      for (final c in server.of('children'))
        if (c['owner'] == o) server.copy(c),
    ];
  }

  @override
  Future<Map<String, dynamic>> createChild(Map<String, dynamic> body) async {
    final o = await _owner('createChild');
    return server.create('children', {...body, 'owner': o});
  }

  @override
  Future<Map<String, dynamic>> updateChild(
    String id,
    Map<String, dynamic> body,
  ) async {
    await _owner('updateChild');
    return server.update('children', id, body);
  }

  @override
  Future<ResetResult> resetChild(String id) async {
    final o = await _owner('resetChild');
    return server.reset(id, o);
  }

  @override
  Future<List<Map<String, dynamic>>> pushBatch(List<PushOp> ops) async {
    await _owner(
      'pushBatch:${ops.isEmpty ? '' : ops.first.collection}:${ops.length}',
    );
    await beforeBatch?.call(ops);
    return server.batch(ops);
  }

  @override
  Future<Map<String, dynamic>?> findOne(
    String collection,
    String filter,
    Map<String, dynamic> params,
  ) async {
    await _owner('findOne:$collection');
    for (final r in server.of(collection)) {
      if (params.entries.every((e) {
        final field = switch (e.key) {
          'u' => 'uuid',
          'c' => 'child',
          'b' => 'badge_id',
          'd' => 'day',
          'v' => 'device_id',
          _ => e.key,
        };
        return r[field] == e.value;
      })) {
        return server.copy(r);
      }
    }
    return null;
  }

  @override
  Future<PullPage> pullPage(
    String collection,
    String childId,
    String cursor,
    int page, {
    int perPage = 500,
  }) async {
    await _owner('pullPage:$collection:$page');
    final all = [
      for (final r in server.of(collection))
        if (r['child'] == childId &&
            (cursor.isEmpty || (r['updated'] as String).compareTo(cursor) >= 0))
          r,
    ]..sort((a, b) => (a['updated'] as String).compareTo(b['updated']));
    final start = (page - 1) * perPage;
    final items = [
      for (final r in all.skip(start).take(perPage)) server.copy(r),
    ];
    return PullPage(items, (all.length / perPage).ceil());
  }

  // Question bank (FEAT-15).

  /// Published banks "on the server": info and file bytes.
  final banks = <(BankInfo, List<int>)>[];

  /// Bank calls, e.g. `latestBank:1`, `downloadBank:2`.
  final bankLog = <String>[];

  /// Next bank call throws this, then it's cleared.
  SyncException? bankFail;

  void _bankCall(String name) {
    bankLog.add(name);
    final e = bankFail;
    if (e != null) {
      bankFail = null;
      throw e;
    }
  }

  /// Publishes [bank] as [text] (default: its JSON); [sha256] overrides the
  /// checksum (a damaged upload).
  void publishBank(QuestionBank bank, {String? text, String? sha256}) {
    final bytes = utf8.encode(text ?? jsonEncode(bank.toJson()));
    banks.add((
      BankInfo(
        version: bank.version,
        format: bank.format,
        sha256: sha256 ?? crypto.sha256.convert(bytes).toString(),
        fileUrl: Uri.parse('https://fake/banks/${bank.version}.json'),
      ),
      bytes,
    ));
  }

  @override
  Future<BankInfo?> latestBank({required int maxFormat}) async {
    _bankCall('latestBank:$maxFormat');
    final ok = [
      for (final (i, _) in banks)
        if (i.format <= maxFormat) i,
    ]..sort((a, b) => b.version.compareTo(a.version));
    return ok.isEmpty ? null : ok.first;
  }

  @override
  Future<List<int>> downloadBank(BankInfo info) async {
    _bankCall('downloadBank:${info.version}');
    return banks.firstWhere((b) => b.$1.version == info.version).$2;
  }
}

class FakeSyncServer {
  final _records = <String, List<Map<String, dynamic>>>{};
  var _ids = 0;

  /// Server time at the next write ([updated], `reset_at`); moves 1 ms per
  /// write. Tests may move it forward.
  DateTime time = DateTime.utc(2027, 1, 5);

  /// Every record body sent (creates and updates), as JSON text.
  final sent = <String>[];

  /// Records created or updated, by collection.
  final writes = <String, int>{};

  List<Map<String, dynamic>> of(String collection) =>
      _records.putIfAbsent(collection, () => []);

  Map<String, dynamic> copy(Map<String, dynamic> r) =>
      jsonDecode(jsonEncode(r)) as Map<String, dynamic>;

  String _now() {
    time = time.add(const Duration(milliseconds: 1));
    return time.toIso8601String().replaceFirst('T', ' ');
  }

  static const _unique = {
    'rounds': ['uuid'],
    'attempts': ['uuid'],
    'badges': ['child', 'badge_id'],
    'daily_usage': ['child', 'day', 'device_id'],
  };

  void _checkUnique(String collection, Map<String, dynamic> r) {
    final keys = _unique[collection];
    if (keys == null) return;
    for (final o in of(collection)) {
      if (o['id'] != r['id'] && keys.every((k) => o[k] == r[k])) {
        throw const SyncException(
          SyncError.rejected,
          status: 400,
          notUnique: true,
        );
      }
    }
  }

  Map<String, dynamic> create(String collection, Map<String, dynamic> body) {
    sent.add(jsonEncode(body));
    final now = _now();
    final r = {
      ...copy(body),
      'id': 'r${_ids++}',
      'created': now,
      'updated': now,
    };
    _checkUnique(collection, r);
    of(collection).add(r);
    writes[collection] = (writes[collection] ?? 0) + 1;
    return copy(r);
  }

  Map<String, dynamic> update(
    String collection,
    String id,
    Map<String, dynamic> body,
  ) {
    sent.add(jsonEncode(body));
    final list = of(collection);
    final i = list.indexWhere((r) => r['id'] == id);
    if (i < 0) throw const SyncException(SyncError.rejected, status: 404);
    if (collection == 'attempts') {
      throw const SyncException(SyncError.rejected, status: 403);
    }
    final r = {...list[i], ...copy(body), 'updated': _now()};
    _checkUnique(collection, r);
    list[i] = r;
    writes[collection] = (writes[collection] ?? 0) + 1;
    return copy(r);
  }

  List<Map<String, dynamic>> batch(List<PushOp> ops) {
    final saved = {
      for (final e in _records.entries) e.key: [...e.value],
    };
    final savedWrites = {...writes};
    try {
      return [
        for (final op in ops)
          op.id == null
              ? create(op.collection, op.body)
              : update(op.collection, op.id!, op.body),
      ];
    } on SyncException {
      if (ops.length == 1) rethrow; // a single op is sent as a plain request
      _records
        ..clear()
        ..addAll(saved);
      writes
        ..clear()
        ..addAll(savedWrites);
      throw const SyncException(SyncError.rejected, status: 400);
    }
  }

  ResetResult reset(String childId, String owner) {
    final c = of('children').firstWhere((c) => c['id'] == childId);
    if (c['owner'] != owner) {
      throw const SyncException(SyncError.rejected, status: 403);
    }
    for (final name in ['rounds', 'attempts', 'badges']) {
      of(name).removeWhere((r) => r['child'] == childId);
    }
    final now = _now();
    c['reset_epoch'] = ((c['reset_epoch'] as num?) ?? 0).toInt() + 1;
    c['reset_at'] = now;
    c['updated'] = now;
    return ResetResult(c['reset_epoch'] as int, now);
  }
}
