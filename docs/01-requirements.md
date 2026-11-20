# BrainBubblz: Requirements

> Version 2.0 · 2026-11-15 (1.0 signed off by Ken 2026-11-14; 1.1 adds D9, PRC-11, NFR-09, NFR-10 from his M1 check; 2.0 is the phase 2 amendment, D10–D16, signed off by Ken 2026-11-15)
> This file is also the traceability matrix: the **Feature** column is filled by planning, **Verified by** by each feature's verify step. IDs are permanent and never reused; a dropped requirement keeps its row marked *Removed*.

## 1. Purpose and scope

BrainBubblz (formerly Number Ninja) is an offline Android tablet app that helps one child (Singapore primary school, entering P2 in 2027) practise maths. It covers P1 revision, the P2 MOE syllabus and Olympiad-style thinking, times every answer, and gives the parent a PIN-protected view of accuracy and speed per topic. It limits daily use to a parent-set number of minutes.

**Out of scope for v1:** iOS, accounts, cloud sync or backup, more than one child, read-aloud or other languages, questions generated on the device at run time, Play Store publishing.

**Phase 2 (v2, D10–D16)** adds an optional parent account (email and password, or Google) that syncs her progress, badges and settings to Ken's own server and across devices; a question bank hosted on that server that the app updates by itself; a revision module for weak question types and recent mistakes; and a child profile that sets where each topic starts. Practice still works fully offline.

**Still out of scope in phase 2:** iOS, a web dashboard, more than one child per account in the app (the data model allows it later), AI-driven analysis (planned for a later phase, D12), questions written outside the generator, Play Store publishing (the new name, D16, is chosen now so it can be published later).

## 2. Users

| User | Needs |
|---|---|
| Child (7–8 years old) | Big, friendly screens; short rounds; clear right/wrong feedback; badges to collect. Reads simple English. |
| Parent (Ken) | Knows which topics are weak or slow, sets screen time, exports a report. The only person who knows the PIN. |

## 3. Decisions recorded

