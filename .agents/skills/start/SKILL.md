---
name: start
description: Load Project's startup documentation, operating instructions, product instructions, durable handoff, relevant implementation state, and recent continuity, then summarize next work without changing anything. Use when the user invokes $start or asks to start, resume, or orient a project session.
---

# Start a Project session

If the project root folder is still named `workbox`, stop: this is the template itself, not a
project. Tell the user to copy it, rename the copy to the project name, and open the copy.

Read the root `README.md` and follow its complete startup order.

List `Application/` for an overview; don't read the code at the start (read what a task needs while
working on it). Skip artifacts, dependency trees, virtual environments, caches, binaries, and
unrelated large files.

Check the project's one-time setup, which is done from Claude Code (`/start` there runs it):
`/install` applied (`.claude/settings.json` and `.claude/settings.local.json` contain the rules in `.claude/commands/install.md`),
`Instructions/manuscript/SECURITY.md` applied if it has content (see `.claude/commands/fence.md`),
and GitHub connected (`git remote get-url origin`). Report anything missing; do not run it
yourself. Note that the `/install` permission rules apply to Claude Code only, not to this agent.

If the `Session:` line in `Instructions/SESSION_LOG.md` ends in `(open)`, the last developer
session ended without `/end`: report that first, with what `CURRENT_STATE.md` has under
"In Progress" and any uncommitted files (`git status -sb`).

Briefly summarize:

- where project stands;
- what was completed most recently;
- what is in progress;
- the next suggested step;
- any setup step still missing;
- open issues in `Instructions/ISSUES.md` (`NEW` or `UNDER WORK`), by ID and title;
- open review findings in `Instructions/REVIEW.md`, by ID, severity, and title; and
- any blocker or decision awaiting the user.

Do not modify files, run mutating commands, publish artifacts, or change external state during
`$start`. Wait for instructions after the summary.
