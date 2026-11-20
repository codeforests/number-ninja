import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/daily.dart';
import '../../domain/stats.dart';
import '../../domain/topics.dart';
import '../../ui/layout.dart';
import '../family/child_switcher.dart';
import '../../ui/theme.dart';
import 'day_screen.dart';
import 'report_export.dart';
import 'stats_view.dart';

/// SCR-09: accuracy, speed and attempts per track and topic for a period
/// (PAR-05), weekly trends per track (PAR-06) and needs practice (PAR-07).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, this.period = StatsPeriod.days30});

  final StatsPeriod period;

  /// From this width (landscape), the table sits beside the rest.
  static const wideFrom = 900.0;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late StatsPeriod _period = widget.period;
  bool _exporting = false;

  /// Exports the period shown (FEAT-07).
  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _exporting = true);
    final ok = await exportReport(ref, _period);
    if (!mounted) return;
    setState(() => _exporting = false);
    if (!ok) showReportFailed(messenger);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(statsDataProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-parent'),
          tooltip: 'Back',
          onPressed: () => context.go(Routes.parent),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Progress'),
        actions: [
          const ChildSwitcher(),
          IconButton(
            key: const Key('export-pdf'),
            tooltip: 'Export PDF',
            onPressed: _exporting || data is! AsyncData ? null : _export,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: switch (data) {
        AsyncData(:final value) => _body(context, value),
        AsyncError(:final error) => Center(
          child: Text('Could not load stats: $error', style: StatsText.body),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(BuildContext context, StatsData data) {
    final picker = Align(
      alignment: Alignment.centerLeft,
      child: PeriodPicker(
        value: _period,
        onChanged: (p) => setState(() => _period = p),
      ),
    );
    if (data.all.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSizes.gap),
        children: [
          picker,
          const SizedBox(height: AppSizes.gap * 2),
          const Center(
            child: Text(
              'No answers yet. Stats appear after her first round.',
              key: Key('stats-empty'),
              textAlign: TextAlign.center,
              style: StatsText.heading,
            ),
          ),
        ],
      );
    }
    final rs = data.inPeriod(_period);
    final topicTallies = byTopic(rs);
    final tracks = byTrack(rs);
    final needsList = needsPractice(topicTallies, overall(rs));
    final needs = needsList.toSet();

    void open(String topicId) =>
        context.go(Routes.topicDetail(topicId, _period));

    final left = <Widget>[
      picker,
      const SizedBox(height: AppSizes.gap),
      _TrackSummary(tracks: tracks),
      const SizedBox(height: AppSizes.gap),
      _DailyCard(days: recentDays(data.all)),
      const SizedBox(height: AppSizes.gap),
      _NeedsPractice(ids: needsList, tallies: topicTallies, onOpen: open),
      const SizedBox(height: AppSizes.gap),
      StatsCard(
        child: TrendCharts(
          now: data.now,
          lines: [
            for (final t in Track.values)
              (
                trackNames[t]!,
                trackColors[t]!,
                [
                  for (final r in data.all)
                    if (topicsById[r.topicId]?.track == t) r,
                ],
              ),
          ],
        ),
      ),
    ];
    final table = _TopicTable(
      tallies: topicTallies,
      needs: needs,
      onOpen: open,
    );

    return LayoutBuilder(
      builder: (context, c) {
        final wide =
            c.maxWidth >= DashboardScreen.wideFrom && c.maxWidth > c.maxHeight;
        if (!wide) {
          return ListView(
            key: const Key('dashboard-list'),
            padding: const EdgeInsets.all(AppSizes.gap),
            children: [
              ...left,
              const SizedBox(height: AppSizes.gap),
              table,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.gap),
                children: left,
              ),
            ),
            Expanded(
              child: ListView(
                key: const Key('dashboard-table'),
                padding: const EdgeInsets.all(AppSizes.gap),
                children: [table],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrackSummary extends StatelessWidget {
  const _TrackSummary({required this.tracks});

  final Map<Track, Tally> tracks;

  /// A card's width when the three fit in a row.
  static const cardWidth = AppSizes.minTap * 3;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      // Too narrow for three (a phone): two to a row, filling the width
      // (FEAT-19).
      const gap = AppSizes.gap;
      final width =
          c.maxWidth >= cardWidth * 3 + gap * 2 ||
              !compact(MediaQuery.sizeOf(context))
          ? cardWidth
          : (c.maxWidth - gap) / 2;
      return _cards(width);
    },
  );

  Widget _cards(double width) => Wrap(
    spacing: AppSizes.gap,
    runSpacing: AppSizes.gap,
    children: [
      for (final t in Track.values)
        SizedBox(
          width: width,
          child: StatsCard(
            key: Key('track-${t.name}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: AppSizes.gap,
                      height: AppSizes.gap,
                      decoration: BoxDecoration(
                        color: trackColors[t],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSizes.gap / 2),
                    Flexible(
                      child: Text(trackNames[t]!, style: StatsText.heading),
                    ),
                  ],
                ),
                Text(pct(tracks[t]), style: StatsText.big),
                Text('${secs(tracks[t])} avg', style: StatsText.muted),
                Text('${count(tracks[t])} answers', style: StatsText.muted),
              ],
            ),
          ),
        ),
    ],
  );
}

/// The latest days with answers, each opening SCR-16 (PAR-11).
class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.days});

  final List<({String day, Tally tally})> days;

  @override
  Widget build(BuildContext context) => StatsCard(
    key: const Key('daily-card'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSizes.gap,
          children: [
            const Text('By day', style: StatsText.heading),
            TextButton.icon(
              key: const Key('open-day'),
              onPressed: () => context.go(Routes.dayToday),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Pick a day', style: StatsText.body),
            ),
          ],
        ),
        for (final d in days)
          ListTile(
            key: Key('daily-${d.day}'),
            contentPadding: EdgeInsets.zero,
            title: Text(dayLabel(d.day), style: StatsText.body),
            subtitle: Text(
              '${count(d.tally)} answers · ${pct(d.tally)} right · '
              '${secs(d.tally)} avg',
              style: StatsText.muted,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.day(d.day)),
          ),
      ],
    ),
  );
}

