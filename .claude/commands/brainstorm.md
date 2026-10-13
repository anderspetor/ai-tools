Start a brainstorm session: plan or revise this project's manuscript together with the user, including the UI and HTML mockups. Run it instead of `/start`, in a new session or straight after developer work in the same session (step 1.2 wraps that work up first). When the brainstorm is done, the user types `/end`, then `/clear` (or opens a new session), and the developer continues with `/start`.

How to run everything below (the full rule is "Running commands" in `Instructions/instructions.md`):
- Read files with the Read tool, one file per call. Never `cat` files in a loop.
- Use Bash only where needed: one command per call, from the project root, with project-relative paths. No `&&` chains, loops, or pipelines.

## 1. Before starting

1. If the project root folder is still named `workbox`, stop: this is the template itself, not a project. Tell the user to create a project with `new-project.sh <name>` and open that instead.
2. If this session has already been a developer session (`/start`, or other work before this command), wrap it up first, without asking: follow section A of `.claude/commands/end.md`, steps 1 to 4 (session log, current state, manuscript task statuses, back up), but skip its sign-off (step 5). Tell the user in one line what was recorded and backed up. From here on the developer role ends: follow only `BRAINSTORMER.md`, even though the developer instructions were read earlier in the session.
3. This command doesn't run the setup checks; `/start` does. If `.claude/settings.json` doesn't exist, the project hasn't been set up yet: suggest running `/start` once first, then `/brainstorm`. Continue if the user prefers.
4. If there was no wrap-up in step 2 (a fresh session) and `git remote get-url origin` succeeds, bring in work pushed from another machine with `git pull --ff-only`, and handle the result as "Pull" in `.claude/commands/start.md` describes. After a wrap-up, skip this: `/start` already pulled at the beginning of the session.

## 2. Read

1. `Instructions/BRAINSTORMER.md`: your role for this session. It replaces the developer role.
2. `Instructions/instructions.md`: for the shared rules only (working boundary, running commands, template files, Git), as `BRAINSTORMER.md` describes.
3. `Instructions/manuscript/README.md`: the manuscript's files, formats, and rules.
4. Every file in `Instructions/manuscript/` except the archives (`TASKS_DONE.md`, `DECISIONS_ARCHIVE.md`): open those only when a discussion needs an archived ID or milestone.
5. `Instructions/CURRENT_STATE.md`, `Instructions/ISSUES.md` (if it exists), and `Instructions/BRAINSTORM_LOG.md`.
6. `Design/`: the existing mockups (list them, open what's relevant).
7. `Source-files/`: the user's reference material (list it, open what's relevant; the Read tool shows images).
8. `Application/`: an overview only: its structure, main files, and what's built. Skip dependency folders, build output, caches, and binaries.

Don't read `Instructions/SESSION_LOG.md` or `PROGRAMMER_GPT_MASTER.md`: they belong to the developer. After a wrap-up in step 1.2, read the files above anyway: the wrap-up has just changed some of them.

## 3. Open the session

Give a short summary, then follow `BRAINSTORMER.md` for the rest of the session:

- **No manuscript yet** (all files empty): say that this is a new plan, and start with the first topic (purpose and users).
- **Manuscript with content:** where the project stands (current milestone, tasks done and remaining, anything blocked) and what changed since the last brainstorm session, if `BRAINSTORM_LOG.md` says. If the manuscript isn't active yet, say it's an unfinished draft to continue. If it isn't in the format `README.md` defines, say it will be converted when the manuscript is next written.
- **Open issues** (`ISSUES.md`): list the `NEW` and `UNDER WORK` ones by ID and title, and say which ones block a task.
- **From the brainstorm log:** where the last discussion stopped, and the parked ideas and open questions.

If this session isn't running on an Opus model, add one line: brainstorming suits Opus, and the user can switch with `/model opus` (a command can't switch it; README "Which model for which role").

Then ask what the user wants to work on. If there are open issues, propose starting with them (`BRAINSTORMER.md` section 6); otherwise propose the first topic.
