#!/usr/bin/env bash
# Checks the permission setup of this project against the template baselines (see .claude/commands/install.md).
# Prints one line and exits 0 only when the setup is complete: "ok local" or "ok vm". Read-only.
#   .claude/settings.json        shared, committed: baseline for every machine (install-baseline.json)
#   .claude/settings.local.json  per machine, git-ignored: the mode, local fencing or VM (install-baseline-local.json / install-baseline-vm.json)
cd "$(dirname "$0")/.." || exit 2
s=.claude/settings.json
sl=.claude/settings.local.json
[ -f "$s" ] || { echo "missing: .claude/settings.json (run /install)"; exit 1; }
jq -e . "$s" >/dev/null 2>&1 || { echo "invalid: .claude/settings.json is not valid JSON"; exit 1; }
if [ -f "$sl" ]; then
  jq -e . "$sl" >/dev/null 2>&1 || { echo "invalid: .claude/settings.local.json is not valid JSON"; exit 1; }
  local_json=$(cat "$sl")
else
  local_json='{}'
fi
out=$(jq -r \
  --slurpfile b .claude/install-baseline.json \
  --slurpfile l .claude/install-baseline-local.json \
  --slurpfile v .claude/install-baseline-vm.json \
  --argjson sl "$local_json" '
  ($b[0].permissions) as $sh | ($l[0].permissions) as $lo | ($v[0].permissions) as $vm
  | (.permissions // {}) as $p | ($sl.permissions // {}) as $q
  | def lacking($want; $have): ($want // []) - ($have // []);
    def sharedMissing: any(("allow","ask","deny"); . as $k | lacking($sh[$k]; $p[$k]) != []);
    def sharedLeftover: ($p | has("blockReadsOutsideWorkingDirectories"))
      or (($p.allow // []) | index("Bash(*)") != null)
      or any(("ask","deny"); . as $k | (($lo[$k] // []) - (($lo[$k] // []) - ($p[$k] // []))) != []);
    def vmOk: ($q.blockReadsOutsideWorkingDirectories == false)
      and all(("allow","ask","deny"); . as $k | lacking($vm[$k]; $q[$k]) == []);
    def localOk: ($q.blockReadsOutsideWorkingDirectories == true)
      and all(("allow","ask","deny"); . as $k | lacking($lo[$k]; $q[$k]) == []);
    if (has("model") | not) then "needs /install: .claude/settings.json has no default model"
    elif sharedLeftover then "needs /install: .claude/settings.json holds rules that belong in .claude/settings.local.json"
    elif sharedMissing then "needs /install: .claude/settings.json lacks baseline rules"
    elif (($q.allow // []) | index("Bash(*)") != null) then (if vmOk then "ok vm" else "needs /install vm: VM rules in .claude/settings.local.json are incomplete" end)
    elif localOk then "ok local"
    else "needs /install: .claude/settings.local.json lacks the local rules" end
  ' "$s") || { echo "error: could not read the baselines"; exit 2; }
echo "$out"
case "$out" in ok*) exit 0 ;; *) exit 1 ;; esac
