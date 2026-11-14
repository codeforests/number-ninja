# Handoff: FEAT-02 — Question bank v1
Branch: feat/FEAT-02-question-bank · PR: [#3](https://github.com/codeforests/number-ninja/pull/3) (draft) · Updated: 2026-11-14 by build T2–T5
Stage done: build (T1–T5 of 5)
Next: verify — kickoff: "Verify FEAT-02 on branch feat/FEAT-02-question-bank. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4."

## What the next stage needs
- Bank: 1,394 questions, 60–71 per topic, levels spread evenly. Format mix mcq 29%, number 62%, drag 9% (target 45/40/15 is reported, not enforced; design says so). Worth a line in the PR for Ken.
- `dart run tool/generate_bank.dart` works in this Flutter package (only pure-Dart imports). `dart run tool/generate_bank.dart p2` builds and validates one prefix without writing.
- Generator layout and the v2 rules are in `tool/bank/README.md`, which also lists every visual kind, icon and figure name FEAT-03 must draw.
- Dedup is per template (a template retries its own repeats); the validator still catches repeats across templates. Doing it per topic would make a new template change other templates' output (AC-4).
- A template rejects a draw with `retry()` (counts as one of 50 tries).
- Prompts carry the numbers for compare/order questions, because the validator's duplicate rule keys on prompt + visual only.
- Number bonds (`p1.bonds.missing-box`, `___ + 8 = 20`) are kept as the topic's "missing numbers" (design §2). The D2 test covers P2 bare sums only. Verify may want to judge this against D2.
- `Draft.mcq` takes an optional `check`; the regrouping MCQs use it so AC-7's test sees every `p2.regroup` question.
- Times in P2 are written `3:25 p.m.` (colon, not the MOE dot), to avoid confusion with money.
- Design deviation: "paths on a grid" counting was replaced by outfit/menu counting (a grid needs a figure per size). Noted here only.
- Tests: `test/tool/generator_test.dart` (framework, AC-3 determinism, AC-4 dummy template, AC-7, D2, per-track validity) and `test/data/question_bank_test.dart` (AC-1, AC-2, AC-4, AC-5, file = generator output).

## Left to CI or later
- APK build and the new "Question bank is up to date" step run only in CI (no Android SDK here).

## Pending for Ken
- none (format mix and the P1 bonds call above are for verify/PR, not blockers)
