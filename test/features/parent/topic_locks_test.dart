import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/topic_lock_repository.dart';
import 'package:number_ninja/features/parent/topic_locks_screen.dart';

import 'parent_harness.dart';

/// FEAT-17 AC-4: SCR-15, the parent opens a School topic (PRC-14).
void main() {
  late ParentHarness h;

  setUp(() async {
    h = ParentHarness()..lockTopics = true;
    await h.setUp();
  });
  tearDown(() => h.db.close());

  String text(String key) =>
      (find.byKey(Key(key)).evaluate().single.widget as Text).data!;

  Future<Set<String>> opened() =>
      TopicLockRepository(h.db, clock: h.clock).opened();

  testWidgets('SCR-11 opens SCR-15', (tester) async {
    await h.openParent(tester, Routes.parent);
    await h.tapKey(tester, 'open-topic-locks');
    expect(find.byType(TopicLocksScreen), findsOneWidget);
    await h.tapKey(tester, 'back-parent');
    expect(find.byKey(const Key('open-topic-locks')), findsOneWidget);
  });

  testWidgets('open a locked topic, then lock it again', (tester) async {
    await h.openParent(tester, Routes.topicLocks);
    expect(text('lock-state-p1.money'), 'Locked: pass Equal groups first');
    expect(find.byKey(const Key('lock-close-p1.money')), findsNothing);
    await h.tapKey(tester, 'lock-open-p1.money');
    expect(text('lock-state-p1.money'), 'Open: opened by you');
    expect(find.byKey(const Key('lock-open-p1.money')), findsNothing);
    expect(await opened(), {'p1.money'});
    // The next topic stays locked behind it.
    expect(text('lock-state-p1.time'), 'Locked: pass Money first');

    await h.tapKey(tester, 'lock-close-p1.money');
    expect(text('lock-state-p1.money'), 'Locked: pass Equal groups first');
    expect(await opened(), isEmpty);
  });

  testWidgets('an opened topic is open on SCR-03', (tester) async {
    await h.openParent(tester, Routes.topicLocks);
    await h.tapKey(tester, 'lock-open-p1.money');
    h.container(tester).read(routerProvider).go(Routes.play('school'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('topic-p1.money')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('topic-p1.money-lock')), findsNothing);
    expect(find.byKey(const Key('topic-p1.money-icon')), findsOneWidget);
  });

  testWidgets('a passed or first topic shows no button', (tester) async {
    final id = await h.repo.startRound('p1.place', 1);
    await h.repo.finishRound(id, score: 7, durationMs: 1000, stars: 1);
    await h.openParent(tester, Routes.topicLocks);
    expect(text('lock-state-p1.place'), 'Open: passed');
    expect(text('lock-state-p1.bonds'), 'Open: the topic before is passed');
    for (final t in ['p1.place', 'p1.bonds']) {
      expect(find.byKey(Key('lock-open-$t')), findsNothing);
      expect(find.byKey(Key('lock-close-$t')), findsNothing);
    }
  });
}
