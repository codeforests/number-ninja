import 'package:material_ui/material_ui.dart';

import 'layout.dart';
import 'theme.dart';

/// A big 4-digit keypad with dots. Calls [onCompleted] when 4 digits are in,
/// then clears itself.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.onCompleted,
    this.enabled = true,
    this.length = 4,
  });

  final ValueChanged<String> onCompleted;
  final bool enabled;
  final int length;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _digits = '';

  void _tap(String d) {
    if (!widget.enabled || _digits.length >= widget.length) return;
    setState(() => _digits += d);
    if (_digits.length == widget.length) {
      final pin = _digits;
      setState(() => _digits = '');
      widget.onCompleted(pin);
    }
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '<'],
    ];
    // On a phone the keys are smaller and closer, so the pad fits a
    // landscape phone's height (FEAT-19); keys stay at least 64 dp.
    final small = compact(MediaQuery.sizeOf(context));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          key: const Key('pin-dots'),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.length; i++)
              Container(
                margin: EdgeInsets.all(small ? 4 : 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _digits.length
                      ? AppColors.ninja
                      : AppColors.ninjaLight,
                ),
              ),
          ],
        ),
        SizedBox(height: small ? AppSizes.gap / 2 : AppSizes.gap),
        for (final row in keys)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final k in row) _key(k, small)],
          ),
      ],
    );
  }

  Widget _key(String k, bool small) {
    final size = small ? AppSizes.minTap : AppSizes.pinKey;
    final pad = small ? 4.0 : 8.0;
    if (k.isEmpty) return SizedBox(width: size + pad * 2, height: size);
    final isBack = k == '<';
    return Padding(
      padding: EdgeInsets.all(pad),
      child: SizedBox(
        width: size,
        height: size,
        child: FilledButton.tonal(
          key: Key(isBack ? 'pin-back' : 'pin-$k'),
          style: FilledButton.styleFrom(
            minimumSize: Size(size, size),
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
          ),
          onPressed: widget.enabled
              ? (isBack ? _backspace : () => _tap(k))
              : null,
          child: isBack
              ? const Icon(Icons.backspace_outlined, semanticLabel: 'Delete')
              : Text(k, style: const TextStyle(fontSize: AppText.heading)),
        ),
      ),
    );
  }
}
