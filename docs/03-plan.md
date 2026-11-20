# BrainBubblz: Plan

> Version 2.0 · 2026-11-15 (1.0 signed off by Ken 2026-11-14; 1.1 adds Ken's M1 feedback, D9; 2.0 adds phase 2, signed off by Ken 2026-11-15) · From [01-requirements.md](01-requirements.md), [02-design.md](02-design.md) and [04-architecture.md](04-architecture.md)

## 1. Features in build order

Each feature is a vertical slice that ends in something Ken can install and try. Feature ids are permanent.

| Feature | What it delivers | Requirements | Milestone |
|---|---|---|---|
| FEAT-01 | Walking skeleton: app shell, theme, database, first-run PIN setup, PIN entry with lockout, parent area stub, CI building the APK | PAR-01..04, NFR-01, NFR-06..08 | M1 |
| FEAT-02 | Question bank v1: generator, validator, all 23 topics, bank loader | BNK-01..06 | M1 |
| FEAT-03 | Quiz engine: rounds of 10, three answer formats, drawn visuals, timing, feedback, results with stars | PRC-02..06, PRC-08, PRC-10, NFR-03..05 | M1 |
| FEAT-04 | Home and topic map: tracks, topics with stars, difficulty steps; layouts that fit smaller screens | PRC-01, PRC-07, PRC-09, NFR-09 | M2 |
| FEAT-05 | Screen-time lock: daily allowance, warning, lock screen, parent unlock and limits | TIM-01..06 | M2 |
| FEAT-06 | Parent dashboard: per-topic stats, trends, needs practice, topic detail, reset | PAR-05..08, PAR-10 | M3 |
| FEAT-07 | PDF report export | PAR-09 | M3 |
| FEAT-08 | Badges and badge shelf | BDG-01..03 | M3 |
| FEAT-09 | Polish and v1.0 release: layout check on 12-inch landscape and portrait, kid-friendly look (backgrounds, celebration) and sound effects with a parent off switch, app icon, release APK | NFR-02, NFR-10, PRC-11 | M4 |

### Phase 2 (v2.0)

| Feature | What it delivers | Requirements | Milestone |
|---|---|---|---|
| FEAT-10 | Child profile: SCR-12 after PIN setup and in the parent area, start level from the profile, greeting by nickname. Small feature (design and build in one thread). | PRO-01..04 | M5 |
| FEAT-17 | School topic unlocking: each year's School topics open in order after the previous one is passed at 70 %, padlocks on SCR-03, years below her profile year open, parent can open any topic. Built right after FEAT-10, as it uses the profile's school year. Small feature. | PRC-12..14 | M5 |
| FEAT-11 | Revision module: weak question types and recent mistakes behind `RevisionPlanner`, revision rounds from SCR-05 and the home screen (SCR-14), weak types on SCR-10 | REV-01..06 | M5 |
| FEAT-12 | Server foundation: PocketBase and Caddy on the droplet from `server/`, collections and API rules with tests in CI, deploy workflow, daily backups and a restore drill, internet permission and HTTPS-only app config, a health check from the app | NFR-11..13, NFR-15 | M6 |
| FEAT-13 | Parent account: SCR-13 with create account, verify, sign in, forgot password, Google sign-in, sign out, delete account, privacy note | ACC-01..07, NFR-14 | M6 |
| FEAT-14 | Sync: uuids and device ids (schema bump), push and pull with the ADR-04 merge rules, first-sign-in merge, reset across devices, sync status | SYN-01..07, NFR-16 | M6 |
| FEAT-15 | Server question bank: publish step in CI, download and checks in the app, safe switch between rounds, bank version on the parent area | BNK-07..12 | M7 |
| FEAT-16 | New name and v2.0 release: app label, icon text, docs and README renamed (application id kept), full regression on the tablet, release APK | D16 | M7 |
| FEAT-18 | Progress per day (asked by Ken after v2.0): SCR-16 shows one chosen day's totals, screen time, topics, rounds and answers; "By day" card on SCR-09. Small feature. | PAR-11 | after v2.0 |
| FEAT-19 | Phone layout: compact quiz keypad and layout with Check always in view, PIN pads and parent pages fitted to phones, tablet unchanged (after v2.0) | D18, NFR-17 | after M7 |

**Phase 2 milestones:** M5 = she gets the right starting level, School topics unlock in order, and revision rounds, still fully offline (FEAT-10, 17, 11; ids are permanent, so FEAT-17 is built before FEAT-11); no server needed, so it can ship while Ken sets up the droplet. M6 = parent account and sync across devices (12–14). M7 = server question bank and v2.0 under the new name (15–16). Same sign-off and `m<N>` release rule as M1–M4; the v2.0 release after FEAT-16 merges is tagged `v2.0`.

**Milestones:** M1 = she can play a real round (FEAT-01..03). M2 = safe for daily use (04–05). M3 = parent insights and rewards (06–08). M4 = v1.0 (09). Ken tries the APK on the tablet at the end of each milestone and signs it off before the next one starts. When a milestone's last PR merges, run the CI workflow on `main` with input `release` = `m<N>` (e.g. `m1`): it publishes a GitHub Release with the release-signed `number-ninja-m<N>.apk` for him to install.

## 2. How each feature is built

One feature at a time, on branch `feat/FEAT-NN-<slug>`, one PR per feature. Each stage below runs in its own fresh thread, reads only `docs/STATE.md`, the feature's `handoff.md` and the design sections it needs, and ends by writing `handoff.md` and starting the next stage's thread. What each stage reads and how it ends, including rework, re-verify and small features that design and build in one thread, is in AGENTS.md ("Stages"). Stages chain without waiting for Ken unless a decision is pending.

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

v1 had no separate architecture document or ADRs: the design file per feature carried that at its size. Phase 2 adds a server, so [04-architecture.md](04-architecture.md) now holds the server, sync and privacy decisions as ADRs; still no UX foundations or design manifest. Handoff files and the token rules (AGENTS.md) were added on 2026-11-14 at Ken's request, to keep each fresh thread's reading small; on 2026-11-15 `docs/code-map.md`, scoped rework and re-verify, fewer CI runs and a one-line-per-stage token log (in project files, not the repo) were added from the kakiagent build kit. If the project grows further (a second child in the app, iOS, AI analysis), revisit this section.

## 5. Open for Ken (phase 2)

1. **New app name (D16):** decided 2026-11-15: **Brain Bubblz** (`brainbubblz.com`). A web search found no app with that spelling; an iOS kids' brain-training app "BrainBubbles" exists, close but spelled differently. The in-app rename lands in FEAT-16.
2. **Hostname (ADR-02):** decided 2026-11-15: Ken buys `brainbubblz.com`, with `api.brainbubblz.com` pointing at the droplet. Needed before FEAT-12.
3. **Setup before FEAT-12** ([04-architecture.md](04-architecture.md) §5): DNS record, repo secrets, email-service account; Google OAuth client before FEAT-13.
4. **Optional:** DigitalOcean droplet backups for an off-box copy (about 20 % of the droplet's price).
