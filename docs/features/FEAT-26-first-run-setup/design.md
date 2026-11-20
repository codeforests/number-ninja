# FEAT-26: Parent first-run setup

> Implements: SET-01..07 (D21) · Touches: PAR-01, PRO-02 (replaces their first-run screens), FAM-01, TIM-04, PRC-11, ACC-02/04, SYN-03 · Screens: SCR-19 (new, replaces SCR-01 and first-run SCR-12), SCR-13 forms reused
> Status: designed · Branch: `feat/FEAT-26-first-run-setup` · 2026-11-20 (auto mode: decisions below taken by Claude on Ken's standing instruction)

## Scope

A fresh install opens a step-by-step setup written for parents instead of today's bare PIN pad (SCR-01) followed by the profile form (SCR-12). Steps: Welcome (three cards) → PIN → Account (optional: sign in to bring the family back, or skip) → Children → Daily time and sound → You're set. Progress dots, Back on every step, big buttons; resumes at the same step if the app is killed; installs already set up never see it.

Not in scope: new illustration assets (AD-9), Plus/free messaging (FEAT-29/30), crash-report consent (FEAT-24 adds its own step if it needs one), changing the parent-area screens themselves.

## Design decisions (this feature)

Auto mode (Ken, 2026-11-20): each takes the recommended option; the reason follows the dash.

- **AD-1 One route, a persisted step.** `/setup` hosts the whole wizard (`SetupScreen`); the current step is saved as `app_settings.setup_step` (text, enum name; NULL = finished). It replaces `hasPin`/`profilePending` as the router's first-run test — one source of truth, and resuming is just reading it. `/setup/profile` goes away.
- **AD-2 Step order: Welcome, PIN, Account, Children, Time & sound, Done** (6 dots). Account comes before Children so a restored family skips the children and time steps (plan row). Time and sound share one step — both are short and per child, fewer taps for the parent.
- **AD-3 The step is saved on every forward move, in the same transaction as the step's own write** (PIN hash + step `account`; children + step `time`; …), so a kill never leaves the data and the step out of step.
- **AD-4 Resuming after the PIN asks for the PIN first** ("Welcome back. Enter your PIN to finish setting up", reuses `PinPad` and the PAR-03 lockout). Without it a child who restarts the app mid-setup could set her own time limit. Resuming at Welcome or PIN needs nothing.
- **AD-5 Back after the PIN is set doesn't make a new one.** The PIN step then shows "PIN is set" with "Change PIN" (enter twice again) and Next — Back must never lock the parent out of a PIN she just made.
- **AD-6 Account step reuses SCR-13's forms.** Extract the sign-in / create / forgot-password / Google forms from `account_screen.dart` into `AccountForms` (same file folder, keys unchanged) and use it in both places. Choices: "Sign in" (email or Google), "Create an account", and a large "Skip for now — you can do this later in the Parent area". ACC-04 still holds: the wizard is past the PIN, so only the parent is there (note added to ACC-04's row wording).
- **AD-7 Restore** (SET-04): after a successful sign-in the step shows "Bringing back your family…" and runs one sync (`SyncController.syncOnce()`, new: `requestSync` + await `idle`, returns the `SyncOutcome`), waiting at most 30 s. If afterwards any child has a nickname (AD-16 of FEAT-25 fills the blank child 1 from the account), the family came back: skip Children and Time & sound (their settings came back too) and go to Done, which names them. If the account has no children, the sync fails or times out, continue to Children as a fresh family; a later sync merges by nickname (FEAT-25 AD-9). A new account (sign-up) waits for email verification as today, so it always continues to Children with "Check your email to finish creating your account".
- **AD-8 Children step** lists the children added so far (avatar, nickname, year) with "Add a child" (hidden at 4, FAM-01) and Edit/Remove on each; at least one child is needed to go on. The form is SCR-12's fields extracted into `ChildForm` (nickname, school year, avatar; starting levels under "More options", closed by default since most parents won't need them). The first child added fills child 1 (FEAT-25 AD-2); later ones are `ChildRepository.add`. Removing during setup needs no PIN (it's the parent's own fresh setup, no progress yet).
- **AD-9 No new image assets.** Welcome cards use large Material icons on theme-coloured circles, matching the avatars (`AvatarCircle`) and the app icon colours; a style choice would wait on Ken, and the plan marks it optional. If Ken wants illustrations later it's a polish item.
- **AD-10 Time & sound**: one row per child with the SCR-11 stepper (5–120 in 5s, `minDailyLimit`/`maxDailyLimit`), preset to 20 with the line "We suggest 20 minutes a day (you can change it any time)". One "Sound effects" switch (default on) applies to every child set up here (sound is per child, FEAT-25 AD-6; one switch is enough at setup).
- **AD-11 Done page** shows a picture of the real home-screen parent button (the same widget, not tappable) and "To change settings or see progress, tap this button on the home screen and enter your PIN." "Start playing" finishes: `setup_step` = NULL, then the usual launch path (SCR-17 with 2+ children, else home).
- **AD-12 Upgrade (schema v10)**: `setup_step` is added; an install with no PIN gets `welcome`, one with a PIN but `profile_pending` gets `children` (it resumes behind the PIN, AD-4), everything else NULL — set-up installs never see the wizard (SET-07). `profile_pending` stays in the table, no longer read (FEAT-25 AD-12 pattern). Fresh databases start at `welcome`.
- **AD-13 Look**: a parent screen (`ScreenFrame` look, parent text sizes) but larger: step title `AppText` headline, body ≥ 18 sp, primary button full width ≥ 56 dp pinned at the bottom (`PinnedAction`), Back as a text button beside it. Copy says "your child" (no gendered words). Landscape tablet: illustration/heading on the left, content on the right (`sideBySide`); phone: stacked (NFR-09, NFR-17).

