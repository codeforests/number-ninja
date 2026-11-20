import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../ui/kid_background.dart';
import '../../app.dart';
import '../../ui/badge_icons.dart';
import '../badges/badge_shelf_screen.dart';
import '../../domain/family.dart';
import '../../domain/progress.dart';
import '../../domain/revision.dart' show mixedScopeId;
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../ui/avatars.dart';
import '../../ui/layout.dart';
import '../../ui/theme.dart';
import '../family/change_child.dart';
import '../screen_time/screen_time_controller.dart';
import '../topics/topic_map_screen.dart';

/// SCR-02: home. Two track cards with the stars earned on each, side by
/// side in landscape and stacked in portrait (PRC-01, NFR-09).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Stars earned on the topics of [slug], and the most there are.
  static (int, int) trackStars(
    Map<String, TopicProgress> progress,
    String slug,
  ) {
    final tracks = TrackSlug.tracks(slug);
    final inTrack = [
      for (final t in topics)
        if (tracks.contains(t.track)) t.id,
    ];
    final earned = inTrack.fold(
      0,
      (sum, id) => sum + (progress[id]?.bestStars ?? 0),
    );
    return (earned, inTrack.length * 3);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final progress = ref.watch(topicProgressProvider).value ?? const {};
    final nickname = ref.watch(childProfileProvider).value?.nickname;
    final revise =
        ref.watch(revisionOffersProvider(mixedScopeId)).value ?? false;
    // FEAT-30 PD-8: free shows one quiet lock where revision would be.
    final reviseLocked =
        !ref.watch(plusProvider) &&
        (ref.watch(revisionDueProvider(mixedScopeId)).value ?? false);
    final size = MediaQuery.sizeOf(context);
    final portrait = size.width < size.height;
    final cards = [
      _TrackCard(
        title: 'School',
        subtitle: 'P1 and P2 maths',
        icon: Icons.school,
        track: TrackSlug.school,
        stars: trackStars(progress, TrackSlug.school),
      ),
      _TrackCard(
        title: 'Olympiad',
        subtitle: 'Puzzles and patterns',
        icon: Icons.extension,
        track: TrackSlug.olympiad,
        stars: trackStars(progress, TrackSlug.olympiad),
      ),
    ];
    const gap = SizedBox.square(dimension: AppSizes.gap * 2);
    return KidBackground(
      scene: KidScene.home,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.gap * 2),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSizes.gap * 4,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const _ChildChip(),
                          Expanded(
                            child: Text(
                              nickname == null
                                  ? 'BrainBubblz'
                                  : 'Hi, $nickname!',
                              key: const Key('greeting'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.displaySmall,
                            ),
                          ),
                          ParentButton(
                            key: const Key('parent-button'),
                            onPressed: () => context.go(Routes.parent),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.gap),
                      const Wrap(
                        spacing: AppSizes.gap * 2,
                        runSpacing: AppSizes.gap,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [_MinutesLeft(), _BadgesButton()],
                      ),
                      gap,
                      Expanded(
                        child: Flex(
                          direction: portrait ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: cards[0]),
                            gap,
                            Expanded(child: cards[1]),
                          ],
                        ),
                      ),
                      if (revise) ...[gap, const _ReviseCard()],
                      if (reviseLocked) ...[gap, const _ReviseLockCard()],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top-left chip with the current child's avatar and name, only with 2+
/// children; opens SCR-17 (FEAT-25 AD-4, PIN first when asked for).
class _ChildChip extends ConsumerWidget {
  const _ChildChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider).value ?? const [];
    if (children.length < 2) return const SizedBox.shrink();
    final current = ref.watch(currentChildProvider);
    final i = children.indexWhere((c) => c.id == current);
    final child = children[i < 0 ? 0 : i];
    final name = displayName(child.nickname, i < 0 ? 0 : i);
    // On a phone the greeting already names her: the avatar alone fits
    // (FEAT-25 AC-9).
    final narrow = compact(MediaQuery.sizeOf(context));
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.gap),
      child: SizedBox(
        height: AppSizes.minTap,
        child: narrow
            ? Tooltip(
                message: name,
                child: OutlinedButton(
                  key: const Key('child-chip'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(AppSizes.minTap, AppSizes.minTap),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => changeChild(context, ref),
                  child: AvatarCircle(child.avatar),
                ),
              )
            : OutlinedButton.icon(
                key: const Key('child-chip'),
                onPressed: () => changeChild(context, ref),
                icon: AvatarCircle(child.avatar),
                label: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.minTap * 2.5,
                  ),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
      ),
    );
  }
}

