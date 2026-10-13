# Autonomous Execution Protocol

## Purpose

Use this protocol in any application project where the developer AI works through a task list autonomously — whether that list lives in a manuscript's `TASKS.md`, a plain backlog, an issue tracker, or the current user request itself. It prevents unnecessary pauses while preserving human control over decisions and actions that only a person can safely perform.

This protocol is a **working rule for the developer AI**. It supplements whatever specification the project has (a manuscript, a design doc, or just the live conversation); it does not replace product, security, deployment, or repository-specific instructions.

## Primary directive

> Work through the task list autonomously. Within a task, and from one task to the next inside the session budget below, continue without asking for confirmation, a status check, or a new prompt. Stop and request the user's help only when a specific human decision, credential, permission, physical action, or unavailable information is required to make further safe progress.

Do not end a work session merely to report progress in the middle of a task. A progress report is not a handoff and must be followed by continued work.

**Session budget (token cost).** Everything in a session's context is sent again with every message, so a session that runs through many tasks grows very expensive: one task's files, test output and conversation are carried through all the later ones. The handoff files exist so a fresh session loses nothing. Therefore a session does **one task**: when it is finished, verified, and committed with the handoff files (steps 8 and 9 below), stop and say, in one or two lines, what was done and what the next task is, and end with: "Run `/clear`, then `/start`, then say go to continue." Don't start the next task in the same session. The exception is the user's own request for more ("do the whole milestone", "do the next three tasks"): then continue, but never beyond 3 tasks in one session; after the third, stop the same way. The budget changes only when the session stops, not what gets done: all unblocked tasks of the milestone are still done, one fresh session each.

This protocol applies to work the user has asked for. A question or discussion ("can you…", "is it possible…", "let's discuss…") is not a work request: answer it and wait for a clear go, as "Questions come before work" in `instructions.md` describes.

## Task-selection loop

At the start of work and after completing every task:

1. Read the project instructions, the current task (and, in the manuscript, only what it lists under `Covers:`, see "Read economically" in `PROGRAMMER_GPT_MASTER.md`), and the existing code the task touches. Don't re-read the whole specification or all code before each task.
2. Update the task list if the work already completed has made its status inaccurate.
3. Select the highest-priority task whose prerequisites are complete and that can be completed with the available repository, tools, and authority.
4. Before starting it, record it in the handoff files, as "Keeping the handoff current" below describes.
5. Implement it fully, including relevant tests, documentation, and verification. Run only the related tests while working, and the full suite once at the end ("Verification and completion" in `PROGRAMMER_GPT_MASTER.md`).
6. Record any material implementation decision or newly discovered constraint in the appropriate project file, if one exists.
7. Mark the task complete only after its acceptance criteria and relevant verification pass.
8. Update the handoff files with the result.
9. If the project is a git repository, commit and push the completed task together with the handoff files and any issue raised during it, following the project's git rules.
10. Apply the session budget (see "Primary directive"): normally stop here with the "Run `/clear`, then `/start`" line. Only when the user asked for more tasks in this session and fewer than 3 are done, return to step 3.

If one task is blocked, record the precise blocker and continue with another independent unblocked task. Ask the user only when the blocker prevents all remaining safe work.

## Keeping the handoff current

A session can end at any moment (a crash, a closed window, a lost connection) without the end-of-session routine running. So the handoff files must be current after every task, not only at the end. In this template they are `Instructions/CURRENT_STATE.md` and `Instructions/SESSION_LOG.md`, and the end-of-session routine is `/end`.

This applies to every task, including a direct request from the user ("Fix Y"). A question or discussion changes nothing, so it isn't recorded until it leads to work.

