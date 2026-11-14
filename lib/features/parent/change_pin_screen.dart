import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/pin_repository.dart';
import '../../providers.dart';
import '../../ui/pin_pad.dart';
import '../../ui/screen_frame.dart';

enum _Step { current, next, confirm }

/// SCR-11, Change PIN (PAR-04): current PIN, then the new one twice.
class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  _Step _step = _Step.current;
  String? _next;
  String? _error;

  Future<void> _onPin(String pin) async {
    final repo = ref.read(pinRepositoryProvider);
    switch (_step) {
      case _Step.current:
        final result = await repo.verify(pin);
        if (!mounted) return;
        setState(() {
          switch (result) {
            case PinOk():
              _step = _Step.next;
              _error = null;
            case PinWrong(:final attemptsLeft):
              _error = 'Wrong PIN. $attemptsLeft tries left.';
            case PinLocked():
              ref.read(appSessionProvider).lockParent();
              context.go(Routes.pinEntry);
          }
        });
      case _Step.next:
        setState(() {
          _next = pin;
          _step = _Step.confirm;
          _error = null;
        });
      case _Step.confirm:
        if (pin != _next) {
          setState(() {
            _step = _Step.next;
            _next = null;
            _error = "PINs don't match. Try again.";
          });
          return;
        }
        await repo.setPin(pin);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('PIN changed')));
        context.go(Routes.parent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, hint) = switch (_step) {
      _Step.current => ('Current PIN', 'Enter your current PIN.'),
      _Step.next => ('New PIN', 'Choose 4 new digits.'),
      _Step.confirm => ('Confirm new PIN', 'Enter the new PIN again.'),
    };
    return ScreenFrame(
      title: title,
      message: _error ?? hint,
      messageIsError: _error != null,
      leading: IconButton(
        key: const Key('back-parent'),
        iconSize: 40,
        tooltip: 'Back',
        onPressed: () => context.go(Routes.parent),
        icon: const Icon(Icons.arrow_back),
      ),
      child: PinPad(key: ValueKey(_step), onCompleted: _onPin),
    );
  }
}
