import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/report.dart';
import 'package:number_ninja/domain/stats.dart';
import 'package:number_ninja/domain/topics.dart';
import 'package:number_ninja/features/parent/report_pdf.dart';

final now = DateTime(2026, 11, 15, 14, 5);

/// Answers in every topic, spread over the last 8 weeks.
List<AttemptRecord> full() => [
  for (final (i, t) in topics.indexed)
    for (var k = 0; k < 12; k++)
      AttemptRecord(
        questionId: '${t.id}-$k',
        topicId: t.id,
        correct: (k + i) % 3 != 0,
        timeMs: 3000 + 500 * i,
        answeredAt: now.subtract(Duration(days: 3 * k)),
      ),
];

/// Page objects in an uncompressed PDF (not the `/Pages` tree).
int pages(Uint8List bytes) =>
    RegExp(r'/Type\s*/Page(?![a-zA-Z])')
        .allMatches(latin1.decode(bytes))
        .length;

void expectPdf(Uint8List bytes) =>
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');

void main() {
  group('PDF file (AC-2)', () {
    test('a full report is a PDF of 2 or more pages', () async {
      final data = ReportData.build(full(), StatsPeriod.all, now);
      final bytes = await buildReportPdf(data, compress: false);
      expectPdf(bytes);
      expect(pages(bytes), greaterThanOrEqualTo(2));
      // The default, compressed file is valid too.
      expectPdf(await buildReportPdf(data));
    });

    test('an empty report is one page', () async {
      final data = ReportData.build(const [], StatsPeriod.days7, now);
      expect(data.isEmpty, isTrue);
      final bytes = await buildReportPdf(data, compress: false);
      expectPdf(bytes);
      expect(pages(bytes), 1);
    });

    test('all topics at 0 answers in the period, with older trends', () async {
      final old = [
        for (final r in full())
          if (r.answeredAt.isBefore(now.subtract(const Duration(days: 8)))) r,
      ];
      final data = ReportData.build(old, StatsPeriod.days7, now);
      expect(data.isEmpty, isTrue);
      expectPdf(await buildReportPdf(data, compress: false));
    });

    test('one track missing from the trends', () async {
      final noOly = [
        for (final r in full())
          if (topicsById[r.topicId]!.track != Track.olympiad) r,
      ];
      final data = ReportData.build(noOly, StatsPeriod.days30, now);
      expect(
        data.accuracyTrend[Track.olympiad]!.every((v) => v == null),
        isTrue,
      );
      final bytes = await buildReportPdf(data, compress: false);
      expectPdf(bytes);
      expect(pages(bytes), greaterThanOrEqualTo(2));
    });

    test('a single answer: trends with one point per line', () async {
      final one = [
        AttemptRecord(
          questionId: 'q',
          topicId: 'p1.bonds',
          correct: false,
          timeMs: 0,
          answeredAt: now,
        ),
      ];
      final data = ReportData.build(one, StatsPeriod.days7, now);
      expectPdf(await buildReportPdf(data, compress: false));
    });
  });
}
