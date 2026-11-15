import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'visual_frame.dart';

/// Line figures for counting puzzles (shapes inside shapes).
class FigureVisual extends StatelessWidget {
  const FigureVisual({super.key, required this.name});

  static const names = {
    'triangle-split-3',
    'square-diagonals',
    'grid-2x2',
    'grid-3x3',
    'grid-2x3',
  };

  final String name;

  @override
  Widget build(BuildContext context) {
    final wide = name == 'grid-2x3';
    return VisualFrame(
      width: wide ? 330 : 260,
      height: 260,
      child: CustomPaint(painter: _FigurePainter(name)),
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter(this.name);

  final String name;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round;
    final r = (Offset.zero & size).deflate(10);
    switch (name) {
      case 'triangle-split-3':
        final top = Offset(r.center.dx, r.top);
        canvas.drawPath(
          Path()
            ..moveTo(top.dx, top.dy)
            ..lineTo(r.right, r.bottom)
            ..lineTo(r.left, r.bottom)
            ..close(),
          p,
        );
        for (final f in [1 / 3, 2 / 3]) {
          canvas.drawLine(top, Offset(r.left + r.width * f, r.bottom), p);
        }
      case 'square-diagonals':
        canvas.drawRect(r, p);
        canvas.drawLine(r.topLeft, r.bottomRight, p);
        canvas.drawLine(r.topRight, r.bottomLeft, p);
      default:
        final m = RegExp(r'^grid-(\d)x(\d)$').firstMatch(name);
        assert(m != null, 'unknown figure $name');
        if (m == null) return;
        final rows = int.parse(m.group(1)!);
        final cols = int.parse(m.group(2)!);
        canvas.drawRect(r, p);
        for (var i = 1; i < rows; i++) {
          final y = r.top + r.height * i / rows;
          canvas.drawLine(Offset(r.left, y), Offset(r.right, y), p);
        }
        for (var j = 1; j < cols; j++) {
          final x = r.left + r.width * j / cols;
          canvas.drawLine(Offset(x, r.top), Offset(x, r.bottom), p);
        }
    }
  }

  @override
  bool shouldRepaint(_FigurePainter old) => old.name != name;
}
