import 'package:material_ui/material_ui.dart';

import '../domain/topics.dart';
import 'theme.dart';

/// Which colours a child screen's background uses (NFR-10).
enum KidScene {
  home(AppColors.bgHomeTop, AppColors.bgHomeBottom),
  school(AppColors.bgSchoolTop, AppColors.bgSchoolBottom),
  olympiad(AppColors.bgOlyTop, AppColors.bgOlyBottom);

  const KidScene(this.top, this.bottom);
  final Color top;
  final Color bottom;

  /// The scene of a topic's track: P1 and P2 are School.
  static KidScene forTopic(String topicId) =>
      topicsById[topicId]?.track == Track.olympiad ? olympiad : school;
}

/// A soft gradient with a few faint rounded shapes behind a child screen
/// (NFR-10). The screen's Scaffold should be transparent.
class KidBackground extends StatelessWidget {
  const KidBackground({super.key, required this.scene, required this.child});

  final KidScene scene;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [scene.top, scene.bottom],
      ),
    ),
    child: CustomPaint(painter: const _ShapesPainter(), child: child),
  );
}

/// Bubbles and rounded squares at fixed places, sized to the screen.
class _ShapesPainter extends CustomPainter {
  const _ShapesPainter();

  // (x, y, radius) as fractions of the shorter side; square if r < 0.
  static const _shapes = [
    (0.06, 0.12, 0.10),
    (0.92, 0.08, 0.07),
    (0.85, 0.85, 0.14),
    (0.12, 0.88, -0.08),
    (0.55, 0.05, -0.05),
    (0.40, 0.95, 0.06),
    (0.97, 0.50, -0.06),
    (0.02, 0.50, 0.05),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.bgShape;
    final unit = size.shortestSide;
    for (final (x, y, r) in _shapes) {
      final c = Offset(x * size.width, y * size.height);
      if (r > 0) {
        canvas.drawCircle(c, r * unit, paint);
      } else {
        final side = -r * unit * 2;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: side, height: side),
            Radius.circular(side / 4),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ShapesPainter oldDelegate) => false;
}