| ID | Decision | Date |
|---|---|---|
| D1 | Questions come from a fixed bank generated once by a script and shipped with the app; new questions ship as a new app version. *Superseded by D11.* | 2026-11-14 |
| D2 | P1 revision plus P2 MOE syllabus; plain addition and subtraction drills are skipped (regrouping and word problems stay). | 2026-11-14 |
| D3 | Olympiad styles: patterns, logic puzzles, counting, model drawing. | 2026-11-14 |
| D4 | Answer formats: multiple choice, typed number, drag and drop. | 2026-11-14 |
| D5 | Screen time is a daily allowance, 20 minutes by default, changed only with the parent PIN. | 2026-11-14 |
| D6 | Badges for motivation; English only; no voice. | 2026-11-14 |
| D7 | Offline only, data on the device, no backup. One child. *Superseded by D10 (still offline-first, still one child).* | 2026-11-14 |
| D8 | Target device: Android tablet around 12 inches, landscape first. | 2026-11-14 |
| D9 | After the M1 tablet check (Ken, 2026-11-15): layouts must also work on smaller screens without overlapping (NFR-09), and the child screens get a more kid-friendly look with short sound effects (PRC-11, NFR-10). Sound effects are not voice, so D6 still holds: no speech, English text only. | 2026-11-15 |
| D10 | Phase 2 (Ken, 2026-11-15): the parent may sign in to an optional account; her progress, badges, profile and settings then sync to the server and across devices. Practice never needs the network; data syncs when online. One child per account, with ids that allow more later. The PIN and its lockout stay on each device and never leave it. Reverses D7's "no backup". | 2026-11-15 |
| D11 | The question bank is also hosted on the server. The generator script stays the only source; a publish step uploads a new bank version. The app keeps its bundled bank as a fallback and switches to a newer published bank by itself. Reverses D1's "new questions = new app version". | 2026-11-15 |
| D12 | Revision module: rule-based in phase 2 (weak question types inside a topic, plus recent mistakes), offered automatically and counted as screen time. It sits behind one planner interface so an AI-driven analysis can replace or extend it in a later phase. | 2026-11-15 |
| D13 | Child profile set by the parent: nickname (no real name or birth date), school year, optional starting level per track. It decides only where a topic starts; PRC-09 steps take over after the first finished round. | 2026-11-15 |
| D14 | The server runs on Ken's existing DigitalOcean droplet (self-hosted, no paid cloud service), reached over HTTPS only. Details and alternatives in [04-architecture.md](04-architecture.md) (ADR-01, ADR-02). | 2026-11-15 |
| D15 | Sign-in with email and password (verification and forgot-password emails) and with Google. Account screens sit inside the PIN-protected parent area. | 2026-11-15 |
| D16 | The app gets a new name because "Number Ninja" clashes on Google Play. Ken's choice (2026-11-15): **Brain Bubblz**, with the domain `brainbubblz.com` (display spelling confirmed by Ken 2026-11-17 in FEAT-16: **BrainBubblz**, one word). An iOS app called "BrainBubbles" exists, so the "z" spelling matters. The Android application id stays `com.codeforests.number_ninja`, so the tablet updates in place and keeps her data. | 2026-11-15 |
| D17 | School topics unlock in order (Ken, 2026-11-15): a School topic opens only after the topic before it in its year is passed with at least 70 % correct. Olympiad topics are never locked. Rules in PRC-12..14; Ken confirmed the defaults on 2026-11-15, including that a year's topics stay locked until every topic of the year before is passed. | 2026-11-15 |
| D18 | Phone use (Ken, 2026-11-20, after v2.0): on a phone the question screen must show Check without scrolling, and the parent pages must adapt to the phone's size (NFR-17). Tablets keep their layout. | 2026-11-20 |
| D19 | Own domain (Ken, 2026-11-20, after buying `brainbubblz.com`): the server moves to `api.brainbubblz.com` (the old host is served until the old app is gone), email comes from `noreply@brainbubblz.com`, and the Android application id becomes `com.brainbubblz.kids` with the sign-in link `brainbubblz://signin`. The new id installs as a new app; her data comes back through sync. Replaces D16's "application id stays". | 2026-11-20 |
| D20 | Siblings (plan §6 decision 5, auto mode 2026-11-20): up to 4 children per family on one device and account, each with own progress, settings and daily screen-time limit; a "Who's playing?" picker, switching needs no PIN unless the parent turns that on; removing a child deletes her data on every device. Details: FEAT-25 design AD-1..15. | 2026-11-20 |

## 4. Functional requirements

Priority: **M** = must for v1, **S** = should, **C** = could.

### Question bank (BNK)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| BNK-01 | The app shall ship a versioned question bank as a bundled asset and load questions only from it. | M | FEAT-02 | FEAT-02 verify.md (2026-11-14) |
| BNK-02 | The bank shall cover every topic in the design's topic list (P1 revision, P2, Olympiad), each tagged with track, topic and difficulty level 1–3. | M | FEAT-02 | FEAT-02 verify.md (2026-11-14) |
| BNK-03 | The bank shall hold at least 40 questions per topic. | M | FEAT-02 | FEAT-02 verify.md (2026-11-14) |
| BNK-04 | A generator script in the repo shall produce the bank reproducibly (same seed, same file) and fail if any question has a wrong answer, a duplicate, or an MCQ option list without exactly one correct option. | M | FEAT-02 | FEAT-02 verify.md (2026-11-14) |
| BNK-05 | Every question shall have a stable id that never changes between bank versions, so old results stay readable. | M | FEAT-02 | FEAT-02 verify.md (2026-11-14) |
| BNK-06 | Every question shall carry a short explanation of the answer shown after she answers. | S | FEAT-02 | FEAT-02 verify.md (2026-11-14) |
| BNK-07 | A publish step in the repo shall upload a new bank version to the server only after the generator's validator passes, and shall refuse a version that is not higher than the latest published one. (D11) | M | FEAT-15 | FEAT-15 verify.md (2026-11-17) |
| BNK-08 | When online, the app shall check for a newer published bank at launch and at most once a day, download it, verify its checksum and run the same checks as the bundled bank before keeping it. A failed download or check keeps the current bank. (D11) | M | FEAT-15 | FEAT-15 verify.md (2026-11-17) |
| BNK-09 | The app shall switch to a newly downloaded bank only between rounds, never during one, and shall fall back to the bundled bank if the downloaded file is missing or damaged. | M | FEAT-15 | FEAT-15 verify.md (2026-11-17) |
| BNK-10 | A newer bank shall keep every question id of the previous one (BNK-05); a question that should no longer be served is marked retired, so old results stay readable. | M | FEAT-15 | FEAT-15 verify.md (2026-11-17) |
| BNK-11 | The app shall ignore a published bank whose format needs a newer app version. | S | FEAT-15 | FEAT-15 verify.md (2026-11-17) |
| BNK-12 | The parent area shall show the bank version in use and when the app last checked for a new one. | C | FEAT-15 | FEAT-15 verify.md (2026-11-17) |