## Design

- **Domain** `lib/domain/setup.dart`: `enum SetupStep { welcome, pin, account, children, time, done }`, `SetupStep? parseStep(String?)`, `next(step, {required bool restored})` (account → done when restored), `back(step)`, `dotIndex(step)`. Pure, unit-tested.
- **Data**: schema v10, `app_settings.setup_step` (nullable text); `_from9To10` per AD-12 (`addColumn` before `_from6To7`, gotcha). `SetupRepository` (`lib/data/setup_repository.dart`): `step()`, `advance(to, {Future<void> Function()? write})` (transaction, AD-3), `finish()`. `setupRepositoryProvider`.
- **Session**: `AppSession` takes `setupStep` instead of `hasPin`/`profilePending` (`inSetup`, `setupUnlocked` for AD-4, `setupFinished()`); `main()` loads it from `SetupRepository`. `redirectFor`: `inSetup` → `/setup` for every location; `/setup` when not in setup → home. Old `pinCreated`/`profileSaved` callers go.
- **Screen** `lib/features/setup/`: `setup_screen.dart` (`SetupScreen`, switches on the step), `setup_frame.dart` (`SetupFrame`: dots `setup-dot-<i>`, title, body, `setup-back`, `setup-next`), one file per step widget (`welcome_step`, `pin_step`, `account_step`, `children_step`, `time_step`, `done_step`), `setup_controller.dart` (Notifier holding the step, calls `SetupRepository`). `setup_pin_screen.dart` is removed; `ProfileScreen` loses `firstRun`.
- **Extracted widgets**: `AccountForms` (from `account_screen.dart`), `ChildForm` (from `profile_screen.dart`); SCR-13 and SCR-12 keep their keys and tests.
- **Keys**: `setup-welcome-card-<0..2>`, `setup-pin-pad`, `setup-change-pin`, `setup-skip-account`, `setup-restoring`, `setup-add-child`, `setup-child-<id>`, `setup-limit-<id>-minus|plus|value`, `setup-sound`, `setup-parent-button-hint`, `setup-start`.

## Acceptance criteria

- **AC-1** (SET-01, SET-02): fresh install: Welcome → PIN (enter twice, mismatch says so and restarts) → Account → Skip → Children → add "Mia", P2, owl → Time & sound → set 30 min, sound off → Done → Start: home greets Mia; her limit is 30, sound off; the PIN opens the parent area. Dots show the step; Back works on every step and never re-creates a set PIN (AD-5).
- **AC-2** (SET-03): kill (rebuild the app from the database) at each step: it reopens at that step; after the PIN step it asks for the PIN first, and a wrong PIN keeps it there (lockout as PAR-03); data written before the kill is still there and not doubled.
- **AC-3** (SET-04): `FakeSyncServer` account with Mia and Leo: sign in on the Account step → "Bringing back your family" → Done names Mia and Leo, Children and Time steps skipped, their limits came back; launch shows SCR-17. Account with no children, or a failing server → Children step with no error dead end.
- **AC-4** (SET-05): Children step: "Add a child" hides at 4; edit and remove work; Next is disabled with no named child.
- **AC-5** (SET-07, migration): `migration_test.dart` v9 → v10: no PIN → `welcome`; PIN + profile pending → `children`; set-up install → NULL and launch goes straight home (or SCR-17) with no wizard.
- **AC-6** (SET-06, NFR-09, NFR-17): every step passes the six FEAT-04 sizes, text scale 1.3 and the phone sizes with no overlap; buttons ≥ 56 dp; SCR-12 and SCR-13 tests still pass after the extraction (unchanged, never weakened).
- **AC-7** (live, Ken, optional): set up a fresh install on the tablet; sign in with the existing account and see the family come back.

## Tasks

- **T1** Domain `setup.dart` + tests; schema v10, `_from9To10`, migration test (AC-5); `SetupRepository`; `AppSession`/`redirectFor`/`main()` on `setup_step`; code-map lines.
- **T2** `SetupFrame`, `SetupScreen`, `SetupController`; Welcome and PIN steps incl. AD-4 resume and AD-5; remove `SetupPinScreen` and its route, move its tests (AC-1 PIN part, AC-2).
- **T3** Extract `ChildForm`; Children step (AC-4); Time & sound step.
- **T4** Extract `AccountForms`; Account step, `SyncController.syncOnce()`, restore path (AC-3).
- **T5** Done step; full-path widget test (AC-1); kill/resume test at every step (AC-2).
- **T6** Layout tests (AC-6), `scripts/check.sh`, docs (02-design §6 SCR-19 row and change log, requirements Feature cells, STATE), draft PR.
