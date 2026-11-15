# Number Ninja: Plan

> Version 1.0 (signed off by Ken 2026-11-14) · 2026-11-14 · From [01-requirements.md](01-requirements.md) and [02-design.md](02-design.md)

## 1. Features in build order

Each feature is a vertical slice that ends in something Ken can install and try. Feature ids are permanent.

| Feature | What it delivers | Requirements | Milestone |
|---|---|---|---|
| FEAT-01 | Walking skeleton: app shell, theme, database, first-run PIN setup, PIN entry with lockout, parent area stub, CI building the APK | PAR-01..04, NFR-01, NFR-06..08 | M1 |
| FEAT-02 | Question bank v1: generator, validator, all 23 topics, bank loader | BNK-01..06 | M1 |
| FEAT-03 | Quiz engine: rounds of 10, three answer formats, drawn visuals, timing, feedback, results with stars | PRC-02..06, PRC-08, PRC-10, NFR-03..05 | M1 |
| FEAT-04 | Home and topic map: tracks, topics with stars, difficulty steps | PRC-01, PRC-07, PRC-09 | M2 |
| FEAT-05 | Screen-time lock: daily allowance, warning, lock screen, parent unlock and limits | TIM-01..06 | M2 |
| FEAT-06 | Parent dashboard: per-topic stats, trends, needs practice, topic detail, reset | PAR-05..08, PAR-10 | M3 |
| FEAT-07 | PDF report export | PAR-09 | M3 |
| FEAT-08 | Badges and badge shelf | BDG-01..03 | M3 |
| FEAT-09 | Tablet polish and v1.0 release: layout check on 12-inch landscape and portrait, app icon, release APK | NFR-02 | M4 |

**Milestones:** M1 = she can play a real round (FEAT-01..03). M2 = safe for daily use (04–05). M3 = parent insights and rewards (06–08). M4 = v1.0 (09). Ken tries the APK on the tablet at the end of each milestone and signs it off before the next one starts.

## 2. How each feature is built

One feature at a time, on branch `feat/FEAT-NN-<slug>`, one PR per feature. Each stage below runs in its own fresh thread, reads only `docs/STATE.md`, the feature's `handoff.md` and the design sections it needs, and ends by writing `handoff.md` and starting the next stage's thread (AGENTS.md, "How a session starts and ends"). Stages chain without waiting for Ken unless a decision is pending.

1. **Design** (`docs/features/FEAT-NN-<slug>/design.md`): scope, the requirement ids it implements, acceptance criteria (AC-1…), and a numbered task list with a "done when" check per task. Questions that change scope go to Ken before building. Ends with `handoff.md` and the build kickoff.
2. **Build:** one commit per task, tests written with the task, the task's check run before ticking it. At most 3 fix attempts on a stuck task, then stop and say so. After about 6 tasks, hand off to a fresh build thread. The last build session opens a draft PR and hands off to verify.
3. **Verify** (`verify.md`), done in a fresh thread that did not write the code: re-run all checks from a clean checkout, check each AC against evidence, review the test diff (no test weakened, skipped or deleted), and fill the **Verified by** column in the requirements. Verdict: accepted, rework, or design change.
4. **PR:** body lists the ACs with evidence and the CI result. Ken reviews and merges.

`docs/STATE.md` says which feature is next and what was merged; it is updated in every feature PR.

## 3. Rules carried over from earlier projects

- Signed-off documents change only by a recorded change (requirements §3 decision or design §9 row), never silently.
- Ids (requirements, decisions, features, screens, topics, question ids) are permanent.
- Never weaken, skip or delete a test to get green; a failing check goes back to build, or to design if the design is wrong.
- Traceability is never skipped: every PR fills its requirements' Feature and Verified by cells.
- Anything with dates or timers takes the clock as a parameter, so tests don't expire.
- Each stage leaves what the next one needs in the repo (`handoff.md`), not in chat, and never reads old threads.

## 4. Kept deliberately small

No separate architecture document, ADRs, UX foundations, design manifest or token logs: the design file per feature carries all of that at this size. Handoff files and the token rules (AGENTS.md) were added on 2026-11-14 at Ken's request, to keep each fresh thread's reading small. If the project grows (a second child, cloud sync, iOS), revisit this section.
