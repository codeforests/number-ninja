# Handoff: FEAT-16 — New name and v2.0
Branch: claude/project-thread-1sd1wa · PR: https://github.com/codeforests/number-ninja/pull/27 · Updated: 2026-11-17 by verify
Stage done: verify (accepted, code `c4d7222`)
Next: merge on Ken's go, then release `v2.0` (workflow_dispatch release=v2.0, asset `brainbubblz-v2.0.apk`) and "Deploy server" on Ken's OK.

## What the next stage needs
- Kept old name on purpose (code-map Gotchas): app id, Dart package, `numberninja://` scheme, server unit/nginx file names, keystore alias, badge id `ninja-master`.
- Server text (appName via `1763251205_rename.js`, return page) is live only after "Deploy server".
- PDF file name renamed to `brainbubblz-report-…` on Ken's ask (2026-11-20).

## Left to CI or later
- APK build and server job: CI on PR #27 at the verify head.

## Pending for Ken
- Merge PR #27; OK for "Deploy server"; tablet run of `regression.md` on v2.0.
