# FEAT-10: Child profile

> Implements: PRO-01..04 (D13) · Screens: SCR-12 (new), SCR-01 (next step), SCR-02 (greeting), SCR-03 (start level), SCR-11 (entry)
> Status: built · Branch: `feat/FEAT-10-child-profile` · 2026-11-15

## Scope

The parent sets a child profile: nickname, school year and an optional starting level (1–3) for each track, School and Olympiad (PRO-01). A new install asks for it right after the PIN is created, before she can play; an install updated from v1 keeps working and offers it in the parent area (PRO-02). A topic she has never finished starts at the level the profile gives; after the first finished round the PRC-09 steps take over (PRO-03). Home greets her by nickname (PRO-04).

Not in scope: syncing the profile (FEAT-14; ADR-04's per-field "last change wins" needs per-field times, which FEAT-14 adds), more than one child, topic unlocking by school year (FEAT-17 reads `schoolYear`).

## Design decisions (this feature)

- **Start-level rule (PRO-03).** `startLevel(profile, topic)`: no profile or unknown topic → 1. Track override set (School override for P1/P2 topics, Olympiad override for `oly.*`) → that. Else for a School topic of year Y and her school year C: `clamp(1 + C − Y, 1, 3)` (her own year starts at 1, a year below at 2, two or more below at 3, a year above at 1). For an Olympiad topic: `clamp(C − 1, 1, 3)` (P1–P2 → 1, P3 → 2, P4+ → 3). Pure function, no stored levels, so changing the profile changes the start of every topic not yet finished, and never a topic already played.
- **School year** is P1–P6 (`1..6`), chosen with six 64 dp chips. Only P1/P2 have topics today; the wider range costs nothing and keeps FEAT-17 and later banks simple.
- **Nickname**: trimmed, 1–20 characters, required. The field's helper text says "A nickname, not her real name" (D13: no real name or birth date). Starting levels: per track "Automatic" (null) or 1, 2, 3, default Automatic.
- **Who must fill it in.** A persisted flag `app_settings.profile_pending` (default true) means "ask for the profile before play". Schema v4 adds it and, on upgrade from v3, sets it false, so updated installs are not forced (PRO-02). A new install has it true from `onCreate`; saving the profile sets it false. If the app is closed between PIN and profile, the next launch asks again. The router reads it through `AppSession.profilePending` (loaded in `main()` like `hasPin`), so the router still listens only to the session and the lock (code-map gotcha).
- **Reset (PAR-10) keeps the profile**: it is a setting, like the PIN and daily limit, not progress.
- **Table `child_profile`** (schema v4): `id` = 1, `nickname`, `school_year`, `school_start_level` (nullable), `olympiad_start_level` (nullable), `updated_at`. One row, created on first save. FEAT-14 adds per-field change times and a uuid when it needs them.

## Design

- **Domain** (`lib/domain/profile.dart`): `class ChildProfile {nickname, schoolYear, schoolStartLevel?, olympiadStartLevel?}` with `==`; `const schoolYears = [1..6]`; `String? nicknameError(String raw)` (null when valid); `int? topicYear(Topic t)` (P1 → 1, P2 → 2, Olympiad → null); `int startLevel(ChildProfile? p, Topic? t)`. `TopicProgress.fresh(int level)` in `progress.dart` (`none` stays = `fresh(1)`).
- **Data**: `database.dart` schema 4 (table above, `AppSettings.profilePending`, migration `from < 4`). `lib/data/profile_repository.dart`: `ProfileRepository(AppDatabase db, {required Clock clock})` with `Future<ChildProfile?> load()`, `Stream<ChildProfile?> watch()`, `Future<void> save(ChildProfile p)` (upsert stamped `clock()`, and `profile_pending = false`, in one transaction), `Future<bool> pending()`. `RoundRepository.levelFor(topicId, {int start = minLevel})` returns `start` when the topic has no finished round. Providers: `profileRepositoryProvider`, `childProfileProvider` (FutureProvider.autoDispose of `load()`, invalidated by SCR-12 after a save; a Drift stream left pending timers in widget tests).
- **Session/router** (`providers.dart`, `app.dart`): `AppSession({hasPin, profilePending = false, clock})`, `profileSaved()` notifies. `redirectFor`: no PIN → `/setup`; PIN and `profilePending` → `Routes.setupProfile = '/setup/profile'` (from any location, parent area included); `/setup` or `/setup/profile` when nothing is pending → home. `Routes.profile = '/parent/profile'` (PIN-protected like the rest of `/parent`). Neither counts as screen time.
- **SCR-12** (`lib/features/profile/profile_screen.dart`, `ProfileScreen({required bool firstRun})`): parent styling (AppBar "Child profile", like SCR-11). Nickname `TextField` key `profile-nickname`; year choices key `year-<n>` (64 dp buttons, selected one filled with a tick); per track a row of four choices key `start-<school|olympiad>-<auto|1|2|3>`; one line under them key `profile-summary` saying where her own year, lower years and Olympiad start (e.g. "P2 topics start at level 1, P1 topics at level 2, Olympiad at level 1."), so the parent sees what Automatic means; Save button key `profile-save`, disabled until nickname and year are valid, error text key `profile-error`. Loads the saved profile when editing. After save: first run → home; parent → back to SCR-11. Scrolls (NFR-09).
- **SCR-01**: after `pinCreated()` goes to `/setup/profile` (the redirect would send it there anyway).
- **SCR-11**: a `ListTile` key `open-profile` "Child profile", subtitle the nickname and year ("Mia · P2") or "Not set yet".
- **Quiz** (`quiz_controller.dart`): loads the profile once per `start`, passes `start: startLevel(profile, topicsById[id])` to `levelFor` for the round topic and the mix-in topic.
- **SCR-03** (`topic_map_screen.dart`): unplayed tiles use `TopicProgress.fresh(startLevel(profile, topic))`, so the "Level N" label matches the round she gets.
- **SCR-02** (`home_screen.dart`): title "Hi, <nickname>!" key `greeting` when a profile exists, else "Number Ninja" as now; long nicknames ellipsize on one line.

## Acceptance criteria

- **AC-1** (PRO-03 rule): `test/domain/profile_test.dart`: no profile → 1 for every topic; years P1..P6 × a P1, a P2 and an Olympiad topic give the table of the rule; each override wins for its own track only; `nicknameError` rejects empty, spaces only and 21 characters, accepts 1 and 20 (after trim).
- **AC-2** (PRO-01 storage, PRO-02 flag): `test/data/profile_repository_test.dart` on an in-memory DB: a new DB is pending with no profile; `save` stores the fields with `updated_at` = clock, clears pending, a second save overwrites; `resetProgress` keeps it. `migration_test.dart`: v3 → v4 keeps data, adds an empty `child_profile` and sets `profile_pending` false.
- **AC-3** (PRO-02 flow): widget tests: a fresh app goes SCR-01 → PIN twice → SCR-12; with pending, `/`, `/play/school` and `/parent` redirect to `/setup/profile` (`redirectFor` tests); Save is disabled until a nickname is typed and a year picked; saving lands on home. An install with a PIN and nothing pending opens home, and SCR-11's `open-profile` opens SCR-12 showing the saved values, whose save returns to SCR-11.
- **AC-4** (PRO-03 in the app): quiz-harness test: with profile P2 and no rounds, a `p1.place` round starts at level 2 and a `p2.place` round at 1; with School override 3, at 3; after a finished 3-star `p1.place` round at level 2, the next is level 3 (PRC-09, profile no longer used). SCR-03 tiles show those levels.
- **AC-5** (PRO-04): home shows `greeting` "Hi, Mia!" with a profile and "Number Ninja" without.
- **AC-6** (NFR-03, NFR-09): SCR-12 at the six FEAT-04 sizes and text scale 1.3 has no overflow (`layout_checks.dart`, parent screen rules), and SCR-02 with a 20-character nickname still passes its child-screen checks. Existing tests pass unchanged.

## Tasks

- [x] T1 — `lib/domain/profile.dart`, `TopicProgress.fresh`.
      Done when: AC-1 passes: `scripts/check.sh 'flutter test test/domain/profile_test.dart'`.
- [x] T2 — Schema v4, `ProfileRepository`, `levelFor(start:)`, providers, `AppSession.profilePending` in `main()`.
      Done when: AC-2 passes: `flutter test test/data`.
- [x] T3 — SCR-12, routes and redirect, SCR-01 next step, SCR-11 entry.
      Done when: AC-3 passes: `flutter test test/features/profile test/features/pin_flow_test.dart test/features/parent`.
- [x] T4 — Start level in quiz and SCR-03; SCR-02 greeting.
      Done when: AC-4 and AC-5 pass: `flutter test test/features/quiz test/features/topics test/features/home`.
- [x] T5 — AC-6 layout checks; PRO-01..04 Feature cells; design §4/§9 rows; code-map lines; full `scripts/check.sh`; draft PR.
      Done when: `scripts/check.sh` all PASS and CI is green on the draft PR.
