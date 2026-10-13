Lock the current project folder as the AI's working boundary, so the "don't access/modify anything outside this folder" rule in `Instructions/instructions.md` is enforced mechanically instead of relying on self-policing a prose instruction. `/start` runs this automatically when the rules are missing or incomplete (after one yes from the user); it can also be run on its own at any time.

The goal: normal work inside the project runs without permission prompts; anything reaching outside the project asks the user; known-dangerous actions are denied outright.

The rules are split in two files, because the project can be worked on from several machines (for example a PC and a VM) through the same GitHub repo:
- **`.claude/settings.json`** is committed and shared by every machine. It holds the baseline in `.claude/install-baseline.json`: the git workflow allows, the git commands that lose uncommitted work (ask), and the denies that make sense everywhere (credential stores, force-push and remote branch deletion, disk and power commands, piping into a bare shell). Never put anything machine-specific in it: a mode written there would reach the other machines with the next pull.
- **`.claude/settings.local.json`** is git-ignored and belongs to this machine alone. It holds the machine's mode, chosen by the user, never by you:
  - **`/install`** (local, the default): `.claude/install-baseline-local.json`, for a PC or any machine that holds more than this project. It fences everything to the project folder (see step 1).
  - **`/install vm`**: `.claude/install-baseline-vm.json`, for a project that runs on its own virtual machine, where the VM is the boundary. See "VM mode" at the end. Run it only when the user typed `vm`: never switch a project to VM mode on your own, and never suggest it for a PC.

A machine is in VM mode when `Bash(*)` is in `allow` of its `.claude/settings.local.json` (or, in a project set up before this split, of `.claude/settings.json`). Without the `vm` argument, follow the steps below. If the machine is in VM mode and the user ran `/install` without `vm`, say so and ask once whether to switch it back to the local rules: on yes, remove `Bash(*)` from `allow` and set `blockReadsOutsideWorkingDirectories` to `true` in `.claude/settings.local.json`, then continue with the steps below, which add the local rules back. On no, stop and change nothing.

Do the following:

