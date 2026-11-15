# FEAT-03: Quiz engine

> Implements: PRC-02, PRC-03, PRC-04, PRC-05, PRC-06, PRC-08, PRC-10, NFR-03, NFR-04, NFR-05 · Screens: SCR-04, SCR-05, SCR-03 (placeholder)
> Status: built (T1–T7 done), to verify · Branch: `feat/FEAT-03-quiz-engine` · 2026-11-15

## Scope

A real round she can play (milestone M1): pick a topic, answer 10 questions in any of the three formats with drawn visuals, see right/wrong with the explanation after each, and finish on a result screen with score, time and stars. Every answer is saved before the next question shows.

To reach a round before FEAT-04, the home track cards open a **placeholder topic list** (SCR-03 placeholder: plain tiles with topic names, no stars). Rounds are played at **level 1** until FEAT-04 adds difficulty steps (PRC-09).

Not in scope: stars on the topic map and difficulty steps (FEAT-04), screen-time lock (FEAT-05), the design §5 "needs practice" mix-in (needs FEAT-06 stats; added there or later), badges on the result screen (FEAT-08). No schema change: `rounds` and `attempts` already exist (design §4).

## Design

- **Domain** (`lib/domain/`, pure Dart):
  - `stars.dart`: `starsFor(int score)` per design §5 (10 → 3, 8–9 → 2, 6–7 → 1, else 0).
  - `round_builder.dart`: `buildRound({required List<Question> topicQuestions, required int level, required Set<String> recentCorrect, required Random random, int size = 10})`. Takes the topic's questions at `level`, shuffles them with `random`, and puts those whose id is not in `recentCorrect` first (PRC-08). If the level has fewer than `size`, it fills from the nearest other level, same preference. Never repeats a question within a round. Returns at most `size` (fewer only if the topic has fewer).
  - `quiz.dart`: `Quiz`, an immutable state machine for one round: `questions`, `index`, `phase` (`answering` | `feedback` | `done`), `results` (list of `AnswerResult {questionId, given, correct, timeMs}`), `shownAt`. `answer(given, now)` → feedback phase with `isCorrect` (FEAT-02 `answers.dart`) and `timeMs = now − shownAt`; `next(now)` → next question (sets `shownAt = now`) or `done`. `score`, `durationMs` (sum of `timeMs`, so reading feedback isn't counted) and `stars`. Time comes in as a parameter (NFR-08).
  - `answerText(Question, Object given)` / `correctAnswerText(Question)`: what is stored in `attempts.answer_given` and shown as "The answer is …". Drag lists join with `, `.
- **Data** (`lib/data/round_repository.dart`), `RoundRepository(db, clock:)`:
  - `startRound(topicId, level)` → round id. Creates the app opening's `play_sessions` row on first use (kept in memory; FEAT-05 may take this over).
  - `saveAttempt(roundId, AnswerResult)` inserts into `attempts` with `answered_at = clock()` (PRC-04).
  - `finishRound(roundId, score, durationMs, stars)` updates the `rounds` row. An unfinished round keeps its attempts and score 0.
  - `recentCorrectIds(topicId, {rounds = 3})`: question ids answered correctly in the topic's last 3 rounds by `started_at` (PRC-08).
- **Flow** (`lib/features/quiz/quiz_controller.dart`, a Riverpod `Notifier` per round): on start it loads the bank, asks the repository for `recentCorrectIds`, builds the round (`Random` injectable, default `Random()`), and calls `startRound`. On **Check**: compute the result, **await `saveAttempt`**, then show feedback (NFR-05: saved before the next question can show). On **Next**: no I/O at all, just `quiz.next(clock())`, so the next question is a synchronous rebuild (NFR-04). After the last answer, `finishRound` is awaited and the app goes to the result screen.
- **Routes** (`lib/app.dart`): `/play/:track` (placeholder topic list; track = `school` | `olympiad`), `/quiz/:topicId` (SCR-04), `/result` (SCR-05, reads the finished round from the controller or route `extra`). Home track cards become tappable.
- **SCR-04 quiz** (`lib/features/quiz/quiz_screen.dart`), landscape first: top bar with a quit button (back to home, no dialog) and 10 progress dots (filled green/red as answered). Left half: prompt text (≥ `AppText.body`) and the visual. Right half: the answer area. Under 900 dp wide (portrait), the halves stack. After Check, a feedback panel replaces the answer area's buttons: "Right!" in `AppColors.leaf` or "Not quite" in `AppColors.berry`, then "The answer is …" and the explanation when wrong (PRC-05), and a Next button ("See results" on the last).
- **Answer widgets** (`lib/features/quiz/answers/`):
  - `mcq_answer.dart`: options as a 2×2 grid of big buttons; tapping one submits.
  - `number_answer.dart`: a display plus an on-screen keypad (0–9, `.`, backspace) and Check; max 6 characters; Check disabled when empty. No system keyboard.
  - `drag_answer.dart`: `slots` empty boxes and the `items` as chips. Drag a chip onto a box (`Draggable`/`DragTarget`), or **tap** a chip to fill the first empty box; tap a filled box to send its chip back. Check is enabled when every box is filled. Up to 6 items, 5 slots, 12 characters per item (FEAT-02 bank).
- **Drawn visuals** (`lib/ui/visuals/`, PRC-10), one widget per `kind` from `tool/bank/README.md` (that table is the field reference), drawn with `CustomPainter` or plain widgets, colours from `theme.dart` (add visual colours there: red, blue, yellow, green, coin colours). `question_visual.dart` dispatches on `kind`; an unknown kind draws nothing and asserts in debug. Group/graph icons map to Material icons (apple → `Icons.apple`, star → `Icons.star`, … child → `Icons.child_care`), chosen in one map in `question_visual.dart`. Each visual fits a box it is given (the left half's free space) and scales to it.
- **SCR-05 result** (`lib/features/quiz/result_screen.dart`): "7 / 10", total time as `m:ss`, 0–3 big stars, and two buttons: Play again (same topic, new round) and Home.
- **NFR-03:** child-screen buttons use `AppSizes.minTap` and text uses `AppText` sizes; a widget test walks every tappable on SCR-04 and SCR-05 and checks ≥ 64 × 64 dp, and every `Text` ≥ 20 sp.

## Acceptance criteria

- **AC-1** (PRC-02, PRC-08): `buildRound` returns 10 distinct questions from the topic at the level; questions in `recentCorrect` come only after all others are used; with too few at the level it fills from the nearest level; same seed → same round (unit tests). `recentCorrectIds` covers exactly the last 3 rounds of that topic (Drift test).
- **AC-2** (PRC-03): one widget test per format answers a question correctly and one wrongly: MCQ by tapping an option; number by the keypad (incl. `.` and backspace); drag by dragging a chip and, separately, by tapping chips; tapping a filled box returns its chip.
- **AC-3** (PRC-04, NFR-05): after Check, the `attempts` row (question id, answer text, correct, `time_ms` from the fake clock) exists **before** the Next button is shown; killing the round mid-way (disposing the widget tree) leaves every answered attempt in the database.
- **AC-4** (PRC-05): a wrong answer shows "Not quite", the correct answer and the explanation; a right one shows "Right!".
- **AC-5** (PRC-06): a full 10-question round in a widget test ends on SCR-05 with the right score, `m:ss` time (sum of answer times from the fake clock) and stars; the `rounds` row has the same score, duration and stars. `starsFor` unit-tested at 5, 6, 7, 8, 9, 10.
- **AC-6** (PRC-10): every visual kind in the shipped bank has a widget; for each template (id up to the counter), its longest-prompt question renders on SCR-04 at 1280 × 800 dp with no overflow or exception, and a sample also renders at 800 × 1280 dp.
- **AC-7** (NFR-03): every tappable on SCR-04 (all three formats, both phases) and SCR-05 is at least 64 × 64 dp and every text is at least 20 sp.
- **AC-8** (NFR-04): Next does no database or bank work (the controller test shows Next completes synchronously); on-tablet timing is Ken's M1 check.
- **AC-9**: home → School → a topic tile → a round plays end to end; Play again starts a new round of the same topic; Home returns to SCR-02.

## Tasks

- [x] T1 — Domain: `stars.dart`, `round_builder.dart`, `quiz.dart` (incl. answer text helpers).
      Done when: `scripts/check.sh 'flutter test test/domain'` passes with the AC-1 builder tests, `starsFor` (AC-5) and `Quiz` transitions and timing.
- [x] T2 — Data: `round_repository.dart` and `roundRepositoryProvider`.
      Done when: `test/data/round_repository_test.dart` passes (start, save, finish, `recentCorrectIds` over 4 rounds, AC-1).
- [x] T3 — Visuals part 1: `clock`, `coins`, `fraction`, `ruler`, `shapes`, `figure`, plus `question_visual.dart` dispatch and theme colours.
      Done when: a widget test renders each of these kinds from sample data at two box sizes without exceptions.
- [x] T4 — Visuals part 2: `groups`, `pictureGraph`, `barModel`; a test that every `kind` in the shipped bank is handled.
      Done when: the same render test passes for all nine kinds and the shipped-bank kind test passes.
- [x] T5 — Answer widgets: MCQ, number keypad, drag (drag and tap).
      Done when: widget tests for each widget alone pass (the AC-2 interactions, on the widget, not yet the screen).
- [x] T6 — Quiz controller, SCR-04 with feedback panel, routes, home cards → placeholder topic list.
      Done when: AC-2, AC-3, AC-4 and AC-8 widget/controller tests pass on SCR-04.
- [x] T7 — SCR-05 result, Play again and Home; the full-round test (AC-5, AC-9); the layout test (AC-6) and the size test (AC-7); full `scripts/check.sh`; draft PR.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