### Practice (PRC)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| PRC-01 | The child shall choose a track (School or Olympiad), then a topic, from screens that need no reading beyond short labels. | M | FEAT-04 | FEAT-04 verify.md (2026-11-15) |
| PRC-02 | A round shall have 10 questions from the chosen topic, shown one at a time. | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| PRC-03 | The app shall support multiple-choice, typed-number (on-screen keypad) and drag-and-drop questions. | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| PRC-04 | The app shall record, for every answer, the question id, answer given, correct or not, and time taken in milliseconds. | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| PRC-05 | After each answer the app shall show whether it was right and, if wrong, the correct answer and explanation. | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| PRC-06 | At the end of a round the app shall show score, total time and stars earned (0–3). | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| PRC-07 | The topic map shall show the best stars earned per topic. | S | FEAT-04 | FEAT-04 verify.md (2026-11-15) |
| PRC-08 | Rounds shall avoid repeating a question she answered correctly in her last 3 rounds of that topic, while questions remain. | S | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| PRC-09 | Difficulty shall step up after a 3-star round and down after a 0–1-star round in that topic. | S | FEAT-04 | FEAT-04 verify.md (2026-11-15) |
| PRC-10 | Pictures (clocks, shapes, coins, bar models, picture graphs) shall be drawn from question data, not image files. | S | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| PRC-12 | On the School track, each year's topics (P1, P2) shall unlock in the order of the design's topic list: the first P1 topic is open, the first topic of the next year opens when every topic of the year before is passed, and each later topic opens when the topic before it has a finished normal round with at least 7 of 10 correct (70 %), at any level. Olympiad topics are always open. (D17) | M | FEAT-17 | FEAT-17 verify.md (2026-11-16) |
| PRC-13 | Topics of a school year below the year in her profile (PRO-01) shall be open from the start, and a topic she has already passed, or that the parent has opened, stays open. | M | FEAT-17 | FEAT-17 verify.md (2026-11-16) |
| PRC-14 | A locked topic shall show a padlock and which topic to pass first, and shall not start a round; in the parent area, with the PIN, the parent shall be able to open any locked topic. | M | FEAT-17 | FEAT-17 verify.md (2026-11-16) |
| PRC-11 | The app shall play short sound effects (right answer, wrong answer, round complete, 3 stars), bundled with the app; the parent shall be able to turn sound off. (D9) | S | FEAT-09 | FEAT-09 verify.md (2026-11-15) |

### Screen time (TIM)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| TIM-01 | The app shall count time used per calendar day only while it is in the foreground. | M | FEAT-05 | FEAT-05 verify.md (2026-11-15) |
| TIM-02 | When the day's allowance (default 20 minutes) is used up, the app shall show a lock screen and allow no practice until the next day or a parent unlock. | M | FEAT-05 | FEAT-05 verify.md (2026-11-15) |
| TIM-03 | Two minutes before the allowance ends, the app shall warn her, and shall let her finish the current question before locking. | S | FEAT-05 | FEAT-05 verify.md (2026-11-15) |
| TIM-04 | With the PIN, the parent shall be able to change the daily allowance (5–120 minutes) and grant extra minutes for today. | M | FEAT-05 | FEAT-05 verify.md (2026-11-15) |
| TIM-05 | Closing and reopening the app, or changing the device clock backwards, shall not reset the day's used time. | M | FEAT-05 | FEAT-05 verify.md (2026-11-15) |
| TIM-06 | The home screen shall show minutes left today. | S | FEAT-05 | FEAT-05 verify.md (2026-11-15) |

