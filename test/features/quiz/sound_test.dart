import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/sound_player.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/features/quiz/result_screen.dart';

import 'quiz_harness.dart';

/// FEAT-09 AC-3 (PRC-11): sound effects in a round.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  Future<void> playRound(WidgetTester tester, {required int right}) async {
    for (var i = 0; i < 10; i++) {
      h.tick(const Duration(seconds: 5));
      await h.answer(tester, right: i < right);
      await h.next(tester);
    }
  }

  testWidgets('answers play right and wrong; 10/10 ends with stars', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    h.tick(const Duration(seconds: 5));
    await h.answer(tester, right: true);
    expect(h.sounds.played, [SoundEffect.right]);
    await h.next(tester);
    await h.answer(tester, right: false);
    expect(h.sounds.played.last, SoundEffect.wrong);
    await h.next(tester);
    for (var i = 2; i < 10; i++) {
      await h.answer(tester, right: true);
      await h.next(tester);
    }
    expect(find.byType(ResultScreen), findsOneWidget);
    // 9/10 is not 3 stars: the plain round sound, once.
    expect(h.sounds.played.where((e) => e == SoundEffect.round), hasLength(1));
    expect(h.sounds.played, isNot(contains(SoundEffect.stars)));

    h.sounds.played.clear();
    await h.tap(tester, 'play-again');
    await tester.pumpAndSettle();
    await playRound(tester, right: 10);
    await tester.pumpAndSettle();
    expect(h.sounds.played.where((e) => e == SoundEffect.right), hasLength(10));
    expect(h.sounds.played.where((e) => e == SoundEffect.stars), hasLength(1));
    expect(h.sounds.played, isNot(contains(SoundEffect.round)));
  });

  testWidgets('a 6/10 round plays round once after its answers', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, right: 6);
    await tester.pumpAndSettle();
    expect(h.sounds.played, [
      ...List.filled(6, SoundEffect.right),
      ...List.filled(4, SoundEffect.wrong),
      SoundEffect.round,
    ]);
  });

  testWidgets('with sound off nothing plays', (tester) async {
    await UsageRepository(h.db).setSoundOn(false);
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, right: 10);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(h.sounds.played, isEmpty);
  });

  testWidgets('a player that throws still finishes the round', (tester) async {
    h.sounds.fail = true;
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    await playRound(tester, right: 10);
    await tester.pumpAndSettle();
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.byKey(const Key('result-score')), findsOneWidget);
  });
}
