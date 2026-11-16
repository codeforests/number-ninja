import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/pin_repository.dart';
import '../../data/sync/account_repository.dart';
import '../../data/sync/server_client.dart';
import '../../providers.dart';
import '../../ui/pin_pad.dart';
import '../../ui/theme.dart';

/// What's stored and where (NFR-14, ADR-07); always shown on SCR-13.
const privacyNote =
    "What's stored: your email, her nickname and school year, and her "
    'practice records (answers, times, stars, badges and settings). '
    "It's kept on our own server, used only by this app, with no ads, "
    'analytics or tracking. Deleting the account removes all of it from '
    'the server; this tablet keeps its copy.';

String authErrorText(AuthError e) => switch (e) {
  AuthError.offline =>
    "Can't reach the server. Check the internet and try again.",
  AuthError.badEmail => 'Enter a valid email address.',
  AuthError.wrongCredentials => 'Email or password is wrong.',
  AuthError.emailTaken => 'That email already has an account. Sign in instead.',
  AuthError.weakPassword => 'Use at least 8 characters.',
  AuthError.notVerified => 'Please verify your email first.',
  AuthError.tooManyTries => 'Too many tries. Wait a minute and try again.',
  AuthError.expired => 'Please sign in again.',
  AuthError.cancelled => "Google sign-in didn't finish.",
  AuthError.notConfigured => "Accounts aren't set up in this build.",
  AuthError.unknown => 'Something went wrong. Try again.',
};

String noticeText(AccountNotice n) => switch (n) {
  AccountNotice.checkInbox =>
    'Check your inbox and tap the link, then sign in.',
  AccountNotice.verifyFirst => 'Please verify your email first.',
  AccountNotice.verificationSent =>
    'Sent. Check your inbox and tap the link, then sign in.',
  AccountNotice.resetSent =>
    'If that email has an account, a reset link is on its way.',
  AccountNotice.signInAgain => 'Please sign in again.',
  AccountNotice.deleted =>
    'The account is deleted. Progress on this tablet stays.',
};

