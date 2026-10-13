# Project Startup Folder

This workspace is organized as a reusable project startup structure.

## Getting Started

New project from this template:
1. Run `new-project.sh <project-name>` in your projects folder. It creates the project folder from the newest template, without the template's own git history. (Copying the template folder by hand also works, but never copy its hidden `.git` folder: the project would then push into the template repo.)
2. Optional, for the GitHub backup: create an empty private repo with the same name on github.com (no README, license, or .gitignore).
3. Open the project folder and type `/start`. It checks the one-time setup and, after one yes, runs what's missing in order: `/install` (permission rules that keep the AI inside the project folder), `/fence` (if `Instructions/manuscript/SECURITY.md` has content to apply), and `/github` (connects and uploads the whole project folder over SSH). After that, every completed task is committed and pushed.

Projects on their own VM (for example a web application that runs and is tested on a virtual machine): there the VM is the sandbox, so the permission rules can be much looser and the approval prompts mostly disappear. After `/start`, type `/install vm` once; you create `.claude/settings.local.json` yourself with one command it shows (`cp .claude/install-baseline-vm.json .claude/settings.local.json`), because Claude Code refuses an AI that grants itself unrestricted Bash. It lets all Bash commands run without a prompt, drops the outside-the-project fencing, and allows `sudo` so the `.deb` can be installed and tested. It still asks before git commands that lose uncommitted work, and still blocks reading the credential folders, force-push, remote branch deletion, disk and power commands, and piping into a bare shell. The mode is stored per machine, in the git-ignored `.claude/settings.local.json`; the committed `.claude/settings.json` only holds the rules that suit every machine. So a PC and a VM can share one repo: the VM's loose rules never reach the PC, and each machine runs `/install` or `/install vm` once. `/start` recognises the mode and checks against the VM rules from then on; plain `/install` asks before switching back. Only use it on a VM that holds nothing but this project: the VM keeps the AI away from your PC, but not from what the VM itself can reach, so give it a GitHub key limited to this one repo, and keep other secrets and network access out of reach. Auto mode (or skipping permission prompts) is a separate choice in the Claude Code UI.

Existing project (on a new PC, or a fresh folder): don't copy the template. Clone the project's repo instead with `fetch-project.sh <project-name>` (or `git clone git@github.com:anderspetor/<project-name>.git`), open the folder, and type `/start`. It sets the commit author if missing and brings the rules and template files up to date.

Working from more than one machine (for example a PC and a VM): `/start` and `/brainstorm` begin by pulling what the other machine pushed (`git pull --ff-only`, which never merges), and `/end` pushes. So end the session on one machine before starting on the other. If both machines have commits the other lacks, `/start` stops and asks you how to combine them.

Planning the project: type `/brainstorm` instead of `/start`. The AI then acts as the brainstormer (`Instructions/BRAINSTORMER.md`): it works out with you what the application should do and how it should look, makes HTML mockups in `Design/` for you to open in a browser along the way, and on your go writes the manuscript in `Instructions/manuscript/`. When plans change after some coding, follow the routine below (`/end`, `/clear`, `/brainstorm`): the brainstormer starts from what's been built and revises the manuscript. If you type `/brainstorm` in a developer session anyway, it wraps up the developer work first (like `/end`) and carries on, but that session is large and costs more with every message. Don't use Plan mode for `/brainstorm`: it would block the mockups.

The routine (keeps sessions small and the handoff files current): a session starts with `/start` (developer) or `/brainstorm` (brainstormer), in a fresh session; either works as the first command, and `/brainstorm` needs no `/start` before it. When the session is done, type `/end`, then `/clear`, and begin the next session with the command for the role you want. Never switch role inside a session: always `/end`, `/clear`, then the new command. `/clear` can't be run by the AI, so it is always yours to type. `/brainstorm` doesn't run the setup and template-update checks that `/start` does, so use `/start` now and then (for example at the start of a working day).

From brainstorming back to building: type `/end`, then `/clear` (a clean session in the same window, or open a new one), then `/start`. The developer starts clean on purpose, so it builds only from what was written into the manuscript, not from ideas that were only discussed.

