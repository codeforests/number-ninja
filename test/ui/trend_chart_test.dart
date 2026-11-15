import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/ui/theme.dart';
import 'package:number_ninja/ui/trend_chart.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget chart, {double width = 600}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(width: width, child: chart),
            ),
          ),
        ),
      );

  final labels = [for (var i = 0; i < 8; i++) '${i + 1} Nov'];

  testWidgets('paints 3 series with gaps and shows the legend (T4)', (
    tester,
  ) async {
    await pump(
      tester,
      TrendChart(
        key: const Key('chart'),
        title: 'Accuracy',
        maxY: 100,
        unit: '%',
        xLabels: labels,
        series: const [
          TrendSeries(
            label: 'P1',
            color: AppColors.trackP1,
            values: [null, 50, 60, null, 80, 90, null, 100],
          ),
          TrendSeries(
            label: 'P2',
            color: AppColors.trackP2,
            values: [null, null, null, null, null, null, null, 40],
          ),
          TrendSeries(
            label: 'Olympiad',
            color: AppColors.trackOly,
            values: [null, null, null, null, null, null, null, null],
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Accuracy'), findsOneWidget);
    for (final l in ['P1', 'P2', 'Olympiad']) {
      expect(find.text(l), findsOneWidget);
    }
    expect(
      find.descendant(
        of: find.byKey(const Key('chart')),
        matching: find.byType(CustomPaint),
      ),
      findsWidgets,
    );
  });

  testWidgets('fits the data when no maxY, narrow and all-empty', (
    tester,
  ) async {
    for (final values in [
      <double?>[2.5, 7.1, null, 130],
      <double?>[null, null],
      <double?>[],
    ]) {
      await pump(
        tester,
        TrendChart(
          title: 'Seconds',
          unit: ' s',
          xLabels: [for (var i = 0; i < values.length; i++) 'w$i'],
          series: [
            TrendSeries(label: 'P1', color: AppColors.trackP1, values: values),
          ],
        ),
        width: 200,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