### Parent area (PAR)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| PAR-01 | On first launch the app shall ask the parent to set a 4-digit PIN (entered twice) before the child can use it. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| PAR-02 | The parent area shall open only after the correct PIN; the PIN shall be stored only as a salted hash. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| PAR-03 | After 5 wrong PIN entries the app shall block PIN entry for 60 seconds. | S | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| PAR-04 | The parent shall be able to change the PIN after entering the current one. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| PAR-05 | The dashboard shall show, per topic, accuracy (% correct), average seconds per question and number of attempts, for a chosen period (7 days, 30 days, all time). | M | FEAT-06 | FEAT-06 verify.md (2026-11-15) |
| PAR-06 | The dashboard shall show weekly trends of accuracy and speed per track and per topic. | M | FEAT-06 | FEAT-06 verify.md (2026-11-15) |
| PAR-07 | The dashboard shall list "needs practice" topics: accuracy under 70% or average time above her own overall average, with at least 10 attempts. | S | FEAT-06 | FEAT-06 verify.md (2026-11-15) |
| PAR-08 | The parent shall be able to open a topic and see its most-missed and slowest questions. | S | FEAT-06 | FEAT-06 verify.md (2026-11-15) |
| PAR-09 | The parent shall be able to export a PDF report (period, per-track summary, per-topic table, trend charts, needs-practice list) and share or save it through Android's share sheet. | M | FEAT-07 | FEAT-07 verify.md (2026-11-15) |
| PAR-10 | The parent shall be able to reset all progress after confirming with the PIN. | C | FEAT-06 | FEAT-06 verify.md (2026-11-15) |
| PAR-11 | The parent shall be able to pick a calendar day and see, for that day: answers, accuracy, average seconds per question and screen time used; the same per topic; each round played (time, topic, level, score); and each question with her answer and the right answer. | S | FEAT-18 | FEAT-18 verify.md (2026-11-20) |

### Badges (BDG)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| BDG-01 | The app shall award badges by rules defined in code (about 20, listed in the design) and record when each was earned. | M | FEAT-08 | FEAT-08 verify.md (2026-11-15) |
| BDG-02 | A newly earned badge shall be celebrated on the round result screen. | M | FEAT-08 | FEAT-08 verify.md (2026-11-15) |
| BDG-03 | A badge shelf shall show earned badges in colour and unearned ones as silhouettes with their hint. | M | FEAT-08 | FEAT-08 verify.md (2026-11-15) |

