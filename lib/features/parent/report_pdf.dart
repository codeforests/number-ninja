import 'dart:typed_data';

import 'package:material_ui/material_ui.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/report.dart';
import '../../domain/topics.dart';
import '../../ui/theme.dart';

/// A theme colour as a PDF colour (no colour literals in the report).
PdfColor pdfColor(Color c) => PdfColor.fromInt(c.toARGB32());

const _trackColors = {
  Track.p1: AppColors.trackP1,
  Track.p2: AppColors.trackP2,
  Track.olympiad: AppColors.trackOly,
};

final _ink = pdfColor(AppColors.ink);
final _muted = pdfColor(AppColors.muted);
final _grid = pdfColor(AppColors.chartGrid);

final _title = pw.TextStyle(
  fontSize: AppPdf.title,
  fontWeight: pw.FontWeight.bold,
  color: _ink,
);
final _heading = pw.TextStyle(
  fontSize: AppPdf.heading,
  fontWeight: pw.FontWeight.bold,
  color: _ink,
);
final _body = pw.TextStyle(fontSize: AppPdf.body, color: _ink);
final _bold = _body.copyWith(fontWeight: pw.FontWeight.bold);
final _small = pw.TextStyle(fontSize: AppPdf.small, color: _muted);

/// The PDF progress report for [data] (PAR-09): A4 portrait, flows onto
/// more pages as needed. [compress] is off only in tests, to count pages.
Future<Uint8List> buildReportPdf(ReportData data, {bool compress = true}) {
  final doc = pw.Document(
    compress: compress,
    title: data.title,
    creator: 'Number Ninja',
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(AppPdf.margin),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Number Ninja - page ${ctx.pageNumber} of ${ctx.pagesCount}',
          style: _small,
        ),
      ),
      build: (ctx) => [
        pw.Text(data.title, style: _title),
        pw.SizedBox(height: AppPdf.gap / 2),
        pw.Text(data.periodLine, style: _body),
        pw.Text(data.createdLine, style: _small),
        pw.SizedBox(height: AppPdf.gap),
        if (data.isEmpty)
          pw.Text('No answers in this period.', style: _heading)
        else ...[
          ..._section('By track'),
          _table(
            const ['Track', 'Accuracy', 'Avg time', 'Answers'],
            [
              for (final r in data.tracks)
                [r.label, r.accuracy, r.avgTime, r.answers],
            ],
          ),
          ..._section('Needs practice'),
          if (data.needsPractice.isEmpty)
            pw.Text('Nothing yet. Needs 10+ answers in a topic.', style: _body)
          else
            _table(
              const ['Topic', 'Track', 'Accuracy', 'Avg time'],
              [
                for (final r in data.needsPractice)
                  [r.label, r.trackLabel, r.accuracy, r.avgTime],
              ],
            ),
          // A heading and its chart stay on one page.
          _keep([
            ..._section('Accuracy, last 8 weeks'),
            _chart(data, data.accuracyTrend, maxY: 100, unit: ' %'),
          ]),
          _keep([
            ..._section('Seconds per question, last 8 weeks'),
            _chart(data, data.speedTrend, unit: ' s'),
          ]),
          ..._section('Topics'),
          pw.Text(
            '! = needs practice: 10+ answers and below 70 % or slower than '
            'average.',
            style: _small,
          ),
          for (final tr in Track.values) ...[
            pw.SizedBox(height: AppPdf.gap / 2),
            pw.Text(reportTrackNames[tr]!, style: _bold),
            pw.SizedBox(height: AppPdf.gap / 4),
            _table(
              const ['Topic', 'Accuracy', 'Avg time', 'Answers', ''],
              [
                for (final r in data.topics)
                  if (r.track == tr)
                    [
                      r.label,
                      r.accuracy,
                      r.avgTime,
                      r.answers,
                      if (r.flagged) '!' else '',
                    ],
              ],
            ),
          ],
        ],
      ],
    ),
  );
  return doc.save();
}

/// Children that MultiPage moves to the next page as one block. A bare
/// Column is a SpanningWidget, so MultiPage would split it.
pw.Widget _keep(List<pw.Widget> children) => pw.Inseparable(
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: children,
  ),
);