/// SCR-13, the parent's account (FEAT-13, ACC-01..07), inside the PIN
/// area (ACC-04). Nothing here reaches child screens.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _google = false;
  bool _confirmingDelete = false;
  bool _pinBusy = false;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    if (!ref.read(serverClientProvider).config.isConfigured) return;
    final repo = ref.read(accountProvider.notifier);
    repo.refreshOnOpen();
    repo.googleOffered().then((offered) {
      if (mounted) setState(() => _google = offered);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  AccountRepository get _repo => ref.read(accountProvider.notifier);

  Future<void> _signIn() async {
    final password = _password.text;
    _password.clear();
    await _repo.signIn(_email.text, password);
  }

  Future<void> _create() async {
    final password = _password.text;
    await _repo.signUp(_email.text, password);
    if (ref.read(accountProvider).error == null) _password.clear();
  }

  Future<void> _signInWithGoogle() async {
    final browser = ref.read(signInBrowserProvider);
    await _repo.signInWithGoogle(browser.open);
    await browser.close();
  }

  Future<void> _askDelete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete the account?'),
        content: const Text(
          'This removes her progress from the server. '
          'Progress on this tablet stays.',
        ),
        actions: [
          TextButton(
            key: const Key('account-delete-cancel'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('account-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      _repo.clearMessage();
      setState(() {
        _confirmingDelete = true;
        _pinError = null;
      });
    }
  }

  Future<void> _onDeletePin(String pin) async {
    if (_pinBusy) return;
    setState(() => _pinBusy = true);
    final result = await ref.read(pinRepositoryProvider).verify(pin);
    if (!mounted) return;
    switch (result) {
      case PinOk():
        await _repo.deleteAccount();
        if (!mounted) return;
        setState(() {
          _pinBusy = false;
          _confirmingDelete = false;
        });
      case PinWrong(:final attemptsLeft):
        setState(() {
          _pinBusy = false;
          _pinError = 'Wrong PIN. $attemptsLeft tries left.';
        });
      case PinLocked():
        ref.read(appSessionProvider).lockParent();
        context.go(Routes.pinEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configured = ref.watch(serverClientProvider).config.isConfigured;
    final state = ref.watch(accountProvider);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final message = state.error != null
        ? authErrorText(state.error!)
        : state.notice != null
        ? noticeText(state.notice!)
        : null;

    final List<Widget> body;
    if (!configured) {
      body = [
        Text(
          authErrorText(AuthError.notConfigured),
          key: const Key('account-message'),
          style: text.bodyLarge,
        ),
      ];
    } else if (!state.loaded) {
      body = [const Center(child: CircularProgressIndicator())];
    } else if (_confirmingDelete) {
      body = [
        Text(
          _pinError ?? 'Enter the PIN to delete the account.',
          key: const Key('account-pin-message'),
          textAlign: TextAlign.center,
          style: text.bodyLarge?.copyWith(
            color: _pinError != null ? scheme.error : null,
          ),
        ),
        const SizedBox(height: AppSizes.gap),
        Center(
          child: PinPad(onCompleted: _onDeletePin, enabled: !_pinBusy),
        ),
        const SizedBox(height: AppSizes.gap),
        Center(
          child: TextButton(
            key: const Key('account-delete-back'),
            onPressed: () => setState(() => _confirmingDelete = false),
            child: const Text('Cancel'),
          ),
        ),
      ];
    } else if (state.signedIn) {
      final account = state.account!;
      body = [
        ListTile(
          key: const Key('account-signed-in'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.account_circle),
          title: Text(account.email, key: const Key('account-email-shown')),
          subtitle: Text(
            account.viaGoogle ? 'Signed in with Google' : 'Signed in',
          ),
        ),
        const SizedBox(height: AppSizes.gap),
        Wrap(
          spacing: AppSizes.gap,
          runSpacing: AppSizes.gap,
          children: [
            OutlinedButton(
              key: const Key('account-signout'),
              onPressed: state.busy ? null : _repo.signOut,
              child: const Text('Sign out'),
            ),
            OutlinedButton(
              key: const Key('account-delete'),
              style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
              onPressed: state.busy ? null : _askDelete,
              child: const Text('Delete account'),
            ),
          ],
        ),
      ];
    } else {
      body = [
        TextField(
          key: const Key('account-email'),
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: AppSizes.gap),
        TextField(
          key: const Key('account-password'),
          controller: _password,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(
            labelText: 'Password (at least 8 characters)',
          ),
        ),
        const SizedBox(height: AppSizes.gap),
        Wrap(
          spacing: AppSizes.gap,
          runSpacing: AppSizes.gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton(
              key: const Key('account-signin'),
              onPressed: state.busy ? null : _signIn,
              child: const Text('Sign in'),
            ),
            OutlinedButton(
              key: const Key('account-create'),
              onPressed: state.busy ? null : _create,
              child: const Text('Create account'),
            ),
            TextButton(
              key: const Key('account-forgot'),
              onPressed: state.busy
                  ? null
                  : () => _repo.forgotPassword(_email.text),
              child: const Text('Forgot password?'),
            ),
          ],
        ),
        if (_google) ...[
          const SizedBox(height: AppSizes.gap),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              key: const Key('account-google'),
              onPressed: state.busy ? null : _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            ),
          ),
        ],
      ];
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-parent'),
          tooltip: 'Back',
          onPressed: () => context.go(Routes.parent),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Account'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.minTap * 10),
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.gap),
            children: [
              ...body,
              if (configured && message != null && !_confirmingDelete) ...[
                const SizedBox(height: AppSizes.gap),
                Text(
                  message,
                  key: const Key('account-message'),
                  style: text.bodyLarge?.copyWith(
                    color: state.error != null ? scheme.error : AppColors.leaf,
                  ),
                ),
              ],
              if (configured &&
                  !state.signedIn &&
                  state.notice == AccountNotice.verifyFirst) ...[
                const SizedBox(height: AppSizes.gap),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton(
                    key: const Key('account-resend'),
                    onPressed: state.busy
                        ? null
                        : () => _repo.resendVerification(_email.text),
                    child: const Text('Send the email again'),
                  ),
                ),
              ],
              if (state.busy) ...[
                const SizedBox(height: AppSizes.gap),
                const LinearProgressIndicator(),
              ],
              const Divider(height: AppSizes.gap * 3),
              Text(
                privacyNote,
                key: const Key('account-privacy'),
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
