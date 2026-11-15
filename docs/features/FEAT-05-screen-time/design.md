# FEAT-05: Screen-time lock

> Implements: TIM-01..06 · Screens: SCR-02 (minutes left), SCR-07 (lock), SCR-11 (limit and extra time), SCR-04/05 (finish the current question)
> Status: designed · Branch: `feat/FEAT-05-screen-time` · 2026-11-15

## Scope

The app counts the time she spends on child screens each day (TIM-01). Two minutes before the day's allowance ends she sees a warning (TIM-03); when it runs out, she finishes the question she is on and then the lock screen SCR-07 replaces every child screen until tomorrow or until a parent grants extra minutes (TIM-02, TIM-04). With the PIN the parent changes the daily limit, 5–120 minutes (D5, TIM-04). Closing the app or setting the clock back doesn't give time back (TIM-05). Home shows minutes left (TIM-06). No schema change: `app_settings.daily_limit_min` and `daily_usage` already exist (design §4).

Not in scope: per-weekday limits, usage history in the dashboard (FEAT-06), stopping her from moving the device clock forward (a forward jump starts a new day; Android's own settings lock covers that, noted for Ken).

## Design decisions (this feature)

- **What counts (TIM-01):** only foreground time on child routes: home, topic map, quiz, result, lock. Setup, PIN entry and the parent area don't count, so a parent changing settings doesn't use her time.
- **Finish the current question (TIM-03):** when time runs out with a question open (answering or its feedback), that question stays: she answers it and sees its feedback. Next then goes to SCR-07 instead of the next question; on the round's last question Next shows SCR-05 as usual and its buttons go to SCR-07. This grace ends at the latest 2 minutes after time ran out (`graceCap`), so a question left open can't stretch the day. Grace time is still counted. An unfinished round stays a quit round (FEAT-04 rule).
- **Parent unlock (TIM-02, TIM-04):** SCR-07's Parent button opens PIN entry, then SCR-11, where "+5 / +10 / +15 / +30 min" adds to `extra_seconds_granted` for today. Raising the daily limit also unlocks. Done returns home, unlocked when minutes are left.
- **Display:** minutes left = `ceil(secondsLeft / 60)`, shown as "N min left" ("Time's up" at 0).

## Design

- **Domain** (`lib/domain/screen_time.dart`, pure Dart, design §5):
  - `String dayKey(DateTime)` → `yyyy-MM-dd` local; `String effectiveDay(DateTime now, String? latestRecorded)` = the later of `dayKey(now)` and `latestRecorded` (string compare works for this format) (TIM-05).
  - `ScreenTimeStatus {day, usedSeconds, limitMinutes, extraSeconds}` with `allowanceSeconds`, `secondsLeft` (≥ 0), `minutesLeft`, `warning` (0 < left ≤ 120), `timeUp` (left == 0). Constants `warnAt = Duration(minutes: 2)`, `graceCap = Duration(minutes: 2)`, `flushEvery = Duration(seconds: 10)`.
  - `abstract interface class UsageStore { Future<String?> latestDay(); Future<void> addSeconds(String day, int s); Future<ScreenTimeStatus> status(String day); }`.
  - `ScreenTimeClock(UsageStore, {required Clock now, required Duration Function() elapsed})`: `start()`/`stop()` gate counting; `flush()` adds whole elapsed seconds since the last flush (carrying the remainder) to `effectiveDay(now(), await latestDay())` and returns the new status. No timers inside; the caller drives `flush`. While stopped, `flush` adds nothing.
- **Data** (`lib/data/usage_repository.dart`, implements `UsageStore`): `addSeconds` upserts the `daily_usage` row; `status(day)` joins the row (or zeros) with `daily_limit_min`; `grantExtra(String day, int minutes)`; `setDailyLimit(int minutes)` (clamps to 5–120, design: D5). `usageRepositoryProvider` in `lib/providers.dart`.
- **Controller** (`lib/features/screen_time/screen_time_controller.dart`, a `ChangeNotifier`, `screenTimeProvider`, overridden in `main()` and tests like `appSessionProvider`):
  - Owns the `ScreenTimeClock` (prod elapsed = a `Stopwatch`), a `Timer.periodic(flushEvery)` that calls `flush`, and an `AppLifecycleListener`: hide/pause → flush and stop; show/resume → start (if on a child route).
  - `setChildRoute(bool)` from a listener on the router delegate (start/stop counting).
  - State: `status`, `holding` (grace active), `locked` = `status.timeUp && !holding`; notifies on change. A warning event fires once each time `warning` turns true (also after an extra grant runs down again).
  - `holdQuestion()` / `releaseHold()` for the quiz; the hold is only granted when time runs out with a question open, and expires `graceCap` after `timeUp` started (checked on each flush).
  - `grantExtra(minutes)` / `setDailyLimit(minutes)` call the repository, then refresh `status`.
- **Routing** (`app.dart`): route `Routes.locked = '/locked'` (SCR-07). `redirectFor(session, screenTime, location)`: after the PIN rules, if `locked` and the location is a child route → `/locked`; if not locked and at `/locked` → home. `/parent*` is never redirected by the lock. `refreshListenable: Listenable.merge([session, screenTime])`.
- **Quiz** (`quiz_controller.dart`, `quiz_screen.dart`): while a question is answering or in feedback, the screen holds; `next()` when `status.timeUp` releases the hold instead of showing the next question (the router then shows SCR-07). The last question's Next goes to SCR-05 as now; SCR-05 holds until a button is tapped.
- **Warning (TIM-03):** `MaterialApp.router` gets a `scaffoldMessengerKey`; on the warning event it shows a SnackBar "2 minutes left! Finish this question." (key `time-warning`, ≥ `AppText.body`, 6 s), on any child screen.
- **SCR-07** (`lib/features/screen_time/lock_screen.dart`): `ScreenFrame`-style centred page: a big icon, "Time's up for today!", "Come back tomorrow for more maths.", a Parent button (key `lock-parent`, ≥ 64 dp) → `Routes.pinEntry`. No back button; Android back stays on it (router redirect).
- **SCR-02 home:** under the title row, "N min left" (key `minutes-left`, `AppText.body`, `Icons.timer`), from `screenTimeProvider`.
- **SCR-11 parent** (`parent_screen.dart`): a "Screen time" section above Change PIN: "Today: U min used, L min left" (key `today-usage`); "Daily limit" with − / value / + (keys `limit-minus`, `limit-value`, `limit-plus`, steps of 5, disabled at 5 and 120); "Extra time today" buttons (keys `extra-5`, `extra-10`, `extra-15`, `extra-30`). Each tap saves at once.

## Acceptance criteria

- **AC-1** (TIM-01, TIM-05): `ScreenTimeClock` unit tests with a fake clock and elapsed source: adds elapsed seconds only between `start` and `stop`, carries sub-second remainders, crosses midnight into the new day, and with the device clock set back a day keeps adding to the later recorded day.
- **AC-2** (TIM-05): Drift test on a file database: add usage, close, reopen `AppDatabase` on the same file: used seconds are unchanged. `effectiveDay` tests for earlier, same and later dates.
- **AC-3** (TIM-02, TIM-06): widget test: with limit 20 and 19 min 50 s used, home shows "1 min left"; after 10 counted seconds the app shows SCR-07, and navigating to `/`, `/play/school` or `/quiz/<id>` lands on SCR-07. On the next day (clock moved forward) the lock lifts and home shows "20 min left".
- **AC-4** (TIM-03): crossing 120 s left shows the `time-warning` SnackBar once. Time running out with a question open: she can still answer it and see feedback; Next shows SCR-07, not question N+1; on the 10th question Next shows SCR-05 and Home then shows SCR-07. A question left open locks once `graceCap` has passed.
- **AC-5** (TIM-04, TIM-02): from SCR-07, Parent → correct PIN → SCR-11 → "+10 min" → Done shows home with "10 min left"; the limit stepper stops at 5 and 120 and the new limit is saved to `app_settings` and applied today. A wrong PIN keeps the lock (PAR-03 lockout still applies).
- **AC-6** (TIM-01): time on PIN entry, SCR-11 and while the app is paused (lifecycle hidden) is not counted.
- **AC-7** (NFR-09, NFR-03): SCR-07 and SCR-02 (with minutes left) at the six FEAT-04 sizes and text scale 1.3: no exception, tappables ≥ 64 dp, text ≥ 20 sp (`test/ui/layout_checks.dart`). Existing FEAT-03/04 tests pass unchanged.

## Tasks

- [ ] T1 — Domain `screen_time.dart` (`dayKey`, `effectiveDay`, `ScreenTimeStatus`, `UsageStore`, `ScreenTimeClock`).
      Done when: `scripts/check.sh 'flutter test test/domain'` passes with the AC-1 tests.
- [ ] T2 — Data `UsageRepository` (`addSeconds`, `status`, `latestDay`, `grantExtra`, `setDailyLimit`), provider.
      Done when: the AC-2 tests and existing `test/data` tests pass.
- [ ] T3 — `ScreenTimeController` (timer, lifecycle, child-route gating, lock state), `/locked` route and redirect, SCR-07, home minutes left; override in `main()` and test helpers.
      Done when: AC-3 and AC-6 widget tests and `flutter test test/features` pass.
- [ ] T4 — Grace hold in quiz and result, warning SnackBar.
      Done when: AC-4 widget tests and the existing quiz tests pass.
- [ ] T5 — SCR-11 screen-time section (usage, limit stepper, extra time).
      Done when: AC-5 widget tests pass.
- [ ] T6 — AC-7 layout checks; full `scripts/check.sh`; draft PR.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
