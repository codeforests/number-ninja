import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/domain/pin.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/providers.dart';

import '../quiz/quiz_harness.dart';

const parentPin = '2468';

/// The quiz harness with a real PIN and helpers to seed attempts and open
/// parent screens (FEAT-06).
class ParentHarness extends QuizHarness {
  ParentHarness() {
    pins = PinRepository(db, clock: clock, hasher: PinHasher(iterations: 10));
    more = [pinRepositoryProvider.overrideWithValue(pins)];
  }

  late final PinRepository pins;

  Future<void> setUp() => pins.setPin(parentPin);

  /// Saves a round of [topic] whose answers are [results] (question number,
  /// right?) with [ms] each, [daysAgo] days before now.
  Future<void> seed(
    String topic,
    List<(int, bool)> results, {
    int daysAgo = 0,
    int ms = 5000,
  }) async {
    final saved = now;
    now = now.subtract(Duration(days: daysAgo));
    final id = await repo.startRound(topic, 1);
    for (final (n, right) in results) {
      await repo.saveAttempt(
        id,
        AnswerResult(
          questionId: '$topic.t.$n',
          given: 'x',
          correct: right,
          timeMs: ms,
        ),
      );
    }
    now = saved;
  }

  /// Unlocks the parent area and goes to [location].
  Future<void> openParent(WidgetTester tester, String location) async {
    await pumpApp(tester);
    container(tester).read(appSessionProvider).unlockParent();
    container(tester).read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }
}

/// Finds [text] inside the widget with [key].
Finder textIn(String key, String text) =>
    find.descendant(of: find.byKey(Key(key)), matching: find.text(text));
