import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/stats.dart';
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
import '../../ui/trend_chart.dart';

/// Every attempt (joined to the bank) and the time it was read, for SCR-09
/// and SCR-10. Auto-disposed, so opening a screen re-reads it.
class StatsData {
  StatsData({required this.now, required this.all});

  final DateTime now;
  final List<AttemptRecord> all;

  List<AttemptRecord> inPeriod(StatsPeriod p, {String? topicId}) => [
    for (final r in all)
      if (p.includes(r.answeredAt, now) &&
          (topicId == null || r.topicId == topicId))
        r,
  ];
}

final statsDataProvider = FutureProvider.autoDispose<StatsData>((ref) async {
  final stats = await ref.watch(statsRepositoryProvider.future);
  final now = ref.watch(clockProvider)();
  return StatsData(now: now, all: await stats.records());
});

const trackNames = {Track.p1: 'P1', Track.p2: 'P2', Track.olympiad: 'Olympiad'};

const trackColors = {
  Track.p1: AppColors.trackP1,
  Track.p2: AppColors.trackP2,
  Track.olympiad: AppColors.trackOly,
};

String pct(Tally? t) {
  final a = t?.accuracy;
  return a == null ? '–' : '${(a * 100).round()} %';
}

String secs(Tally? t) {
  final s = t?.avgSeconds;
  return s == null ? '–' : '${s.toStringAsFixed(1)} s';
}

String count(Tally? t) => t == null || t.attempts == 0 ? '–' : '${t.attempts}';

final _weekLabel = DateFormat('d MMM');

/// The accuracy and speed charts for [lines] (label, colour, records) over
/// the last 8 weeks (PAR-06).
class TrendCharts extends StatelessWidget {
  const TrendCharts({super.key, required this.now, required this.lines});

  final DateTime now;
  final List<(String, Color, List<AttemptRecord>)> lines;

  @override
  Widget build(BuildContext context) {
    final trends = [
      for (final (label, color, rs) in lines)
        (label, color, weeklyTrend(rs, now)),
    ];
    final weeks = trends.isEmpty ? weeklyTrend(const [], now) : trends.first.$3;
    final xLabels = [for (final w in weeks) _weekLabel.format(w.weekStart)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrendChart(
          key: const Key('trend-accuracy'),
          title: 'Accuracy per week',
          maxY: 100,
          unit: '%',
          xLabels: xLabels,
          series: [
            for (final (label, color, points) in trends)
              TrendSeries(
                label: label,
                color: color,
                values: [
                  for (final p in points)
                    p.tally?.accuracy == null ? null : p.tally!.accuracy! * 100,
                ],
              ),
          ],
        ),
        const SizedBox(height: AppSizes.gap * 1.5),
        TrendChart(
          key: const Key('trend-speed'),
          title: 'Seconds per question',
          unit: ' s',
          xLabels: xLabels,
          series: [
            for (final (label, color, points) in trends)
              TrendSeries(
                label: label,
                color: color,
                values: [for (final p in points) p.tally?.avgSeconds],
              ),
          ],
        ),
      ],
    );
  }
}

/// A rounded white card for parent screens.
class StatsCard extends StatelessWidget {
  const StatsCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.card,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.button),
    ),
    child: Padding(padding: const EdgeInsets.all(AppSizes.gap), child: child),
  );
}

/// Parent-screen text styles from the theme sizes.
abstract final class StatsText {
  static const heading = TextStyle(
    fontSize: AppText.small,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontSize: AppText.parentBody,
    color: AppColors.ink,
  );
  static const muted = TextStyle(
    fontSize: AppText.parentBody,
    color: AppColors.muted,
  );
  static const big = TextStyle(
    fontSize: AppText.heading,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );
}

/// The period picker (PAR-05).
class PeriodPicker extends StatelessWidget {
  const PeriodPicker({super.key, required this.value, required this.onChanged});

  final StatsPeriod value;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<StatsPeriod>(
    showSelectedIcon: false,
    segments: [
      for (final p in StatsPeriod.values)
        ButtonSegment(
          value: p,
          label: Text(
            p.label,
            key: Key('period-${p.query}'),
            style: StatsText.body,
          ),
        ),
    ],
    selected: {value},
    onSelectionChanged: (s) => onChanged(s.single),
  );
}
