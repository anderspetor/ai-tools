Start a session: first check that this project's one-time setup is complete, then read the project and summarize where it stands.

How to run everything below, including the setup commands, so it needs no permission prompts (the full rule is "Running commands" in `Instructions/instructions.md`):
- Read files with the Read tool, one file per call. Never `cat` files in a loop.
- Use Bash only for the checks and git commands: one command per call, run from the project root (the session already starts there, so no `cd`), with project-relative paths. No `&&` chains, loops, or pipelines.

If `/brainstorm` has already been run in this session, stop: the developer must start from a clean context, building only from what was written into the manuscript, not from ideas that were discussed but not approved. Tell the user to type `/end`, then `/clear` (or open a new session), then `/start`. Do nothing else.

## 1. Setup check

Check these in order. The checks only read; nothing is changed without the user's yes in step 2.

1. **Renamed?** If the project root folder is still named `workbox`, stop here: this is the template itself, not a project. Tell the user to copy the folder, rename the copy to the project name, and open the copy instead. Do nothing else.
2. **GitHub connected?**
   - `git remote get-url origin` points to `anderspetor/workbox` → stop here: this folder is a copy of the template's own git repository, and project work must never be pushed there. Tell the user to create projects with `new-project.sh <name>` (or delete this folder's `.git` folder), then run `/start` again. Do nothing else.
   - `git remote get-url origin` succeeds otherwise → connected. Then run `git config user.email`: if it doesn't print `anders.petor.holm@gmail.com`, the commit author is missing (a fresh `git clone` doesn't carry it). Then bring in work pushed from another machine with `git pull --ff-only`, as described under "Pull" below.
   - Otherwise, work out the repo name as `/github` step 1 does and run `git ls-remote git@github.com:anderspetor/<repo-name>.git`:
     - succeeds with no output → an empty repo is waiting: `/github` is missing.
     - `Repository not found` → no repo yet. Not a blocker: mention that the user can create an empty private repo named `<repo-name>` on github.com if they want the backup, then run `/start` or `/github` again.
     - anything else (SSH or network error, repo not empty) → report it as `/github` would; don't offer to run it.
