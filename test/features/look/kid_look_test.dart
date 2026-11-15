import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/features/badges/badge_shelf_screen.dart';
import 'package:number_ninja/features/home/home_screen.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';
import 'package:number_ninja/features/screen_time/lock_screen.dart';
import 'package:number_ninja/features/topics/topic_map_screen.dart';
import 'package:number_ninja/ui/celebration.dart';
import 'package:number_ninja/ui/kid_background.dart';

import '../quiz/quiz_harness.dart';

/// FEAT-09 AC-4 (NFR-10): kid backgrounds and the SCR-05 celebration.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  KidScene sceneOf(WidgetTester tester, Type screen) => tester
      .widget<KidBackground>(
        find.descendant(
          of: find.byType(screen),
          matching: find.byType(KidBackground),
        ),
      )
      .scene;

  Future<void> playRound(WidgetTester tester, {required int right}) async {
    for (var i = 0; i < 10; i++) {
      h.tick(const Duration(seconds: 5));
      await h.answer(tester, right: i < right);
      if (i < 9) await h.next(tester);
    }
    await tester.tap(find.byKey(const Key('next')));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('SCR-02, SCR-03, SCR-06 have their backgrounds', (tester) async {
    await h.pumpApp(tester, location: Routes.home);
    expect(sceneOf(tester, HomeScreen), KidScene.home);

    h.container(tester).read(routerProvider).go(Routes.play('school'));
    await tester.pumpAndSettle();
    expect(sceneOf(tester, TopicMapScreen), KidScene.school);

    h.container(tester).read(routerProvider).go(Routes.play('olympiad'));
    await tester.pumpAndSettle();
    expect(sceneOf(tester, TopicMapScreen), KidScene.olympiad);

    h.container(tester).read(routerProvider).go(Routes.badges);
    await tester.pumpAndSettle();
    expect(sceneOf(tester, BadgeShelfScreen), KidScene.home);
  });

  testWidgets('SCR-07 has the home background', (tester) async {
    await UsageRepository(h.db).addSeconds('2027-01-05', 20 * 60);
    await h.pumpApp(tester, location: Routes.home);
    expect(find.byType(LockScreen), findsOneWidget);
    expect(sceneOf(tester, LockScreen), KidScene.home);
  });

  test('topics map to their track scene', () {
    expect(KidScene.forTopic('p1.place'), KidScene.school);
    expect(KidScene.forTopic('p2.money'), KidScene.school);
    expect(KidScene.forTopic('oly.logic'), KidScene.olympiad);
  });

  testWidgets('SCR-04 and SCR-05 use the round\'s track; 10/10 celebrates '
      'and play-again works while the confetti falls', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    expect(sceneOf(tester, QuizScreen), KidScene.school);
    await playRound(tester, right: 10);

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(sceneOf(tester, ResultScreen), KidScene.school);
    expect(find.byKey(const Key('celebration')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    // Still falling: the tap goes through the IgnorePointer.
    await h.tap(tester, 'play-again');
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(find.byType(Celebration), findsNothing);
  });

  testWidgets('a 0-star round gets no confetti', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, right: 0);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byKey(const Key('celebration')), findsNothing);
  });

  test('screens never hard-code a colour', () {
    final offenders = [
      for (final f in Directory('lib/features').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('.dart') &&
            RegExp(r'Color\(0x').hasMatch(f.readAsStringSync()))
          f.path,
    ];
    expect(offenders, isEmpty);
  });
}
