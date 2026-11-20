import 'package:material_ui/material_ui.dart';

import '../../../ui/layout.dart';
import '../../../ui/theme.dart';

/// A display, an on-screen keypad (0–9, `.`, backspace) and Check (PRC-03).
/// No system keyboard. On a phone (FEAT-19) the keys are 4 × 3 with the
/// display and Check in a row above, so the whole pad fits the screen.
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
    final small = compact(MediaQuery.sizeOf(context));
    final keys = small
        ? const [
            ['1', '2', '3', '<'],
            ['4', '5', '6', '.'],
            ['7', '8', '9', '0'],
          ]
        : const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['.', '0', '<'],
          ];
    Widget display({double? width, required double height}) => Container(
      key: const Key('number-display'),
      width: width,
      height: height,
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
    );
    final check = FilledButton(
      key: const Key('check'),
      style: small
          ? FilledButton.styleFrom(
              minimumSize: const Size(AppSizes.minTap * 1.75, AppSizes.minTap),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.gap),
            )
          : null,
      onPressed: _text.isEmpty || _text == '.'
          ? null
          : () => widget.onSubmit(_text),
      child: const Text('Check'),
    );
    final rows = [
      for (final row in keys)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [for (final k in row) _key(k, small)],
        ),
    ];
    if (small) {
      return SizedBox(
        width: 4 * (AppSizes.minTap + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(child: display(height: AppSizes.minTap)),
                  const SizedBox(width: AppSizes.gap / 2),
                  check,
                ],
              ),
            ),
            const SizedBox(height: AppSizes.gap / 2),
            ...rows,
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        display(
          width: 3 * (AppSizes.pinKey + 16) - 16,
          height: AppSizes.minTap * 1.2,
        ),
        const SizedBox(height: AppSizes.gap / 2),
        ...rows,
        const SizedBox(height: AppSizes.gap / 2),
        check,
      ],
    );
  }

  Widget _key(String k, bool small) {
    final size = small ? AppSizes.minTap : AppSizes.pinKey;
    final isBack = k == '<';
    final name = switch (k) {
      '<' => 'back',
      '.' => 'dot',
      _ => k,
    };
    final face = isBack ? AppColors.keyDelete : AppColors.keyFace;
    final edge = isBack ? AppColors.keyDeleteEdge : AppColors.keyEdge;
    final ink = switch (k) {
      '<' => AppColors.keyDeleteInk,
      '.' => AppColors.muted,
      _ => AppColors.ninja,
    };
    final radius = BorderRadius.circular(AppRadii.button);
    return Padding(
      padding: EdgeInsets.all(small ? 4 : 6),
      // A white "candy" key with a coloured bottom edge, so it looks
      // pressable on the light backgrounds (FEAT-16).
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: edge, offset: const Offset(0, AppSizes.keyEdge)),
          ],
        ),
        child: SizedBox(
          width: small ? size : size + 4,
          height: size,
          child: FilledButton.tonal(
            key: Key('key-$name'),
            style: FilledButton.styleFrom(
              minimumSize: Size(size, size),
              padding: EdgeInsets.zero,
              backgroundColor: face,
              foregroundColor: ink,
              textStyle: const TextStyle(
                fontSize: AppText.heading,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(borderRadius: radius),
            ),
            onPressed: isBack ? _back : () => _type(k),
            child: isBack
                ? const Icon(
                    Icons.backspace_outlined,
                    size: AppText.heading,
                    semanticLabel: 'Delete',
                  )
                : Text(k),
          ),
        ),
      ),
    );
  }
}
