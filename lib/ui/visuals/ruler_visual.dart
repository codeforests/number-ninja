import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'visual_frame.dart';

/// A pencil lying from 0 to [cm] on a 15 cm ruler.
class RulerVisual extends StatelessWidget {
  const RulerVisual({super.key, required this.cm});

  final int cm;

  @override
  Widget build(BuildContext context) => VisualFrame(
    width: 600,
    height: 170,
    child: CustomPaint(painter: _RulerPainter(cm)),
  );
}

class _RulerPainter extends CustomPainter {
  _RulerPainter(this.cm);

  final int cm;
  static const length = 15;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 24.0;
    final unit = (size.width - 2 * left) / length;
    final rulerTop = size.height * 0.45;
    final rulerRect = Rect.fromLTWH(
      left - 12,
      rulerTop,
      unit * length + 24,
      size.height - rulerTop - 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rulerRect, const Radius.circular(6)),
      Paint()..color = AppColors.wood,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rulerRect, const Radius.circular(6)),
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tick = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 2;
    for (var i = 0; i <= length * 2; i++) {
      final x = left + i * unit / 2;
      final h = i.isEven ? 22.0 : 12.0;
      canvas.drawLine(Offset(x, rulerTop), Offset(x, rulerTop + h), tick);
      if (i.isEven) {
        paintLabel(canvas, '${i ~/ 2}', Offset(x, rulerTop + 42));
      }
    }
    paintLabel(
      canvas,
      'cm',
      Offset(left + unit * length - 4, rulerTop + 72),
      size: 20,
    );
    // The pencil: body from 0 to cm, with a pointed tip at cm.
    final y = rulerTop - 34;
    final end = left + cm * unit;
    final tipLen = unit * 0.6 < 20 ? unit * 0.6 : 20.0;
    final body = Rect.fromLTRB(left, y, end - tipLen, y + 26);
    canvas.drawRect(body, Paint()..color = AppColors.yellow);
    final tip = Path()
      ..moveTo(end - tipLen, y)
      ..lineTo(end, y + 13)
      ..lineTo(end - tipLen, y + 26)
      ..close();
    canvas.drawPath(tip, Paint()..color = AppColors.brown);
    final outline = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(body, outline);
    canvas.drawPath(tip, outline);
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.cm != cm;
}
