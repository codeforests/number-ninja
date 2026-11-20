# Handoff: FEAT-25 — Siblings
Branch: feat/FEAT-25-siblings · PR: https://github.com/codeforests/number-ninja/pull/32 (ready) · Updated: 2026-11-20 by verify
Stage done: verify (accepted)
Next: merge PR #32 (auto mode), then design FEAT-26 — kickoff: "Design FEAT-26 on branch feat/FEAT-26-first-run-setup (create it from main). Read docs/STATE.md, then do the Design stage in AGENTS.md."

## What the next stage needs
- `verify.md` has the AC table; FAM-01..07 Verified by cells filled.
- FEAT-26 replaces SCR-01 → SCR-12 first run: since FEAT-25 there is always a child 1 (AD-2) and SCR-12 takes `?child=<id>|new`; "add children" in the wizard should reuse `ChildRepository.add` and the avatar row.
- M8 release `v2.2.0` comes after FEAT-24 (crash reports), not now.

## Left to CI or later
- APK build and `server/test/run.sh` on the PR's final head (CI). AC-10 two tablets per child: Ken, optional, after v2.2.0.

## Pending for Ken
- none
