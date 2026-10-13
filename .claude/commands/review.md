Review this project: check its code and handoff for bugs, security problems, failing or missing checks, and mismatches with the manuscript, and report them. Run it on demand: at the end of a milestone, before a release, or when the user wants a second look. Optional argument: a path or focus to review (for example `/review Application/src/api`). The review itself is done by the `reviewer` subagent (`.claude/agents/reviewer.md`), which starts with a clean context and runs on its own model. It only reports; the developer fixes later.

How to run everything below (the full rule is "Running commands" in `Instructions/instructions.md`):
- Read files with the Read tool, one file per call.
- Use Bash only where needed: one command per call, from the project root, with project-relative paths. No `&&` chains, loops, or pipelines.

## 1. Before starting

1. If the project root folder is still named `workbox`, stop: this is the template itself, not a project. Tell the user to create a project with `new-project.sh <name>` and open that instead.
2. If `.claude/agents/reviewer.md` doesn't exist, stop and say so: the project's template files are out of date, and `/start` brings them up to date.
3. If `.claude/settings.json` doesn't exist, the project hasn't been set up: suggest `/start` once first. Continue if the user prefers.
4. If `git remote get-url origin` succeeds, run `git pull --ff-only` and handle the result as "Pull" in `.claude/commands/start.md` describes, so the review covers what's on GitHub.

## 2. Run the reviewer

Start the `reviewer` subagent with the Agent tool, in the foreground (`run_in_background: false`), since everything after depends on its result. In the prompt, give only the scope from the user's argument (or "the whole project") and nothing else: don't pass your own view of the project, so the review stays independent.

## 3. Report

Relay the reviewer's reply to the user as it is, without softening or adding findings of your own. Then give the next step: to fix the findings, type `/clear` (or open a new session), then `/start`, and tell the developer to fix the open review findings. There's no `/end` for a review: the reviewer has already saved and pushed its report. Don't fix anything yourself, even a one-line bug.
