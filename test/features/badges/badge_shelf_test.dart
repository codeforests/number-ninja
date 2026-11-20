import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/domain/badges.dart' as b;
import 'package:number_ninja/features/badges/badge_shelf_screen.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/providers.dart';

import '../quiz/quiz_harness.dart';

/// FEAT-08 AC-4 (BDG-03, SCR-06) and AC-5 (SCR-02, TIM-01).
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  Future<void> seed(String id, DateTime at) => h.db
      .into(h.db.badgesEarned)
      .insert(
        BadgesEarnedCompanion.insert(childId: 1, badgeId: id, earnedAt: at),
      );

  String text(String key) =>
      (find.byKey(Key(key)).evaluate().single.widget as Text).data!;

  testWidgets('AC-4: the shelf shows earned badges with dates, the rest '
      'with hints; back goes home', (tester) async {
    await seed('first-round', DateTime(2026, 11, 15, 9));
    await seed('speedy', DateTime(2026, 11, 16, 9));
    await h.pumpApp(tester, location: Routes.badges);

    expect(find.byType(BadgeShelfScreen), findsOneWidget);
    expect(text('badge-count'), '2 of 20');
    for (final badge in b.badges) {
      expect(find.byKey(Key('badge-${badge.id}')), findsOneWidget);
    }
    Finder inTile(String id, String s) => find.descendant(
      of: find.byKey(Key('badge-$id')),
      matching: find.text(s),
    );
    expect(inTile('first-round', 'First Round'), findsOneWidget);
    expect(inTile('first-round', 'Earned 15 Nov'), findsOneWidget);
    expect(inTile('speedy', 'Earned 16 Nov'), findsOneWidget);
    var hints = 0;
    for (final badge in b.badges) {
      if (badge.id == 'first-round' || badge.id == 'speedy') {
        expect(inTile(badge.id, badge.hint), findsNothing);
      } else {
        expect(inTile(badge.id, badge.hint), findsOneWidget);
        hints++;
      }
    }
    expect(hints, 18);
    expect(find.bySemanticsLabel('Perfect 10, not earned yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('badges-back')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AC-5: home shows "My badges", then the latest badge', (
    tester,
  ) async {
    await h.pumpApp(tester);
    expect(find.text('My badges'), findsOneWidget);

    await seed('perfect-10', DateTime(2026, 11, 15, 9));
    await seed('first-round', DateTime(2026, 11, 15, 9)); // same time
    h.container(tester).invalidate(earnedBadgesProvider);
    await tester.pumpAndSettle();
    expect(find.text('Latest: Perfect 10'), findsOneWidget);

    await tester.tap(find.byKey(const Key('badges-button')));
    await tester.pumpAndSettle();
    expect(find.byType(BadgeShelfScreen), findsOneWidget);
  });

  test('latestBadge: greatest earned_at, ties to the later shelf slot', () {
    final t = DateTime(2026, 11, 15);
    expect(latestBadge(const {}), isNull);
    expect(latestBadge({'speedy': t, 'first-round': t})?.id, 'speedy');
    expect(
      latestBadge({'speedy': t, 'first-round': t.add(const Duration(days: 1))})
          ?.id,
      'first-round',
    );
  });

  test('AC-5: /badges counts as screen time and locks', () {
    final session = AppSession(hasPin: true, clock: () => DateTime(2027));
    expect(Routes.counts(Routes.badges), isTrue);
    expect(redirectFor(session, true, Routes.badges), Routes.locked);
    expect(redirectFor(session, false, Routes.badges), isNull);
  });
}
