import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/topic_lock_repository.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/quiz.dart';
import 'package:number_ninja/features/quiz/quiz_controller.dart';
import 'package:number_ninja/providers.dart';

Question q(String topic, int i) => Question(
  id: '$topic.$i',
  topic: topic,
  level: 1,
  format: QuestionFormat.number,
  prompt: '$topic $i',
  answer: '1',
  explanation: '',
);

/// The quiz controller takes the mix-in topic from 30-day stats (AC-4).
void main() {
  late AppDatabase db;
  late DateTime now;
  late ProviderContainer container;
  late RoundRepository rounds;

  final bank = QuestionBank(
    version: 1,
    questions: [
      for (final t in ['p1.bonds', 'p1.money', 'p2.times', 'oly.logic'])
        for (var i = 0; i < 15; i++) q(t, i),
    ],
  );

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2027, 1, 20, 9);
    rounds = RoundRepository(db, clock: () => now);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        bankProvider.overrideWith((ref) => bank),
        roundRepositoryProvider.overrideWithValue(rounds),
        quizRandomProvider.overrideWith((ref) => Random(7)),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 10 answers to p1.bonds at 20 % on [at].
  Future<void> weakBonds(DateTime at) async {
    final saved = now;
    now = at;
    final id = await rounds.startRound('p1.bonds', 1);
    for (var i = 0; i < 10; i++) {
      await rounds.saveAttempt(
        id,
        AnswerResult(
          questionId: 'p1.bonds.$i',
          given: 'x',
          correct: i < 2,
          timeMs: 3000,
        ),
      );
    }
    now = saved;
  }

  Future<List<Question>> start(String topic) async {
    // Past the FEAT-17 lock: the parent opens the topic.
    await TopicLockRepository(db, clock: () => now).open(topic);
    final sub = container.listen(quizControllerProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(quizControllerProvider.notifier).start(topic);
    final s = container.read(quizControllerProvider);
    expect(s.error, isNull);
    return s.quiz!.questions;
  }

  test('no attempts: no mix-in', () async {
    final qs = await start('p1.money');
    expect(qs.every((x) => x.topic == 'p1.money'), isTrue);
  });

  test('a weak School topic in the last 30 days gives 2 questions', () async {
    await weakBonds(now.subtract(const Duration(days: 29)));
    final qs = await start('p2.times');
    expect(qs, hasLength(10));
    expect(qs.where((x) => x.topic == 'p1.bonds'), hasLength(2));
    expect(qs.where((x) => x.topic == 'p2.times'), hasLength(8));
  });

  test('older than 30 days does not count', () async {
    await weakBonds(now.subtract(const Duration(days: 31)));
    final qs = await start('p2.times');
    expect(qs.every((x) => x.topic == 'p2.times'), isTrue);
  });

  test('never its own topic, never in an Olympiad round', () async {
    await weakBonds(now.subtract(const Duration(days: 1)));
    expect(
      (await start('p1.bonds')).every((x) => x.topic == 'p1.bonds'),
      isTrue,
    );
    expect(
      (await start('oly.logic')).every((x) => x.topic == 'oly.logic'),
      isTrue,
    );
  });
}
