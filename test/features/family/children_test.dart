import 'dart:typed_data';

import 'package:drift/drift.dart' show Variable;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/child_repository.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/features/parent/children_screen.dart';
import 'package:number_ninja/features/parent/report_export.dart';
import 'package:number_ninja/features/parent/stats_view.dart';
import 'package:number_ninja/features/profile/profile_screen.dart';
import 'package:number_ninja/providers.dart';

import '../parent/parent_harness.dart';
import '../quiz/quiz_harness.dart';

/// FEAT-25 AC-5 (SCR-18, SCR-12 add/edit/remove) and AC-6 (the parent
/// switcher on SCR-09/11/16 and the report nickname).
void main() {
  late ParentHarness h;
  late ChildRepository kids;
  late List<(Uint8List, String)> shared;

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
    kids = ChildRepository(h.db, clock: h.clock);
    await ProfileRepository(
      h.db,
      clock: h.clock,
    ).save(const ChildProfile(nickname: 'Mia', schoolYear: 2));
    shared = [];
    h.more = [
      ...h.more,
      reportSharerProvider.overrideWithValue(
        (b, n) async => shared.add((b, n)),
      ),
    ];
  });
  tearDown(() => h.db.close());

  Future<int> addLeo() => kids.add(
    const ChildProfile(nickname: 'Leo', schoolYear: 1),
    pickAvatar: true,
  );

  /// A round of [n] answers for child [childId].
  Future<void> seedRounds(int childId, int n) async {
    final repo = RoundRepository(h.db, clock: h.clock, childId: childId);
    final id = await repo.startRound(numberTopic, 1);
    for (var i = 1; i <= n; i++) {
      await repo.saveAttempt(
        id,
        AnswerResult(
          questionId: '$numberTopic.t.$i',
          given: 'x',
          correct: true,
          timeMs: 4000,
        ),
      );
    }
  }

  Future<int> attemptsOf(int childId) async =>
      (await h.db
              .customSelect(
                'SELECT COUNT(*) AS n FROM attempts WHERE child_id = ?',
                variables: [Variable.withInt(childId)],
              )
              .getSingle())
          .read<int>('n');

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('AC-5: add a child from SCR-18 with nickname, year and avatar; '
      'Add child hides at 4', (tester) async {
    await h.openParent(tester, '/parent');
    expect(
      tester.widget<Text>(find.byKey(const Key('children-subtitle'))).data,
      'Add a brother or sister',
    );
    await h.tapKey(tester, 'open-children');
    expect(find.byType(ChildrenScreen), findsOneWidget);
    expect(find.byKey(const Key('child-1')), findsOneWidget);
    // The only child can't be removed.
    await h.tapKey(tester, 'child-1');
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byKey(const Key('remove-child')), findsNothing);
    await h.tapKey(tester, 'back-parent');
    expect(find.byType(ChildrenScreen), findsOneWidget);

    await h.tapKey(tester, 'add-child');
    expect(find.text('Add a child'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('profile-nickname')), 'Leo');
    await h.tapKey(tester, 'year-1');
    await h.tapKey(tester, 'avatar-frog');
    await h.tapKey(tester, 'profile-save');

    expect(find.byType(ChildrenScreen), findsOneWidget);
    final all = await kids.all();
    expect(all, hasLength(2));
    final leo = all.last;
    expect((leo.nickname, leo.schoolYear, leo.avatar), ('Leo', 1, 'frog'));
    expect(find.byKey(Key('child-${leo.id}')), findsOneWidget);
    // Mia still plays; adding doesn't switch.
    expect(h.container(tester).read(currentChildProvider), 1);

    for (final n in ['Ana', 'Bo']) {
      expect(find.byKey(const Key('add-child')), findsOneWidget);
      await h.tapKey(tester, 'add-child');
      await tester.enterText(find.byKey(const Key('profile-nickname')), n);
      await h.tapKey(tester, 'year-1');
      await h.tapKey(tester, 'profile-save');
    }
    expect(await kids.all(), hasLength(4));
    expect(find.byKey(const Key('add-child')), findsNothing);
  });

  testWidgets('AC-5: editing a child changes only that child', (tester) async {
    final leo = await addLeo();
    await h.openParent(tester, '/parent/children');
    await h.tapKey(tester, 'child-$leo');
    final field = find.byKey(const Key('profile-nickname'));
    expect(tester.widget<TextField>(field).controller!.text, 'Leo');
    await tester.enterText(field, 'Leon');
    await h.tapKey(tester, 'avatar-tiger');
    await h.tapKey(tester, 'profile-save');

    expect(find.byType(ChildrenScreen), findsOneWidget);
    final all = await kids.all();
    expect((all.first.nickname, all.first.schoolYear), ('Mia', 2));
    expect((all.last.nickname, all.last.avatar), ('Leon', 'tiger'));
  });

  testWidgets('AC-5: remove needs the PIN and deletes only her rows', (
    tester,
  ) async {
    final leo = await addLeo();
    await seedRounds(1, 3);
    await seedRounds(leo, 5);
    await h.openParent(tester, '/parent/children');
    await h.tapKey(tester, 'child-$leo');
    await h.tapKey(tester, 'remove-child');
    expect(find.byType(RemoveChildScreen), findsOneWidget);

    await enterPin(tester, '1111');
    expect(find.textContaining('Wrong PIN'), findsOneWidget);
    expect(await kids.all(), hasLength(2));

    await enterPin(tester, parentPin);
    expect(find.byType(ChildrenScreen), findsOneWidget);
    expect(find.byKey(Key('child-$leo')), findsNothing);
    expect((await kids.all()).map((c) => c.nickname), ['Mia']);
    expect(await attemptsOf(leo), 0);
    expect(await attemptsOf(1), 3);
  });

  testWidgets('AC-5: removing the playing child makes the first one current', (
    tester,
  ) async {
    final leo = await addLeo();
    await kids.setCurrent(leo);
    h.startChild = leo;
    await h.openParent(tester, Routes.removeChild(leo));
    await enterPin(tester, parentPin);
    expect(h.container(tester).read(currentChildProvider), 1);
    expect(await kids.current(), 1);
  });

  testWidgets('AC-6: the switcher is absent with one child', (tester) async {
    await h.openParent(tester, '/parent');
    expect(find.byKey(const Key('parent-child-switch')), findsNothing);
    h.container(tester).read(routerProvider).go('/parent/dashboard');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('parent-child-switch')), findsNothing);
  });

  testWidgets('AC-6: switching on SCR-09 changes the dashboard, SCR-16 and '
      'the PDF to that child', (tester) async {
    final leo = await addLeo();
    await seedRounds(1, 3);
    await seedRounds(leo, 5);
    await h.openParent(tester, '/parent/dashboard');
    final c = h.container(tester);
    expect((await c.read(statsDataProvider.future)).all, hasLength(3));
    expect(find.text('Mia'), findsOneWidget);

    await h.tapKey(tester, 'parent-child-switch');
    await tester.tap(find.byKey(Key('parent-child-$leo')).last);
    await tester.pumpAndSettle();
    expect(c.read(currentChildProvider), leo);
    expect(find.byKey(const Key('parent-child-name')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('parent-child-name'))).data,
      'Leo',
    );
    expect((await c.read(statsDataProvider.future)).all, hasLength(5));

    c.read(routerProvider).go('/parent/day');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('parent-child-switch')), findsOneWidget);

    c.read(routerProvider).go('/parent/dashboard');
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('export-pdf')));
      for (var i = 0; i < 250 && shared.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    expect(shared.single.$2, startsWith('brainbubblz-report-leo-'));
  });
}
