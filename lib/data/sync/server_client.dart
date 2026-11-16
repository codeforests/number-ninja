import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

import 'server_config.dart';
import 'token_store.dart';

/// Result of a server check (FEAT-12, SCR-11 "Server" row).
enum ServerHealth { ok, unreachable, notConfigured }

/// Why an account call failed (FEAT-13). SCR-13 maps each to a message.
enum AuthError {
  offline,
  badEmail,
  wrongCredentials,
  emailTaken,
  weakPassword,
  notVerified,
  tooManyTries,
  expired,
  cancelled,
  notConfigured,
  unknown,
}

/// Thrown by the account calls of [ServerClient].
class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;

  @override
  String toString() => 'AuthException($error)';
}

/// Why a sync call failed (FEAT-14). SCR-13 maps each to a message.
enum SyncError { offline, expired, server, rejected, unknown }

/// Thrown by the record calls of [ServerClient].
class SyncException implements Exception {
  const SyncException(this.error, {this.status = 0, this.notUnique = false});
  final SyncError error;
  final int status;

  /// A create broke a unique index (the record is already there).
  final bool notUnique;

  @override
  String toString() => 'SyncException($error, $status)';
}

/// One record to send: a create when [id] is null, else an update.
class PushOp {
  const PushOp(this.collection, this.body, {this.id});
  final String collection;
  final Map<String, dynamic> body;
  final String? id;
}

/// One page of a pull: records as JSON maps (with `id` and `updated`).
class PullPage {
  const PullPage(this.items, this.totalPages);
  final List<Map<String, dynamic>> items;
  final int totalPages;
}

/// What the reset route returns (SYN-06).
class ResetResult {
  const ResetResult(this.epoch, this.resetAt);
  final int epoch;
  final String resetAt;
}

/// The signed-in parent (FEAT-13).
class Account {
  const Account({
    required this.id,
    required this.email,
    this.viaGoogle = false,
  });

  final String id;
  final String email;
  final bool viaGoogle;

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.id == id &&
      other.email == email &&
      other.viaGoogle == viaGoogle;

  @override
  int get hashCode => Object.hash(id, email, viaGoogle);
}

/// Which sign-in methods the server offers.
class AuthMethods {
  const AuthMethods({required this.google});
  final bool google;
}

/// Opens Google's sign-in page in a browser tab.
typedef UrlLauncher = Future<void> Function(Uri url);

/// The app's view of the sync server. Nothing calls it at start-up or on
/// child screens (NFR-11): only the parent area does. Account calls throw
/// [AuthException].
abstract class ServerClient {
  ServerConfig get config;
  Future<ServerHealth> health();

  /// The session kept on the tablet, loaded without any network call.
  Future<Account?> loadSession();

  /// The current session, after [loadSession].
  Account? get currentAccount;

  Future<AuthMethods> authMethods();

  /// Creates the account and sends the verification email. Doesn't sign in.
  Future<void> signUp(String email, String password);

  /// Signs in; an unverified account throws [AuthError.notVerified] and
  /// nothing is kept.
  Future<Account> signIn(String email, String password);
  Future<Account> signInWithGoogle(UrlLauncher launch);
  Future<void> requestVerification(String email);
  Future<void> requestPasswordReset(String email);

  /// Renews the token; [AuthError.expired] signs out.
  Future<Account> refresh();
  Future<void> signOut();

  /// Deletes the account on the server (cascades to her data), then signs out.
  Future<void> deleteAccount();

  // Record calls (FEAT-14). They throw [SyncException].

  /// The signed-in parent's `children` records, oldest first.
  Future<List<Map<String, dynamic>>> listChildren();

  /// Creates a child owned by the signed-in parent.
  Future<Map<String, dynamic>> createChild(Map<String, dynamic> body);
  Future<Map<String, dynamic>> updateChild(
    String id,
    Map<String, dynamic> body,
  );
  Future<ResetResult> resetChild(String id);

  /// Sends [ops] in one batch (all or nothing) and returns each record.
  Future<List<Map<String, dynamic>>> pushBatch(List<PushOp> ops);

  /// The first record of [collection] matching [filter] (PocketBase syntax,
  /// values bound from [params]), or null.
  Future<Map<String, dynamic>?> findOne(
    String collection,
    String filter,
    Map<String, dynamic> params,
  );

  /// Records of [childId] with `updated >= cursor` (all when [cursor] is
  /// empty), oldest change first, [perPage] per page, page from 1.
  Future<PullPage> pullPage(
    String collection,
    String childId,
    String cursor,
    int page, {
    int perPage = 500,
  });
}

/// [ServerClient] over the `pocketbase` package. The session is persisted
/// to [store] after each successful auth call and cleared on sign-out.
class PocketBaseServerClient implements ServerClient {
  PocketBaseServerClient(
    this.config, {
    TokenStore? store,
    this.timeout = const Duration(seconds: 10),
    this.googleTimeout = const Duration(minutes: 3),
    this.httpClientFactory,
  }) : _store = store ?? SecureTokenStore();

