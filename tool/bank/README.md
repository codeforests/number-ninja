# Question bank generator (FEAT-02)

`dart run tool/generate_bank.dart` builds every template, validates the bank
(`lib/domain/bank_validator.dart`) and writes `assets/questions/bank_v1.json`,
one question per line. Pass a topic prefix (`p1`, `p2`, `oly`, `p2.time`) to
build and validate only those topics without writing the file. CI regenerates
the bank and fails if the committed file differs.

| File | Holds |
|---|---|
| `generator.dart` | `Draft`, `Template`, `Handwritten`, `retry()`, seeding, `buildBank`, `encodeBank` |
| `helpers.dart` | random helpers, names, money and regrouping helpers |
| `templates_p1.dart`, `templates_p2.dart`, `templates_oly.dart` | the templates, by track |
| `handwritten.dart` | hand-written `oly.logic` and `oly.counting` questions |
| `bank.dart` | the list of all templates and `buildFor(prefix)` |

## Rules for v2 and later (BNK-05)

- Each template has its own `Random`, seeded with FNV-1a of `<topic>.<name>`.
  Adding a template or topic never changes another template's questions.
- Never rename a template, change its draws (the code before the `return`
  of an existing branch) or lower its `count`. To fix a bad question, add a
  new template and retire the old one in a new bank version, noting the ids.
- Raising `count` appends new ids (`.061`, ...); existing ids keep their
  content.
- Hand-written entries are numbered by position within their topic: only append.
- A new bank is a new file (`bank_v2.json`) with `version: 2`, written by a
  new app version.

## Visuals FEAT-03 draws

| `kind` | Fields | Notes |
|---|---|---|
| `clock` | `h` 1–12, `m` 0–55 (steps of 5) | analogue clock |
| `coins` | `cents`: list of 5, 10, 20, 50, 100 | Singapore coins, biggest first |
| `fraction` | `parts` 2–12, `shaded` | a bar or circle cut into equal parts |
| `groups` | `groups`, `each`, `icon` | icons: apple, star, ball, flower, orange, cookie, crayon |
| `pictureGraph` | `title`, `rows` [{`label`, `count`}], `scale` 1/2/5/10, `icon` | `count` is the real number; draw `count ÷ scale` icons (always whole). Icon: `child` |
| `barModel` | `bars` [{`label`, `units`, `unitValue?`, `known?`}], `total?` | `known` is an extra labelled part after the units; `unitValue` labels each unit; `total` a brace over all bars |
| `shapes` | `items` [{`shape`, `color`}] | shapes: circle, square, triangle, rectangle, semicircle, quarter circle; colours: red, blue, yellow, green |
| `ruler` | `cm` 1–15 | an object from 0 to `cm` on a ruler |
| `figure` | `name` | `triangle-split-3` (triangle with 2 lines from the top corner to the base), `square-diagonals`, `grid-2x2`, `grid-3x3`, `grid-2x3` (2 rows, 3 columns) |

Fractions in options are written `3/8`; times are `3:25` or `3:25 p.m.`;
money is `$3.05` or `45¢`. Typed money answers are in dollars (`3.05`) or
cents, as the prompt says.
