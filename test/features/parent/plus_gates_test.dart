import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/plus.dart';
import 'package:number_ninja/domain/stats.dart';
import 'package:number_ninja/features/parent/plus_screen.dart';
import 'package:number_ninja/features/parent/stats_view.dart';

import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

/// FEAT-30 AC-3 (parent half): free hides the Plus parts of SCR-09, SCR-10,
/// SCR-11 and SCR-16 behind Plus cards; with Plus they show as before.
void main() {
  late ParentHarness h;
  setUp(() async {
    h = ParentHarness();
    await h.setUp();
    await h.seed(numberTopic, [for (var i = 1; i <= 6; i++) (i, i <= 2)]);
  });
  tearDown(() => h.db.close());

  Finder card(PlusFeature f) => find.byKey(Key('plus-card-${f.name}'));

  for (final plus in [false, true]) {
    final on = plus ? 'Plus' : 'free';

    testWidgets('$on: SCR-09 day card, trends and PDF export', (tester) async {
      h.plus = plus;
      await h.openParent(tester, Routes.dashboard);
      expect(
        find.byKey(const Key('daily-card')),
        plus ? findsOne : findsNothing,
      );
      expect(
        find.byKey(const Key('export-pdf')),
        plus ? findsOne : findsNothing,
      );
      await tester.scrollUntilVisible(
        plus ? find.byType(TrendCharts) : card(PlusFeature.trends),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(card(PlusFeature.dayView), plus ? findsNothing : findsOne);
      expect(card(PlusFeature.trends), plus ? findsNothing : findsOne);
    });

    testWidgets('$on: SCR-10 weak types and trends', (tester) async {
      h.plus = plus;
      await h.openParent(
        tester,
        Routes.topicDetail(numberTopic, StatsPeriod.all),
      );
      expect(
        find.byKey(const Key('weak-types')),
        plus ? findsOne : findsNothing,
      );
      expect(find.byType(TrendCharts), plus ? findsOne : findsNothing);
      expect(card(PlusFeature.trends), plus ? findsNothing : findsOne);
    });

    testWidgets('$on: SCR-16 day view', (tester) async {
      h.plus = plus;
      await h.openParent(tester, Routes.dayToday);
      expect(card(PlusFeature.dayView), plus ? findsNothing : findsOne);
    });

    testWidgets('$on: SCR-11 PDF and bank rows', (tester) async {
      h.plus = plus;
      await h.openParent(tester, Routes.parent);
      final pdf = tester.widget<Text>(find.byKey(const Key('export-subtitle')));
      expect(
        pdf.data,
        plus ? 'Share or save a summary' : 'PDF reports come with Plus',
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('bank-status')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final bank = tester.widget<Text>(find.byKey(const Key('bank-status')));
      expect(bank.data!.endsWith('Question updates come with Plus'), !plus);
    });
  }

  testWidgets('free: SCR-11 PDF row opens SCR-20', (tester) async {
    h.plus = false;
    await h.openParent(tester, Routes.parent);
    await h.tapKey(tester, 'export-report');
    expect(find.byType(PlusScreen), findsOneWidget);
  });
}
