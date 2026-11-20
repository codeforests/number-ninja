# Handoff: FEAT-18 — Progress per day
Branch: feat/FEAT-18-daily-progress · PR: (draft, see branch) · Updated: 2026-11-20 by design+build
Stage done: build (T1–T4 of 4)
Next: verify — kickoff: "Verify FEAT-18 on branch feat/FEAT-18-daily-progress. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Small feature: designed and built in one thread. New PAR-11 (requirements), SCR-16 (02-design), plan row FEAT-18; Verified by cell for PAR-11 still empty.
- No schema change. `StatsRepository.day()` queries one local day; `daily_usage` summed over device rows.
- Round tile shows "N right" (not "N/10"): a round crossing midnight has only that day's answers, so the total isn't known on one day.
- Summary figure keys: `day-answers`, `day-right`, `day-speed`, `day-minutes`, `day-round-count` (`day-rounds` is the rounds card).
- `answerText` moved from `topic_detail_screen.dart` to `stats_view.dart`; `AppSizes.parentColumn` (900) added to the theme.
- Another thread is making the parent pages responsive (item 2 of Ken's list): expect a merge touch in `dashboard_screen.dart` (`_DailyCard` sits after `_TrackSummary`) and `parent_layout_test.dart`.

## Left to CI or later
- APK build (CI only). No tablet look yet: render SCR-16 and SCR-09 at 1280×800 and 360×640 in verify.

## Pending for Ken
- none (after merge: release APK per his standing rule)
