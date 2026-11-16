import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/topics.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/features/topics/topic_map_screen.dart';

import '../quiz/quiz_harness.dart';

/// FEAT-17 AC-3: padlocks on SCR-03 and the SCR-04 guard (PRC-12, PRC-14).
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness()..lockTopics = true);
  tearDown(() => h.db.close());

  const tall = Size(2560, 4000);

  String text(String key) =>
      (find.byKey(Key(key)).evaluate().single.widget as Text).data!;

  String location(WidgetTester tester) => h
      .container(tester)
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .toString();

  Future<void> finished(String topic, int score) async {
    h.tick(const Duration(minutes: 1));
    final id = await h.repo.startRound(topic, 1);
    await h.repo.finishRound(id, score: score, durationMs: 1000, stars: 1);
  }

  testWidgets('a fresh app shows padlocks with what to pass first', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.play('school'), size: tall);
    expect(find.byKey(const Key('topic-p1.place-lock')), findsNothing);
    expect(find.byKey(const Key('topic-p1.place-icon')), findsOneWidget);
    expect(find.byKey(const Key('topic-p1.bonds-lock')), findsOneWidget);
    expect(text('topic-p1.bonds-hint'), 'Pass Numbers to 100 first');
    expect(text('topic-p2.place-hint'), 'Pass Numbers to 100 first');
    await tester.tap(find.byKey(const Key('topic-p1.bonds')));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsNothing);
    expect(find.byType(TopicMapScreen), findsOneWidget);
    expect(h.repo.calls, 0);
  });

  testWidgets('a 7 of 10 round opens the next topic', (tester) async {
    await finished('p1.place', 7);
    await h.pumpApp(tester, location: Routes.play('school'), size: tall);
    expect(find.byKey(const Key('topic-p1.bonds-lock')), findsNothing);
    expect(find.byKey(const Key('topic-p1.bonds-icon')), findsOneWidget);
    expect(text('topic-p1.groups-hint'), 'Pass Number bonds first');
  });

  testWidgets('a locked topic by URL starts no round, back to the map', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.quiz('p1.bonds'));
    expect(find.byType(QuizScreen), findsNothing);
    expect(location(tester), Routes.play(TrackSlug.school));
    expect(h.repo.calls, 0);
    expect(await h.db.select(h.db.rounds).get(), isEmpty);
  });

  testWidgets('Olympiad tiles never show a padlock', (tester) async {
    await h.pumpApp(tester, location: Routes.play('olympiad'), size: tall);
    for (final t in topics.where((t) => t.track == Track.olympiad)) {
      expect(find.byKey(Key('topic-${t.id}-lock')), findsNothing);
      expect(find.byKey(Key('topic-${t.id}-icon')), findsOneWidget);
    }
  });
}
