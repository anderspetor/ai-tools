# Brainstorm Log

Written by `/end` after a `/brainstorm` session and read by `/brainstorm` at the start of the next one. The developer doesn't read it: only what's written into the manuscript counts as agreed.

## Parked ideas and open questions

Kept across brainstorm sessions. An item is removed when it's resolved or written into the manuscript.

Open questions:
- Team kit (M1): how team files reach the developer VMs: SSH from the ai-tools VM (its key allowed on each VM, plus a `SECURITY.md` item here) or a script run on the host. Not answered.
- Team kit (M1): auto-load the team files through one line in each project's `CLAUDE.md` (not a template file, so no template change needed). Proposed, not answered.
- When to write the manuscript: brainstormer proposed writing it soon, with M1 (team kit) in full, M2/M3 as goals and features only, and a separate UI brainstorm with mockups for the hub page before M2 is planned. Not answered.
- Hub details proposed, not answered: messages are text only (markdown and code blocks, no attachments) in v1; developers are deactivated and get new keys instead of being deleted, so history stays.
- Template feedback: offered an entry proposing a "trusted VM" setup option (auto mode plus hard limits) for the workbox template. User didn't answer; not written.

Parked ideas:
- "Contracts": a shared place on the hub for agreed interfaces between parts (API formats, shared names). Planned for M2.
- Hub card shows "waiting for approval" for a developer, via a Claude Code notification hook.
- Hub page links each developer card to its Remote Control session in claude.ai/code.
- Developer VM profile: auto mode plus hard limits (per-repo GitHub key, branch protection, firewall to hub/GitHub/internet only, VM snapshots); bypass mode only after experience.
- Manager AI: a Claude session with the manager role that instructs and collects answers from all developers through the hub (later level).
- An `ask_manager` hub tool for questions to the user, answered on the hub page.
- Tip for the user: VS Code with Remote - SSH on the host to look at VM code, with claude.ai/code for talking.

## Last brainstorm session

Session: 2026-10-14

**Discussed:**
- Purpose: a tool that lets the user's developer AIs (Claude Code, one per VM in virt-manager, each building part of a bigger project) talk to each other, with the user as manager. Today the user copy-pastes technical questions between sessions. Also a learning project.
- Network: VMs are on libvirt's default NAT network (this VM 192.168.122.18, host 192.168.122.1).
- MCP explained: the server is an ordinary program (a "post office"); no AI runs on it, and every request comes from a VM.
- Existing projects (MCP Agent Mail, claude-agent-bus, cc2cc, cross-agent-teams, AgentsRoom): mostly built for many agents on one repo on one machine.
- Claude Code Remote Control: the user enabled it as org admin and tested it.
- Claude Code channels (research preview): a hub can push messages into a session, wake an idle developer, and relay permission prompts. CLI only, needs `--dangerously-load-development-channels` and the org Channels setting; combining it with Remote Control is undocumented.
- Permission modes on a VM: guidelines vs hard limits.

**Agreed (nothing written to the manuscript yet; no go):**
- Build our own small hub (option 2), borrowing proven ideas (identities, threads, read receipts, broadcast), not MCP Agent Mail as-is.
- The hub runs on the host, listening on 192.168.122.1, reachable only from the VMs. It's an MCP server plus a web page in one program, with one access key per developer.
- Several teams on one server, each team closed off from the others; only the manager sees all.
- The hub page has a manager password; the user is its only user.
- Messages from other developers are information and questions, not orders. Only the user (or, later, the manager) says "go".
- Timing for v1: a busy developer answers at its next pause, and the asker tells the user it's waiting and continues. An idle developer sees messages when nudged, and the page marks unanswered questions. No timed polling, because it costs usage.
- Contracts move to M2.
- The user wants one page to manage everything. The recommended way is channels, with a test first; this fits M3.
- Plan in three steps:
  - **M1, team kit:** a master team file per team plus shared guidelines kept in this project (`teams/<team>/team.md`, `teams/GUIDE.md`), a `sync-team.sh` that copies them into each member project (`Instructions/team/`) with "you are X", and a fixed TEAM MESSAGE format that the user copy-pastes between chats in claude.ai/code.
  - **M2, hub:** the same format, delivered automatically.
  - **M3, one page:** channels, starting with a feasibility test.
- Not in scope: our own remote chat (Remote Control covers it), and any AI on the server.

**Done outside the manuscript (user's VM setup, verified on proxy-admin):**
- Steps, in order:
  1. Install the Claude CLI (`curl -fsSL https://claude.ai/install.sh | bash`) and add `~/.local/bin` to PATH.
  2. Run `claude` once in the project to log in and trust the folder.
  3. Add a systemd user service that runs `tmux new-session -d -s claude-rc claude remote-control --name <proj> --spawn=same-dir`, with `Restart=always`.
  4. Run `loginctl enable-linger`.
- Lessons:
  - Server mode asks a one-time spawn-mode question, so `--spawn=same-dir` is needed for the service.
  - Sessions spawned from the web get "Accept edits"; add `--permission-mode auto` if wanted (suggested, not confirmed).
  - Workbox commands like `/start` work from claude.ai/code even though its menu doesn't list them.
- This becomes the VM setup script in the plan.

**Mockups:** none.

**Not written yet:** everything above. The user paused the project to try Remote Control across VMs for a while. The discussion stopped at the three open M1 questions (team-file delivery, `CLAUDE.md` auto-load, when to write the manuscript).

**Next:**
- Ask about the user's experience with Remote Control.
- Answer the open M1 questions.
- Finish features and data for M1, then write the manuscript (M1 in detail, M2/M3 as goals).
- Hold a UI session with mockups for the hub page before M2.
