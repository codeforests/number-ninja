# Handoff: FEAT-02 — Question bank v1
Branch: feat/FEAT-02-question-bank · PR: none yet · Updated: 2026-11-14 by design + build T1
Stage done: design, build (T1 of 5)
Next: build — kickoff: "Build FEAT-02 (from T2) on branch feat/FEAT-02-question-bank. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 step 2."

## What the next stage needs
- Domain API from T1 (read signatures only): `lib/domain/topics.dart` (`Track`, `Topic`, `topics`, `topicsById`), `question.dart` (`Question`, `QuestionFormat`, `DragSpec`, `QuestionBank` with `toJson`/`fromJson`, `byTopic`), `expr.dart` (`evaluate(String) → num`), `answers.dart` (`isCorrect`), `bank_validator.dart` (`validateBank(bank, {topicList, minPerTopic = 40}) → List<String>`).
- `answer` is a `String` for mcq/number and a `List<String>` for drag. `check` is only for numeric answers; the validator parses `answer` as a number when `check` is set.
- Ids: `<topic>.<template>.<nnn>` (template part `[a-z0-9-]+`, 3-digit counter from 001). Seed each template's `Random` from a stable hash of its id: write an FNV-1a over the code units, because `String.hashCode` isn't guaranteed stable across runs.
- `tool/` may import only `package:number_ninja/domain/...` (pure Dart). Check early whether `dart run tool/generate_bank.dart` works in this Flutter package. If it doesn't, use `flutter pub run` or put the generator behind a `flutter test`-style runner, and update AGENTS.md Commands to match.
- `scripts/check.sh` with no arguments formats `lib test tool`, so `tool/` must exist before the full run. T5 also adds `tool` to CI's format step and a "regenerate and `git diff --exit-code assets/`" step.
- Target: 60 questions per topic spread over levels 1–3, P2 numbers ≤ 1000, no plain add/subtract drills (D2, AC-7). Use visual kinds only as listed in design.md, because FEAT-03 draws exactly those.
- The questions are for a 7–8-year-old: short sentences, Singapore context (dollars and cents, names like Mei, Ravi, Siti, Jun Wei, Aisha), no trick wording.

## Left to CI or later
- APK build only in CI (no Android SDK in cloud sessions).

## Pending for Ken
- none