When the developer finds something it may not decide itself (a gap or conflict in the manuscript, a requirement that can't be built as written, a change that's needed), it writes it as an issue in `Instructions/ISSUES.md` (`NEW` → `UNDER WORK` → `SOLVED` or `DECLINED`) and carries on with the work the issue doesn't affect. `/start` lists the open issues, and the next `/brainstorm` takes them up first with you and writes the decisions into the manuscript. You can add issues there yourself too.

Reviewing the code: now and then (at the end of a milestone, before a release, or whenever you want a second look) type `/review`. It starts the `reviewer` subagent (`.claude/agents/reviewer.md`), which has a clean context and its own model (Opus), so it works in any session. The reviewer (`Instructions/REVIEWER.md`) reads the code and the manuscript, runs the project's checks, and reports bugs, security problems, failing or missing checks, and places where the code doesn't match the manuscript. It changes no code. Code findings go to `Instructions/REVIEW.md`; if the manuscript itself is unclear or wrong, it raises an issue in `Instructions/ISSUES.md` instead. The reviewer commits and pushes its report itself, so there's no `/end`. To fix the findings, type `/clear`, then `/start`, and tell the developer to fix the review findings. An optional argument narrows the review: `/review Application/src/api`.

Which model for which role: a command can't switch the session's model for longer than its first turn, so you set it yourself with `/model` right after the command. Suggested (change it if the results say otherwise):

| Role | Command | Suggested model | Why |
| --- | --- | --- | --- |
| Brainstormer | `/brainstorm`, then `/model opus` | Opus | Judgment and writing the spec everything else depends on; short sessions. |
| Developer | `/start`, then `/model sonnet` | Sonnet | The spec defines the work; long sessions. Switch up with `/model` for a hard task. |
| Reviewer | `/review` | Opus (set automatically) | Judgment, rarely run. |

One task per session (token cost): everything in a session is sent to the model again with every message, so long sessions get expensive. The developer therefore does one task, commits it with the handoff files, and stops with "Run `/clear`, then `/start`, then say go to continue". Nothing is lost: the handoff files carry the state, and a fresh start costs far less than a grown session. If you want more in one session, ask for it ("do the next three tasks"); the limit is 3.

Asking instead of building: the developer answers questions ("is it possible…", "let's discuss…") without changing anything, and starts work only on a clear go ("ok", "go", "do it"). For a guarantee, switch to Plan mode first, with `/plan` (optionally followed by the question) or the mode selector under the input box: the AI can then read and answer but can't change anything, and it shows a plan for you to approve before it works. Switch back to Auto, or approve the plan, to let it build.

Ending a session: type `/end`. It writes the session log and current state (after a `/brainstorm` session: the brainstorm log), commits and pushes everything (unfinished work as "Work in progress"), and signs off with "Thanks for now". The next `/start` or `/brainstorm` picks up from there. If a developer session ends without `/end` (a crash, a closed window), little is lost: the developer updates the current state and session log after every task, and the next `/start` says the last session didn't end cleanly and shows any half-done work.

Each of those commands can also be run on its own, e.g. `/fence` after changing `SECURITY.md`. All are safe to run again.

Template updates: the template lives at `git@github.com:anderspetor/workbox.git`. In a project that uses git, `/start` checks whether the template has changed and, after one yes, updates the template files (listed in `.claude/template-files.txt`) without touching the project's own files, then commits and pushes "Template update". Template files are never edited inside a project.