- **Open the session log** before the session's first task. Its `Session:` line ends in `(open)` while a session is running and in `(ended)` once `/end` has completed it; a log with neither counts as ended. If the log holds an earlier session, first move anything durable from it (decisions, open items, blockers, unfinished work) that `CURRENT_STATE.md` doesn't have yet into `CURRENT_STATE.md`. Then replace it with a new log, keeping the file's short header: `Session: <today's date, YYYY-MM-DD> (open)`, followed by the sections that `/end` fills (`.claude/commands/end.md`, section A.1), empty for now. An earlier log that is still marked `(open)` comes from a session that ended without `/end`: also note that in `CURRENT_STATE.md`, with what it left under "In Progress".
- **Starting a task:** under "In Progress" in `CURRENT_STATE.md`, write `<task ID, if any> <what> (started YYYY-MM-DD)`.
- **Finishing a task:** in `CURRENT_STATE.md`, move it from "In Progress" to "Last Completed" and update "Next Suggested Step", replacing outdated lines rather than piling new ones on top. "Last Completed" keeps only the last 3 entries (one short line each; drop the oldest: it is covered by `DECISIONS.md` and git history), and "Open Notes" only items that are still true. In the session log, add one line under **Done:** (what, with the main files), and add anything new to its other sections (decisions, open questions, issues raised by ID). A blocked task stays under "In Progress" with its blocker.
- Commit the handoff files together with the task (step 9). If the session ends in the middle of a task, the files on disk still say what was underway.

## Task statuses

Use these statuses consistently in `TASKS.md` or whatever task tracker the project uses:

| Status | Meaning |
| --- | --- |
| `TODO` | Not started; may have unmet prerequisites. |
| `IN PROGRESS` | The current implementation task. Only one task should normally have this status. |
| `BLOCKED — HUMAN ACTION REQUIRED` | Cannot proceed without the exact action stated in the blocker. |
| `DONE` | Implemented and verified against its acceptance criteria. |
| `DEFERRED` | Intentionally moved beyond the current scope, with a reason. |

Never use vague statuses such as `waiting`, `review needed`, or `needs confirmation` when the developer can make a safe, documented choice and continue.

## Decisions the developer AI must make itself

The developer AI should make the smallest safe, reversible, spec-compatible choice, record material choices in a decision log if the project has one, and continue for ordinary implementation questions, including:

- code structure, naming, module boundaries, and test layout that fit the existing codebase;
- compatible library or framework choices when the project does not prescribe one;
- minor UI, validation, copy, and error-handling details consistent with the spec;
- how to diagnose and resolve ordinary build, lint, type-check, test, or local-environment failures;
- whether to split an implementation task into smaller technical subtasks;
- a conservative default when requirements are incomplete but the choice is reversible and does not change product scope, security, cost, or an external commitment.

Do not ask the user whether to continue after a successful task, test run, review, or documentation update. Continuing is the default.

## Legitimate human stop conditions

Stop only when at least one of the following is true and it prevents all remaining safe work:

1. **Human access is required.** A person must sign in, complete MFA/CAPTCHA, grant a permission, attach a file, supply a secret, approve a payment, or provide access to an external system.
2. **A material product decision is unresolved.** The spec (if any) contains a real conflict or lacks a decision that would materially change user behavior, scope, security, data retention, cost, or a non-reversible architecture choice.
3. **A human-only or external action is required.** Examples include testing physical hardware, confirming a production observation, registering a domain, accepting a vendor agreement, or completing a manual third-party configuration step.
4. **An irreversible or high-impact action needs approval.** Examples include production deployment, destructive data migration, deleting user data, changing live access controls, sending external communications, or incurring meaningful cost—unless the project instructions explicitly authorize that action.
5. **Further progress would require guessing protected or unavailable facts.** For example, an API contract, credentials, legal requirement, business rule, or user-owned data that cannot be derived safely from the repository and spec.

A failed command, test, dependency installation, configuration issue, or implementation uncertainty is **not** by itself a stop condition. Investigate, repair, use safe alternatives, or clearly document the technical limitation before asking for help.

## Product decisions: raise an issue

In this template, an unresolved product decision (stop condition 2) is raised as an issue in `Instructions/ISSUES.md`, for the user to decide with the brainstormer. The rules are in "Issues" in `Instructions/manuscript/README.md`, and when to raise one is in `PROGRAMMER_GPT_MASTER.md` section 6. Raising an issue is not a stop: mark only the tasks that truly can't continue as blocked, and continue with the rest. Stop with a human action request only when every remaining task waits on an open issue. The request then names the issues and asks the user to run `/brainstorm`, or to decide them directly if they're small changes.

## How to ask for human help

When a stop condition is reached, do not ask a broad question such as "What would you like me to do?" or "Should I continue?" Instead, provide one concise action request:

```md
## Human action required

**Why work cannot continue:** <one concrete blocker>

**Please do:** <one or more exact actions, in order>

**Where / what to provide:** <link, command result, value name, screen, file, or approval needed>

**What I will do next:** <the next task that will resume automatically once this is supplied>

**Work completed while blocked:** <short list of completed tasks, if relevant>
```

Ask only for information or actions that are necessary. If there is a safe default, state the chosen default in the decision log (if one exists) and continue instead.

## Completion and reporting rules

- Treat the current user request as authorization to complete the agreed work, within the session budget (one task per session unless the user asks for more, at most 3). The remaining unblocked tasks of the milestone stay authorized: the user continues them in a fresh session with a plain "go". A question is not such a request.
- Keep working after intermediate reports inside a task; do not convert an informational update into a request for permission.
- Before declaring a milestone complete, run the relevant automated checks and manual verification the project defines (e.g. a `TEST_PLAN.md`).
- Update task status, decision records, the handoff files, and any affected documentation as part of the task—not as optional follow-up work.
- End the session when the session budget is reached, the agreed milestone has no remaining unblocked tasks, a genuine human stop condition exists, or the user explicitly asks to pause.
- At a real handoff, report completed work, verification performed, remaining `TODO`/`BLOCKED` work, open issues raised for the brainstormer, and the exact next action. If the project is a git repository with commits that failed to push, say how many and why. Do not imply that the user needs to respond when no response is required.

## Priority and conflict rules

Use this order when instructions conflict:

1. Explicit instructions in the current user request.
2. Security, safety, legal, and platform constraints — including a project's `SECURITY.md` access policy, if applied.
3. Repository-level instructions and any approved spec (e.g. `INTRO`, `SPEC`, `DATA_MODEL`, `DECISIONS`, `TEST_PLAN`).
4. The staged order and scope in the task list (e.g. `TASKS.md`).
5. This autonomous execution protocol.
6. Local implementation preferences.

If two higher-priority sources conflict and the difference is material, record the conflict and ask the user to decide. If the difference is not material, choose the safest compatible interpretation and continue.

## Required project-instruction placement

Place this protocol near the beginning of the developer AI's persistent project instructions, before project-specific technical rules. If the project uses a staged task list such as `TASKS.md`, add this instruction under the section that tells the AI how to read and execute it.

The implementation plan should use milestone wording such as:

> Complete all unblocked tasks in the current milestone autonomously. Do not pause between tasks. Use the autonomous execution protocol for decisions and stop conditions.

This is intentionally stronger and more useful than "continue unless you have questions," because it defines what counts as a valid question and what the AI must do when it has none.
