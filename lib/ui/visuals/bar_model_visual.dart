import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'visual_frame.dart';

typedef Bar = ({String label, int units, int? unitValue, int? known});

/// A bar model: one bar per label, cut into equal units, with an optional
/// labelled extra part ([Bar.known]) and a bracket for the [total].
class BarModelVisual extends StatelessWidget {
  const BarModelVisual({super.key, required this.bars, this.total});

  final List<Bar> bars;
  final int? total;

  static const _unit = 72.0;
  static const _known = 96.0;
  static const _label = 130.0;
  static const _height = 56.0;

  @override
  Widget build(BuildContext context) {
    final longest = bars.fold(0.0, (m, b) {
      final w = b.units * _unit + (b.known != null ? _known : 0);
      return w > m ? w : m;
    });
    final width = _label + 12 + longest + (total != null ? 110 : 8);
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in bars)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: _label,
                  child: Text(
                    b.label,
                    style: visualText,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 12),
                for (var i = 0; i < b.units; i++)
                  _box(
                    _unit,
                    AppColors.shade,
                    b.unitValue == null ? '' : '${b.unitValue}',
                  ),
                if (b.known != null) _box(_known, AppColors.sun, '${b.known}'),
              ],
            ),
          ),
      ],
    );
    return VisualFrame(
      width: width,
      child: total == null
          ? column
          : IntrinsicHeight(
              child: Row(
                children: [
                  column,
                  const Spacer(),
                  const SizedBox(width: 12),
                  CustomPaint(
                    size: const Size(20, double.infinity),
                    painter: _Brace(),
                  ),
                  const SizedBox(width: 8),
                  Text('$total', style: visualText),
                  const SizedBox(width: 8),
                ],
              ),
            ),
    );
  }

  Widget _box(double width, Color color, String text) => Container(
    width: width,
    height: _height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: AppColors.ink, width: 2),
    ),
    child: Text(text, style: visualText),
  );
}

/// A right-facing curly bracket spanning its height.
class _Brace extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height - 16;
    final p = Path()
      ..moveTo(0, 8)
      ..quadraticBezierTo(w / 2, 8, w / 2, 8 + h * 0.2)
      ..lineTo(w / 2, 8 + h * 0.4)
      ..quadraticBezierTo(w / 2, 8 + h / 2, w, 8 + h / 2)
      ..quadraticBezierTo(w / 2, 8 + h / 2, w / 2, 8 + h * 0.6)
      ..lineTo(w / 2, 8 + h * 0.8)
      ..quadraticBezierTo(w / 2, 8 + h, 0, 8 + h);
    canvas.drawPath(
      p,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_Brace old) => false;
}