Template feedback: when the template gets in the way in a project (a command that misbehaves, an unclear rule, a missing step) or you have an idea for it, the AI notes it in `Instructions/TEMPLATE_FEEDBACK.md`, and you can ask it to ("note this for the template"). The file is sent to the shared repo `anderspetor/workbox-feedback`, one branch per project, holding only that file (the project's code never goes there), and the template's development folder collects it from there. Sending needs the project to be a git repository.

When starting a new developer session, read files in this order (a `/brainstorm` session has its own order, in `.claude/commands/brainstorm.md`):
1. `Instructions/instructions.md`, `Instructions/PROGRAMMER_GPT_MASTER.md`, and `Instructions/AUTONOMOUS_EXECUTION_PROTOCOL.md` — how to operate
2. `Instructions/CURRENT_STATE.md` — current state, and `Instructions/ISSUES.md` — issues waiting for a product decision, and `Instructions/REVIEW.md` — open review findings (older projects may not have the last two yet: then there are none)
3. If the manuscript is active (`Instructions/manuscript/README.md` defines when): `INTRO.md`, and in `TASKS.md` only the current milestone. Don't read `SPEC.md`, `UI.md`, `DATA_MODEL.md`, `DECISIONS.md`, `TEST_PLAN.md`, the archives, or the mockups in `Design/` in full at the start. Everything read at the start stays in the session's context and is paid for on every message, so while working on a task, search those files for the IDs the task lists under `Covers:` (F…, S…, D…) and read only those sections; open a mockup only for a UI task on its screen
4. `Application/` — list the files for an overview; don't read the code at the start. Read the files a task needs while working on it
5. `Instructions/SESSION_LOG.md` — last session's log, read last for continuity

## Folder Overview

- `Instructions/` contains the operating instructions and project guidance for the programmer GPT.
  - `Instructions/AUTONOMOUS_EXECUTION_PROTOCOL.md` defines the task-selection loop, task statuses, self-serve decisions, and stop conditions for autonomous work. Applies to any project, manuscript or not.
  - `Instructions/CURRENT_STATE.md` is the compact handoff for future sessions, updated after every task.
  - `Instructions/SESSION_LOG.md` is the last developer session's log, kept up during the session and completed by `/end`. Before a new log replaces it, anything durable is moved into `CURRENT_STATE.md`.
  - `Instructions/ISSUES.md` is where the developer (or you) raises findings that need a product decision, for the brainstormer. Its rules are in "Issues" in `Instructions/manuscript/README.md`.
  - `Instructions/REVIEW.md` holds the findings from `/review` sessions (code problems and missing checks), which the developer fixes on your go.
  - `Instructions/REVIEWER.md` is the reviewer role for `/review` sessions.
  - `Instructions/TEMPLATE_FEEDBACK.md` collects problems and ideas for the template itself, not for this project.
  - `Instructions/BRAINSTORMER.md` is the brainstormer role for `/brainstorm` sessions.
  - `Instructions/BRAINSTORM_LOG.md` is the brainstormer's log: the last brainstorm session, and parked ideas and open questions kept across sessions. Written by `/end`, read only by `/brainstorm`.
  - `Instructions/manuscript/` is the optional product spec — see Manuscript Rule below. Its `README.md` defines each file's format and who may change what, and how accepted milestones move to archive files (`TASKS_DONE.md`, `DECISIONS_ARCHIVE.md`) so the files read at startup stay small.
  - `Instructions/manuscript/SECURITY.md` declares outside-project-root access exceptions (always-OK, always-ask, always-deny). Unlike the other manuscript files, it isn't just read — it's applied to `.claude/settings.json` by `/fence`.
- `Application/` is the working area for application code, tests, and implementation-related files. All source code lives here.
- `Release/` holds the finished, installable application package built from `Application/` (e.g. a `.deb`, a browser extension, an installer). Keep only the latest version here. Never put source code in it.
- `Design/` holds the HTML mockups made in `/brainstorm` sessions. The approved ones are linked from `Instructions/manuscript/UI.md`, where the UI decisions are written down, and the developer builds the user interface against them.
- `Source-files/` stores background/reference material provided by the user (documents, notes, screenshots, example images), for context only — it is **not** part of this project's own scope, and may include material about related-but-separate initiatives (e.g. other systems this project's output feeds into). Treat it as read-only unless the user explicitly says otherwise, and never treat its contents as this project's own requirements just because it lives here.

## Manuscript Rule

`Instructions/manuscript/` is optional.

- It is written with you in `/brainstorm` sessions, or you can put in one you've written elsewhere.
- It is active when both `INTRO.md` and `TASKS.md` have content. Then it acts as the product source of truth.
- Otherwise it is not used as an active specification.
- `SECURITY.md` is the exception: run `/fence` after adding or changing its content — it isn't active until applied, and once applied it's a binding constraint, not a passive reference.

## Default Working Mode

- Read and follow the files in `Instructions/`.
- Write code in `Application/`.
- Read from `Source-files/` when reference material is available.
