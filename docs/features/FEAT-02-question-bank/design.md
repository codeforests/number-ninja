# FEAT-02: Question bank v1

> Implements: BNK-01, BNK-02, BNK-03, BNK-04, BNK-05, BNK-06 · Screens: none
> Status: in build (T1 done) · Branch: `feat/FEAT-02-question-bank` · 2026-11-14

## Scope

The question model, the 23 topics from design §2, a seeded generator that writes `assets/questions/bank_v1.json`, a validator that the generator and the tests both run, and a loader the app uses. No screens: FEAT-03 shows the questions.

## Design

- **Domain** (`lib/domain/`, pure Dart, so `tool/` can import it):
  - `topics.dart`: `Track` (`p1`, `p2`, `olympiad`) and the 23 `Topic`s with id, track, name and order (design §2).
  - `question.dart`: `Question` with `id`, `topic`, `level` (1–3), `format` (`mcq` | `number` | `drag`), `prompt`, `visual` (optional `Map`), `options` (mcq), `answer`, `drag` (`items` and `slots`), `check` (optional) and `explanation`, plus `toJson`/`fromJson`. `QuestionBank` holds `version`, `questions` and `byTopic`.
  - `answers.dart`: `isCorrect(question, given)`. Number answers are compared as numbers (`"3.60"` = `"3.6"`), MCQ answers by option text, and drag answers by the ordered list of items.
  - `bank_validator.dart`: `validateBank(bank, topics)` returns a list of problems. An empty list means the bank is valid.
- **Answer check (BNK-04):** most templates also write `check`, an arithmetic expression (digits, `+ - * /`, brackets) such as `(456+278)` or `24/4*3`. The validator evaluates it with a small parser and fails if the result differs from `answer`. So a template bug that prints the wrong answer is caught, not just a typo. Questions whose answer isn't arithmetic (shapes, logic) have no `check`; the validator still checks their structure.
- **Validator rules:** ids are unique and match `<topic>.<template>.<nnn>`; the topic is known; level is 1–3; prompt and explanation are not empty; an MCQ has 3–4 unique options with exactly one equal to the answer; a number answer parses as a number; a drag question's answer has one item per slot and every answer item is in `items`; no two questions in a topic share the same prompt and visual; each topic has at least 40 questions and at least one question per level; `check`, when present, equals the answer.
- **Visuals** are data only. FEAT-03 draws them. Kinds: `clock {h, m}`, `coins {cents: [...]}`, `fraction {parts, shaded}`, `groups {groups, each, icon}`, `pictureGraph {title, rows: [{label, count}], scale, icon}`, `barModel {bars: [{label, units, unitValue?, known?}], total?}`, `shapes {items: [{shape, color}]}`, `ruler {cm}`, `figure {name}` (fixed Olympiad counting figures such as `triangle-split-3`).
- **Drag questions** are one shape: drag `items` into `slots` in order, for example ordering numbers, completing a pattern, or labelling a bar model. Items can include distractors.
- **Generator** (`tool/generate_bank.dart`, with templates in `tool/bank/`): each topic has 3–6 templates. A template is a function `(Random rng, int level) → Draft` that returns prompt, answer, options, visual, check and explanation. The generator runs each template with one `Random(seed)` per template. It keeps a draft only if it is new within its topic (same-prompt duplicates are retried, up to 50 times). It writes ids as `<topic>.<template>.<nnn>`, counting up from 001. The target is 60 questions per topic, spread evenly over levels 1–3. It validates and writes sorted JSON, so a re-run gives the same file byte for byte.
- **Stable ids (BNK-05):** a template's seed is a fixed hash of its id, so adding a template or topic never changes the questions other templates produce. A later bank (v2) may add templates or raise counts but never edits or reorders an existing template's output; the plan for that is noted in `tool/bank/README.md`.
- **MCQ distractors** come from common mistakes: no regrouping, off by one group, wrong unit, swapped digits, the other fraction bigger.
- **Olympiad logic and counting** combine templates (ordering puzzles with names, age puzzles, handshakes, rectangles in a grid, paths on a grid, page-number digits) with about 15 hand-written questions each in `tool/bank/handwritten.dart`.
- **Loader** (`lib/data/question_bank_loader.dart`): `loadBank(AssetBundle)` reads and parses `assets/questions/bank_v1.json`, and a Riverpod `bankProvider` exposes it. The asset is listed in `pubspec.yaml` (BNK-01).
- **Format mix:** the generator prints the share of each format. Target: about 45% MCQ, 40% number, 15% drag (design §3); this is reported, not enforced.

## Acceptance criteria

- **AC-1** (BNK-01): `assets/questions/bank_v1.json` is bundled (listed in `pubspec.yaml`), carries `"version": 1`, and `loadBank` returns every question in it.
- **AC-2** (BNK-02, BNK-03): every one of the 23 topics has at least 40 questions, and each topic has questions at levels 1, 2 and 3.
- **AC-3** (BNK-04): `dart run tool/generate_bank.dart` run twice gives byte-identical files. The validator rejects a bank with a wrong `check` result, a duplicate id, an MCQ with zero or two correct options, a duplicate prompt in a topic, and a topic under 40 questions (one test per rule). The shipped bank passes the validator with zero problems.
- **AC-4** (BNK-05): every id matches `<topic>.<template>.<nnn>`. Regenerating with an extra dummy template added to one topic leaves every existing question's id and content unchanged (test).
- **AC-5** (BNK-06): every question has a non-empty explanation.
- **AC-6**: `isCorrect` accepts `3.6` for answer `3.60`, rejects a wrong option, and accepts a drag answer only in the right order.
- **AC-7**: no plain single-step add/subtract drill within 100 appears in P2 (D2). Every `p2.regroup` question needs regrouping or is a two-step or word problem, and a test checks this from `check`.

## Tasks

- [x] T1 — Domain: `topics.dart`, `question.dart` (JSON round-trip), `answers.dart`, expression evaluator, `bank_validator.dart`.
      Done when: `test/domain/question_test.dart`, `answers_test.dart` and `bank_validator_test.dart` pass (AC-3 rule cases, AC-6).
      Evidence: `scripts/check.sh 'flutter test test/domain'` → PASS [25 tests]; `flutter analyze` clean.
- [ ] T2 — Generator framework and P1 templates (8 topics): `tool/generate_bank.dart`, `tool/bank/{generator,templates_p1}.dart`.
      Done when: generating P1 only gives at least 40 valid questions per P1 topic, with no validator problems.
- [ ] T3 — P2 templates (11 topics).
      Done when: same check for the P2 topics, plus the AC-7 regrouping test.
- [ ] T4 — Olympiad templates and hand-written questions (4 topics).
      Done when: same check for the Olympiad topics.
- [ ] T5 — Generate `bank_v1.json`, register the asset, add the loader and `bankProvider`, add the shipped-bank test (AC-1, AC-2, AC-4, AC-5), and add a CI step that regenerates the bank and fails if it differs from the committed file.
      Done when: `flutter test` passes, and `git diff --exit-code assets/` is clean after regeneration.
