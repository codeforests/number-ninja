import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/badge_repository.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/round_repository.dart';
import 'package:number_ninja/data/stats_repository.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/quiz.dart';

Question q(String id, String topic) => Question(
  id: id,
  topic: topic,
  level: 1,
  format: QuestionFormat.number,
  prompt: id,
  answer: '1',
  explanation: '',
);

void main() {
  late AppDatabase db;
  late DateTime now;
  late RoundRepository rounds;
  late StatsRepository stats;
  late BadgeRepository repo;

  final bank = QuestionBank(
    version: 1,
    questions: [for (var i = 0; i < 10; i++) q('b$i', 'p1.bonds')],
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 18, 9);
    rounds = RoundRepository(db, clock: () => now);
    stats = StatsRepository(db, bank, clock: () => now);
    repo = BadgeRepository(db, stats, clock: () => now);
  });
  tearDown(() => db.close());

  Future<void> playRound({required int score, bool finish = true}) async {
    final id = await rounds.startRound('p1.bonds', 1);
    for (var i = 0; i < 10; i++) {
      await rounds.saveAttempt(
        id,
        AnswerResult(
          questionId: 'b$i',
          given: '1',
          correct: i < score,
          timeMs: 3000,
        ),
      );
    }
    if (finish) {
      await rounds.finishRound(
        id,
        score: score,
        durationMs: 30000,
        stars: score == 10 ? 3 : 1,
      );
    }
  }

  test('awards new badges once, stamped with the clock, in shelf order '
      '(AC-2)', () async {
    expect(await repo.awardNew(), isEmpty);
    await playRound(score: 10);
    final got = await repo.awardNew();
    expect(got.map((b) => b.id), ['first-round', 'perfect-10', 'speedy']);
    expect(await repo.earned(), {
      'first-round': now,
      'perfect-10': now,
      'speedy': now,
    });

    final first = now;
    now = DateTime(2026, 11, 19, 9);
    expect(await repo.awardNew(), isEmpty, reason: 'nothing new');
    await playRound(score: 10);
    expect(await repo.awardNew(), isEmpty);
    expect((await repo.earned())['first-round'], first, reason: 'kept');
  });

  test('quit rounds award nothing but their attempts count later', () async {
    // The quiz only calls awardNew after a finished round.
    for (var i = 0; i < 9; i++) {
      await playRound(score: 6, finish: false);
    }
    await playRound(score: 6);
    expect((await repo.awardNew()).map((b) => b.id), [
      'first-round',
      'questions-100',
    ]);
  });

  test('after resetProgress the shelf is empty and badges come back', () async {
    await playRound(score: 10);
    await repo.awardNew();
    await stats.resetProgress();
    rounds.forgetSession();
    expect(await repo.earned(), isEmpty);
    now = DateTime(2026, 11, 20, 9);
    await playRound(score: 6);
    expect((await repo.awardNew()).map((b) => b.id), ['first-round']);
    expect(await repo.earned(), {'first-round': now});
  });
}
