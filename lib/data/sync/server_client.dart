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
}
