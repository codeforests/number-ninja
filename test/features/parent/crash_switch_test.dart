import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/crash_repository.dart';
import 'package:number_ninja/domain/crash.dart';
import 'package:number_ninja/ui/theme.dart';

import '../../ui/layout_checks.dart';
import 'parent_harness.dart';

/// FEAT-24 AC-5 (CRS-05): "Send crash reports" on SCR-11.
void main() {
  late ParentHarness h;
  const key = 'crash-reports-switch';
  final finder = find.byKey(const Key(key));

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  Future<void> show(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('on for a fresh install; off deletes unsent reports and stays '
      'off after a restart', (tester) async {
    final repo = CrashRepository(h.db);
    await repo.record(
      CrashEntry(
        type: 'StateError',
        message: 'x',
        stack: '#0 f',
        screen: '/',
        at: h.now,
      ),
      const CrashInfo(appVersion: '1', os: 'a', device: 'b'),
      1,
    );
    await h.openParent(tester, Routes.parent);
    await show(tester);
    expect(tester.widget<SwitchListTile>(finder).value, isTrue);

    await h.tapKey(tester, key);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(finder).value, isFalse);
    expect(await repo.enabled(), isFalse);
    expect(await repo.all(), isEmpty);

    // A restart reads the saved setting.
    await tester.pumpWidget(const SizedBox());
    await h.openParent(tester, Routes.parent);
    await show(tester);
    expect(tester.widget<SwitchListTile>(finder).value, isFalse);

    await h.tapKey(tester, key);
    await tester.pumpAndSettle();
    expect(await repo.enabled(), isTrue);
  });

  for (final dp in layoutSizes) {
    testWidgets('fits at ${dp.width.toInt()} × ${dp.height.toInt()} '
        '(NFR-09, NFR-17)', (tester) async {
      await h.openParent(tester, Routes.parent, size: physical(dp));
      await show(tester);
      expectNoOverlap(tester, [key]);
      expect(
        tester.getSize(finder).height,
        greaterThanOrEqualTo(AppSizes.minTap),
      );
    });
  }

  testWidgets('fits at text scale $scaledText', (tester) async {
    setTextScale(tester, scaledText);
    await h.openParent(tester, Routes.parent, size: physical(scaledSize));
    await show(tester);
    expectNoOverlap(tester, [key]);
  });
}
