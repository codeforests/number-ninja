import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/providers.dart';

import '../quiz/quiz_harness.dart';

/// FEAT-10 AC-4 (PRO-03) and AC-5 (PRO-04).
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  Future<void> profile(ChildProfile p) =>
      ProfileRepository(h.db, clock: h.clock).save(p);

  String text(String key) =>
      (find.byKey(Key(key)).evaluate().single.widget as Text).data!;

  Future<int> startedLevel(WidgetTester tester, String topic) async {
    h.container(tester).read(routerProvider).go(Routes.home);
    await tester.pumpAndSettle();
    h.container(tester).read(routerProvider).go(Routes.quiz(topic));
    await tester.pumpAndSettle();
    return h.round(tester).level;
  }

  testWidgets('no profile: unplayed topics start at level 1', (tester) async {
    await h.pumpApp(tester);
    expect(await startedLevel(tester, mcqTopic), 1);
  });

  testWidgets('P3 profile: P2 topics start at 2, override 3 wins', (
    tester,
  ) async {
    await profile(const ChildProfile(nickname: 'Mia', schoolYear: 3));
    await h.pumpApp(tester);
    expect(await startedLevel(tester, mcqTopic), 2);

    await profile(
      const ChildProfile(nickname: 'Mia', schoolYear: 1, schoolStartLevel: 3),
    );
    expect(await startedLevel(tester, numberTopic), 3);
  });

  testWidgets('after a finished round PRC-09 takes over', (tester) async {
    await profile(const ChildProfile(nickname: 'Mia', schoolYear: 3));
    await h.pumpApp(tester, location: Routes.quiz(mcqTopic));
    expect(h.round(tester).level, 2);
    for (var i = 0; i < 10; i++) {
      await h.answer(tester, right: true);
      await h.next(tester);
    }
    expect(await startedLevel(tester, mcqTopic), 3); // 3 stars at 2 -> 3

    // A profile change no longer moves a played topic.
    await profile(
      const ChildProfile(nickname: 'Mia', schoolYear: 1, schoolStartLevel: 1),
    );
    expect(await startedLevel(tester, mcqTopic), 3);
    expect(await startedLevel(tester, numberTopic), 1);
  });

  testWidgets('SCR-03 tiles show the start level', (tester) async {
    await profile(
      const ChildProfile(nickname: 'Mia', schoolYear: 2, olympiadStartLevel: 3),
    );
    await h.pumpApp(tester, size: const Size(2560, 4000));
    await h.tap(tester, 'track-school');
    await tester.pumpAndSettle();
    expect(text('topic-p1.place-level'), 'Level 2');
    expect(text('topic-p2.place-level'), 'Level 1');
    await h.tap(tester, 'back');
    await tester.pumpAndSettle();
    await h.tap(tester, 'track-olympiad');
    await tester.pumpAndSettle();
    expect(text('topic-oly.logic-level'), 'Level 3');
  });

  testWidgets('home greets her by nickname (PRO-04)', (tester) async {
    await h.pumpApp(tester);
    expect(text('greeting'), 'BrainBubblz');
    await profile(const ChildProfile(nickname: 'Mia', schoolYear: 2));
    h.container(tester).invalidate(childProfileProvider);
    await tester.pumpAndSettle();
    expect(text('greeting'), 'Hi, Mia!');
  });
}
