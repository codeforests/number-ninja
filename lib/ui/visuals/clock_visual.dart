import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'visual_frame.dart';

/// An analogue clock showing [h]:[m].
class ClockVisual extends StatelessWidget {
  const ClockVisual({super.key, required this.h, required this.m});

  final int h;
  final int m;

  @override
  Widget build(BuildContext context) => VisualFrame(
    width: 260,
    height: 260,
    child: CustomPaint(painter: _ClockPainter(h, m)),
  );
}

class _ClockPainter extends CustomPainter {
  _ClockPainter(this.h, this.m);

  final int h;
  final int m;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    canvas.drawCircle(c, r, Paint()..color = AppColors.card);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    final tick = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 2;
    for (var i = 0; i < 60; i++) {
      final a = i * pi / 30;
      final dir = Offset(sin(a), -cos(a));
      final inner = i % 5 == 0 ? r - 14 : r - 8;
      canvas.drawLine(c + dir * inner, c + dir * (r - 3), tick);
    }
    for (var n = 1; n <= 12; n++) {
      final a = n * pi / 6;
      paintLabel(canvas, '$n', c + Offset(sin(a), -cos(a)) * (r - 34));
    }
    void hand(double angle, double len, double width, Color color) {
      canvas.drawLine(
        c,
        c + Offset(sin(angle), -cos(angle)) * len,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    hand(((h % 12) + m / 60) * pi / 6, r * 0.5, 10, AppColors.ink);
    hand(m * pi / 30, r * 0.78, 6, AppColors.ninja);
    canvas.drawCircle(c, 8, Paint()..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.h != h || old.m != m;
}
