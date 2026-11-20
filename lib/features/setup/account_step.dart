import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sync/account_repository.dart';
import '../../data/sync/server_client.dart';
import '../../domain/setup.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
import '../parent/account_forms.dart';
import '../parent/account_screen.dart' show authErrorText;
import '../parent/children_screen.dart' show familyChanged;
import 'children_step.dart' show namedChildren;
import 'setup_controller.dart';
import 'setup_frame.dart';

/// How long the Account step waits for the family to come back (AD-7).
const restoreWait = Duration(seconds: 30);

/// Step 3 (SET-03, SET-04, AD-6, AD-7): sign in to bring the family back,
/// create an account, or skip. Only the parent is here: the PIN is set
/// (ACC-04).
class AccountStep extends ConsumerStatefulWidget {
  const AccountStep({super.key});

  @override
  ConsumerState<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends ConsumerState<AccountStep> {
  bool _restoring = false;

  Future<void> _restore() async {
    setState(() => _restoring = true);
    ref.read(syncProvider);
    await ref
        .read(syncProvider.notifier)
        .syncOnce()
        .timeout(restoreWait, onTimeout: () => null)
        .catchError((Object _) => null);
    if (!mounted) return;
    await familyChanged(ref);
    final restored = (await namedChildren(ref)).isNotEmpty;
    if (!mounted) return;
    await ref.read(setupControllerProvider.notifier).next(restored: restored);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(accountProvider.select((s) => s.signedIn), (was, now) {
      if (was == false && now && !_restoring) unawaited(_restore());
    });
    final controller = ref.read(setupControllerProvider.notifier);
    final configured = ref.watch(serverClientProvider).config.isConfigured;
    final state = ref.watch(accountProvider);
    final created = state.notice == AccountNotice.checkInbox;
    final Widget body;
    if (_restoring) {
      body = const Column(
        key: Key('setup-restoring'),
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSizes.gap),
          Text(
            'Bringing back your family…',
            textAlign: TextAlign.center,
            style: setupBodyStyle,
          ),
        ],
      );
    } else if (!configured) {
      body = Text(
        authErrorText(AuthError.notConfigured),
        key: const Key('account-message'),
        style: setupBodyStyle,
      );
    } else if (state.signedIn) {
      body = Text(
        'Signed in as ${state.account!.email}.',
        key: const Key('setup-signed-in'),
        style: setupBodyStyle,
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (created)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSizes.gap),
              child: Text(
                'Check your email to finish creating your account. '
                'Carry on setting up meanwhile.',
                key: Key('setup-check-email'),
                style: setupBodyStyle,
              ),
            ),
          const AccountForms(),
        ],
      );
    }
    final skip = !state.signedIn && !created;
    return SetupFrame(
      step: SetupStep.account,
      icon: Icons.cloud_sync_outlined,
      title: 'Sign in (optional)',
      subtitle:
          'Already use BrainBubblz on another tablet? Sign in to bring your '
          'family back. An account also keeps progress safe if this tablet '
          'is lost.',
      showActions: !_restoring,
      onBack: state.busy ? null : controller.back,
      nextKey: Key(skip ? 'setup-skip-account' : 'setup-next'),
      nextLabel: skip
          ? 'Skip for now (you can do this later in the parent area)'
          : 'Next',
      onNext: state.busy ? null : () => controller.next(),
      body: body,
    );
  }
}
