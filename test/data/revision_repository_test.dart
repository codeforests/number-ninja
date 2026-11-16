import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/revision_repository.dart';
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
  late RevisionRepository repo;

  final bank = QuestionBank(
    version: 1,
    questions: [for (var i = 0; i < 5; i++) q('p1.place.a.00$i', 'p1.place')],
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 18, 9);
    rounds = RoundRepository(db, clock: () => now);
    repo = RevisionRepository(
      StatsRepository(db, bank, clock: () => now),
      rounds,
      clock: () => now,
    );
  });
  tearDown(() => db.close());

  Future<void> answerAt(DateTime at, String id, bool correct) async {
    now = at;
    final r = await rounds.startRound('p1.place', 2);
    await rounds.saveAttempt(
      r,
      AnswerResult(questionId: id, given: 'x', correct: correct, timeMs: 900),
    );
    await rounds.finishRound(r, score: 8, durationMs: 900, stars: 2);
  }

  test(
    'history cuts to 30 days, fills levels and recentCorrect (AC-2)',
    () async {
      final today = DateTime(2026, 11, 18, 9);
      await answerAt(
        today.subtract(const Duration(days: 31)),
        'p1.place.a.000',
        false,
      );
      await answerAt(
        today.subtract(const Duration(days: 20)),
        'p1.place.a.001',
        true,
      );
      await answerAt(
        today.subtract(const Duration(days: 6)),
        'p1.place.a.002',
        true,
      );
      await answerAt(
        today.subtract(const Duration(days: 1)),
        'p1.place.a.003',
        false,
      );
      now = today;

      final h = await repo.history();
      expect(h.attempts.map((a) => a.questionId).toSet(), {
        'p1.place.a.001',
        'p1.place.a.002',
        'p1.place.a.003',
      });
      expect(h.levels, {'p1.place': 2});
      expect(h.recentCorrect, {'p1.place.a.002'});
    },
  );
}
