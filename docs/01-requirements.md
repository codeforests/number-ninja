# Number Ninja: Requirements

> Version 1.1 · 2026-11-15 (1.0 signed off by Ken 2026-11-14; 1.1 adds D9, PRC-11, NFR-09, NFR-10 from his M1 check)
> This file is also the traceability matrix: the **Feature** column is filled by planning, **Verified by** by each feature's verify step. IDs are permanent and never reused; a dropped requirement keeps its row marked *Removed*.

## 1. Purpose and scope

Number Ninja is an offline Android tablet app that helps one child (Singapore primary school, entering P2 in 2027) practise maths. It covers P1 revision, the P2 MOE syllabus and Olympiad-style thinking, times every answer, and gives the parent a PIN-protected view of accuracy and speed per topic. It limits daily use to a parent-set number of minutes.

**Out of scope for v1:** iOS, accounts, cloud sync or backup, more than one child, read-aloud or other languages, questions generated on the device at run time, Play Store publishing.

## 2. Users

| User | Needs |
|---|---|
| Child (7–8 years old) | Big, friendly screens; short rounds; clear right/wrong feedback; badges to collect. Reads simple English. |
| Parent (Ken) | Knows which topics are weak or slow, sets screen time, exports a report. The only person who knows the PIN. |

## 3. Decisions recorded

| ID | Decision | Date |
|---|---|---|
| D1 | Questions come from a fixed bank generated once by a script and shipped with the app; new questions ship as a new app version. | 2026-11-14 |
| D2 | P1 revision plus P2 MOE syllabus; plain addition and subtraction drills are skipped (regrouping and word problems stay). | 2026-11-14 |
| D3 | Olympiad styles: patterns, logic puzzles, counting, model drawing. | 2026-11-14 |
| D4 | Answer formats: multiple choice, typed number, drag and drop. | 2026-11-14 |
| D5 | Screen time is a daily allowance, 20 minutes by default, changed only with the parent PIN. | 2026-11-14 |
| D6 | Badges for motivation; English only; no voice. | 2026-11-14 |
| D7 | Offline only, data on the device, no backup. One child. | 2026-11-14 |
| D8 | Target device: Android tablet around 12 inches, landscape first. | 2026-11-14 |
| D9 | After the M1 tablet check (Ken, 2026-11-15): layouts must also work on smaller screens without overlapping (NFR-09), and the child screens get a more kid-friendly look with short sound effects (PRC-11, NFR-10). Sound effects are not voice, so D6 still holds: no speech, English text only. | 2026-11-15 |

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

### Badges (BDG)

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| BDG-01 | The app shall award badges by rules defined in code (about 20, listed in the design) and record when each was earned. | M | FEAT-08 | FEAT-08 verify.md (2026-11-15) |
| BDG-02 | A newly earned badge shall be celebrated on the round result screen. | M | FEAT-08 | FEAT-08 verify.md (2026-11-15) |
| BDG-03 | A badge shelf shall show earned badges in colour and unearned ones as silhouettes with their hint. | M | FEAT-08 | FEAT-08 verify.md (2026-11-15) |

## 5. Non-functional requirements

| ID | Requirement | Pri | Feature | Verified by |
|---|---|---|---|---|
| NFR-01 | The app shall work fully with no network connection and request no internet permission. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| NFR-02 | Layouts shall fit a 12-inch landscape tablet without scrolling during a question, and stay usable in portrait. | M | FEAT-09 | FEAT-09 verify.md (2026-11-15) |
| NFR-03 | Tap targets on child screens shall be at least 64 × 64 dp; text at least 20 sp. | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| NFR-04 | The next question shall appear within 300 ms of tapping Next on the target tablet. | S | FEAT-03 | FEAT-03 verify.md (2026-11-15, tests); tablet timing: Ken's M1 check |
| NFR-05 | All progress shall survive the app being killed; an answer is saved before the next question shows. | M | FEAT-03 | FEAT-03 verify.md (2026-11-15) |
| NFR-06 | The app shall run on Android 7.0 (API 24) and later. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| NFR-07 | CI shall build a release APK on every push to main and every pull request, and run all tests. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| NFR-08 | Logic with dates or timers shall take the clock as a parameter so tests never depend on today's date. | M | FEAT-01 | FEAT-01 verify.md (2026-11-14) |
| NFR-09 | On screens smaller than the target tablet, down to 640 × 360 dp (landscape or portrait), no text, picture or answer control shall overlap another or be cut off; the page may scroll instead. (D9) | M | FEAT-04 | FEAT-04 verify.md (2026-11-15) |
| NFR-10 | Child screens shall have a colourful, kid-friendly look: coloured backgrounds per track, a celebration when a round ends, colours still from `theme.dart`. (D9) | S | FEAT-09 | FEAT-09 verify.md (2026-11-15) |