1. **Shared file, `.claude/settings.json`.**
   - If it doesn't exist, create it as an exact copy of `.claude/install-baseline.json`.
   - If it exists, read it and merge in `.claude/install-baseline.json` without dropping any existing keys.
   - Then remove what belongs in the local file instead (projects set up before the split have it in the shared file): the `blockReadsOutsideWorkingDirectories` key, `Bash(*)` from `allow`, and every `ask` and `deny` entry that is in `.claude/install-baseline-local.json`. Anything else stays, for example entries from `/fence` or other sources. Remember which of them you removed: step 2 puts them where they belong.

   The baseline also sets `"model": "sonnet"`, the default model for development (cheaper than Opus; the user switches with `/model` for brainstorm and review). Add the `model` key only if the file has none: a model the project already chose stays.

   When merging, add each `allow`, `ask`, and `deny` entry only if not already present (union, don't duplicate). Never drop existing entries that aren't in a baseline: those came from somewhere else (e.g. `/fence`) and are still wanted.

2. **Local file, `.claude/settings.local.json`** (personal; it may hold the user's own entries, which stay). Create it if missing, otherwise merge: set `blockReadsOutsideWorkingDirectories` to `true`, and add each `allow`, `ask`, and `deny` entry of `.claude/install-baseline-local.json` that isn't there yet. `.claude/settings.local.json` is in `.gitignore`; if the project's `.gitignore` lacks that line, add it.

   What the rules do:
   - **Built-in (no rule needed):** Claude Code already runs its read-only commands (`ls`, `cat`, `grep`, `find`, `head`, `diff`, `cd`, read-only `git`, …) without a prompt. `blockReadsOutsideWorkingDirectories` fences them and the file tools to the project, and the `Read`/`Edit` deny rules also apply to Bash file commands (`cat`, `sed`, `tee`) and to `>` redirects.
   - **allow (shared):** the one-time git setup that `/github` runs (`git init`, this repo's commit author, and checking or adding a remote on the `anderspetor` GitHub account only), the normal git workflow including the per-task backup push (see the Git rules in `Instructions/instructions.md`), and the template and setup scripts.
   - **ask (shared):** git commands that lose uncommitted work.
   - **ask (local):** commands that reach outside the project (remote shells, containers, services, scheduled jobs, global package installs, permission changes), and any command with an argument in the home folder (`~`, `$HOME`, `/home/...`). Ask rules force a prompt in every mode, including auto mode. The home-folder rules also catch the project's own absolute path, which is why the AI must use project-relative paths (see "Running commands" in `Instructions/instructions.md`).
   - **deny (shared):** credential stores, force-push and remote branch deletion, disk-level and power commands, and piping into a bare shell (`curl ... | bash`).
   - **deny (local):** `/etc`, shell startup files and autostart locations (common malware persistence spots), and `sudo`/`su`.

   These rules are a baseline for every project, independent of whether `/fence` / `SECURITY.md` has been set up. `/fence` adds project-specific exceptions and denials on top of this baseline (in the shared file); it does not replace it.

3. Verify the result with this exact command (one Bash call, from the project root; `/start` uses the same check):

   ```
   bash .claude/install-check.sh
   ```

   It prints one line and exits 0 only when both files hold every rule for this machine's mode: `ok local` here (`ok vm` after `/install vm`). Anything else means a file is incomplete or the shared file still holds local rules: fix it and run the check again before reporting success. If the check itself is the command that prompts (a project whose old settings don't yet allow it), the user approves it once.

   Never edit the `.claude/install-*` files in a project: they are the template's baselines, and `/start` compares against them. Project-specific rules belong in `SECURITY.md` (applied by `/fence`).

4. Look at the rest of `.claude/settings.local.json`. It's personal and never shipped with the template. Flag (don't silently remove) and ask the user whether to remove each one or leave it:
   - any `allow` rule whose path points outside the project root (an absolute path, e.g. `Read(//home/...)`, that isn't under this project's own directory): dead weight once `blockReadsOutsideWorkingDirectories` is set, since that block wins over any allow rule;
   - any `allow` rule that lets arbitrary code run without a prompt, such as `Bash(python3 -)`, `Bash(python3 *)`, `Bash(node *)`, `Bash(bash *)`, `Bash(sh *)`, or `Bash(*)`. These silently bypass every ask rule above.

5. Report what was changed, and note plainly:
   - **Per machine:** the mode is stored in `.claude/settings.local.json`, which stays on this machine. Another machine using the same repo sets its own mode with its own `/install` or `/install vm`; a fresh clone has the shared rules only, and `/start` asks to run `/install`.
   - **Mode:** the rules work best with **auto mode**, set by the user in the Claude Code UI (it can't be set from project settings). Its reviewer model checks commands no rule covers, such as running scripts. If auto mode is unavailable (for example disabled by an organization admin), use **accept edits** mode: file edits and `mkdir`/`touch`/`rm`/`mv`/`cp` inside the project run without a prompt, and other commands ask.
   - **Known gap:** without a sandbox, rules control which commands run without asking, not what they do. A script or program Claude runs (`python3 script.py`, `npm run build`) can read and write anywhere the user can. Auto mode's reviewer and the user's own review of prompts are the protection there.
   - **Sandbox (not enabled):** Claude Code's Bash sandbox would close that gap at OS level, but on Ubuntu 24.04+ it needs a system AppArmor change for `bwrap`. On a managed (company) PC that needs IT approval. Don't enable or suggest system changes without the user asking.
   - The deny list is generic and not exhaustive. Project-specific exceptions and additional denials belong in `Instructions/manuscript/SECURITY.md`, applied via `/fence`.

## VM mode (`/install vm`)

Use this when the user typed `vm`. The VM is the sandbox: a project that runs on its own VM, with nothing on it that the user wouldn't want the AI to reach, doesn't need the local fencing, and every approval prompt costs progress. Check with the user, in one sentence and only once, that this machine is a VM that holds only this project; on no, stop and suggest plain `/install`.

VM mode lives in `.claude/settings.local.json` only, so it never reaches the PC through the repo. The shared file stays as it is.

1. Do step 1 above (shared file: merge the baseline, and move out anything that belongs in the local file).
2. **The user writes `.claude/settings.local.json`, not you.** It grants `Bash(*)`, and Claude Code's auto-mode classifier refuses an AI that writes its own unrestricted Bash permission (a write attempt is blocked as self-modification, and the project is left half-migrated). Don't try to write it, and don't look for another way. Instead, make sure `.gitignore` has the `.claude/settings.local.json` line, then read `.claude/settings.local.json` (if it exists) and tell the user in one short message what to do:
   - **The file doesn't exist:** the user runs this in the terminal of the Claude Code prompt (the `!` runs it in their shell, not through you): `! cp .claude/install-baseline-vm.json .claude/settings.local.json`
   - **The file exists** (it has the user's own entries): the user adds `"Bash(*)"` to `permissions.allow` and sets `permissions.blockReadsOutsideWorkingDirectories` to `false`, and removes every entry of `.claude/install-baseline-local.json` from `permissions.ask` and `permissions.deny`: those are the local fencing rules that VM mode drops. Show the exact lines to add and remove. Entries from other sources stay.

   Then wait for the user to say it's done. Removing `Bash(*)` and the local rules from the shared `.claude/settings.json` (step 1) is something you may do: it only narrows permissions.
3. Verify with `bash .claude/install-check.sh` (one Bash call, from the project root). It must print `ok vm`. If it doesn't, tell the user what is missing, and wait again.
4. Report what changed, and say plainly:
   - **What VM mode does:** all Bash commands run without a prompt, and files outside the project are readable. Still asked (shared rules): git commands that lose uncommitted work. Still denied (shared rules): credential stores (`~/.ssh`, `~/.aws`, `~/.gnupg`, `~/.netrc`), force-push and remote branch deletion, disk and power commands, and piping into a bare shell. `sudo` and `/etc` are no longer blocked, so the AI can install and test the `.deb`.
   - **What it protects and what it doesn't:** the VM keeps the AI away from the user's PC and other projects. It doesn't stop the AI from using what is reachable from the VM: the GitHub key on it (use a key limited to this one repo, not the whole account), the network the VM can reach, and any secret stored on it. Keep those in mind before using VM mode.
   - **Mode:** auto mode or skipping permission prompts is the user's separate choice in the Claude Code UI. The `/install vm` rules alone don't cover everything: edits to files outside the project, and web access to new sites, may still ask.
   - **Only on this machine:** the mode is in `.claude/settings.local.json`, so a PC working on the same repo keeps its own local rules. `/start` recognises VM mode by `Bash(*)` in that file and checks against the VM baseline from then on. `/install` without `vm` asks before switching back.
   - Skip the `Bash(*)` flag in step 4 above: `Bash(*)` is wanted here.

This command is idempotent: safe to run again on a project that's already locked.
