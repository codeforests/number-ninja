import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// One line of a [TrendChart]; a null value is a gap.
class TrendSeries {
  const TrendSeries({
    required this.label,
    required this.color,
    required this.values,
  });

  final String label;
  final Color color;
  final List<double?> values;
}

/// A small line chart for weekly trends (PAR-06): one line per series,
/// dots on points, gaps for null weeks, x labels under the plot and a
/// legend. [maxY] fixes the top (e.g. 100 for %); otherwise it fits the data.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.title,
    required this.series,
    required this.xLabels,
    this.maxY,
    this.unit = '',
  });

  final String title;
  final List<TrendSeries> series;
  final List<String> xLabels;
  final double? maxY;
  final String unit;

  double get _top {
    if (maxY != null) return maxY!;
    var m = 0.0;
    for (final s in series) {
      for (final v in s.values) {
        if (v != null && v > m) m = v;
      }
    }
    return m <= 0 ? 10 : (m * 1.15).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      fontSize: AppText.chartLabel,
      color: AppColors.muted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppText.parentBody,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSizes.gap / 2),
        SizedBox(
          height: AppSizes.chartHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: TrendPainter(
              series: series,
              xLabels: xLabels,
              top: _top,
              unit: unit,
              labelStyle: labelStyle,
              textScaler: MediaQuery.textScalerOf(context),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.gap / 2),
        Wrap(
          spacing: AppSizes.gap,
          runSpacing: AppSizes.gap / 4,
          children: [
            for (final s in series)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSizes.chartDot * 3,
                    height: AppSizes.chartDot * 3,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSizes.gap / 4),
                  Text(s.label, style: labelStyle),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class TrendPainter extends CustomPainter {
  TrendPainter({
    required this.series,
    required this.xLabels,
    required this.top,
    required this.unit,
    required this.labelStyle,
    required this.textScaler,
  });

  final List<TrendSeries> series;
  final List<String> xLabels;
  final double top;
  final String unit;
  final TextStyle labelStyle;
  final TextScaler textScaler;

  TextPainter _text(String s) => TextPainter(
    text: TextSpan(text: s, style: labelStyle),
    textDirection: TextDirection.ltr,
    textScaler: textScaler,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final yTicks = [0.0, top / 2, top];
    final yTexts = [for (final v in yTicks) _text('${_fmt(v)}$unit')];
    final left = yTexts.map((t) => t.width).reduce(math.max) + AppSizes.gap / 2;
    final xTexts = [for (final l in xLabels) _text(l)];
    final bottomPad =
        (xTexts.isEmpty ? 0.0 : xTexts.first.height) + AppSizes.gap / 4;
    final halfY = yTexts.first.height / 2;
    final plot = Rect.fromLTRB(
      left,
      halfY,
      math.max(left + 1, size.width - AppSizes.gap / 2),
      math.max(halfY + 1, size.height - bottomPad),
    );

    final grid = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 1;
    for (var i = 0; i < yTicks.length; i++) {
      final y = plot.bottom - plot.height * (yTicks[i] / top);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      yTexts[i].paint(
        canvas,
        Offset(left - AppSizes.gap / 2 - yTexts[i].width, y - halfY),
      );
    }

    final n = xLabels.isEmpty
        ? series.fold(0, (m, s) => math.max(m, s.values.length))
        : xLabels.length;
    double xAt(int i) =>
        n <= 1 ? plot.center.dx : plot.left + plot.width * i / (n - 1);

    // Skip every other label when they would overlap.
    final widest = xTexts.isEmpty
        ? 0.0
        : xTexts.map((t) => t.width).reduce(math.max);
    final slot = n <= 1 ? plot.width : plot.width / (n - 1);
    final step = math.max(1, (widest + AppSizes.gap / 2) ~/ slot + 1);
    for (var i = 0; i < xTexts.length; i++) {
      if ((xTexts.length - 1 - i) % step != 0) continue;
      final t = xTexts[i];
      final x = (xAt(i) - t.width / 2).clamp(0.0, size.width - t.width);
      t.paint(canvas, Offset(x, plot.bottom + AppSizes.gap / 4));
    }

    for (final s in series) {
      final line = Paint()
        ..color = s.color
        ..strokeWidth = AppSizes.chartLine
        ..style = PaintingStyle.stroke;
      final dot = Paint()..color = s.color;
      Offset? prev;
      for (var i = 0; i < s.values.length && i < n; i++) {
        final v = s.values[i];
        if (v == null) {
          prev = null;
          continue;
        }
        final p = Offset(
          xAt(i),
          plot.bottom - plot.height * (v.clamp(0, top) / top),
        );
        if (prev != null) canvas.drawLine(prev, p, line);
        canvas.drawCircle(p, AppSizes.chartDot, dot);
        prev = p;
      }
    }
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(TrendPainter old) =>
      old.series != series ||
      old.xLabels != xLabels ||
      old.top != top ||
      old.textScaler != textScaler;
}
