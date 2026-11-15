import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/progress.dart';
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
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
    return Scaffold(
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
                        Expanded(
                          child: Text(
                            'Number Ninja',
                            style: theme.displaySmall,
                          ),
                        ),
                        SizedBox(
                          height: AppSizes.minTap,
                          child: OutlinedButton.icon(
                            key: const Key('parent-button'),
                            onPressed: () => context.go(Routes.parent),
                            icon: const Icon(Icons.lock_outline),
                            label: const Text('Parent'),
                          ),
                        ),
                      ],
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
                  ],
                ),
              ),
            ),
          ),
        ),
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