List<pw.Widget> _section(String title) => [
  pw.SizedBox(height: AppPdf.gap),
  pw.Text(title, style: _heading),
  pw.SizedBox(height: AppPdf.gap / 2),
];

pw.Widget _table(List<String> headers, List<List<String>> rows) =>
    pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: _bold,
      cellStyle: _body,
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(AppPdf.cellPadding),
      columnWidths: {0: const pw.FlexColumnWidth(3)},
      defaultColumnWidth: const pw.FlexColumnWidth(),
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _grid),
        bottom: pw.BorderSide(color: _grid),
      ),
      headerDecoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _muted)),
      ),
    );

/// A line chart, one line per track, a gap for each empty week. Points sit
/// in the middle of equal week slots so the labels below line up.
pw.Widget _chart(
  ReportData data,
  Map<Track, List<double?>> series, {
  double? maxY,
  String unit = '',
}) {
  var top = maxY ?? 0;
  if (maxY == null) {
    for (final vs in series.values) {
      for (final v in vs) {
        if (v != null && v > top) top = v;
      }
    }
    top = top <= 0 ? 10 : (top * 1.15).ceilToDouble();
  }
  final n = data.weeks.length;

  void paint(PdfGraphics g, PdfPoint size) {
    final w = size.x, h = size.y;
    double x(int i) => (i + 0.5) * w / n;
    double y(double v) => (v / top).clamp(0, 1) * h;

    g
      ..setStrokeColor(_grid)
      ..setLineWidth(AppPdf.gridLine);
    for (final f in const [0.0, 0.5, 1.0]) {
      g
        ..drawLine(0, f * h, w, f * h)
        ..strokePath();
    }
    for (final MapEntry(key: tr, value: vs) in series.entries) {
      final c = pdfColor(_trackColors[tr]!);
      g
        ..setStrokeColor(c)
        ..setFillColor(c)
        ..setLineWidth(AppPdf.chartLine);
      var drawing = false;
      for (var i = 0; i < vs.length && i < n; i++) {
        final v = vs[i];
        if (v == null) {
          drawing = false;
          continue;
        }
        if (drawing) {
          g.lineTo(x(i), y(v));
        } else {
          g.moveTo(x(i), y(v));
          drawing = true;
        }
      }
      g.strokePath();
      for (var i = 0; i < vs.length && i < n; i++) {
        final v = vs[i];
        if (v == null) continue;
        g
          ..drawEllipse(x(i), y(v), AppPdf.chartDot, AppPdf.chartDot)
          ..fillPath();
      }
    }
  }

  String axis(double v) => '${v.round()}$unit';

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: AppPdf.axisWidth,
            height: AppPdf.chartHeight,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(axis(top), style: _small),
                pw.Text(axis(top / 2), style: _small),
                pw.Text(axis(0), style: _small),
              ],
            ),
          ),
          pw.SizedBox(width: AppPdf.axisGap),
          pw.Expanded(
            child: pw.SizedBox(
              height: AppPdf.chartHeight,
              child: pw.CustomPaint(
                size: const PdfPoint(double.infinity, AppPdf.chartHeight),
                painter: paint,
              ),
            ),
          ),
        ],
      ),
      pw.Row(
        children: [
          pw.SizedBox(width: AppPdf.axisWidth + AppPdf.axisGap),
          for (final l in data.weekLabels)
            pw.Expanded(
              child: pw.Text(l, style: _small, textAlign: pw.TextAlign.center),
            ),
        ],
      ),
      pw.SizedBox(height: AppPdf.gap / 4),
      pw.Row(
        children: [
          pw.SizedBox(width: AppPdf.axisWidth + AppPdf.axisGap),
          for (final tr in Track.values) ...[
            pw.Container(
              width: AppPdf.swatchWidth,
              height: AppPdf.swatchHeight,
              color: pdfColor(_trackColors[tr]!),
            ),
            pw.SizedBox(width: AppPdf.axisGap),
            pw.Text(reportTrackNames[tr]!, style: _small),
            pw.SizedBox(width: AppPdf.gap),
          ],
        ],
      ),
    ],
  );
}
