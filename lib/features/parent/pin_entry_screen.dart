import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/pin_repository.dart';
import '../../providers.dart';
import '../../ui/pin_pad.dart';
import '../../ui/screen_frame.dart';

/// SCR-08: PIN entry with lockout (PAR-02, PAR-03). With [forChildChange]
/// the right PIN opens SCR-17 instead of the parent area (FEAT-25 AD-4).
class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key, this.forChildChange = false});

  final bool forChildChange;

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
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
      case PinOk() when widget.forChildChange:
        ref.read(appSessionProvider).chooseChild();
        context.go(Routes.who);
      case PinOk():
        ref.read(appSessionProvider).unlockParent();
        context.go(Routes.parent);
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
    String? message = _error;
    if (locked) {
      final now = ref.read(clockProvider)();
      final secs = (_lockedUntil!.difference(now).inMilliseconds / 1000)
          .ceil()
          .clamp(0, 999);
      message = 'Too many tries. Try again in $secs s.';
    }
    return ScreenFrame(
      title: 'Parent PIN',
      message: message ?? 'Enter your 4-digit PIN.',
      messageIsError: message != null,
      leading: IconButton(
        key: const Key('back-home'),
        iconSize: 40,
        tooltip: 'Back',
        onPressed: () => context.go(Routes.home),
        icon: const Icon(Icons.arrow_back),
      ),
      child: PinPad(onCompleted: _onPin, enabled: !locked),
    );
  }
}
