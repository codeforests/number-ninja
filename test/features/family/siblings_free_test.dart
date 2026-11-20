import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/child_repository.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/features/family/change_child.dart';
import 'package:number_ninja/features/family/who_screen.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/parent/plus_screen.dart';
import 'package:number_ninja/providers.dart';

import '../parent/parent_harness.dart';
import '../quiz/quiz_harness.dart';

/// FEAT-30 AC-4: siblings on the free tier (PD-6).
void main() {
  late ParentHarness h;
  late ChildRepository kids;
  late int leo;
  late int ava;

  setUp(() async {
    h = ParentHarness()..plus = false;
    await h.setUp();
    kids = ChildRepository(h.db, clock: h.clock);
    await ProfileRepository(
      h.db,
      clock: h.clock,
    ).save(const ChildProfile(nickname: 'Mia', schoolYear: 2));
    leo = await kids.add(
      const ChildProfile(nickname: 'Leo', schoolYear: 1),
      pickAvatar: true,
    );
    ava = await kids.add(
      const ChildProfile(nickname: 'Ava', schoolYear: 1),
      pickAvatar: true,
    );
    await h.seed(numberTopic, [(1, true)]);
  });
  tearDown(() => h.db.close());

  test('the picker shows by itself only with Plus', () async {
    expect(await pickerShows(kids, plus: false), isFalse);
    expect(await pickerShows(kids, plus: true), isTrue);
  });

  testWidgets('free: no home chip, Done goes home, not SCR-17', (tester) async {
    await h.pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('child-chip')), findsNothing);
    h.container(tester).read(appSessionProvider).unlockParent();
    h.container(tester).read(routerProvider).go(Routes.parent);
    await tester.pumpAndSettle();
    await h.tapKey(tester, 'parent-done');
    expect(find.byType(WhoScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);

    // Plus back: the chip returns.
    h.setPlus(tester, true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('child-chip')), findsOneWidget);
  });

  testWidgets('SCR-18: others paused, Make active switches, Add opens '
      'SCR-20, nothing deleted', (tester) async {
    final before = (await h.db.select(h.db.rounds).get()).length;
    await h.openParent(tester, Routes.children);
    String status(int id) =>
        tester.widget<Text>(find.byKey(Key('child-$id-status'))).data!;
    expect(status(1), contains('playing now'));
    expect(status(leo), contains('Paused – needs Plus'));
    expect(status(ava), contains('Paused – needs Plus'));
    expect(find.byKey(const Key('make-active-1')), findsNothing);

    await h.tapKey(tester, 'make-active-$leo');
    expect(h.container(tester).read(currentChildProvider), leo);
    expect(await kids.current(), leo);
    expect(status(leo), contains('playing now'));
    expect(status(1), contains('Paused – needs Plus'));

    await h.tapKey(tester, 'add-child');
    expect(find.byType(PlusScreen), findsOneWidget);

    expect(await h.db.select(h.db.children).get(), hasLength(3));
    expect((await h.db.select(h.db.rounds).get()).length, before);
  });

  testWidgets('with Plus SCR-18 shows no paused child', (tester) async {
    h.plus = true;
    await h.openParent(tester, Routes.children);
    expect(find.textContaining('Paused'), findsNothing);
    expect(find.byKey(Key('make-active-$leo')), findsNothing);
  });
}
