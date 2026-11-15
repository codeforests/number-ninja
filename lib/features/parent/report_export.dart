import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:printing/printing.dart';

import '../../domain/report.dart';
import '../../domain/stats.dart';
import '../../ui/theme.dart';
import 'report_pdf.dart';
import 'stats_view.dart';

/// Hands a finished PDF to the platform (PAR-09).
typedef ReportSharer = Future<void> Function(Uint8List bytes, String filename);

/// Android's share sheet by default; tests override it to capture the file.
final reportSharerProvider = Provider<ReportSharer>(
  (ref) => (bytes, filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  },
);

const reportFailedMessage = "Couldn't create the report";

/// Builds the report for [period] from [statsDataProvider] and shares it.
/// Returns false if anything failed (nothing is shared then). The caller
/// keeps [statsDataProvider] watched while this runs.
Future<bool> exportReport(WidgetRef ref, StatsPeriod period) async {
  final share = ref.read(reportSharerProvider);
  final stats = ref.read(statsDataProvider.future);
  try {
    final data = await stats;
    final report = ReportData.build(data.all, period, data.now);
    final bytes = await buildReportPdf(report);
    await share(bytes, reportFileName(period, data.now));
    return true;
  } catch (e, s) {
    debugPrint('Report export failed: $e\n$s');
    return false;
  }
}

void showReportFailed(ScaffoldMessengerState messenger) =>
    messenger.showSnackBar(const SnackBar(content: Text(reportFailedMessage)));

/// The SCR-11 export sheet: period picker and "Create and share".
class ExportSheet extends ConsumerStatefulWidget {
  const ExportSheet({super.key});

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  StatsPeriod _period = StatsPeriod.days30;
  bool _busy = false;

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    final ok = await exportReport(ref, _period);
    if (!mounted) return;
    nav.pop();
    if (!ok) showReportFailed(messenger);
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the stats loaded while the sheet is open.
    ref.watch(statsDataProvider);
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('export-sheet'),
        padding: const EdgeInsets.all(AppSizes.gap * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export PDF report', style: StatsText.heading),
            const SizedBox(height: AppSizes.gap / 2),
            const Text(
              'Tracks, needs practice, 8-week trends and every topic.',
              style: StatsText.muted,
            ),
            const SizedBox(height: AppSizes.gap),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: PeriodPicker(
                value: _period,
                onChanged: (p) => setState(() => _period = p),
              ),
            ),
            const SizedBox(height: AppSizes.gap * 1.5),
            SizedBox(
              height: AppSizes.minTap,
              child: FilledButton.icon(
                key: const Key('export-share'),
                onPressed: _busy ? null : _export,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: AppText.parentBody,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share),
                label: const Text('Create and share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens [ExportSheet] over SCR-11.
Future<void> showExportSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ExportSheet(),
    );