### Child profile (PRO)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| PRO-01 | In the parent area the parent shall be able to set the child's nickname, school year and an optional starting level (1–3) per track. (D13) | M | FEAT-10 | FEAT-10 verify.md (2026-11-15) |
| PRO-02 | After first-run PIN setup (PAR-01) the app shall ask for the profile before the child can play; an existing install shall keep working and offer the profile in the parent area. | M | FEAT-10 | FEAT-10 verify.md (2026-11-15) |
| PRO-03 | A topic with no finished round shall start at the level the profile gives (the track override if set, else a level worked out from her school year and the topic's year), instead of level 1; after that PRC-09 applies. | M | FEAT-10 | FEAT-10 verify.md (2026-11-15) |
| PRO-04 | The home screen shall greet her by nickname. | C | FEAT-10 | FEAT-10 verify.md (2026-11-15) |

### Family (FAM)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| FAM-01 | In the parent area the parent shall be able to add up to 4 children (nickname, school year, starting levels, avatar), edit each, and remove one after confirming with the PIN; at least one child stays. (D20) | M | FEAT-25 | |
| FAM-02 | With more than one child, the app shall show "Who's playing?" (avatar and nickname) at launch, after leaving the parent area and from the home screen; changing child needs no PIN unless the parent turns on "Ask for PIN to change child". | M | FEAT-25 | |
| FAM-03 | Each child shall have her or his own levels, topic locks, badges, revision, stats, day view, PDF report and settings (daily limit, extra time, sound, parent-opened topics); PRO, PRC, REV, BDG and PAR rules apply per child. | M | FEAT-25 | |
| FAM-04 | Each child shall have her or his own daily screen-time allowance; one child's used time shall never count for another, and a locked child's lock screen shall let a sibling take over. | M | FEAT-25 | |
| FAM-05 | The parent dashboard, settings and day view shall show which child they are for and let the parent switch child. | M | FEAT-25 | |
| FAM-06 | While signed in, each child shall sync as its own record (SYN-02..05 per child); the first sign-in on a device shall merge children with the same nickname and add the rest; a reset (PAR-10, SYN-06) applies to one child; removing a child removes her data on the server and her other devices. | M | FEAT-25 | |
| FAM-07 | Updating from a one-child version shall make the existing progress, profile and settings the first child, with nothing lost. | M | FEAT-25 | |

### Revision (REV)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| REV-01 | The app shall work out her weak question types (a question type = one generator template inside a topic): enough recent attempts with low accuracy or slow answers, by rules defined in the design. (D12) | M | FEAT-11 | FEAT-11 verify.md (2026-11-16) |
| REV-02 | The app shall keep a list of recent mistakes: questions answered wrong recently and not answered right since. | M | FEAT-11 | FEAT-11 verify.md (2026-11-16) |
| REV-03 | After a round in a topic that has weak types or recent mistakes, the result screen shall offer a revision round for that topic; the home screen shall offer a revision round across all topics when there is enough to revise. | M | FEAT-11 | FEAT-11 verify.md (2026-11-16) |
| REV-04 | A revision round shall be built from her recent mistakes and her weakest types, use the normal quiz screen, feedback and timing (PRC-03..06), count as screen time, in stats and for badges, and not change topic levels (PRC-09). | M | FEAT-11 | FEAT-11 verify.md (2026-11-16) |
| REV-05 | The topic detail in the dashboard shall list the topic's weak question types. | S | FEAT-11 | FEAT-11 verify.md (2026-11-16) |
| REV-06 | Weak-spot analysis and revision building shall sit behind one planner interface in the domain layer, so a later AI planner can replace it without changing screens. | S | FEAT-11 | FEAT-11 verify.md (2026-11-16) |

### Account (ACC)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| ACC-01 | From the parent area the parent shall be able to create an account with email and password (at least 8 characters); the server sends a verification email. (D15) | M | FEAT-13 | FEAT-13 verify.md (2026-11-16; live at AC-6) |
| ACC-02 | The parent shall be able to sign in with email and password, or with Google. | M | FEAT-13 | FEAT-13 verify.md (2026-11-16; live at AC-6) |
| ACC-03 | The parent shall be able to ask for a forgot-password email and set a new password from its link. | M | FEAT-13 | FEAT-13 verify.md (2026-11-16; live at AC-6) |
| ACC-04 | Account screens shall be reachable only inside the PIN-protected parent area; the child never sees a sign-in prompt. | M | FEAT-13 | FEAT-13 verify.md (2026-11-16) |
| ACC-05 | The app shall keep the sign-in session in Android's encrypted storage and never store the password. | M | FEAT-13 | FEAT-13 verify.md (2026-11-16) |
| ACC-06 | The parent shall be able to sign out; progress stays on the device and syncing stops. | M | FEAT-13 | FEAT-13 verify.md (2026-11-16; live at AC-6) |
| ACC-07 | The parent shall be able to delete the account, which deletes all of the child's data on the server after confirming with the PIN; data on the device stays. | M | FEAT-13 | FEAT-13 verify.md (2026-11-16; live at AC-6) |

### Sync (SYN)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| SYN-01 | Every child feature shall work with no network; the database on the device stays what the app reads, and sync runs in the background without slowing or blocking practice. (D10) | M | FEAT-14 | FEAT-14 verify.md (2026-11-16; live at AC-9) |
| SYN-02 | While signed in, the app shall sync rounds, attempts, badges, the child profile, settings (daily limit, sound) and daily screen time; the PIN and lockout never leave the device. | M | FEAT-14 | FEAT-14 verify.md (2026-11-16; live at AC-9) |
| SYN-03 | On the first sign-in on a device, progress already on it shall be uploaded and merged with the account's, never lost or doubled. | M | FEAT-14 | FEAT-14 verify.md (2026-11-16; live at AC-9) |
| SYN-04 | Merging shall follow the rules in [04-architecture.md](04-architecture.md) ADR-04: records only ever added are merged by id; a round's finish only moves forward; a badge keeps its earliest date; profile and settings take the latest change; screen time adds up across devices for the day. | M | FEAT-14 | FEAT-14 verify.md (2026-11-16; live at AC-9) |
| SYN-05 | The app shall sync at launch, on resume, after each finished round, every 5 minutes while online, and on "Sync now" in the parent area; failures retry with growing delays. | M | FEAT-14 | FEAT-14 verify.md (2026-11-16; live at AC-9) |
| SYN-06 | A PAR-10 reset on a signed-in device shall also clear the account's progress on the server and on her other devices at their next sync. | M | FEAT-14 | FEAT-14 verify.md (2026-11-16; live at AC-9) |
| SYN-07 | The parent area shall show the signed-in email, the last successful sync time and any sync error in plain words. | S | FEAT-14 | FEAT-14 verify.md (2026-11-16; live at AC-9) |

## 5. Non-functional requirements

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| NFR-01 | The app shall work fully with no network connection and request no internet permission. *Superseded by NFR-11 (D10).* | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| NFR-02 | Layouts shall fit a 12-inch landscape tablet without scrolling during a question, and stay usable in portrait. | M | FEAT-09 | FEAT-09 verify.md (2026-11-15) |
| NFR-03 | Tap targets on child screens shall be at least 64 × 64 dp; text at least 20 sp. | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| NFR-04 | The next question shall appear within 300 ms of tapping Next on the target tablet. | S | FEAT-03 | FEAT-03 verify.md (2026-11-15, tests); tablet timing: Ken's M1 check |
| NFR-05 | All progress shall survive the app being killed; an answer is saved before the next question shows. | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| NFR-06 | The app shall run on Android 7.0 (API 24) and later. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| NFR-07 | CI shall build a release APK on every push to main and every pull request, and run all tests. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| NFR-08 | Logic with dates or timers shall take the clock as a parameter so tests never depend on today's date. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| NFR-09 | On screens smaller than the target tablet, down to 640 × 360 dp (landscape or portrait), no text, picture or answer control shall overlap another or be cut off; the page may scroll instead. (D9) | M | FEAT-04 | FEAT-04 verify.md (2026-11-15) |
| NFR-10 | Child screens shall have a colourful, kid-friendly look: coloured backgrounds per track, a celebration when a round ends, colours still from `theme.dart`. (D9) | S | FEAT-09 | FEAT-09 verify.md (2026-11-15) |
| NFR-11 | The app shall work fully with no network connection. It may request only the internet permission, used only for the account, sync and bank updates. (D10, replaces NFR-01) | M | FEAT-12 | FEAT-12 verify.md (2026-11-16) |
| NFR-12 | All traffic between app and server shall use HTTPS with a valid certificate; the app shall allow no plain-HTTP traffic. | M | FEAT-12 | FEAT-12 verify.md (2026-11-16; live certificate at AC-6) |
| NFR-13 | The server shall let a signed-in parent read and write only their own child's records, and let nobody write banks except the publish step; automated tests in CI shall prove these rules. | M | FEAT-12 | FEAT-12 verify.md (2026-11-16) |
| NFR-14 | Child data shall be kept to the minimum (nickname, school year, practice data); no ads, analytics or tracking SDKs; the parent area shall carry a short privacy note on what is stored and where. Data is handled in line with Singapore's PDPA. | M | FEAT-13 | FEAT-13 verify.md (2026-11-16) |
| NFR-15 | The server shall be set up from files in the repo (`server/`) with one deploy script, back up its data daily and keep 14 days of backups; a restore shall be tested once before v2.0. | M | FEAT-12 | FEAT-12 verify.md (2026-11-16; live backups and restore drill at AC-6) |
| NFR-16 | Syncing a year of practice (about 20,000 attempts) for the first time shall finish within 60 seconds on home Wi-Fi, and later syncs shall send only what changed. | S | FEAT-14 | FEAT-14 verify.md (2026-11-16; live at AC-9) |
| NFR-17 | On a phone (shorter side under 600 dp, down to 360 × 640 dp in either orientation), the answer controls of a question, with Check and Next, and every PIN key shall be in view without scrolling; parent pages shall use the phone's width. Tablet layouts stay as in NFR-02. (D18) | M | FEAT-19 | FEAT-19 verify.md (2026-11-20) |
