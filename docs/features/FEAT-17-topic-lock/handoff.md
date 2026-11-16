# Handoff: FEAT-17 — School topic lock
Branch: feat/FEAT-17-topic-lock · PR: https://github.com/codeforests/number-ninja/pull/15 · Updated: 2026-11-16 by build
Stage done: build (T1–T5 of 5; designed and built in one thread, small feature)
Next: verify — kickoff: "Verify FEAT-17 on branch feat/FEAT-17-topic-lock. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Rules in `lib/domain/topic_lock.dart` (`topicLocks`); design decisions in design.md. Two choices beyond PRC-13's wording: a topic with any finished round stays open (v1 installs played out of order), and no profile counts as P1.
- Build change: the parent opens topics on a new SCR-15 (`/parent/topics`, SCR-11 tile `open-topic-locks`), not SCR-10, because SCR-09 lists no topics before her first answers.
- `QuizHarness.lockTopics` defaults to false (every topic open via a provider override) so older tests needed no change; lock tests set it true. Only two existing test setups changed: `mix_in_test.dart` opens its topics through `TopicLockRepository`, and `pin_flow_test.dart` scrolls SCR-11 to `change-pin` (the new tile pushed it out of the lazy list). No assertions changed.
- Schema v5 (`topic_unlocks`), migration test v4 → v5. 776 tests, `scripts/check.sh` all PASS locally.

## Left to CI or later
- Release APK build in CI on the PR head. Padlock look on the real tablet at M5.

## Pending for Ken
- none
