import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'visual_frame.dart';

/// A row of coloured shapes, e.g. a repeating pattern.
class ShapesVisual extends StatelessWidget {
  const ShapesVisual({super.key, required this.items});

  /// (shape, colour) pairs from the bank.
  final List<({String shape, String color})> items;

  static const _size = 80.0;

  static Color colorOf(String name) => switch (name) {
    'red' => AppColors.red,
    'blue' => AppColors.blue,
    'yellow' => AppColors.yellow,
    'green' => AppColors.green,
    _ => AppColors.muted,
  };

  @override
  Widget build(BuildContext context) => VisualFrame(
    width: items.length * (_size + 16),
    height: _size + 16,
    child: Row(
      children: [
        for (final i in items)
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox.square(
              dimension: _size,
              child: CustomPaint(
                painter: ShapePainter(i.shape, colorOf(i.color)),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Paints one named shape filling its box.
class ShapePainter extends CustomPainter {
  ShapePainter(this.shape, this.color);

  final String shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = switch (shape) {
      'circle' => Path()..addOval(Offset.zero & size),
      'square' => Path()..addRect(Offset.zero & size),
      'rectangle' => Path()..addRect(Rect.fromLTWH(0, h * 0.2, w, h * 0.6)),
      'triangle' =>
        Path()
          ..moveTo(w / 2, 0)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close(),
      'semicircle' =>
        Path()
          ..moveTo(0, h * 0.75)
          ..arcTo(Rect.fromLTWH(0, h * 0.25, w, h), pi, pi, false)
          ..close(),
      'quarter circle' =>
        Path()
          ..moveTo(0, h)
          ..lineTo(0, 0)
          ..arcTo(Rect.fromLTWH(-w, 0, 2 * w, 2 * h), -pi / 2, pi / 2, false)
          ..close(),
      _ => Path(),
    };
    assert(path.getBounds() != Rect.zero, 'unknown shape $shape');
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(ShapePainter old) =>
      old.shape != shape || old.color != color;
}