/// SCR-02's way into a mixed revision round (REV-03), shown only when the
/// planner offers one.
class _ReviseCard extends StatelessWidget {
  const _ReviseCard();

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.revisionLight,
    borderRadius: BorderRadius.circular(AppRadii.card),
    child: InkWell(
      key: const Key('home-revise'),
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: () => context.go(Routes.revise(mixedScopeId)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.gap * 2,
            vertical: AppSizes.gap,
          ),
          child: Row(
            children: [
              const Icon(Icons.replay, size: 36, color: AppColors.revision),
              const SizedBox(width: AppSizes.gap),
              Expanded(
                child: Text(
                  'Revision: practise your tricky ones',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.revision,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.revision),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Where revision would be on free (FEAT-30 PD-8): a padlock and, on tap,
/// one "ask a grown-up" sheet. No price, store or parent-area link.
class _ReviseLockCard extends StatelessWidget {
  const _ReviseLockCard();

  static Future<void> _explain(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => SafeArea(
          child: Padding(
            key: const Key('revise-ask-sheet'),
            padding: const EdgeInsets.all(AppSizes.gap * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Revision is part of BrainBubblz Plus. '
                  'Ask a grown-up to have a look.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSizes.gap * 2),
                FilledButton(
                  key: const Key('revise-ask-ok'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.locked,
    borderRadius: BorderRadius.circular(AppRadii.card),
    child: InkWell(
      key: const Key('home-revise-locked'),
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: () => _explain(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.gap * 2,
            vertical: AppSizes.gap,
          ),
          child: Row(
            children: [
              const Icon(Icons.lock, size: 36, color: AppColors.lockedText),
              const SizedBox(width: AppSizes.gap),
              Expanded(
                child: Text(
                  'Revision',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.lockedText,
                    fontWeight: FontWeight.w600,
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

/// "N min left" today (TIM-06), from [screenTimeProvider].
class _MinutesLeft extends ConsumerWidget {
  const _MinutesLeft();

  /// The label for [minutesLeft], or null before the first read.
  static String label(int minutesLeft) =>
      minutesLeft > 0 ? '$minutesLeft min left' : "Time's up";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenTime = ref.watch(screenTimeProvider);
    return ListenableBuilder(
      listenable: screenTime,
      builder: (context, _) {
        final status = screenTime.status;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, color: AppColors.ninja),
            const SizedBox(width: AppSizes.gap / 2),
            Flexible(
              child: Text(
                status == null ? '' : label(status.minutesLeft),
                key: const Key('minutes-left'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Opens SCR-06, showing the latest badge when there is one (BDG-03).
class _BadgesButton extends ConsumerWidget {
  const _BadgesButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = latestBadge(
      ref.watch(earnedBadgesProvider).value ?? const {},
    );
    return SizedBox(
      height: AppSizes.minTap,
      child: OutlinedButton.icon(
        key: const Key('badges-button'),
        onPressed: () => context.go(Routes.badges),
        icon: latest == null
            ? const Icon(Icons.emoji_events)
            : BadgeIcon(latest.id, size: AppSizes.badgeSmall),
        label: Text(latest == null ? 'My badges' : 'Latest: ${latest.name}'),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.track,
    required this.stars,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String track;

  /// Stars earned and the most there are.
  final (int, int) stars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.ninjaLight, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('track-$track'),
        onTap: () => context.go(Routes.play(track)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gap * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 96, color: AppColors.ninja),
              const SizedBox(height: AppSizes.gap),
              Text(title, style: theme.headlineSmall),
              Text(
                subtitle,
                style: theme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.gap / 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${stars.$1} / ${stars.$2}',
                    key: Key('track-stars-$track'),
                    style: theme.bodyLarge,
                  ),
                  const SizedBox(width: AppSizes.gap / 4),
                  const Icon(
                    Icons.star,
                    size: AppText.heading,
                    color: AppColors.sun,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The home screen's Parent button (PAR-02); setup's Done step shows the
/// same widget so the parent knows what to look for (FEAT-26 AD-11).
class ParentButton extends StatelessWidget {
  const ParentButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppSizes.minTap,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.lock_outline),
      label: const Text('Parent'),
    ),
  );
}
