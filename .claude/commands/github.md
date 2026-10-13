Connect this project folder to its private GitHub repository and upload it. The whole project folder (Instructions/, manuscript, CURRENT_STATE, Application/, Design/, Source-files/) goes into one repo, which is also the project's backup. `.gitignore` leaves out build output in `Release/` and personal settings. Run this once per project, after the template folder has been renamed to the project name and the user has created an empty repo with the same name on GitHub.

## Account settings

- GitHub user: `anderspetor`
- Commit author: `Anders Petor Holm` <`anders.petor.holm@gmail.com`>
- Login: SSH key on this machine (no GitHub CLI needed)
- Remote URL: `git@github.com:anderspetor/<repo-name>.git`

Invoking `/github` is the user's approval to push this project to that remote. Ask again only if a check below flags something.

This command is idempotent: on a project that is already connected, it only reports the current state.

## Procedure

Run every command below as its own Bash call from the project root, exactly as shown: no `cd`, no `&&` chains, loops, or pipelines. `/install`'s allow rules cover these setup commands, so done this way they run without permission prompts.

1. **Check the folder name.** The repo is named after the project root folder. If the folder is still named `workbox` (the template's default name), stop: the template hasn't been renamed to a project yet. Otherwise, work out the repo name the way GitHub does: replace each run of characters other than ASCII letters, digits, `.`, `-`, `_` (spaces and letters like æ, ø, å included) with a single `-`. If the user has said the repo has a different name, use that instead.

2. **Check the git state** of the project root:
   - `git rev-parse --show-toplevel` succeeds with a path *above* the project root → the project is inside another git repo. Stop and tell the user; do not create a nested repo without their decision.
   - It's already a repo and `git remote get-url origin` succeeds → already connected. Report the remote URL, the current branch, and whether there are unpushed commits (`git status -sb`), then stop. Do not change anything.
   - It's a repo without a remote → skip `git init` in step 4.
   - Not a repo → continue.

3. **Check that GitHub is reachable and the repo is ready**, with `git ls-remote git@github.com:anderspetor/<repo-name>.git`. Stop on failure and give a "Human action required" request (format in `Instructions/AUTONOMOUS_EXECUTION_PROTOCOL.md`):
   - `Host key verification failed` → this machine hasn't connected to GitHub over SSH before. Ask the user to run `ssh -T git@github.com` once in their own terminal and answer `yes` only if the fingerprint shown matches one of GitHub's published SSH key fingerprints (docs.github.com, "GitHub's SSH key fingerprints"). Then run `/github` again. Never accept the host key on the user's behalf.
   - `Permission denied (publickey)` → the SSH key isn't loaded or isn't added to the `anderspetor` account. Ask the user to fix that, then run `/github` again.
   - `Repository not found` → tell the user the exact name you looked for. Ask them to either create a private repo with that name under `anderspetor` on github.com, **empty** (no README, license, or .gitignore), or tell you the exact name of the repo they already created. Then run `/github` again.
   - It succeeds but lists refs → the GitHub repo isn't empty. Stop and ask the user. Never force-push or merge into an existing repo from this command.
   - It succeeds with no output → the repo exists and is empty. Continue.

4. **Create the local repo.** If not already a repo: `git init -b main`. Then set the commit author for this repo, as two separate calls: `git config user.name "Anders Petor Holm"` and `git config user.email "anders.petor.holm@gmail.com"`.

5. **Complete `.gitignore`.** The template ships a base `.gitignore`: keep all of it. Look at what's in `Application/` and append the ignore entries its stack needs (e.g. `node_modules/`, `.venv/`, `__pycache__/`, `dist/`, `build/`, `target/`, `.env`). Only add entries for things actually present or clearly implied by the project; don't paste a generic kitchen-sink list.

6. **Stage and check before committing.** `git add -A`, then review what is staged (`git status --porcelain`):
   - Anything that looks like a secret (`.env` files, private keys, `*.pem`, files or lines containing tokens/passwords/API keys) → unstage it, add it to `.gitignore`, and tell the user. Search contents with the Grep tool, not a shell pipeline.
   - Any file over 50 MB → stop and ask the user (GitHub rejects files over 100 MB and warns above 50 MB). It probably belongs in `Release/` or outside git. Find them with `find . -path ./.git -prune -o -type f -size +50M -print`.
   - Then commit: `git commit -m "Initial commit"`.

7. **Connect and push**, as two separate calls:

   ```
   git remote add origin git@github.com:anderspetor/<repo-name>.git
   ```
   ```
   git push -u origin main
   ```

   If the push is rejected with `GH007` (GitHub's "keep my email private" setting blocks pushes that show the email), tell the user: either turn that setting off, or tell you to use their GitHub `noreply` address as the commit email instead (then amend the unpushed commit's author and push again).

8. **Report** the repo URL (`https://github.com/anderspetor/<repo-name>`) and what was pushed. Mention that from now on the Git rules in `Instructions/instructions.md` apply: the AI commits and pushes after each completed task, so the GitHub repo stays a current backup.
