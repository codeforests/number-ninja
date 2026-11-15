import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Lays [child] out at its natural [width] × [height] and scales it to fit
/// the box it is given, so every visual fits any space (PRC-10).
class VisualFrame extends StatelessWidget {
  const VisualFrame({
    super.key,
    required this.width,
    this.height,
    required this.child,
  });

  final double width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.contain,
    child: SizedBox(width: width, height: height, child: child),
  );
}

/// Text used inside visuals.
const visualText = TextStyle(
  fontSize: AppText.small,
  color: AppColors.ink,
  fontWeight: FontWeight.w600,
);

/// Paints [text] centred at [at].
void paintLabel(Canvas canvas, String text, Offset at, {double? size}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: visualText.copyWith(fontSize: size ?? AppText.small),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
}