  @override
  final ServerConfig config;
  final Duration timeout;
  final Duration googleTimeout;
  final TokenStore _store;

  /// Tests pass a mock HTTP client.
  final http.Client Function()? httpClientFactory;
  bool _viaGoogle = false;
  bool _loaded = false;

  late final PocketBase _pb = PocketBase(
    config.url.toString(),
    httpClientFactory: httpClientFactory,
  );

  RecordService get _users => _pb.collection('users');

  @override
  Future<ServerHealth> health() async {
    if (!config.isConfigured) return ServerHealth.notConfigured;
    try {
      final result = await _pb.health.check().timeout(timeout);
      return result.code == 200 ? ServerHealth.ok : ServerHealth.unreachable;
    } on Object {
      return ServerHealth.unreachable;
    }
  }

  @override
  Account? get currentAccount {
    final record = _pb.authStore.record;
    if (!config.isConfigured || record == null || _pb.authStore.token.isEmpty) {
      return null;
    }
    return Account(
      id: record.id,
      email: record.getStringValue('email'),
      viaGoogle: _viaGoogle,
    );
  }

  @override
  Future<Account?> loadSession() async {
    if (!config.isConfigured) return null;
    if (!_loaded) {
      _loaded = true;
      try {
        final raw = await _store.read();
        if (raw != null && raw.isNotEmpty) {
          final data = jsonDecode(raw) as Map<String, dynamic>;
          _viaGoogle = data['google'] == true;
          _pb.authStore.save(
            data['token'] as String,
            RecordModel.fromJson(data['record'] as Map<String, dynamic>),
          );
        }
      } on Object {
        await _store.clear();
      }
    }
    return currentAccount;
  }

  Future<void> _persist(RecordAuth auth, {required bool google}) async {
    _viaGoogle = google;
    _pb.authStore.save(auth.token, auth.record);
    await _store.write(
      jsonEncode({
        'token': auth.token,
        'record': auth.record.toJson(),
        'google': google,
      }),
    );
  }

  Future<void> _forget() async {
    _pb.authStore.clear();
    _viaGoogle = false;
    await _store.clear();
  }

  void _requireConfig() {
    if (!config.isConfigured) {
      throw const AuthException(AuthError.notConfigured);
    }
  }

  Future<T> _call<T>(
    Future<T> Function() body, {
    bool passwordAuth = false,
    bool refresh = false,
    Duration? limit,
    AuthError onTimeout = AuthError.offline,
  }) async {
    _requireConfig();
    try {
      return await body().timeout(limit ?? timeout);
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw AuthException(onTimeout);
    } on ClientException catch (e) {
      throw AuthException(
        mapError(e, passwordAuth: passwordAuth, refresh: refresh),
      );
    } on Object {
      throw const AuthException(AuthError.unknown);
    }
  }

  /// Maps a PocketBase error to an [AuthError].
  static AuthError mapError(
    ClientException e, {
    bool passwordAuth = false,
    bool refresh = false,
  }) {
    final status = e.statusCode;
    if (status == 0) return e.isAbort ? AuthError.cancelled : AuthError.offline;
    if (status == 429) return AuthError.tooManyTries;
    if (refresh && (status == 401 || status == 403 || status == 404)) {
      return AuthError.expired;
    }
    final data = e.response['data'];
    if (data is Map) {
      String? code(String field) {
        final f = data[field];
        return f is Map ? f['code'] as String? : null;
      }

      if (code('email') == 'validation_not_unique') return AuthError.emailTaken;
      if (code('password') != null) return AuthError.weakPassword;
    }
    if (passwordAuth && status == 400) return AuthError.wrongCredentials;
    if (status == 401 || status == 403) return AuthError.expired;
    return AuthError.unknown;
  }

  @override
  Future<AuthMethods> authMethods() => _call(() async {
    final list = await _users.listAuthMethods();
    return AuthMethods(
      google:
          list.oauth2.enabled &&
          list.oauth2.providers.any((p) => p.name == 'google'),
    );
  });

  @override
  Future<void> signUp(String email, String password) => _call(() async {
    await _users.create(
      body: {'email': email, 'password': password, 'passwordConfirm': password},
    );
    await _users.requestVerification(email);
  });

  @override
  Future<Account> signIn(String email, String password) => _call(() async {
    final auth = await _users.authWithPassword(email, password);
    if (!auth.record.getBoolValue('verified')) {
      await _forget();
      throw const AuthException(AuthError.notVerified);
    }
    await _persist(auth, google: false);
    return currentAccount!;
  }, passwordAuth: true);

  @override
  Future<Account> signInWithGoogle(UrlLauncher launch) => _call(
    () async {
      final auth = await _users.authWithOAuth2('google', (url) {
        unawaited(launch(url));
      });
      await _persist(auth, google: true);
      return currentAccount!;
    },
    limit: googleTimeout,
    onTimeout: AuthError.cancelled,
  );

  @override
  Future<void> requestVerification(String email) =>
      _call(() => _users.requestVerification(email));

