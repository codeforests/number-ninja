import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/pin_repository.dart';
import '../../providers.dart';
import '../../ui/pin_pad.dart';
import '../../ui/screen_frame.dart';
import '../../ui/theme.dart';

/// Added to the reset warning while signed in (SYN-06).
const otherTabletsNote = 'Her other tablets clear at their next sync.';

/// SCR-11, Reset all progress (PAR-10): the PIN confirms it. A wrong PIN
/// deletes nothing and counts towards the PAR-03 lockout.
class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key});

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  String? _error;
  bool _busy = false;

  Future<void> _onPin(String pin) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(pinRepositoryProvider).verify(pin);
    if (!mounted) return;
    switch (result) {
      case PinOk():
        final stats = await ref.read(statsRepositoryProvider.future);
        await stats.resetProgress();
        ref.read(roundRepositoryProvider).forgetSession();
        if (ref.read(syncAccountProvider) != null) {
          // The server and her other tablets clear at the next sync (SYN-06).
          await ref.read(syncServiceProvider).markPendingReset();
          ref.read(syncProvider.notifier).requestSync();
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Progress reset')));
        context.go(Routes.parent);
      case PinWrong(:final attemptsLeft):
        setState(() {
          _busy = false;
          _error = 'Wrong PIN. $attemptsLeft tries left.';
        });
      case PinLocked():
        ref.read(appSessionProvider).lockParent();
        context.go(Routes.pinEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final signedIn = ref.watch(syncAccountProvider) != null;
    return ScreenFrame(
      title: 'Reset all progress',
      message: _error ?? 'Enter the PIN to reset.',
      messageIsError: _error != null,
      leading: IconButton(
        key: const Key('back-parent'),
        iconSize: 40,
        tooltip: 'Cancel',
        onPressed: () => context.go(Routes.parent),
        icon: const Icon(Icons.arrow_back),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.minTap * 8),
            child: Text(
              'This deletes every answer, round, star and badge. '
              'The PIN, the daily limit and today’s screen time stay.'
              '${signedIn ? ' $otherTabletsNote' : ''}',
              key: const Key('reset-warning'),
              textAlign: TextAlign.center,
              style: theme.bodyLarge?.copyWith(color: AppColors.berry),
            ),
          ),
          const SizedBox(height: AppSizes.gap),
          PinPad(onCompleted: _onPin, enabled: !_busy),
        ],
      ),
    );
  }
}
