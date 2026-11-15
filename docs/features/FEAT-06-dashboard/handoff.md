# Handoff: FEAT-06 — Parent dashboard
Branch: feat/FEAT-06-dashboard · PR: [#7](https://github.com/codeforests/number-ninja/pull/7) (draft) · Updated: 2026-11-15 by build
Stage done: build (T1–T7 of 7)
Next: verify — kickoff: "Verify FEAT-06 on branch feat/FEAT-06-dashboard. Read AGENTS.md, docs/STATE.md and the feature's handoff.md, then do docs/03-plan.md §2 steps 3–4."

## What the next stage needs
- design.md "Build deviations" lists every change from the design (domain join `withBankTopics`, `StatsRepository.mixInTopic`, `RoundRepository.forgetSession()` after reset, one `statsDataProvider` filtered in memory, parent-only theme sizes, route helpers).
- AC evidence: AC-1..3 `test/domain/stats_test.dart`; AC-1/AC-7 data `test/data/stats_repository_test.dart`; AC-4 `test/domain/round_builder_test.dart` (mix-in group) and `test/features/quiz/mix_in_test.dart`; AC-5 `test/features/parent/dashboard_test.dart`; AC-6/AC-7 `test/features/parent/topic_detail_reset_test.dart`; AC-8 `test/features/parent/parent_layout_test.dart`.
- Test helper: `test/features/parent/parent_harness.dart` (extends `QuizHarness`; real PIN 2468, `seed()`, `openParent()`).
- Build run: `scripts/check.sh` all PASS, 574 tests (507 before); `build_runner` and `generate_bank` gave no diff.
- Existing tests unchanged; only additions.

## Left to CI or later
- APK build and CI run on the PR. M3 tablet check after FEAT-08.

## Pending for Ken
- none
