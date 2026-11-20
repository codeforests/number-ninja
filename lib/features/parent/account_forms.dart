import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sync/account_repository.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
import 'account_screen.dart' show authErrorText, noticeText;

/// The signed-out SCR-13 forms: sign in, create an account, forgot
/// password and Google (FEAT-13), with their message line. Shared by
/// SCR-13 and the setup Account step (FEAT-26 AD-6); keys unchanged.
class AccountForms extends ConsumerStatefulWidget {
  const AccountForms({super.key});

  @override
  ConsumerState<AccountForms> createState() => _AccountFormsState();
}

class _AccountFormsState extends ConsumerState<AccountForms> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _google = false;

  @override
  void initState() {
    super.initState();
    if (!ref.read(serverClientProvider).config.isConfigured) return;
    ref.read(accountProvider.notifier).googleOffered().then((offered) {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountProvider);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final message = state.error != null
        ? authErrorText(state.error!)
        : state.notice != null
        ? noticeText(state.notice!)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
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
        if (message != null) ...[
          const SizedBox(height: AppSizes.gap),
          Text(
            message,
            key: const Key('account-message'),
            style: text.bodyLarge?.copyWith(
              color: state.error != null ? scheme.error : AppColors.leaf,
            ),
          ),
        ],
        if (state.notice == AccountNotice.verifyFirst) ...[
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
      ],
    );
  }
}
