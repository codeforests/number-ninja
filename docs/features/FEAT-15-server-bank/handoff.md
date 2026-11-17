# Handoff: FEAT-15 — Server question bank
Branch: claude/project-thread-665xht · PR: https://github.com/codeforests/number-ninja/pull/20 (draft) · Updated: 2026-11-17 by build
Stage done: build (T1–T5 of 5; design and build in one thread)
Next: verify — kickoff: "Verify FEAT-15 on branch claude/project-thread-665xht. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Branch is `claude/project-thread-665xht`, not `feat/FEAT-15-…` (session branch rule). Code head 3a12da2.
- Bank asset renamed `bank_v1.json` → `bank.json`; only header change is `"format":1`. `QuestionBank.byTopic` = active only, `byId` = all.
- `banks.version` is now a number (migration 1763251204); no bank had been published, so nothing lost.
- `tool/publish_bank.dart` retries superuser sign-in on 429 (2 per 3 s limit). Tests use `--bank-file`; the default mode also checks the newest release tag's bundled bank (needs `fetch-depth: 0`, set in `publish-bank.yml`).
- Schema v8 columns are added before `_from6To7` in `onUpgrade` (that step rebuilds `app_settings` with all current columns); FEAT-14's migration test now compares to `db.schemaVersion` instead of 7.
- Live test `test/live/bank_live_test.dart` doesn't use the test binding (it would 400 every HTTP request).
- SCR-11 row is in the parent area, so NFR-03 64 dp isn't applied (same as the Server row).

## Left to CI or later
- APK build and the `server` job run only in CI (CI on PR #20 from 3a12da2). `server/test/run.sh` passed locally here.
- Live server: after merge Ken runs "Deploy server"; seeing an update on the tablet needs a `bankVersion` bump PR and "Publish bank".

## Pending for Ken
- none (merge needs his OK after verify)
