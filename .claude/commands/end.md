End the session for now: make sure the project's state and session log are written, back them up, and sign off.

Follow "Running commands" in `Instructions/instructions.md` for every command: Read/Edit tools for files, and Bash one command per call from the project root. Don't start new work, and don't finish half-done work silently; record it.

If `/review` was run in this session, there's nothing to write: the reviewer has already saved and pushed its report. Reply in one line that the review is saved, name the next step (`/clear`, then `/start`, and ask the developer to fix the open review findings), and end with the sign-off line below. Otherwise decide which kind of session this was. A session where `/brainstorm` was run is a **brainstorm session**: follow section B. That includes a session that started as a developer session: `/brainstorm` already wrapped up the developer part (section A) when it started, so only the brainstorm part is left. Any other session is a **developer session**: follow section A.

# A. Developer session

## 1. Session log

Read `Instructions/SESSION_LOG.md` and `Instructions/CURRENT_STATE.md`. During the session, both should have been kept current after each task ("Keeping the handoff current" in `Instructions/AUTONOMOUS_EXECUTION_PROTOCOL.md`); this step completes them.

1. If the session log was opened in this session, complete it (step 2). If it still holds an earlier session (for example because this session did no work), first move anything durable from it that `CURRENT_STATE.md` doesn't have yet (decisions, open items, blockers, unfinished work) into `CURRENT_STATE.md`. If that earlier log is still marked `(open)`, its session ended without `/end`: note that in `CURRENT_STATE.md` too. Then replace it with this session's log.
2. The log keeps the file's short header (title and the note on how the file is used) and has:
   - `Session: <today's date, YYYY-MM-DD> (ended)` (change `(open)` to `(ended)`, or write it so)
   - **Done:** what was completed and verified, with the main files touched. Check it against the session and add what's missing.
   - **Decisions:** choices made with the user, and why.
   - **Unfinished:** work started but not done, and exactly where it stands.
   - **Open questions / blockers:** anything waiting on the user or someone else, including issues raised in `Instructions/ISSUES.md` this session (by ID).
   - **Next:** the first thing to do in the next session.

## 2. Current state

Update `Instructions/CURRENT_STATE.md` so a new session can start from it alone: current snapshot, last completed, in progress, next suggested step, open notes. "In Progress" lists only what is actually unfinished now. Keep it short, because it is read at every start: replace outdated lines instead of piling new ones on top, use absolute dates, keep only the last 3 entries under "Last Completed" (one short line each; older ones are covered by `DECISIONS.md` and git history), and keep "Open Notes" to items that are still true.

## 3. Manuscript files (only if the manuscript is active)

If the manuscript is active (`Instructions/manuscript/README.md` defines when): update task statuses in `TASKS.md` (the statuses in `AUTONOMOUS_EXECUTION_PROTOCOL.md`), and add an entry to `DECISIONS.md` for any material decision from this session that isn't recorded yet, in the format `README.md` there defines. Don't change anything else in the manuscript.

## 4. Back up

Only if the project is a git repository:

The goal is that GitHub always has the latest state of everything, so this step never asks.

1. `git status --short` to see what's uncommitted.
2. If there's uncommitted work from an unfinished task (anything besides the state files), commit it as "Work in progress: <short description>" so it's in the backup. The session log already says exactly where it stands. Never describe unfinished work as done. The Git rules still apply: never commit secrets. If something looks like one, leave it out and say so in the reply.
3. Commit the updated state files (`SESSION_LOG.md`, `CURRENT_STATE.md`, `ISSUES.md` and `TEMPLATE_FEEDBACK.md` if they changed, and any manuscript files from step 3) with the message "Session end: update state and log".
4. Push. If there are other unpushed commits, the push includes them. If the push fails, say so plainly in the reply; the work is still committed locally.
5. If `Instructions/TEMPLATE_FEEDBACK.md` has entries, send it: `bash .claude/feedback-push.sh` ("Template files" in `Instructions/instructions.md`). It says when it's already sent. If it fails, say so in the reply.

If the project isn't a git repository, skip this step and mention that nothing is backed up (`/github` sets up the backup), and that template feedback can't be sent.

## 5. Sign off

Reply briefly: what was recorded (one or two lines), any template feedback entries added this session (by ID), what's backed up or not, and the next step for the next session. End with exactly:

Thanks for now

# B. Brainstorm session

`SESSION_LOG.md` belongs to the developer: leave it untouched.

## 1. Brainstorm log

Read `Instructions/BRAINSTORM_LOG.md` and keep its short header (title and the note on how the file is used).

1. **Parked ideas and open questions:** add the ones from this session, and remove those that were resolved or written into the manuscript. This list is kept across sessions. Issues stay in `ISSUES.md`; don't copy them here.
2. **Last brainstorm session:** replace it with this session's log:
   - `Session: <today's date, YYYY-MM-DD>`
   - **Discussed:** the topics covered, including issues by ID.
   - **Agreed:** what the user agreed to, and whether it was written into the manuscript. Issues closed (`SOLVED`/`DECLINED`) by ID.
   - **Mockups:** made, changed, or approved, with their files in `Design/`.
   - **Not written yet:** anything agreed but not yet in the manuscript (no go yet), and exactly where the discussion stopped.
   - **Next:** where the next `/brainstorm` should pick up, or "developer: `/start`" when the manuscript is ready to build from.

## 2. Current state

If the manuscript was written or changed in this session, check that `Instructions/CURRENT_STATE.md` has the line the brainstormer adds for it ("Manuscript written/updated …", see `Instructions/BRAINSTORMER.md` section 5), and add it if missing. Otherwise leave `CURRENT_STATE.md` as it is. Don't change the manuscript: only what the user gave a go for belongs there, and that was written during the session.

## 3. Back up

Only if the project is a git repository; the same goal as A.4, so this step never asks.

1. `git status --short` to see what's uncommitted.
2. If there are uncommitted mockups in `Design/`, commit them as "Mockups: <short description>". They're drafts until approved in `UI.md`, and that's fine.
3. Commit `BRAINSTORM_LOG.md`, and `CURRENT_STATE.md`, `ISSUES.md`, and `TEMPLATE_FEEDBACK.md` if they changed, with the message "Session end: update brainstorm log".
4. Push, as in A.4.
5. Send template feedback, as in A.4 step 5.

If the project isn't a git repository, skip this step and mention that nothing is backed up.

## 4. Sign off

Reply briefly: what was recorded, any template feedback entries added this session (by ID), what's backed up or not, and the next step: another `/brainstorm`, or `/clear` (or a new session) and then `/start` to build from the manuscript. End with exactly:

Thanks for now
