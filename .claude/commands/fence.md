Apply `Instructions/manuscript/SECURITY.md` — this project's declared outside-project-root access policy — to `.claude/settings.json`. The point is to decide access exceptions once, deliberately, in writing, rather than repeatedly mid-session when the user's attention to what you're doing has faded (this is the documented "approval fatigue" failure mode: after many permission prompts in one session, approvals get rubber-stamped rather than reviewed).

## SECURITY.md format

Three buckets, each a bullet list of tagged items:

```
# Security Fence

## Always OK (no prompt)
- [directory] <path> — <why>
- [bash] <command pattern> — <why>
- [write] <path> — <why>

## Always Ask
- [directory|bash|write] <path or pattern> — <why this stays manual despite being named here>

## Always Deny
- [path] <path> — <why>
- [bash] <command pattern> — <why>

<!-- fence-applied: sha256:<hex> -->
```

Tags mean:
- `[directory]` under **Always OK** → a directory outside the project the AI may *read* freely. Maps to `permissions.additionalDirectories` (tilde-expand to an absolute path) **plus** `permissions.ask` entries `Edit(//<absolute-path>/**)` and `Write(//<absolute-path>/**)`. The ask entries are required: an additional directory otherwise counts as part of the workspace, and accept-edits mode would change files there without asking. Do not use this tag for write access: reads and writes are different risk levels and get different rules.
- `[bash]` under **Always OK** → a specific command pattern that should never prompt. Maps to `permissions.allow` as `Bash(<pattern>)`.
- `[write] ` under **Always OK** → a specific path the AI may create/modify files in without asking. Maps to `permissions.allow` as both `Edit(//<absolute-path>/**)` and `Write(//<absolute-path>/**)`.
- Anything under **Always Ask** → maps to `permissions.ask` with the matching rule syntax for its tag (`Bash(...)`, `Edit(//...)`, `Write(//...)`). Items here are mostly for the record — untagged paths already default to "ask" — but list one explicitly whenever you want to document that you considered it and deliberately decided it should keep prompting (e.g. because it's borderline), so a later reviewer doesn't mistake the omission for an oversight.
- `[path]` under **Always Deny** → maps to `permissions.deny` as `Read(//<path>/**)`, `Edit(//<path>/**)`, and `Write(//<path>/**)` — a hard block regardless of mode, for genuinely sensitive locations (credential stores, `/etc`, etc.).
- `[bash]` under **Always Deny** → maps to `permissions.deny` as `Bash(<pattern>)`.

How these interact with the `/install` baseline (rule precedence is deny, then ask, then allow):
- On a machine in local mode (not VM mode), `/install` has ask rules (in `.claude/settings.local.json`) for any Bash command with an argument under `~`, `$HOME`, or `/home/`. They beat allow rules, so a `[bash]` allow whose command names a path in the home folder will still prompt, and so will Bash reads of a `[directory]` under `/home`. The Read/Grep/Glob tools read a `[directory]` without prompting. When a `[bash]` item needs a home-folder path, tell the user it will keep prompting and suggest moving it to **Always Ask** for the record.
- An Always OK item can never override an `/install` deny rule (e.g. credential stores; on a machine in local mode also `sudo` and shell startup files). If the user lists one, say so and don't pretend it's active.

The trailing HTML comment is a hash marker this command manages — never author it by hand.

## Procedure

1. Read `Instructions/manuscript/SECURITY.md`.
2. Strip the trailing `<!-- fence-applied: sha256:... -->` line if present, and compute the SHA-256 of the remaining content (trimmed of surrounding whitespace so incidental formatting doesn't count as a change).
3. Determine state:
   - **EMPTY** — the body (excluding the marker) is blank.
   - **UNAPPLIED** — the body has content but there is no marker line at all.
   - **UNCHANGED** — a marker exists and its hash matches the computed one.
   - **CHANGED** — a marker exists but the hash differs.
4. Branch:
   - **EMPTY** → Ask the user, in one pass, for the Always-OK / Always-Ask / Always-Deny items (use AskUserQuestion where the option set is discrete; free-text for paths/patterns). Write the answer into `SECURITY.md` in the format above, without a marker yet, then continue to step 5.
   - **UNAPPLIED** → Parse the existing buckets and summarize them back to the user (what will become allow/ask/deny, in plain language) and get explicit confirmation before continuing — first activation of a security policy deserves one look even if the user wrote it themselves. If they want changes, help edit `SECURITY.md`, then re-run this procedure from step 1.
   - **UNCHANGED** → Report "SECURITY.md unchanged since it was last applied — no action taken" and stop. Do not touch `.claude/settings.json`.
   - **CHANGED** → Parse the new buckets, summarize what's different from what `.claude/settings.json` currently contains (in plain language — "X is newly allowed", "Y is no longer denied", etc.), and get explicit confirmation before continuing. This is the one case where silent auto-apply is exactly the wrong behavior — the whole feature exists so changes get a deliberate look.
5. **Apply**: read `.claude/settings.json` (create it if missing) and merge in — never replace the whole file:
   - Leave `permissions.blockReadsOutsideWorkingDirectories` alone: `/install` keeps it in this machine's `.claude/settings.local.json`, not in this shared file. This command assumes `/install` has been run, but don't skip the fence just because it hasn't.
   - `permissions.additionalDirectories` — union with existing entries, don't duplicate.
   - `permissions.allow` / `permissions.ask` / `permissions.deny` — append the mapped rules, merging with whatever is already in each array.
6. Validate the result with `jq . .claude/settings.json` before reporting success.
7. Update the marker line in `SECURITY.md` to the new hash (add it if this was the first apply).
8. Report exactly what changed in `.claude/settings.json`, in plain language per bucket.

This command is idempotent when SECURITY.md is unchanged (state UNCHANGED is a pure no-op) — safe to re-run at any time to check status.
