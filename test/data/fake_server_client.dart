import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';

/// A [ServerClient] that answers from fields and records calls (FEAT-12/13).
class FakeServerClient implements ServerClient {
  FakeServerClient(
    this.config, {
    this.result = ServerHealth.ok,
    this.stored,
    this.google = false,
  });

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
    await _step('authMethods');
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
}
