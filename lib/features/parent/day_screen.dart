import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/daily.dart';
import '../../domain/question.dart';
import '../../domain/screen_time.dart';
import '../../domain/stats.dart';
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../domain/plus.dart';
import 'plus_screen.dart';
import '../family/child_switcher.dart';
import '../../ui/theme.dart';
import 'stats_view.dart';

/// One day's answers, rounds and screen time (SCR-16, PAR-11). Re-read when
/// the screen opens and after a sync.
final dayDetailProvider = FutureProvider.autoDispose.family<DayDetail, String>((
  ref,
  day,
) async {
  ref.watch(syncDataVersionProvider);
  final stats = await ref.watch(statsRepositoryProvider.future);
  return stats.day(day);
});

/// The day of her first answer, for the date picker's first date.
final firstDayProvider = FutureProvider.autoDispose<String?>((ref) async {
  ref.watch(syncDataVersionProvider);
  final stats = await ref.watch(statsRepositoryProvider.future);
  return stats.firstDay();
});

final _dayLabel = DateFormat('EEE d MMM yyyy');
final _clockTime = DateFormat('HH:mm');

String dayLabel(String day) => _dayLabel.format(DateTime.parse(day));

/// "3 min 20 s", "45 s".
String durationText(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return m == 0 ? '$s s' : (s == 0 ? '$m min' : '$m min $s s');
}

/// SCR-16: pick a calendar day and see its totals, screen time, topics,
/// rounds and every answer (PAR-11).
class DayScreen extends ConsumerWidget {
  const DayScreen({super.key, this.day});

  /// `yyyy-MM-dd`; null or invalid means today.
  final String? day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = dayKey(ref.watch(clockProvider)());
    final shown = switch (day) {
      final d? when DateTime.tryParse(d) != null => dayKey(DateTime.parse(d)),
      _ => today,
    };
    final detail = ref.watch(dayDetailProvider(shown));
    final bank = ref.watch(bankProvider).value;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-dashboard'),
          tooltip: 'Back',
          onPressed: () => context.go(Routes.dashboard),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('One day'),
        actions: const [ChildSwitcher()],
      ),
      // The day view needs Plus (FEAT-30 PD-1).
      body: !ref.watch(plusProvider)
          ? const Padding(
              padding: EdgeInsets.all(AppSizes.gap),
              child: Align(
                alignment: Alignment.topCenter,
                child: PlusCard(
                  feature: PlusFeature.dayView,
                  text: 'The day-by-day view comes with Plus',
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.gap),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.parentColumn,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DayHeader(day: shown, today: today),
                      const SizedBox(height: AppSizes.gap),
                      ...switch (detail) {
                        AsyncData(:final value) => _cards(value, bank),
                        AsyncError(:final error) => [
                          Text(
                            'Could not load the day: $error',
                            style: StatsText.body,
                          ),
                        ],
                        _ => [const Center(child: CircularProgressIndicator())],
                      },
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _cards(DayDetail d, QuestionBank? bank) {
    final byId = bank?.byId ?? const <String, Question>{};
    return [
      _Summary(detail: d),
      const SizedBox(height: AppSizes.gap),
      if (d.rounds.isEmpty)
        const StatsCard(
          child: Text(
            'No answers on this day.',
            key: Key('day-empty'),
            style: StatsText.body,
          ),
        )
      else ...[
        _Topics(tallies: d.topics),
        const SizedBox(height: AppSizes.gap),
        StatsCard(
          key: const Key('day-rounds'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Rounds', style: StatsText.heading),
              for (final r in d.rounds) _RoundTile(round: r, byId: byId),
            ],
          ),
        ),
      ],
    ];
  }
}

class _DayHeader extends ConsumerWidget {
  const _DayHeader({required this.day, required this.today});

  final String day;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = ref.watch(firstDayProvider).value;
    Future<void> pick() async {
      final now = DateTime.parse(today);
      final firstDate = first == null
          ? DateTime(now.year - 1, now.month, now.day)
          : DateTime.parse(first);
      final current = DateTime.parse(day);
      final picked = await showDatePicker(
        context: context,
        initialDate: current.isBefore(firstDate) ? firstDate : current,
        firstDate: current.isBefore(firstDate) ? current : firstDate,
        lastDate: now,
      );
      if (picked != null && context.mounted) {
        context.go(Routes.day(dayKey(picked)));
      }
    }