3. **Template up to date?** Only when the project is a git repository (a fresh copy without git is current by definition). Run `bash .claude/template-sync.sh check` as one Bash call. Exit 0: up to date. Exit 10: a template update is missing; keep the list of changes it prints for the checklist. Any other exit: report the message and treat it as not a blocker.
4. **`/install` applied?** Run `bash .claude/install-check.sh` as one Bash call (it only reads). It checks the shared `.claude/settings.json` and this machine's `.claude/settings.local.json` and prints `ok local` or `ok vm` when every baseline rule for this machine's mode is present. Any other line means `/install` is missing (`/install vm` when the line says so): the template's baseline may have gained rules since this project was set up, or this machine has no local rules yet (a fresh clone has only the shared file), and `/install` adds them. A machine in VM mode is never moved back to the local rules by `/start`. Don't judge this by reading the files; the script decides. If the script itself prompts for permission (an older project whose settings don't allow it yet), that is expected once.
5. **`SECURITY.md` applied?** Determine its state as `/fence` step 3 defines it (EMPTY, UNAPPLIED, UNCHANGED, CHANGED). UNAPPLIED or CHANGED means `/fence` is missing. EMPTY is fine: the project simply has no extra access policy yet.

**Pull.** The project may be worked on from more than one machine (for example a PC and a VM), so the session must start from what's on GitHub. `git pull --ff-only` is the one change these checks make without asking: it only brings in commits that are already on GitHub, and it never merges.
- "Already up to date" → nothing to report.
- It fast-forwards → say in one line what came in (number of commits, and the latest commit's message).
- It fails because this machine and GitHub both have commits the other lacks ("Not possible to fast-forward" or "diverging branches") → don't merge, rebase, or reset. Report it as a blocker in the summary with a "Human action required" request (format in `Instructions/AUTONOMOUS_EXECUTION_PROTOCOL.md`): the user decides how to combine the two, and no work starts before that.
- It fails because uncommitted changes here would be overwritten → don't stash or discard them. Report which files, and ask the user what to do with them.
- Any other failure (network, SSH) → report it and continue: the summary must say the session may not have the latest state.

## 2. Run missing steps (ask once)

If nothing is missing, go straight to section 3.

Otherwise show a short checklist (what's done, what's missing, in the order below) and ask the user once whether to run the missing steps now, as a real question the user can answer with one click (the AskUserQuestion tool: "Run the missing steps now?", options Yes and No), placed before the summary and not at the end of a long status message. On yes, run them in this order, following each command's own file in `.claude/commands/`:

1. Commit author, if missing: `git config user.name "Anders Petor Holm"` and `git config user.email "anders.petor.holm@gmail.com"`, as two separate calls (this repo only).
2. Template update: `bash .claude/template-sync.sh apply`. It replaces only template files (listed in `.claude/template-files.txt`); project files are never touched. Afterwards run the `/install` check again, since the update may bring new baseline rules. (If this `/start` file itself changed, finish this run as started; the next `/start` uses the new version.)
3. `/install`, or `/install vm` when the line printed by `bash .claude/install-check.sh` says so, or when `Bash(*)` is in `.claude/settings.json` (a VM project set up before the rules were split into two files). The user writes `.claude/settings.local.json` for VM mode (see "VM mode" in `.claude/commands/install.md`); wait for that before the commit step
4. `/fence` (its own confirmation of the policy still applies)
5. `/github` (last, so the first upload includes the settings from the steps above)

When the steps are done and the project is connected to GitHub, commit the files they changed (the template files, `.gitignore`, `.claude/settings.json`) with the message "Template update" if step 2 ran, otherwise "Project setup", and push, following the Git rules in `Instructions/instructions.md`. `/github`'s own initial commit already includes everything before it, so skip this if nothing changed after that commit.

On no, continue to section 3 and list the missing steps in the summary's blockers. If a step fails, report it and continue with the others where their order allows.

## 3. Start the session

Read `README.md` in the project root and follow its "Getting Started" read order in full.

**Last session ended cleanly?** If the `Session:` line in `Instructions/SESSION_LOG.md` ends in `(open)`, the last developer session ended without `/end` (a crash, a closed window, a lost connection). The state files are current up to its last finished task, and what's under "In Progress" in `CURRENT_STATE.md` may be half done. If the project is a git repository, run `git status -sb` as one Bash call to see uncommitted files and unpushed commits. Don't change or commit anything now: the next task's handoff update records the old session ("Keeping the handoff current" in `Instructions/AUTONOMOUS_EXECUTION_PROTOCOL.md`).

Then give a short summary: where the project stands, what was completed most recently, what is in progress, the next suggested step, and any blocker or decision awaiting the user (including setup steps still missing). If `Instructions/ISSUES.md` has open issues (`NEW` or `UNDER WORK`), list them by ID and title, say which tasks they block, and suggest `/brainstorm` to decide them. If `Instructions/REVIEW.md` has open findings, list them by ID, severity, and title, and say the user can tell the developer to fix them. If the last session didn't end cleanly, say so first, with what was in progress and what `git status -sb` showed, so the user can decide whether to continue, keep, or drop that half-done work. If the manuscript isn't active (`Instructions/manuscript/README.md` defines when), mention that the project can be planned with `/brainstorm`. End with one line: developer work runs cheaper on Sonnet, so if the session isn't already on it, type `/model sonnet` (Opus is for `/brainstorm` and `/review`; see the model table in `README.md`). Wait for instructions before continuing work.

Apart from the pull in section 1, the setup steps the user approved in step 2, and their commit, do not modify files or change external state during `/start`.
