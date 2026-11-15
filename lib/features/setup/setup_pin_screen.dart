import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../providers.dart';
import '../../ui/pin_pad.dart';
import '../../ui/screen_frame.dart';

/// SCR-01: first-run PIN setup (PAR-01).
class SetupPinScreen extends ConsumerStatefulWidget {
  const SetupPinScreen({super.key});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  String? _first;
  String? _error;

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
    await ref.read(pinRepositoryProvider).setPin(pin);
    final session = ref.read(appSessionProvider)..pinCreated();
    if (mounted) {
      context.go(session.profilePending ? Routes.setupProfile : Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirming = _first != null;
    return ScreenFrame(
      title: confirming ? 'Enter the PIN again' : 'Parents: create a PIN',
      message:
          _error ??
          (confirming
              ? 'Type the same 4 digits to confirm.'
              : 'Only you will know it. It opens the parent area.'),
      messageIsError: _error != null,
      child: PinPad(onCompleted: _onPin),
    );
  }
}