  @override
  Future<void> requestPasswordReset(String email) =>
      _call(() => _users.requestPasswordReset(email));

  @override
  Future<Account> refresh() async {
    await loadSession();
    if (currentAccount == null) throw const AuthException(AuthError.expired);
    try {
      return await _call(() async {
        final auth = await _users.authRefresh();
        await _persist(auth, google: _viaGoogle);
        return currentAccount!;
      }, refresh: true);
    } on AuthException catch (e) {
      if (e.error == AuthError.expired) await _forget();
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _forget();

  @override
  Future<void> deleteAccount() => _call(() async {
    final id = currentAccount?.id;
    if (id == null) throw const AuthException(AuthError.expired);
    await _users.delete(id);
    await _forget();
  });

  // Record calls (FEAT-14).

  Future<T> _sync<T>(Future<T> Function() body, {Duration? limit}) async {
    if (!config.isConfigured) throw const SyncException(SyncError.offline);
    try {
      return await body().timeout(limit ?? timeout);
    } on SyncException {
      rethrow;
    } on TimeoutException {
      throw const SyncException(SyncError.offline);
    } on ClientException catch (e) {
      throw syncError(e);
    } on Object {
      throw const SyncException(SyncError.unknown);
    }
  }

  /// Maps a PocketBase error to a [SyncException].
  static SyncException syncError(ClientException e) {
    final status = e.statusCode;
    if (status == 0) return const SyncException(SyncError.offline);
    if (status == 401) {
      return const SyncException(SyncError.expired, status: 401);
    }
    if (status >= 500 || status == 429) {
      return SyncException(SyncError.server, status: status);
    }
    if (status >= 400) {
      return SyncException(
        SyncError.rejected,
        status: status,
        notUnique: _hasNotUnique(e.response),
      );
    }
    return SyncException(SyncError.unknown, status: status);
  }

  static bool _hasNotUnique(Object? json) => switch (json) {
    {'code': 'validation_not_unique'} => true,
    final Map<dynamic, dynamic> m => m.values.any(_hasNotUnique),
    _ => false,
  };

  String get _ownerId {
    final id = currentAccount?.id;
    if (id == null) throw const SyncException(SyncError.expired);
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> listChildren() => _sync(() async {
    final list = await _pb
        .collection('children')
        .getFullList(
          filter: _pb.filter('owner = {:o}', {'o': _ownerId}),
          sort: 'created',
        );
    return [for (final r in list) r.toJson()];
  });

  @override
  Future<Map<String, dynamic>> createChild(Map<String, dynamic> body) =>
      _sync(() async {
        final r = await _pb
            .collection('children')
            .create(body: {...body, 'owner': _ownerId});
        return r.toJson();
      });

  @override
  Future<Map<String, dynamic>> updateChild(
    String id,
    Map<String, dynamic> body,
  ) => _sync(() async {
    final r = await _pb.collection('children').update(id, body: body);
    return r.toJson();
  });

  @override
  Future<ResetResult> resetChild(String id) => _sync(() async {
    final out = await _pb.send<Map<String, dynamic>>(
      '/api/nn/children/$id/reset',
      method: 'POST',
    );
    return ResetResult(
      (out['reset_epoch'] as num).toInt(),
      out['reset_at'] as String,
    );
  });

  @override
  Future<List<Map<String, dynamic>>> pushBatch(List<PushOp> ops) =>
      _sync(() async {
        if (ops.length == 1) {
          final op = ops.single;
          final c = _pb.collection(op.collection);
          final r = op.id == null
              ? await c.create(body: op.body)
              : await c.update(op.id!, body: op.body);
          return [r.toJson()];
        }
        final batch = _pb.createBatch();
        for (final op in ops) {
          final c = batch.collection(op.collection);
          if (op.id == null) {
            c.create(body: op.body);
          } else {
            c.update(op.id!, body: op.body);
          }
        }
        final results = await batch.send();
        return [
          for (final r in results)
            Map<String, dynamic>.from(r.body as Map<dynamic, dynamic>),
        ];
      }, limit: timeout * 3);

  @override
  Future<Map<String, dynamic>?> findOne(
    String collection,
    String filter,
    Map<String, dynamic> params,
  ) => _sync(() async {
    final page = await _pb
        .collection(collection)
        .getList(perPage: 1, filter: _pb.filter(filter, params));
    return page.items.isEmpty ? null : page.items.first.toJson();
  });

  @override
  Future<PullPage> pullPage(
    String collection,
    String childId,
    String cursor,
    int page, {
    int perPage = 500,
  }) => _sync(() async {
    final filter = cursor.isEmpty
        ? _pb.filter('child = {:c}', {'c': childId})
        : _pb.filter('child = {:c} && updated >= {:u}', {
            'c': childId,
            'u': cursor,
          });
    final list = await _pb
        .collection(collection)
        .getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: 'updated,id',
          skipTotal: false,
        );
    return PullPage([for (final r in list.items) r.toJson()], list.totalPages);
  }, limit: timeout * 3);
}