class _NeedsPractice extends StatelessWidget {
  const _NeedsPractice({
    required this.ids,
    required this.tallies,
    required this.onOpen,
  });

  final List<String> ids;
  final Map<String, Tally> tallies;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => StatsCard(
    key: const Key('needs-practice'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Needs practice', style: StatsText.heading),
        if (ids.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSizes.gap / 2),
            child: Text(
              'Nothing yet. Needs 10+ answers in a topic.',
              style: StatsText.muted,
            ),
          ),
        for (final id in ids)
          ListTile(
            key: Key('needs-$id'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag, color: AppColors.berry),
            title: Text(topicsById[id]!.name, style: StatsText.body),
            subtitle: Text(
              '${pct(tallies[id])} right · ${secs(tallies[id])} avg',
              style: StatsText.muted,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onOpen(id),
          ),
      ],
    ),
  );
}

class _TopicTable extends StatelessWidget {
  const _TopicTable({
    required this.tallies,
    required this.needs,
    required this.onOpen,
  });

  final Map<String, Tally> tallies;
  final Set<String> needs;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => StatsCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Topics', style: StatsText.heading),
        for (final track in Track.values) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.gap),
            child: Text(
              trackNames[track]!,
              style: StatsText.heading.copyWith(color: trackColors[track]),
            ),
          ),
          for (final t in topics.where((t) => t.track == track))
            _TopicRow(
              topic: t,
              tally: tallies[t.id],
              flagged: needs.contains(t.id),
              onTap: () => onOpen(t.id),
            ),
        ],
      ],
    ),
  );
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.tally,
    required this.flagged,
    required this.onTap,
  });

  final Topic topic;
  final Tally? tally;
  final bool flagged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: Key('topic-row-${topic.id}'),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.gap / 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    topic.name,
                    style: StatsText.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (flagged)
                  const Padding(
                    padding: EdgeInsets.only(left: AppSizes.gap / 4),
                    child: Icon(
                      Icons.flag,
                      key: Key('flag'),
                      color: AppColors.berry,
                      size: AppText.small,
                    ),
                  ),
              ],
            ),
          ),
          for (final v in [pct(tally), secs(tally), count(tally)])
            Expanded(
              child: Text(v, textAlign: TextAlign.end, style: StatsText.body),
            ),
        ],
      ),
    ),
  );
}
