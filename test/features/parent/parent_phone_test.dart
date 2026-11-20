import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/ui/theme.dart';

import '../../ui/layout_checks.dart';
import '../quiz/quiz_harness.dart';
import 'parent_harness.dart';

/// FEAT-19 AC-4..6: the parent pages on a phone.
void main() {
  late ParentHarness h;
  setUp(() async {
    h = ParentHarness();
    await h.setUp();
    await h.seed(numberTopic, [(1, true), (2, false)]);
  });
  tearDown(() => h.db.close());

  const portrait = Size(360, 640);
  const landscape = Size(640, 360);

  for (final dp in [portrait, landscape]) {
    final name = '${dp.width.toInt()} × ${dp.height.toInt()}';

    testWidgets('$name: every PIN key in view (SCR-08)', (tester) async {
      await h.pumpApp(tester, location: Routes.pinEntry, size: physical(dp));
      expect(tester.takeException(), isNull);
      for (final k in ['pin-1', 'pin-3', 'pin-0', 'pin-back']) {
        expectInView(tester, k);
      }
      expectNoOverlap(tester, ['screen-message', 'pin-dots', 'pin-1']);
    });

    testWidgets('$name: every PIN key in view (change PIN)', (tester) async {
      await h.openParent(tester, Routes.changePin, size: physical(dp));
      for (final k in ['pin-1', 'pin-0', 'pin-back']) {
        expectInView(tester, k);
      }
    });

    testWidgets('$name: Done fits the app bar (SCR-11)', (tester) async {
      await h.openParent(tester, Routes.parent, size: physical(dp));
      final done = tester.getSize(find.byKey(const Key('parent-done')));
      expect(done.height, lessThanOrEqualTo(56));
      expect(done.width, lessThan(AppSizes.minTap * 3));
    });

    testWidgets('$name: track cards fill the width (SCR-09)', (tester) async {
      await h.openParent(tester, Routes.dashboard, size: physical(dp));
      expectNoOverlap(tester, ['track-p1', 'track-p2', 'track-olympiad']);
      final p1 = tester.getRect(find.byKey(const Key('track-p1')));
      final p2 = tester.getRect(find.byKey(const Key('track-p2')));
      final oly = tester.getRect(find.byKey(const Key('track-olympiad')));
      expect(p1.left, AppSizes.gap);
      if (dp == portrait) {
        // Two to a row, reaching the page's padding on the right.
        expect(dp.width - p2.right, lessThanOrEqualTo(AppSizes.gap + 1));
        expect(oly.top, greaterThan(p1.bottom));
      } else {
        expect(oly.top, p1.top, reason: 'three in a row');
      }
    });
  }

  testWidgets('1280 × 800: tablet keeps its Done button and cards', (
    tester,
  ) async {
    await h.openParent(tester, Routes.parent, size: physical(scaledSize));
    final done = tester.getSize(find.byKey(const Key('parent-done')));
    expect(done.width, greaterThanOrEqualTo(AppSizes.minTap * 3));
    await h.openParent(tester, Routes.dashboard, size: physical(scaledSize));
    expect(
      tester.getSize(find.byKey(const Key('track-p1'))).width,
      AppSizes.minTap * 3,
    );
  });

  testWidgets('topic rows start at the card edge (SCR-15)', (tester) async {
    await h.openParent(tester, Routes.topicLocks, size: physical(portrait));
    final row = tester.getRect(find.byKey(const Key('lock-row-p1.place')));
    final icon = tester.getRect(find.byKey(const Key('lock-icon-p1.place')));
    expect(icon.left - row.left, lessThan(1));
  });
}
