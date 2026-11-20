import 'package:material_ui/material_ui.dart';

import '../domain/family.dart';
import 'theme.dart';

/// Icon and colour of each built-in avatar (FEAT-25 AD-7); ids from
/// [avatarIds]. No photos (ADR-07).
const avatarLooks = <String, (IconData, Color)>{
  'fox': (Icons.pets, AppColors.avatarFox),
  'owl': (Icons.nightlight_round, AppColors.avatarOwl),
  'cat': (Icons.star, AppColors.avatarCat),
  'bear': (Icons.cruelty_free, AppColors.avatarBear),
  'bunny': (Icons.favorite, AppColors.avatarBunny),
  'frog': (Icons.eco, AppColors.avatarFrog),
  'panda': (Icons.rocket_launch, AppColors.avatarPanda),
  'tiger': (Icons.bolt, AppColors.avatarTiger),
};

/// A round avatar of [id], [size] across; an unknown id shows the first.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle(this.id, {super.key, this.size = AppSizes.avatarSmall});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = avatarLooks[id] ?? avatarLooks[avatarIds.first]!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.6, color: AppColors.card),
    );
  }
}
