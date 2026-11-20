# Handoff: FEAT-24 — Crash reports
Branch: feat/FEAT-24-crash-reports · PR: none · Updated: 2026-11-20 by design
Stage done: design
Next: build — kickoff: "Build FEAT-24 (from T1) on branch feat/FEAT-24-crash-reports. Read docs/STATE.md and the feature's handoff.md, then do the Build stage in AGENTS.md."

## What the next stage needs
- Decisions AD-1..13 in design.md (auto mode); D22 and CRS-01..07 rows added to 01-requirements.md (Verified by blank).
- No new plugin: device info comes from a `brainbubblz/device` channel in `MainActivity.kt` (AD-5). CI's APK build at T6 proves it.
- Schema v11; add `app_settings.crash_reports` before `_from6To7` (gotcha).
- Upload must not carry the auth token: post with plain `http`, not the shared `PocketBase` client (AD-4).
- PocketBase 0.40.6: digest test runs the cron via `POST /api/crons/crash_digest` as superuser and reads the existing mail sink.
- `privacyNote` changes wording; update the SCR-13 test that checks it rather than weakening it.

## Left to CI or later
- APK build (Kotlin channel) and server job run in CI on the PR.
- AC-8 is Ken's optional live check. Live digest needs `CRASH_DIGEST_TO` in the server env (optional).

## Pending for Ken
- none (optional: give an address for the daily digest; it can be added any time)
