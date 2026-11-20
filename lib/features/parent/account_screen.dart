import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/pin_repository.dart';
import '../../data/sync/account_repository.dart';
import '../../data/sync/server_client.dart';
import '../../providers.dart';
import '../../ui/pin_pad.dart';
import '../../ui/theme.dart';
import 'account_forms.dart';
import 'weekly_email_section.dart';

/// SCR-13 sync error lines (SYN-07). An expired session signs out and shows
/// the FEAT-13 "Please sign in again." instead.
String syncErrorText(SyncError e) => switch (e) {
  SyncError.offline => 'Not synced: no internet. It will try again.',
  SyncError.server => 'The server had a problem. It will try again.',
  SyncError.rejected => "Some records weren't accepted by the server.",
  SyncError.expired => 'Please sign in again.',
  SyncError.unknown => 'Not synced. It will try again.',
};

/// "Last synced: today, 2:31 pm" (SYN-07).
String lastSyncText(DateTime? at, DateTime now) {
  if (at == null) return 'Not synced yet';
  final time = DateFormat('h:mm a').format(at).toLowerCase();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(at.year, at.month, at.day);
  final when = switch (today.difference(day).inDays) {
    0 => 'today',
    1 => 'yesterday',
    _ => DateFormat('d MMM').format(at),
  };
  return 'Last synced: $when, $time';
}

/// The SCR-13 sync section while signed in (SYN-07).
class SyncSection extends ConsumerWidget {
  const SyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(syncProvider);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.running
              ? 'Syncing…'
              : lastSyncText(s.lastSyncAt, ref.watch(clockProvider)()),
          key: const Key('account-last-sync'),
          style: const TextStyle(fontSize: AppText.body),
        ),
        if (s.lastError != null && !s.running)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.gap / 2),
            child: Text(
              syncErrorText(s.lastError!),
              key: const Key('account-sync-error'),
              style: TextStyle(fontSize: AppText.body, color: scheme.error),
            ),
          ),
        const SizedBox(height: AppSizes.gap / 2),
        OutlinedButton.icon(
          key: const Key('account-sync-now'),
          onPressed: s.running
              ? null
              : ref.read(syncProvider.notifier).requestSync,
          icon: const Icon(Icons.sync),
          label: const Text('Sync now'),
        ),
      ],
    );
  }
}

/// What's stored and where (NFR-14, ADR-07); always shown on SCR-13.
const privacyNote =
    "What's stored: your email, your child's nickname and school year, and "
    "your child's practice records (answers, times, stars, badges and "
    "settings). It's kept on our own server, used only by this app, with no "
    'ads, analytics or tracking. Deleting the account removes all of it from '
    'the server; this tablet keeps its copy. If crash reports are on, error '
    'details (app version, device model, the screen and the error) are sent '
    'with no names or account; turn them off in Settings. With the weekly '
    "email on, a summary of each child's practice is emailed to you each "
    'Monday.';

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
  bool _confirmingDelete = false;
  bool _pinBusy = false;
  String? _pinError;

  @override
  void initState() {
    super.initState();
    if (!ref.read(serverClientProvider).config.isConfigured) return;
    ref.read(accountProvider.notifier).refreshOnOpen();
  }

  AccountRepository get _repo => ref.read(accountProvider.notifier);

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
        const SyncSection(),
        const SizedBox(height: AppSizes.gap),
        WeeklyEmailSection(email: account.email),
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
      body = [const AccountForms()];
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
            // The PIN step starts at the top, so its message is in view
            // however far the list was scrolled (FEAT-24's longer note).
            // Signing in starts at the top too, so the account shows above
            // the longer signed-in page (FEAT-31).
            key: ValueKey((_confirmingDelete, state.signedIn)),
            padding: const EdgeInsets.all(AppSizes.gap),
            children: [
              ...body,
              if (configured &&
                  state.signedIn &&
                  message != null &&
                  !_confirmingDelete) ...[
                const SizedBox(height: AppSizes.gap),
                Text(
                  message,
                  key: const Key('account-message'),
                  style: text.bodyLarge?.copyWith(
                    color: state.error != null ? scheme.error : AppColors.leaf,
                  ),
                ),
              ],
              if (state.busy && state.signedIn) ...[
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
