import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'icons.dart';
import 'visual_frame.dart';

typedef GraphRow = ({String label, int count});

/// A picture graph: one row of icons per label, each icon standing for
/// [scale] (the bank's `count` is the real number).
class PictureGraphVisual extends StatelessWidget {
  const PictureGraphVisual({
    super.key,
    required this.title,
    required this.rows,
    required this.scale,
    required this.icon,
  });

  final String title;
  final List<GraphRow> rows;
  final int scale;
  final String icon;

  static const _icon = 40.0;
  static const _label = 170.0;

  @override
  Widget build(BuildContext context) {
    final most = rows.fold(1, (m, r) {
      final n = r.count ~/ scale;
      return n > m ? n : m;
    });
    final width = _label + 16 + (most < 6 ? 6 : most) * _icon + 40;
    return VisualFrame(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.ink, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: visualText.copyWith(fontSize: AppText.body)),
            const SizedBox(height: 8),
            for (final r in rows)
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.muted)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: _label,
                      child: Text(r.label, style: visualText),
                    ),
                    const SizedBox(width: 16),
                    for (var i = 0; i < r.count ~/ scale; i++)
                      visualIcon(icon, _icon),
                  ],
                ),
              ),
            if (scale > 1) ...[
              const SizedBox(height: 8),
              // One text so it wraps under large text instead of
              // overflowing (NFR-09).
              Text.rich(
                TextSpan(
                  style: visualText,
                  children: [
                    const TextSpan(text: 'Each '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: visualIcon(icon, 32),
                    ),
                    TextSpan(text: ' stands for $scale'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
