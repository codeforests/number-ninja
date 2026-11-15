import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/features/parent/dashboard_screen.dart';
import 'package:number_ninja/features/parent/report_export.dart';

import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

/// AC-4 (SCR-11 export sheet) and AC-5 (SCR-09 export action), PAR-09.
void main() {
  late ParentHarness h;
  late List<(Uint8List, String)> shared;
  late ReportSharer sharer;
  setUp(() async {
    h = ParentHarness();
    await h.setUp();
    shared = [];
    sharer = (bytes, name) async => shared.add((bytes, name));
    h.more = [
      ...h.more,
      reportSharerProvider.overrideWithValue((b, n) => sharer(b, n)),
    ];
    await h.seed(numberTopic, [
      for (var i = 1; i <= 10; i++) (i, i <= 3),
    ], daysAgo: 3);
  });
  tearDown(() => h.db.close());

  void expectPdf(Uint8List bytes) =>
      expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');

  testWidgets('SCR-11: export tile, 7 days, Create and share (AC-4)', (
    tester,
  ) async {
    await h.openParent(tester, '/parent');
    await h.tapKey(tester, 'export-report');
    expect(find.byKey(const Key('export-sheet')), findsOneWidget);
    await h.tapKey(tester, 'period-7');
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('export-share')));
      // PDF building is real async work; let it finish outside fake time.
      for (var i = 0; i < 250 && shared.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    expect(shared, hasLength(1));
    expectPdf(shared.single.$1);
    final y = h.now.year.toString();
    final m = h.now.month.toString().padLeft(2, '0');
    final d = h.now.day.toString().padLeft(2, '0');
    expect(shared.single.$2, 'number-ninja-report-$y-$m-$d-7d.pdf');
    expect(find.byKey(const Key('export-sheet')), findsNothing);
    expect(find.text(reportFailedMessage), findsNothing);
  });

  testWidgets('a sharer that throws shows the error (AC-4)', (tester) async {
    sharer = (bytes, name) async => throw Exception('no share sheet');
    await h.openParent(tester, '/parent');
    await h.tapKey(tester, 'export-report');
    var done = false;
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('export-share')));
      for (var i = 0; i < 250 && !done; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
        done = find.text(reportFailedMessage).evaluate().isNotEmpty;
      }
    });
    await tester.pump();
    expect(find.text(reportFailedMessage), findsOneWidget);
    expect(shared, isEmpty);
  });

  testWidgets('SCR-09: All time, then export-pdf shares -all (AC-5)', (
    tester,
  ) async {
    await h.openParent(tester, '/parent');
    await h.tapKey(tester, 'open-dashboard');
    expect(find.byType(DashboardScreen), findsOneWidget);
    await h.tapKey(tester, 'period-all');
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('export-pdf')));
      for (var i = 0; i < 250 && shared.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    expect(shared, hasLength(1));
    expectPdf(shared.single.$1);
    expect(shared.single.$2, endsWith('-all.pdf'));
    expect(find.text(reportFailedMessage), findsNothing);
  });
}
