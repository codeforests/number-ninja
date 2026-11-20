import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/pin_repository.dart';
import '../../domain/setup.dart';
import '../../providers.dart';
import '../../ui/pin_pad.dart';
import '../../ui/theme.dart';
import 'account_step.dart';
import 'children_step.dart';
import 'done_step.dart';
import 'pin_step.dart';
import 'setup_controller.dart';
import 'setup_frame.dart';
import 'time_step.dart';
import 'welcome_step.dart';

/// SCR-19: first-run setup (FEAT-26, SET-01..07), one route for every step.
/// Resuming once the PIN is set asks for it first (AD-4).
class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionProvider);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final step = ref.watch(setupControllerProvider);
        if (!session.setupUnlocked) return _ResumePin(step: step);
        return switch (step) {
          SetupStep.welcome => const WelcomeStep(),
          SetupStep.pin => const PinStep(),
          SetupStep.account => const AccountStep(),
          SetupStep.children => const ChildrenStep(),
          SetupStep.time => const TimeStep(),
          SetupStep.done => const DoneStep(),
        };
      },
    );
  }
}

/// "Welcome back" PIN check before resuming (AD-4), with the PAR-03 lockout.
class _ResumePin extends ConsumerStatefulWidget {
  const _ResumePin({required this.step});

  final SetupStep step;

  @override
  ConsumerState<_ResumePin> createState() => _ResumePinState();
}

class _ResumePinState extends ConsumerState<_ResumePin> {
  String? _error;
  DateTime? _lockedUntil;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    ref.read(pinRepositoryProvider).lockedUntil().then((until) {
      if (mounted && until != null) _lock(until);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _lock(DateTime until) {
    setState(() => _lockedUntil = until);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = ref.read(clockProvider)();
      setState(() {
        if (!now.isBefore(_lockedUntil!)) {
          _lockedUntil = null;
          _error = null;
          _ticker?.cancel();
        }
      });
    });
  }

  Future<void> _onPin(String pin) async {
    final result = await ref.read(pinRepositoryProvider).verify(pin);
    if (!mounted) return;
    switch (result) {
      case PinOk():
        ref.read(appSessionProvider).unlockSetup();
      case PinWrong(:final attemptsLeft):
        setState(
          () => _error =
              'Wrong PIN. $attemptsLeft ${attemptsLeft == 1 ? 'try' : 'tries'} left.',
        );
      case PinLocked(:final until):
        _lock(until);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _lockedUntil != null;
    var message = _error;
    if (locked) {
      final now = ref.read(clockProvider)();
      final secs = (_lockedUntil!.difference(now).inMilliseconds / 1000)
          .ceil()
          .clamp(0, 999);
      message = 'Too many tries. Try again in $secs s.';
    }
    return SetupFrame(
      step: widget.step,
      icon: Icons.lock_outline,
      title: 'Welcome back',
      subtitle: 'Enter your PIN to finish setting up.',
      showActions: false,
      body: Column(
        children: [
          SizedBox(
            height: AppText.setupBody * 2.6,
            child: message == null
                ? null
                : Text(
                    message,
                    key: const Key('setup-resume-message'),
                    textAlign: TextAlign.center,
                    style: setupBodyStyle.copyWith(color: AppColors.berry),
                  ),
          ),
          PinPad(
            key: const Key('setup-resume-pin'),
            onCompleted: _onPin,
            enabled: !locked,
          ),
        ],
      ),
    );
  }
}
