import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// One icon and colour per badge id (FEAT-08 design), for SCR-02/05/06.
const badgeIcons = <String, (IconData, Color)>{
  'first-round': (Icons.flag, AppColors.leaf),
  'perfect-10': (Icons.workspace_premium, AppColors.sun),
  'streak-3': (Icons.local_fire_department, AppColors.orange),
  'streak-7': (Icons.whatshot, AppColors.red),
  'streak-30': (Icons.calendar_month, AppColors.berry),
  'questions-100': (Icons.looks_one, AppColors.blue),
  'questions-500': (Icons.military_tech, AppColors.ninja),
  'speedy': (Icons.bolt, AppColors.sun),
  'times-hero': (Icons.close, AppColors.trackP2),
  'division-dojo': (Icons.call_split, AppColors.trackP2),
  'fraction-friend': (Icons.pie_chart, AppColors.trackP2),
  'money-master': (Icons.savings, AppColors.coinGold),
  'time-keeper': (Icons.schedule, AppColors.blue),
  'shape-spotter': (Icons.category, AppColors.green),
  'pattern-finder': (Icons.auto_awesome, AppColors.trackOly),
  'puzzle-master': (Icons.psychology, AppColors.trackOly),
  'counting-star': (Icons.star, AppColors.trackOly),
  'bar-model-builder': (Icons.view_week, AppColors.trackOly),
  'school-explorer': (Icons.explore, AppColors.trackP1),
  'ninja-master': (Icons.bubble_chart, AppColors.ninja),
};

/// A badge's icon in a circle: coloured when [earned], else a grey
/// silhouette (BDG-03).
class BadgeIcon extends StatelessWidget {
  const BadgeIcon(
    this.badgeId, {
    super.key,
    this.earned = true,
    this.size = AppSizes.badge,
  });

  final String badgeId;
  final bool earned;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, colour) =
        badgeIcons[badgeId] ?? (Icons.emoji_events, AppColors.sun);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: earned ? colour : AppColors.chartGrid,
      ),
      child: Icon(
        icon,
        size: size * 0.6,
        color: earned ? AppColors.card : AppColors.muted,
      ),
    );
  }
}
