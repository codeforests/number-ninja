# FEAT-19: Phone layout

> Implements: D18, NFR-17 · Screens: SCR-04 (quiz), SCR-08 and other PIN screens (`ScreenFrame` + `PinPad`), SCR-09, SCR-11, SCR-15
> Status: built · Branch: `claude/project-thread-tnfd5g` · 2026-11-20 · small feature (design and build in one thread)

## Scope

Ken's v2.0 feedback: on a phone the question screen needed scrolling to reach Check, and the parent pages didn't adapt. A phone is `compact(size)` in `lib/ui/layout.dart`: shorter side under 600 dp. Everything below applies only when `compact` is true, so the tablet layouts (1280 × 800, 960 × 600, portrait tablets) don't change.

## Design decisions

1. **Quiz, portrait phone:** the answer area sits at the bottom at its natural height (at most 60 % of the body, never less than 300 dp), the prompt and picture scroll in what's left. Prompt text is `AppText.body` instead of `heading`; the picture box min is 100 dp.
2. **Quiz, landscape phone:** the top bar (quit, progress, n/10) moves over the question half, so the answer half has the full height.
3. **Number keypad on a phone:** 4 × 3 keys (`1 2 3 ⌫ / 4 5 6 . / 7 8 9 0`), 64 dp each (NFR-03 holds), with the display and Check in one row above the keys. 288 × 288 dp.
4. **Drag answer and feedback:** `PinnedAction` (`lib/features/quiz/answers/pinned_action.dart`) keeps Check / Next in view and scrolls the boxes and chips, or the explanation, when the height is bounded (phone only; on a tablet they sit inside the existing scroll view, unbounded, so nothing changes).
5. **MCQ on a phone:** less button padding and `AppText.body` text so short words don't break mid-word.
6. **PIN pad on a phone:** 64 dp keys, 4 dp gaps; `ScreenFrame` puts the title beside the pad on a landscape phone.
7. **Parent pages on a phone:** the Done button on SCR-11 is normal app-bar size; SCR-09 track cards go two to a row filling the width when three don't fit. SCR-15 rows now start at the card's left edge on every size (they were centred: a layout bug, not a tablet design).
8. **Test fixes found on the way:** `ParentHarness.openParent` always reset the view to 2560 × 1600, so `parent_layout_test.dart` never ran at its six sizes; it now takes `size:`. `expectNoOverlap` compares what shows (each rect clipped to its scroll view), since the phone question area scrolls under a pinned answer area.

## Acceptance criteria

- **AC-1** (NFR-17 quiz): at 360 × 640 and 640 × 360, for the longest-prompt question of every template, every option or Check is wholly on screen and hit-testable, and after answering so is Next (`test/features/quiz/phone_layout_test.dart`).
- **AC-2** (NFR-02 unchanged): `compact` is false at 960 × 600, 600 × 960, 1280 × 800; `no_scroll_test.dart` and the existing responsive tests pass unchanged.
- **AC-3** (NFR-17 PIN): at both phone sizes every PIN key on SCR-08 and change PIN is in view (`test/features/parent/parent_phone_test.dart`).
- **AC-4** (NFR-17 parent): Done fits the app bar on a phone and keeps its size on the tablet; SCR-09 cards fill a portrait phone's width, three in a row on a landscape phone; SCR-15 rows start at the card edge.
- **AC-5** (NFR-09, NFR-03): `parent_layout_test.dart` passes at its real six sizes; existing child-size checks pass; full `scripts/check.sh` and CI APK build green. Version `2.0.1+4`.

## Tasks

- [x] T1 — `compact`, quiz phone layout, number keypad, drag/feedback/MCQ, tests.
- [x] T2 — PIN pad and `ScreenFrame`, parent Done button, SCR-09 cards, SCR-15 rows, harness fix, tests, docs.
