import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/progress.dart';
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
import 'topic_icons.dart';

/// The track slug in `/play/:track`: `school` (P1 and P2) or `olympiad`.
abstract final class TrackSlug {
  static const school = 'school';
  static const olympiad = 'olympiad';

  /// The topic tracks behind a slug, in map order.
  static List<Track> tracks(String slug) =>
      slug == olympiad ? const [Track.olympiad] : const [Track.p1, Track.p2];
}

/// SCR-03: the topic map. Tiles grouped P1 / P2 (School) or Olympiad, each
/// with her best stars and current level (PRC-01, PRC-07).
class TopicMapScreen extends ConsumerWidget {
  const TopicMapScreen({super.key, required this.track});

  final String track;

  static const _sectionNames = {
    Track.p1: 'P1',
    Track.p2: 'P2',
    Track.olympiad: 'Olympiad',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final progress = ref.watch(topicProgressProvider).value ?? const {};
    final tracks = TrackSlug.tracks(track);
    final scaler = MediaQuery.textScalerOf(context);
    // Two lines of name plus the stars row, with padding, at her text size.
    final tileHeight = [
      AppSizes.minTap * 2,
      scaler.scale(AppText.body) * 1.3 * 2 +
          scaler.scale(AppText.small) * 1.5 +
          AppSizes.gap * 2.5,
    ].reduce((a, b) => a > b ? a : b);
    return Scaffold(
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
                      key: const Key('back'),
                      iconSize: 36,
                      onPressed: () => context.go(Routes.home),
                      icon: const Icon(Icons.arrow_back, semanticLabel: 'Back'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.gap),
                  Expanded(
                    child: Text(
                      track == TrackSlug.olympiad ? 'Olympiad' : 'School',
                      style: theme.displaySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.gap),
              Expanded(
                child: CustomScrollView(
                  key: const Key('topic-map'),
                  slivers: [
                    for (final t in tracks) ...[
                      if (tracks.length > 1)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.gap,
                            ),
                            child: Text(
                              _sectionNames[t]!,
                              key: Key('section-${t.name}'),
                              style: theme.headlineSmall,
                            ),
                          ),
                        ),
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          mainAxisExtent: tileHeight,
                          mainAxisSpacing: AppSizes.gap,
                          crossAxisSpacing: AppSizes.gap,
                        ),
                        delegate: SliverChildListDelegate([
                          for (final topic in topics)
                            if (topic.track == t)
                              _TopicTile(
                                topic: topic,
                                progress:
                                    progress[topic.id] ?? TopicProgress.none,
                              ),
                        ]),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSizes.gap),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic, required this.progress});

  final Topic topic;
  final TopicProgress progress;

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
        key: Key('topic-${topic.id}'),
        onTap: () => context.go(Routes.quiz(topic.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gap),
          child: Row(
            children: [
              Icon(
                topicIcons[topic.id],
                key: Key('topic-${topic.id}-icon'),
                size: AppSizes.minTap,
                color: AppColors.ninja,
              ),
              const SizedBox(width: AppSizes.gap),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        topic.name,
                        key: Key('topic-${topic.id}-name'),
                        style: theme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: AppSizes.gap / 2),
                    Row(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Icon(
                            i < progress.bestStars
                                ? Icons.star
                                : Icons.star_border,
                            key: Key('topic-${topic.id}-star-$i'),
                            size: AppText.heading,
                            color: i < progress.bestStars
                                ? AppColors.sun
                                : AppColors.muted,
                          ),
                        const SizedBox(width: AppSizes.gap / 2),
                        Flexible(
                          child: Text(
                            'Level ${progress.level}',
                            key: Key('topic-${topic.id}-level'),
                            style: theme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
