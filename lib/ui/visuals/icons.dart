import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Icons for `groups` and `pictureGraph` visuals, in one place.
const visualIcons = <String, (IconData, Color)>{
  'apple': (Icons.apple, AppColors.red),
  'star': (Icons.star, AppColors.coinGold),
  'ball': (Icons.sports_soccer, AppColors.ink),
  'flower': (Icons.local_florist, AppColors.berry),
  'orange': (Icons.circle, AppColors.orange),
  'cookie': (Icons.cookie, AppColors.brown),
  'crayon': (Icons.edit, AppColors.blue),
  'child': (Icons.child_care, AppColors.ninja),
};

/// The bank icon [name] at [size]; an unknown name asserts in debug.
Widget visualIcon(String name, double size) {
  final entry = visualIcons[name];
  assert(entry != null, 'unknown icon $name');
  final (icon, color) = entry ?? (Icons.circle, AppColors.muted);
  return Icon(icon, size: size, color: color);
}
