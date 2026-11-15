import 'package:material_ui/material_ui.dart';

import '../../../ui/theme.dart';

/// A display, an on-screen keypad (0–9, `.`, backspace) and Check (PRC-03).
/// No system keyboard.
class NumberAnswer extends StatefulWidget {
  const NumberAnswer({super.key, required this.onSubmit});

  static const maxLength = 6;

  final ValueChanged<String> onSubmit;

  @override
  State<NumberAnswer> createState() => _NumberAnswerState();
}

class _NumberAnswerState extends State<NumberAnswer> {
  String _text = '';

  void _type(String c) {
    if (_text.length >= NumberAnswer.maxLength) return;
    if (c == '.' && _text.contains('.')) return;
    setState(() => _text += c);
  }

  void _back() {
    if (_text.isEmpty) return;
    setState(() => _text = _text.substring(0, _text.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '<'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: const Key('number-display'),
          width: 3 * (AppSizes.pinKey + 16) - 16,
          height: AppSizes.minTap * 1.2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: Border.all(color: AppColors.ninja, width: 3),
          ),
          child: Text(
            _text,
            style: const TextStyle(
              fontSize: AppText.title,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.gap / 2),
        for (final row in keys)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final k in row) _key(k)],
          ),
        const SizedBox(height: AppSizes.gap / 2),
        FilledButton(
          key: const Key('check'),
          onPressed: _text.isEmpty || _text == '.'
              ? null
              : () => widget.onSubmit(_text),
          child: const Text('Check'),
        ),
      ],
    );
  }

  Widget _key(String k) {
    const size = AppSizes.pinKey;
    final isBack = k == '<';
    final name = switch (k) {
      '<' => 'back',
      '.' => 'dot',
      _ => k,
    };
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: size + 4,
        height: size,
        child: FilledButton.tonal(
          key: Key('key-$name'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(size, size),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.button),
            ),
          ),
          onPressed: isBack ? _back : () => _type(k),
          child: isBack
              ? const Icon(Icons.backspace_outlined, semanticLabel: 'Delete')
              : Text(k, style: const TextStyle(fontSize: AppText.heading)),
        ),
      ),
    );
  }
}
