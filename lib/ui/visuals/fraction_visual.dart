import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'visual_frame.dart';

/// A bar cut into [parts] equal parts with the first [shaded] coloured.
class FractionVisual extends StatelessWidget {
  const FractionVisual({super.key, required this.parts, required this.shaded});

  final int parts;
  final int shaded;

  @override
  Widget build(BuildContext context) => VisualFrame(
    width: 480,
    height: 100,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ink, width: 4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < parts; i++)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: i < shaded ? AppColors.shade : AppColors.card,
                  border: i == 0
                      ? null
                      : const Border(
                          left: BorderSide(color: AppColors.ink, width: 3),
                        ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