    return Row(
      children: [
        IconButton(
          key: const Key('day-prev'),
          tooltip: 'Day before',
          onPressed: () => context.go(Routes.day(shiftDay(day, -1))),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: TextButton.icon(
            key: const Key('day-pick'),
            onPressed: pick,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              day == today ? 'Today, ${dayLabel(day)}' : dayLabel(day),
              textAlign: TextAlign.center,
              style: StatsText.heading,
            ),
          ),
        ),
        IconButton(
          key: const Key('day-next'),
          tooltip: 'Day after',
          onPressed: day.compareTo(today) >= 0
              ? null
              : () => context.go(Routes.day(shiftDay(day, 1))),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.detail});

  final DayDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = detail.tally;
    final minutes = (detail.secondsUsed / 60).round();
    return StatsCard(
      key: const Key('day-summary'),
      child: Wrap(
        spacing: AppSizes.gap * 2,
        runSpacing: AppSizes.gap / 2,
        children: [
          _Figure(label: 'answers', value: count(t), keyName: 'answers'),
          _Figure(label: 'right', value: pct(t), keyName: 'right'),
          _Figure(label: 'per question', value: secs(t), keyName: 'speed'),
          _Figure(
            label: 'screen time',
            value: '$minutes min',
            keyName: 'minutes',
          ),
          _Figure(
            label: 'rounds',
            value: '${detail.rounds.length}',
            keyName: 'round-count',
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.keyName,
  });

  final String label;
  final String value;
  final String keyName;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value, key: Key('day-$keyName'), style: StatsText.big),
      Text(label, style: StatsText.muted),
    ],
  );
}

class _Topics extends StatelessWidget {
  const _Topics({required this.tallies});

  final Map<String, Tally> tallies;

  @override
  Widget build(BuildContext context) {
    // Bank topic order, then any unknown id.
    final ids = [
      for (final t in topics)
        if (tallies.containsKey(t.id)) t.id,
      for (final id in tallies.keys)
        if (!topicsById.containsKey(id)) id,
    ];
    return StatsCard(
      key: const Key('day-topics'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Topics', style: StatsText.heading),
          for (final id in ids)
            Padding(
              key: Key('day-topic-$id'),
              padding: const EdgeInsets.only(top: AppSizes.gap / 2),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      topicsById[id]?.name ?? id,
                      style: StatsText.body,
                    ),
                  ),
                  for (final v in [
                    count(tallies[id]),
                    pct(tallies[id]),
                    secs(tallies[id]),
                  ])
                    Expanded(
                      child: Text(
                        v,
                        textAlign: TextAlign.end,
                        style: StatsText.body,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  const _RoundTile({required this.round, required this.byId});

  final DayRound round;
  final Map<String, Question> byId;

  @override
  Widget build(BuildContext context) {
    final r = round;
    final name = topicsById[r.topicId]?.name ?? 'Mixed revision';
    final result = r.finishedAt == null ? 'not finished' : '${r.score} right';
    final details = [
      if (r.revision) 'Revision',
      'Level ${r.level}',
      if (r.finishedAt != null) '${r.stars} ★',
      if (r.durationMs > 0) durationText(Duration(milliseconds: r.durationMs)),
    ].join(' · ');
    return ExpansionTile(
      key: Key('day-round-${r.id}'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppSizes.gap / 2),
      title: Text(
        '${_clockTime.format(r.startedAt)} · $name · $result',
        style: StatsText.body,
      ),
      subtitle: Text(details, style: StatsText.muted),
      children: [
        for (final (i, a) in r.answers.indexed)
          _AnswerRow(index: i, answer: a, question: byId[a.record.questionId]),
      ],
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.index,
    required this.answer,
    required this.question,
  });

  final int index;
  final DayAnswer answer;
  final Question? question;

  @override
  Widget build(BuildContext context) {
    final rec = answer.record;
    return Padding(
      key: Key('day-answer-$index'),
      padding: const EdgeInsets.only(top: AppSizes.gap / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            rec.correct ? Icons.check_circle : Icons.cancel,
            color: rec.correct ? AppColors.leaf : AppColors.berry,
            semanticLabel: rec.correct ? 'Right' : 'Wrong',
          ),
          const SizedBox(width: AppSizes.gap / 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question?.prompt ?? rec.questionId,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: StatsText.body,
                ),
                Text('Her answer: ${answer.given}', style: StatsText.muted),
                if (!rec.correct && question != null)
                  Text(
                    'Right answer: ${answerText(question!.answer)}',
                    style: StatsText.muted,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.gap / 2),
          Text(
            '${(rec.timeMs / 1000).toStringAsFixed(1)} s',
            style: StatsText.muted,
          ),
        ],
      ),
    );
  }
}
