import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/question.dart';
import '../../domain/revision.dart';
import '../../domain/stats.dart';
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
import 'stats_view.dart';

/// SCR-10: one topic's tally for the period, its weekly trend and its most
/// missed and slowest questions (PAR-08).
class TopicDetailScreen extends ConsumerWidget {
  const TopicDetailScreen({
    super.key,
    required this.topicId,
    this.period = StatsPeriod.days30,
  });

  final String topicId;
  final StatsPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = topicsById[topicId];
    final data = ref.watch(statsDataProvider);
    final bank = ref.watch(bankProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-dashboard'),
          tooltip: 'Back',
          onPressed: () => context.go(Routes.dashboardFor(period)),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(topic?.name ?? topicId),
      ),
      body: switch ((data, bank)) {
        (AsyncData(value: final d), AsyncData(value: final b)) => _body(
          d,
          b,
          topic,
        ),
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => Center(
          child: Text('Could not load stats: $error', style: StatsText.body),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(StatsData data, QuestionBank bank, Topic? topic) {
    final rs = data.inPeriod(period, topicId: topicId);
    final tally = overall(rs);
    // Retired questions too, so her history still shows them (BNK-10).
    final byId = bank.byId;
    final track = topic?.track ?? Track.p1;
    // Not a lazy ListView: the cards are few, and tests find rows far down.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(period.longLabel, style: StatsText.muted),
          const SizedBox(height: AppSizes.gap / 2),
          StatsCard(
            key: const Key('topic-tally'),
            child: Wrap(
              spacing: AppSizes.gap * 2,
              runSpacing: AppSizes.gap / 2,
              children: [
                _Figure(label: 'right', value: pct(tally)),
                _Figure(label: 'per question', value: secs(tally)),
                _Figure(label: 'answers', value: count(tally)),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gap),
          _WeakTypesCard(topicId: topicId, byId: byId),
          const SizedBox(height: AppSizes.gap),
          StatsCard(
            child: TrendCharts(
              now: data.now,
              lines: [
                (
                  topic?.name ?? topicId,
                  trackColors[track]!,
                  [
                    for (final r in data.all)
                      if (r.topicId == topicId) r,
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gap),
          _QuestionList(
            key: const Key('most-missed'),
            title: 'Most missed',
            empty: 'No wrong answers in this period.',
            items: [
              for (final m in mostMissed(rs))
                (
                  m.questionId,
                  byId[m.questionId],
                  'wrong ${m.tally.wrong} of ${m.tally.attempts}',
                ),
            ],
            showAnswer: true,
          ),
          const SizedBox(height: AppSizes.gap),
          _QuestionList(
            key: const Key('slowest'),
            title: 'Slowest',
            empty: 'No answers in this period.',
            items: [
              for (final s in slowest(rs))
                (s.questionId, byId[s.questionId], 'avg ${secs(s.tally)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value, style: StatsText.big),
      Text(label, style: StatsText.muted),
    ],
  );
}

class _QuestionList extends StatelessWidget {
  const _QuestionList({
    super.key,
    required this.title,
    required this.empty,
    required this.items,
    this.showAnswer = false,
  });

  final String title;
  final String empty;
  final List<(String, Question?, String)> items;
  final bool showAnswer;

  @override
  Widget build(BuildContext context) => StatsCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: StatsText.heading),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.gap / 2),
            child: Text(empty, style: StatsText.muted),
          ),
        for (final (id, q, detail) in items)
          Padding(
            key: Key('q-$id'),
            padding: const EdgeInsets.only(top: AppSizes.gap / 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q?.prompt ?? id,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StatsText.body,
                      ),
                      if (showAnswer && q != null)
                        Text(
                          'Answer: ${answerText(q.answer)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StatsText.muted,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.gap),
                Text(detail, style: StatsText.muted),
              ],
            ),
          ),
      ],
    ),
  );
}

/// The topic's weak question types (REV-05), over the planner's fixed
/// 30-day window whatever the period.
class _WeakTypesCard extends ConsumerWidget {
  const _WeakTypesCard({required this.topicId, required this.byId});

  final String topicId;
  final Map<String, Question> byId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(revisionHistoryProvider).value;
    final weak = history == null
        ? const <WeakType>[]
        : ref
              .watch(revisionPlannerProvider)
              .weakTypes(history, topicId: topicId);
    String? example(String typeId) {
      AttemptRecord? latest;
      for (final a in history?.attempts ?? const <AttemptRecord>[]) {
        if (typeOf(a.questionId) == typeId &&
            byId.containsKey(a.questionId) &&
            (latest == null || !a.answeredAt.isBefore(latest.answeredAt))) {
          latest = a;
        }
      }
      return latest == null ? null : byId[latest.questionId]!.prompt;
    }

    return StatsCard(
      key: const Key('weak-types'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weak question types', style: StatsText.heading),
          const Text('Last 30 days', style: StatsText.muted),
          const SizedBox(height: AppSizes.gap / 2),
          if (weak.isEmpty)
            const Text('No weak types', style: StatsText.body)
          else
            for (final w in weak)
              Padding(
                key: Key('weak-${w.typeId}'),
                padding: const EdgeInsets.symmetric(vertical: AppSizes.gap / 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${typeLabel(w.typeId)}: '
                      '${w.tally.correct}/${w.tally.attempts} right · '
                      '${secs(w.tally)}',
                      style: StatsText.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (example(w.typeId) case final prompt?)
                      Text(
                        prompt,
                        style: StatsText.muted,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
