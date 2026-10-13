# Manuscript

The manuscript is the project's product specification: what to build, how it should look and behave, in what order, and how to check it. It is written and revised with the user in `/brainstorm` sessions (the role is `Instructions/BRAINSTORMER.md`), and the developer (`/start`) builds from it. It is optional: a project can also run on the user's instructions alone.

## When it is active

The manuscript is active when both `INTRO.md` and `TASKS.md` have content. Then it is the product source of truth (precedence is in `Instructions/PROGRAMMER_GPT_MASTER.md`). Otherwise it is not used as a specification, even if other files have content; a `/brainstorm` session treats such content as an unfinished draft.

`SECURITY.md` is separate: it is active once `/fence` has applied it, independent of the rest.

## Files

| File | Holds |
| --- | --- |
| `INTRO.md` | Purpose, users, goals, non-goals, platform and constraints. |
| `SPEC.md` | Features: behaviour, rules, validation, edge cases, and what is out of scope. |
| `UI.md` | Look and feel, navigation, screens and their states, shared components, links to the approved mockups in `Design/`. |
| `DATA_MODEL.md` | What is stored: entities, fields, identifiers, relationships, statuses, where and how long it is kept. |
| `DECISIONS.md` | The decision log: what was chosen, by whom, and why. |
| `TASKS.md` | Milestones and tasks, in build order, with status and acceptance criteria. |
| `TEST_PLAN.md` | How each milestone is checked, and how to run the checks. |
| `SECURITY.md` | Access outside the project folder: always OK, always ask, always deny. Format and procedure in `.claude/commands/fence.md`. |

Two archive files are created the first time a milestone is accepted (see "Archiving accepted milestones"); a project without them simply hasn't archived anything yet:

| File | Holds |
| --- | --- |
| `TASKS_DONE.md` | Accepted milestones, moved out of `TASKS.md` unchanged. |
| `DECISIONS_ARCHIVE.md` | Decisions that only concerned accepted milestones, moved out of `DECISIONS.md` unchanged. |

An empty file means "not written yet". A file that doesn't apply to the project (for example `UI.md` for a command-line tool) holds one line instead: `Not applicable: <reason>`.

## Who may change what

- **Brainstormer** (`/brainstorm`): everything except `SECURITY.md`, and only on the user's clear go. It alone moves accepted milestones to the archive files.
- **Developer** (`/start`), only these:
  - `TASKS.md`: the `Status:` line of each task, and splitting a task into subtasks (`M1-T3.1`, `M1-T3.2`) under it.
  - `TASKS.md`: a new task for a small change the user asked for directly, together with a `DECISIONS.md` entry (`By: user`). Changes to scope or direction belong in a `/brainstorm` session.
  - `DECISIONS.md`: new entries for material implementation decisions (`By: developer`).
  - `TEST_PLAN.md`: the "How to run the checks" section.
- **`SECURITY.md`**: changes only when the user decides; the brainstormer may suggest items. It takes effect when `/fence` applies it.
- **The user** may change any file at any time.

## Rules for changes

- IDs (`F1`, `S1`, `M1-T1`, `D1`) are never renumbered or reused.
- Nothing is deleted to remove it: a task becomes `DEFERRED` with a reason, a decision becomes superseded, a feature moves to "Out of scope". Moving an accepted milestone or its decisions to an archive file is not deleting: the text is copied unchanged and stays searchable by its ID.
- `SPEC.md`, `UI.md`, and `DATA_MODEL.md` always describe the current target, not its history. The history, and the reason for each change, is in `DECISIONS.md`.
- A task that is `DONE` stays as it is. If built behaviour has to change, that is a new task.

## Reading the manuscript

Everything read at the start of a session stays in its context and is paid for on every message, so the developer doesn't read the whole manuscript up front. At the start: `INTRO.md` and the current milestone of `TASKS.md`. While working on a task: search `SPEC.md`, `UI.md`, `DATA_MODEL.md`, `DECISIONS.md`, `TEST_PLAN.md` (and the archives, when a referenced ID isn't in the live file) for the IDs the task lists under `Covers:`, and read only those sections; read a data-model entity by its name, a mockup only for a UI task on its screen.

