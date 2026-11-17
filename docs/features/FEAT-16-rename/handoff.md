# Handoff: FEAT-16 — New name and v2.0
Branch: claude/project-thread-1sd1wa · PR: https://github.com/codeforests/number-ninja/pull/27 · Updated: 2026-11-17 by build
Stage done: build (T1–T4 of 4)
Next: verify — kickoff: "Verify FEAT-16 on branch claude/project-thread-1sd1wa. Read docs/STATE.md and the feature's handoff.md, then do the Verify stage in AGENTS.md."

## What the next stage needs
- Ken chose spelling "BrainBubblz" (one word) and keypad option A "Candy keys" (mockup: /mnt/project-files/designs/keypad-progress-options.png); T4/AC-7 came from his tablet screenshot (dots ran off a phone screen).
- Old name kept on purpose (design decision 2, code-map Gotchas): app id, Dart package, `numberninja://` scheme, server unit/nginx file names, keystore alias, badge id `ninja-master`. AC-1 grep should ignore those and old features' docs.
- Server: new migration `1763251205_rename.js`, nginx return-page text, unit Description. Live only after "Deploy server" (needs Ken's OK).
- Version 2.0.0+3; CI release asset is now `brainbubblz-<tag>.apk`, artifact `brainbubblz-apk`.
- `regression.md` is Ken's tablet checklist for the v2.0 check.

## Left to CI or later
- APK build, server job (migration applies, nginx -t): CI on the PR.
- After merge: release `v2.0` (workflow_dispatch release=v2.0), Deploy server on Ken's OK.

## Pending for Ken
- Merge after verify; OK for "Deploy server"; tablet run of regression.md.
