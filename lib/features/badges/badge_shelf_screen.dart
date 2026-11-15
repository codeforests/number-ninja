import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart' hide Badge;

import '../../ui/kid_background.dart';
import '../../app.dart';
import '../../domain/badges.dart';
import '../../providers.dart';
import '../../ui/badge_icons.dart';
import '../../ui/theme.dart';

/// The badge earned last: greatest `earned_at`, ties to the later shelf
/// position (FEAT-08 design). Null when none.
Badge? latestBadge(Map<String, DateTime> earned) {
  Badge? best;
  DateTime? at;
  for (final b in badges) {
    final t = earned[b.id];
    if (t != null && (at == null || !t.isBefore(at))) {
      best = b;
      at = t;
    }
  }
  return best;
}

/// SCR-06: all 20 badges, earned in colour with the date, the rest as grey
/// silhouettes with a hint (BDG-03). A child screen, so it counts as
/// screen time (TIM-01).
class BadgeShelfScreen extends ConsumerWidget {
  const BadgeShelfScreen({super.key});

  /// Tile width; the shelf wraps as many per row as fit.
  static const tileWidth = 220.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final earned = ref.watch(earnedBadgesProvider).value ?? const {};
    return KidBackground(
      scene: KidScene.home,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.gap * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: AppSizes.minTap,
                      child: IconButton.filledTonal(
                        key: const Key('badges-back'),
                        iconSize: 36,
                        onPressed: () => context.go(Routes.home),
                        icon: const Icon(
                          Icons.arrow_back,
                          semanticLabel: 'Back',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.gap),
                    Expanded(
                      child: Text(
                        'My badges',
                        style: theme.displaySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.gap / 2),
                Text(
                  '${earned.length} of ${badges.length}',
                  key: const Key('badge-count'),
                  style: theme.headlineSmall,
                ),
                const SizedBox(height: AppSizes.gap),
                Expanded(
                  // A Wrap, not a fixed-height grid, so long hints at large
                  // text sizes grow the tile instead of overflowing (NFR-09).
                  child: SingleChildScrollView(
                    key: const Key('badge-shelf'),
                    child: Wrap(
                      spacing: AppSizes.gap,
                      runSpacing: AppSizes.gap,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final b in badges)
                          _BadgeTile(badge: b, earnedAt: earned[b.id]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earnedAt});

  final Badge badge;
  final DateTime? earnedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final at = earnedAt;
    final tile = SizedBox(
      key: Key('badge-${badge.id}'),
      width: BadgeShelfScreen.tileWidth,
      child: Card(
        color: at == null ? AppColors.paper : AppColors.card,
        elevation: at == null ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gap),
          child: Column(
            children: [
              BadgeIcon(badge.id, earned: at != null),
              const SizedBox(height: AppSizes.gap / 2),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: theme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: at == null ? AppColors.muted : AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSizes.gap / 4),
              Text(
                at == null
                    ? badge.hint
                    : 'Earned ${DateFormat('d MMM').format(at)}',
                textAlign: TextAlign.center,
                style: theme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
    if (at != null) return tile;
    return Semantics(
      label: '${badge.name}, not earned yet',
      excludeSemantics: true,
      child: tile,
    );
  }
}
