import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/data/child_repository.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/domain/family.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/setup.dart';

import '../../data/fake_server_client.dart';
import '../../ui/layout_checks.dart';
import 'setup_harness.dart';

/// FEAT-26 AC-6 (SET-06, NFR-09, NFR-17): every setup step at the six
/// sizes and text scale 1.3, with the most children and longest names:
/// nothing overflows or overlaps, the main button stays on screen without
/// scrolling, and buttons are at least 56 dp tall.
void main() {
  late SetupHarness h;

  setUp(() => h = SetupHarness());
  tearDown(() => h.db.close());

  final cases = [
    for (final dp in layoutSizes)
      ('${dp.width.toInt()} × ${dp.height.toInt()}', dp, 1.0),
    ('1280 × 800 at text scale $scaledText', scaledSize, scaledText),
  ];

  Future<void> fullFamily() async {
    await ProfileRepository(
      h.db,
      clock: h.clock,
    ).save(ChildProfile(nickname: 'W' * maxNicknameLength, schoolYear: 2));
    final kids = ChildRepository(h.db, clock: h.clock);
    for (var i = 1; i < maxChildren; i++) {
      await kids.add(
        ChildProfile(nickname: 'M' * maxNicknameLength, schoolYear: 1),
        pickAvatar: true,
      );
    }
  }

  const primary = ['setup-next', 'setup-skip-account', 'setup-start'];

  void check(WidgetTester tester, String what) {
    expect(tester.takeException(), isNull, reason: what);
    expectNoOverlap(tester, [
      'setup-title',
      'setup-back',
      ...primary,
      for (var i = 0; i < 6; i++) 'setup-dot-$i',
    ]);
    final main = primary.firstWhere(
      (k) => find.byKey(Key(k)).evaluate().isNotEmpty,
      orElse: () => '',
    );
    if (main.isEmpty) return; // the resume PIN has no buttons
    expectInView(tester, main);
    for (final k in [main, 'setup-back']) {
      if (find.byKey(Key(k)).evaluate().isEmpty) continue;
      expect(
        tester.getSize(find.byKey(Key(k))).height,
        greaterThanOrEqualTo(56),
        reason: '$k on $what',
      );
    }
  }

  for (final (name, dp, scale) in cases) {
    testWidgets('every step at $name', (tester) async {
      if (scale != 1) setTextScale(tester, scale);
      h.useServer(FakeSyncServer()); // the Account step shows its forms
      final size = physical(dp);

      for (final step in [SetupStep.welcome, SetupStep.pin]) {
        await h.setup.advance(step);
        await h.start(tester, size: size);
        check(tester, step.name);
      }
      await h.pastPin(SetupStep.account);
      await h.start(tester, size: size);
      check(tester, 'resume PIN');
      for (final step in [SetupStep.account, SetupStep.children]) {
        await h.setup.advance(step);
        await h.start(tester, size: size, unlocked: true);
        check(tester, step.name);
      }
      await fullFamily();
      for (final step in [SetupStep.children, SetupStep.time, SetupStep.done]) {
        await h.setup.advance(step);
        await h.start(tester, size: size, unlocked: true);
        check(tester, '${step.name} with $maxChildren children');
      }
    });
  }
}
