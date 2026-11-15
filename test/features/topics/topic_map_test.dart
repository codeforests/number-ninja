import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/domain/topics.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/features/topics/topic_icons.dart';
import 'package:number_ninja/features/topics/topic_map_screen.dart';

import '../quiz/quiz_harness.dart';

/// SCR-02 and SCR-03, AC-4 and AC-5.
void main() {
  late QuizHarness h;

  setUp(() => h = QuizHarness());
  tearDown(() => h.db.close());

  /// Tall enough that every tile of a track is built.
  const tall = Size(2560, 4000);

  Iterable<String> tileIds() => find
      .byWidgetPredicate((w) {
        final k = w.key;
        return k is ValueKey<String> &&
            RegExp(r'^topic-[a-z0-9]+\.[a-z]+$').hasMatch(k.value);
      })
      .evaluate()
      .map((e) => (e.widget.key! as ValueKey<String>).value.substring(6));

  int filled(WidgetTester tester, String id) => [
    for (var i = 0; i < 3; i++)
      (tester.widget(find.byKey(Key('topic-$id-star-$i'))) as Icon).icon,
  ].where((icon) => icon == Icons.star).length;

  String text(String key) =>
      (find.byKey(Key(key)).evaluate().single.widget as Text).data!;

  /// A finished round straight through the repository.
  Future<void> finished(String topic, int level, int stars) async {
    h.tick(const Duration(minutes: 1));
    final id = await h.repo.startRound(topic, level);
    await h.repo.finishRound(id, score: 0, durationMs: 1000, stars: stars);
  }

  test('AC-4: every topic has an icon and a name of at most 4 words', () {
    for (final t in topics) {
      expect(topicIcons[t.id], isNotNull, reason: t.id);
      expect(t.name.split(' ').length, lessThanOrEqualTo(4), reason: t.id);
    }
    expect(topicIcons.keys.toSet(), topicsById.keys.toSet());
  });

  testWidgets('AC-4: School shows P1 and P2 sections with 19 topics', (
    tester,
  ) async {
    await h.pumpApp(tester, size: tall);
    await h.tap(tester, 'track-school');
    await tester.pumpAndSettle();
    expect(find.byType(TopicMapScreen), findsOneWidget);
    expect(find.byKey(const Key('section-p1')), findsOneWidget);
    expect(find.byKey(const Key('section-p2')), findsOneWidget);
    expect(text('section-p1'), 'P1');
    expect(text('section-p2'), 'P2');
    final ids = tileIds().toList();
    expect(ids, [
      for (final t in topics)
        if (t.track != Track.olympiad) t.id,
    ]);
    expect(ids, hasLength(19));
    for (final id in ids) {
      expect(find.byKey(Key('topic-$id-icon')), findsOneWidget);
      expect(text('topic-$id-name'), topicsById[id]!.name);
    }

    await h.tap(tester, 'back');
    await tester.pumpAndSettle();
    expect(find.byType(TopicMapScreen), findsNothing);
    expect(find.byKey(const Key('track-school')), findsOneWidget);
  });

  testWidgets('AC-4: Olympiad shows its 4 topics in one section', (
    tester,
  ) async {
    await h.pumpApp(tester, size: tall);
    await h.tap(tester, 'track-olympiad');
    await tester.pumpAndSettle();
    expect(tileIds().toList(), [
      'oly.patterns',
      'oly.logic',
      'oly.counting',
      'oly.models',
    ]);
    expect(find.byKey(const Key('section-p1')), findsNothing);
    expect(find.byKey(const Key('section-olympiad')), findsNothing);
  });

  testWidgets('AC-4: tapping a tile starts a round of that topic', (
    tester,
  ) async {
    await h.pumpApp(tester, location: Routes.play('school'));
    await h.tap(tester, 'topic-$mcqTopic');
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(h.current(tester).topic, mcqTopic);
  });

  testWidgets('AC-5: tiles show best stars and the latest level', (
    tester,
  ) async {
    await finished(mcqTopic, 2, 2);
    await finished(mcqTopic, 2, 1); // latest: level 2, 1 star -> level 1
    await finished('oly.logic', 1, 3); // -> level 2
    // A quit round counts for nothing.
    await h.repo.startRound(numberTopic, 1);

    await h.pumpApp(tester, size: tall);
    expect(text('track-stars-school'), '2 / 57');
    expect(text('track-stars-olympiad'), '3 / 12');

    await h.tap(tester, 'track-school');
    await tester.pumpAndSettle();
    expect(filled(tester, mcqTopic), 2);
    expect(text('topic-$mcqTopic-level'), 'Level 1');
    expect(filled(tester, numberTopic), 0);
    expect(text('topic-$numberTopic-level'), 'Level 1');
    expect(filled(tester, 'p1.place'), 0);

    await h.tap(tester, 'back');
    await tester.pumpAndSettle();
    await h.tap(tester, 'track-olympiad');
    await tester.pumpAndSettle();
    expect(filled(tester, 'oly.logic'), 3);
    expect(text('topic-oly.logic-level'), 'Level 2');
  });

  testWidgets('AC-5: the map and home update after a round', (tester) async {
    await h.pumpApp(tester, location: Routes.quiz(mcqTopic));
    for (var i = 0; i < 10; i++) {
      await h.answer(tester, right: true);
      await h.next(tester);
    }
    await h.tap(tester, 'home');
    await tester.pumpAndSettle();
    expect(text('track-stars-school'), '3 / 57');
    await h.tap(tester, 'track-school');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('topic-$mcqTopic')));
    expect(filled(tester, mcqTopic), 3);
    expect(text('topic-$mcqTopic-level'), 'Level 2');
  });

  testWidgets('SCR-02: cards side by side in landscape, stacked in portrait', (
    tester,
  ) async {
    Rect rect(String k) => tester.getRect(find.byKey(Key(k)));

    await h.pumpApp(tester);
    expect(rect('track-school').top, rect('track-olympiad').top);
    expect(rect('track-school').right, lessThan(rect('track-olympiad').left));

    await h.pumpApp(tester, size: const Size(1600, 2560));
    expect(rect('track-school').left, rect('track-olympiad').left);
    expect(rect('track-school').bottom, lessThan(rect('track-olympiad').top));
  });
}