This only works if every task names what it needs: a task's `Covers:` line lists every feature, screen, and decision ID that bears on it, plus the data-model entities by name. A task without it is incomplete. Whoever adds a task (brainstormer, or developer for a small change) writes the line, and the reviewer flags tasks that lack it. A standing decision (an architecture, data, or security rule that applies to all later work) is listed in every task it constrains, so it isn't missed.

## Archiving accepted milestones

`TASKS.md` and `DECISIONS.md` only grow, and every session pays for what it reads. When the user accepts a finished milestone, the brainstormer archives it in the same step as the other manuscript changes (on the user's go, like any change):

- **A milestone is accepted** when every task in it is `DONE` or `DEFERRED` and the user says so in a `/brainstorm` session. The brainstormer offers it when it sees such a milestone that isn't archived yet; a project adopts this the first time it applies, with no separate migration.
- **`TASKS_DONE.md`**: the milestone's section is cut from `TASKS.md` and appended to `TASKS_DONE.md` unchanged (create the file with a `# Tasks done` title and one line saying what it is). In `TASKS.md`, keep one line where it was: `## M<n> <name>: accepted YYYY-MM-DD, in TASKS_DONE.md`. This keeps `TASKS.md` non-empty, so the manuscript stays active.
- **`DECISIONS_ARCHIVE.md`**: a decision moves, unchanged, only when it is `superseded`, or when it only concerned the accepted milestone and no remaining task lists it under `Covers:`. A standing decision stays in `DECISIONS.md`. When in doubt, it stays. The file is created like `TASKS_DONE.md`.
- **Nothing else changes.** IDs, statuses, and text stay as they were, `SPEC.md`, `UI.md`, and `DATA_MODEL.md` still describe the current target, and a reference to an archived ID still resolves by searching the archive. The brainstormer records the archiving as one `DECISIONS.md` entry.
- A `DONE` task in the archive stays as it is; if its behaviour has to change, that is a new task, as above.

## Issues

`Instructions/ISSUES.md` is how the developer hands the brainstormer something it may not decide itself. It sits outside the manuscript on purpose: an issue is a request for a decision, never part of the specification, and it doesn't count toward whether the manuscript is active. What gets decided is written into the manuscript and `DECISIONS.md`, and the issue then points there.

- **The reviewer** (`/review`, `Instructions/REVIEWER.md`) raises an issue when it finds the manuscript unclear or contradicting itself, or the code right and the spec wrong. It never changes the manuscript.
- **When the developer raises one:** the manuscript is active, and the work shows that a product decision is needed: a conflict or gap in the manuscript, a requirement that can't be built as written, or a change to behaviour, scope, UI, or data. Ordinary implementation choices are not issues: the developer makes them and records the material ones in `DECISIONS.md`. Without an active manuscript there's nothing to revise, so the developer asks the user directly.
- **Raising one doesn't stop the work.** The developer continues with everything the issue doesn't affect. A task that can't continue without the answer gets `Status: BLOCKED — HUMAN ACTION REQUIRED: decide I<n> (/brainstorm)`.
- **Statuses:**

  | Status | Meaning |
  | --- | --- |
  | `NEW` | Raised, not taken up yet. |
  | `UNDER WORK` | Being discussed in a `/brainstorm` session. |
  | `SOLVED` | Decided and written into the manuscript. The closed entry names the decisions (`→ D7, D8`). |
  | `DECLINED` | The user decided against it. The reason is kept, so it isn't raised again. |

- **Who may change what:**
  - Developer: adds issues, and may add findings to an issue that is still `NEW`. It closes an issue only when the user decides it directly in a developer session and it's a small change (a new task with a `DECISIONS.md` entry `By: user`, as above); otherwise it doesn't change statuses.
  - Brainstormer: sets `UNDER WORK` when the discussion of an issue starts, and closes it as `SOLVED` or `DECLINED` on the user's go, in the same step that writes the manuscript changes.
  - The user: may add or change issues at any time.
- **IDs** (`I1`, `I2`, …) are never renumbered or reused. A closed issue moves from "Open" to a one-line entry under "Closed".
- A project created before this file existed may not have it. Whoever raises the first issue creates it, with the header in the format below.

## Formats

A manuscript in another format (for example one written before this template had `/brainstorm`) still counts as it is. The developer works with it without reformatting it; the next `/brainstorm` revision converts it.

### INTRO.md

```
# <Project name>

## Purpose
## Users
## Goals
## Non-goals
## Platform and constraints
```

### SPEC.md

```
# Specification

## Features

### F1 <feature name>
- Behaviour: <what it does, step by step where it matters>
- Rules and validation: <...>
- Edge cases: <...>

## Out of scope
- <what the application deliberately doesn't do>
```

### UI.md

```
# UI

## Look and feel
<colours, typography, density, tone; which references in Source-files/ it follows>

## Navigation
<the screens and how the user moves between them>

## Screens

### S1 <screen name>
- Purpose: <...>
- Shows: <...>
- Actions: <...>
- States: empty: <...>; loading: <...>; error: <...>; first run: <...>
- Mockup: Design/<file>.html (approved YYYY-MM-DD)

## Components
<elements shared by several screens>
```

If a mockup and the text disagree, the text wins: the mockup shows the look, `UI.md` defines the behaviour.

### DATA_MODEL.md

```
# Data model

## Entities

### <Entity>
| Field | Type | Required | Notes |
| --- | --- | --- | --- |
- Identifier: <...>
- Relationships: <...>
- Statuses: <values and allowed transitions, if any>

## Storage
<where data is kept, how long, derived vs stored values>
```

### DECISIONS.md

Newest entry last.

```
# Decisions

### D1 <short title>
- Date: YYYY-MM-DD
- By: user | brainstormer | developer
- Decision: <...>
- Why: <...>
- Status: active | superseded by D<n>
```

### TASKS.md

The current milestone is the first one with tasks that are not `DONE` or `DEFERRED`. An accepted milestone is one line pointing to `TASKS_DONE.md` ("Archiving accepted milestones"). Statuses are the ones in `Instructions/AUTONOMOUS_EXECUTION_PROTOCOL.md`; a blocked task says what's needed: `Status: BLOCKED — HUMAN ACTION REQUIRED: <action>`.

```
# Tasks

## M1 <milestone name>
Goal: <what the user can do when this milestone is done>

### M1-T1 <task title>
- Status: TODO
- Depends on: none | M1-T<n>
- Covers: <every ID that bears on this task: F1, S2, D4, ...; data-model entities by name>
- Done when: <acceptance criteria that can be checked>
```

### TEST_PLAN.md

```
# Test plan

## How to run the checks
<commands for tests, lint, build; filled in by the developer once they exist>

## M1 <milestone name>
- <check>: <expected result>

## Manual checks
- <what a person checks by hand, and what they should see>
```

### ISSUES.md

In `Instructions/`, not in `manuscript/`. Newest open issue last.

```
# Issues

Findings that need a product decision, for the next `/brainstorm`: raised mostly by the developer (and the reviewer),
decided by the user with the brainstormer. Rules and format: "Issues" in
`Instructions/manuscript/README.md`.

## Open

### I1 <short title>
- Date: YYYY-MM-DD
- Raised by: developer | reviewer | user
- Status: NEW | UNDER WORK
- Kind: problem | change | question
- Affects: <IDs, e.g. F2, S1, M1-T4, D3>
- Found: <what was discovered, with evidence: file, test, observed behaviour>
- Suggestion: <the options, with the raiser's recommendation>
- Meanwhile: <what the developer does until it's decided, e.g. "continues with M1-T5; M1-T4 BLOCKED">

## Closed

- I<n> <title>: SOLVED YYYY-MM-DD → D<n> (<tasks added or changed>)
- I<n> <title>: DECLINED YYYY-MM-DD: <reason>
```

An empty section holds `- None.`
