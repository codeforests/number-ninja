import 'dart:math';

import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// Confetti falling once over SCR-05 when a round ends (NFR-10). It never
/// takes taps, so the buttons under it work at once.
class Celebration extends StatefulWidget {
  const Celebration({super.key});

  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.celebration,
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_c)),
    ),
  );
}

class _Piece {
  _Piece(Random r)
    : x = r.nextDouble(),
      delay = r.nextDouble() * 0.3,
      drift = (r.nextDouble() - 0.5) * 0.2,
      spin = (r.nextDouble() - 0.5) * 12,
      size = 8 + r.nextDouble() * 10,
      color = AppColors.confetti[r.nextInt(AppColors.confetti.length)];

  final double x, delay, drift, spin, size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;
  static final _pieces = List.generate(40, (_) => _Piece(_seed));
  static final _seed = Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t >= 1) return;
    final paint = Paint();
    for (final p in _pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -p.size + local * (size.height + p.size * 2);
      final x = (p.x + p.drift * local) * size.width;
      paint.color = p.color.withValues(alpha: 1 - local * local);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.spin * local);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(AppRadii.confetti),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}
