# FEAT-18: Verify

> Verified 2026-11-20 in a fresh thread that did not write the code · Commit under test: `b576412` · Verdict: **accepted** (two test fixes made here, no production change)

## Checks re-run from a clean checkout

Fresh checkout of `b576412`, Flutter 3.50.0.

| Check | Result |
|---|---|
| `flutter pub get` | ok |
| `dart run build_runner build` | no diff (no schema change) |
| `dart run tool/generate_bank.dart` | no diff |
| `scripts/check.sh` (format, analyze, test) | all PASS |
| Test files changed here | `parent_layout_test.dart` (49), `day_test.dart` (3): PASS |
| CI on the final head | see the PR checks (release APK build) |

## Acceptance criteria

| AC | Evidence | Result |
|---|---|---|
| AC-1 | `test/domain/daily_test.dart`: `dayBounds` local midnight to midnight, built from calendar fields (DST-safe); `shiftDay` across months/years; `recentDays` newest first, capped at 7, tallies; `DayDetail` sums. | pass |
| AC-2 | `test/data/stats_day_test.dart`: 23:59 in, next 00:00 out, grouped by round with level/score/stars/revision; `daily_usage` summed over two devices; unknown question falls back to round topic; `firstDay()` earliest or null. | pass |
| AC-3 | `test/features/parent/day_test.dart`: summary figures, topic rows, round tile, expanded answer with "Her answer" and "Right answer"; prev twice, next disabled on today, picker opens/cancels; bad `d` opens today. Strengthened here: the empty day now has 120 s seeded and must show `2 min` (was `0 min`, which didn't prove the empty day reads screen time). | pass |
| AC-4 | `dashboard_test.dart` FEAT-18 AC-4: 7 newest days, `daily-<day>` opens SCR-16, `open-day` opens today, back to SCR-09. | pass |
| AC-5 | `parent_layout_test.dart` SCR-16 (round expanded) and SCR-09 at six sizes + scale 1.3. **Fixed here:** `open()` set the size and then `openParent` → `pumpApp` reset it to 2560×1600, so every "size" ran at 1280×800 (since FEAT-06). The size is now set after `openParent`; all 49 cases still pass at the real sizes. | pass |

## Beyond the tests

- Rendered SCR-16 (round expanded, scrolled) and SCR-09 with Roboto at 1280×800 and 360×640: one centred column ≤900 dp on the tablet, figures and the date label wrap on the phone size, no clipping. The "By day" card sits first on the left column at 1280×800.
- Data path reads one day by `answered_at` bounds and `daily_usage.day`, so synced rows from other devices count; no schema change.

## Test diff review

New tests only add cases; no existing assertion removed or loosened. The two edits made here make tests stricter.

## Nits (not blocking)

- Round tile shows the whole round's score ("7 right"), so a round across midnight shows the same score on both days, which the handoff's reason for dropping "/10" doesn't cover.
- Back from SCR-16 goes to the 7-day dashboard, not the period the parent had picked.
- A hand-typed future `d=` would make the date picker assert (initial date after today); no button leads there.
