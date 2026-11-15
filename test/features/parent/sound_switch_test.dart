import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/usage_repository.dart';

import 'parent_harness.dart';

/// FEAT-09 AC-2 (PRC-11): the sound switch on SCR-11.
void main() {
  late ParentHarness h;

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  testWidgets('the switch shows the setting and saves a change', (
    tester,
  ) async {
    await h.openParent(tester, Routes.parent);
    final finder = find.byKey(const Key('sound-switch'));
    expect(tester.widget<SwitchListTile>(finder).value, isTrue);

    await h.tapKey(tester, 'sound-switch');
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(finder).value, isFalse);
    expect(await UsageRepository(h.db).soundOn(), isFalse);

    await h.tapKey(tester, 'sound-switch');
    await tester.pumpAndSettle();
    expect(await UsageRepository(h.db).soundOn(), isTrue);
  });
}
