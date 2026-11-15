import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'icons.dart';
import 'visual_frame.dart';

/// [groups] boxes of [each] icons.
class GroupsVisual extends StatelessWidget {
  const GroupsVisual({
    super.key,
    required this.groups,
    required this.each,
    required this.icon,
  });

  final int groups;
  final int each;
  final String icon;

  static const _icon = 36.0;

  @override
  Widget build(BuildContext context) {
    final perRow = each <= 4 ? 2 : 3;
    final groupWidth = perRow * _icon + 24;
    final perLine = groups <= 5 ? groups : (groups + 1) ~/ 2;
    return VisualFrame(
      width: perLine * (groupWidth + 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          for (var g = 0; g < groups; g++)
            Container(
              width: groupWidth,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadii.button),
                border: Border.all(color: AppColors.ink, width: 3),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < each; i++) visualIcon(icon, _icon),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
