import 'package:material_ui/material_ui.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          key: const Key('pin-dots'),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.length; i++)
              Container(
                margin: const EdgeInsets.all(8),
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
        const SizedBox(height: AppSizes.gap),
        for (final row in keys)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final k in row) _key(k)],
          ),
      ],
    );
  }

  Widget _key(String k) {
    const size = AppSizes.pinKey;
    if (k.isEmpty) return const SizedBox(width: size + 16, height: size + 16);
    final isBack = k == '<';
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: size,
        height: size,
        child: FilledButton.tonal(
          key: Key(isBack ? 'pin-back' : 'pin-$k'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(size, size),
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
