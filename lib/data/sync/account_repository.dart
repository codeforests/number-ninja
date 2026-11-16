import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'server_client.dart';

/// Something SCR-13 tells the parent that isn't an error (FEAT-13).
enum AccountNotice {
  checkInbox,
  verifyFirst,
  verificationSent,
  resetSent,
  signInAgain,
  deleted,
}

/// The parent's account as SCR-13 sees it.
class AccountState {
  const AccountState({
    this.loaded = false,
    this.account,
    this.busy = false,
    this.error,
    this.notice,
  });

  /// False until the stored session has been read.
  final bool loaded;
  final Account? account;
  final bool busy;
  final AuthError? error;
  final AccountNotice? notice;

  bool get signedIn => account != null;
}

/// Client-side checks before any request (FEAT-13).
bool validEmail(String email) {
  final at = email.indexOf('@');
  return at > 0 && email.indexOf('.', at + 2) > at + 1 && !email.endsWith('.');
}

const minPasswordLength = 8;

/// Holds the account state over [ServerClient] (ACC-01..07). The stored
/// session loads at first read with no network call (NFR-11). FEAT-14
/// watches it to start and stop syncing.
class AccountRepository extends Notifier<AccountState> {
  AccountRepository(this._clientProvider);

  final Provider<ServerClient> _clientProvider;
  bool _refreshed = false;
  Future<void> _ready = Future.value();

  /// Completes once the stored session has been read.
  Future<void> get ready => _ready;

  ServerClient get _client => ref.read(_clientProvider);

  @override
  AccountState build() {
    final client = ref.watch(_clientProvider);
    _refreshed = false;
    _ready = client.loadSession().then(
      (account) {
        if (ref.mounted) state = AccountState(loaded: true, account: account);
      },
      onError: (Object _) {
        if (ref.mounted) state = const AccountState(loaded: true);
      },
    );
    return const AccountState();
  }

  Future<void> _run(
    Future<void> Function() body, {
    AccountNotice? onDone,
  }) async {
    await _ready;
    state = AccountState(loaded: true, account: state.account, busy: true);
    try {
      await body();
      state = AccountState(
        loaded: true,
        account: _client.currentAccount,
        notice: onDone,
      );
    } on AuthException catch (e) {
      state = AccountState(
        loaded: true,
        account: _client.currentAccount,
        error: e.error == AuthError.notVerified ? null : e.error,
        notice: e.error == AuthError.notVerified
            ? AccountNotice.verifyFirst
            : null,
      );
    }
  }

  void _check(String email, [String? password]) {
    if (!validEmail(email.trim())) {
      throw const AuthException(AuthError.badEmail);
    }
    if (password != null && password.length < minPasswordLength) {
      throw const AuthException(AuthError.weakPassword);
    }
  }

  Future<void> signUp(String email, String password) => _run(() async {
    _check(email, password);
    await _client.signUp(email.trim(), password);
  }, onDone: AccountNotice.checkInbox);

  Future<void> signIn(String email, String password) => _run(() async {
    _check(email);
    if (password.isEmpty) throw const AuthException(AuthError.wrongCredentials);
    await _client.signIn(email.trim(), password);
  });

  Future<void> signInWithGoogle(UrlLauncher launch) =>
      _run(() => _client.signInWithGoogle(launch));

  Future<void> resendVerification(String email) => _run(() async {
    _check(email);
    await _client.requestVerification(email.trim());
  }, onDone: AccountNotice.verificationSent);

  /// Always ends with the neutral "reset link on its way" unless offline.
  Future<void> forgotPassword(String email) => _run(() async {
    _check(email);
    try {
      await _client.requestPasswordReset(email.trim());
    } on AuthException catch (e) {
      if (e.error == AuthError.offline || e.error == AuthError.tooManyTries) {
        rethrow;
      }
    }
  }, onDone: AccountNotice.resetSent);

  /// Called when SCR-13 opens: renews the session once. Offline keeps it.
  Future<void> refreshOnOpen() async {
    await _ready;
    if (_refreshed || !ref.mounted || !state.signedIn) return;
    _refreshed = true;
    try {
      final account = await _client.refresh();
      if (ref.mounted) state = AccountState(loaded: true, account: account);
    } on AuthException catch (e) {
      if (e.error == AuthError.expired && ref.mounted) {
        state = const AccountState(
          loaded: true,
          notice: AccountNotice.signInAgain,
        );
      }
    }
  }

  Future<void> signOut() => _run(_client.signOut);

  /// The PIN is checked by SCR-13 before this is called (ACC-07).
  Future<void> deleteAccount() =>
      _run(_client.deleteAccount, onDone: AccountNotice.deleted);

  /// Whether to offer "Sign in with Google"; false offline or when the
  /// server has no Google secrets.
  Future<bool> googleOffered() async {
    try {
      return (await _client.authMethods()).google;
    } on AuthException {
      return false;
    }
  }

  void clearMessage() =>
      state = AccountState(loaded: state.loaded, account: state.account);
}
