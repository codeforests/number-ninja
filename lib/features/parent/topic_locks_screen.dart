import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/topic_lock.dart';
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
import 'stats_view.dart';

/// SCR-15: every School topic's lock state; the parent opens a locked topic
/// or locks again one they opened (PRC-14).
class TopicLocksScreen extends ConsumerWidget {
  const TopicLocksScreen({super.key});

  static const _yearNames = {Track.p1: 'P1', Track.p2: 'P2'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locks = ref.watch(topicLocksProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const Key('back-parent'),
          tooltip: 'Back',
          onPressed: () => context.go(Routes.parent),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('School topics'),
      ),
      body: switch (locks) {
        AsyncData(:final value) => ListView(
          key: const Key('topic-locks'),
          padding: const EdgeInsets.all(AppSizes.gap),
          children: [
            const Text(
              'A topic opens when she gets 7 of 10 in the one before it. '
              'You can open any topic here.',
              style: StatsText.body,
            ),
            for (final track in _yearNames.keys) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSizes.gap,
                  bottom: AppSizes.gap / 2,
                ),
                child: Text(_yearNames[track]!, style: StatsText.heading),
              ),
              StatsCard(
                child: Column(
                  children: [
                    for (final t in topics.where((t) => t.track == track))
                      _LockRow(topic: t, lock: value[t.id]!),
                  ],
                ),
              ),
            ],
          ],
        ),
        AsyncError(:final error) => Center(
          child: Text('Could not load topics: $error', style: StatsText.body),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// What a lock state says to the parent.
String lockText(TopicLock lock) => switch (lock) {
  TopicLocked(:final passFirstId) =>
    'Locked: pass ${topicsById[passFirstId]?.name ?? passFirstId} first',
  TopicOpen(reason: OpenReason.parent) => 'Open: opened by you',
  TopicOpen(reason: OpenReason.passed) => 'Open: passed',
  TopicOpen(reason: OpenReason.played) => 'Open: she has played it',
  TopicOpen(reason: OpenReason.belowYear) => 'Open: below her school year',
  TopicOpen(reason: OpenReason.previousPassed) =>
    'Open: the topic before is passed',
  TopicOpen(reason: OpenReason.first) => 'Open: first topic of the year',
  TopicOpen(reason: OpenReason.olympiad) => 'Open: Olympiad',
};

class _LockRow extends ConsumerWidget {
  const _LockRow({required this.topic, required this.lock});

  final Topic topic;
  final TopicLock lock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = topic.id;
    Future<void> change({required bool open}) async {
      final repo = ref.read(topicLockRepositoryProvider);
      await (open ? repo.open(id) : repo.close(id));
      ref.invalidate(topicLocksProvider);
    }

    final locked = lock is TopicLocked;
    final parentOpened = lock == const TopicOpen(OpenReason.parent);
    return Padding(
      key: Key('lock-row-$id'),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.gap / 4),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSizes.gap,
        runSpacing: AppSizes.gap / 4,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  locked ? Icons.lock : Icons.lock_open,
                  key: Key('lock-icon-$id'),
                  color: locked ? AppColors.muted : AppColors.leaf,
                ),
                const SizedBox(width: AppSizes.gap / 2),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic.name, style: StatsText.heading),
                      Text(
                        lockText(lock),
                        key: Key('lock-state-$id'),
                        style: StatsText.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (locked)
            FilledButton(
              key: Key('lock-open-$id'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppSizes.minTap),
              ),
              onPressed: () => change(open: true),
              child: const Text('Open for her'),
            )
          else if (parentOpened)
            OutlinedButton(
              key: Key('lock-close-$id'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppSizes.minTap),
              ),
              onPressed: () => change(open: false),
              child: const Text('Lock again'),
            ),
        ],
      ),
    );
  }
}
