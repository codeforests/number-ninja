import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/setup.dart';
import '../../providers.dart';
import '../../ui/pin_pad.dart';
import '../../ui/theme.dart';
import 'setup_controller.dart';
import 'setup_frame.dart';

/// Step 2 (SET-02, PAR-01): create the PIN, entered twice. Once it is set,
/// coming Back shows "PIN is set" with Change PIN, never a new PIN by
/// itself (AD-5).
class PinStep extends ConsumerStatefulWidget {
  const PinStep({super.key});

  @override
  ConsumerState<PinStep> createState() => _PinStepState();
}

class _PinStepState extends ConsumerState<PinStep> {
  bool? _pinSet;
  bool _changing = false;
  bool _busy = false;
  String? _first;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(pinRepositoryProvider).hasPin().then((set) {
      if (mounted) setState(() => _pinSet = set);
    });
  }

  Future<void> _onPin(String pin) async {
    if (_first == null) {
      setState(() {
        _first = pin;
        _error = null;
      });
      return;
    }
    if (pin != _first) {
      setState(() {
        _first = null;
        _error = "PINs don't match. Try again.";
      });
      return;
    }
    setState(() => _busy = true);
    final pins = ref.read(pinRepositoryProvider);
    await ref
        .read(setupControllerProvider.notifier)
        .next(write: () => pins.setPin(pin));
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(setupControllerProvider.notifier);
    final entering = _pinSet == false || _changing;
    final confirming = _first != null;
    final Widget body;
    if (_pinSet == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (entering) {
      body = Column(
        children: [
          Text(
            _error ??
                (confirming
                    ? 'Type the same 4 digits again to confirm.'
                    : 'Choose 4 digits your child does not know.'),
            key: const Key('setup-pin-message'),
            textAlign: TextAlign.center,
            style: setupBodyStyle.copyWith(
              color: _error != null ? AppColors.berry : null,
            ),
          ),
          const SizedBox(height: AppSizes.gap),
          PinPad(
            key: const Key('setup-pin-pad'),
            onCompleted: _onPin,
            enabled: !_busy,
          ),
        ],
      );
    } else {
      body = Column(
        children: [
          const Icon(Icons.check_circle, color: AppColors.leaf, size: 64),
          const SizedBox(height: AppSizes.gap / 2),
          const Text(
            'Your PIN is set.',
            key: Key('setup-pin-set'),
            style: setupBodyStyle,
          ),
          const SizedBox(height: AppSizes.gap),
          SizedBox(
            height: AppSizes.minTap,
            child: OutlinedButton(
              key: const Key('setup-change-pin'),
              onPressed: () => setState(() {
                _changing = true;
                _first = null;
                _error = null;
              }),
              child: const Text('Change PIN'),
            ),
          ),
        ],
      );
    }
    return SetupFrame(
      step: SetupStep.pin,
      icon: Icons.lock_outline,
      title: entering
          ? (confirming ? 'Enter the PIN again' : 'Create a parent PIN')
          : 'Parent PIN',
      subtitle:
          'The PIN opens the parent area: progress, settings and screen time.',
      onBack: _busy ? null : controller.back,
      onNext: entering || _pinSet == null ? null : () => controller.next(),
      body: body,
    );
  }
}
