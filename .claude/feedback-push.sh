#!/usr/bin/env bash
# Send this project's template feedback to the shared feedback repo.
#
# Usage (from the project root): bash .claude/feedback-push.sh
#
# Pushes Instructions/TEMPLATE_FEEDBACK.md, and nothing else, to the branch named after this project
# (the root folder's name, made safe the way /github makes repo names; "main" is the feedback repo's
# own branch, so a project can't use it) in the feedback repo. The
# project's own code and history never leave its repo, and nothing is cloned: the commit is built
# in this repo with git plumbing, holds only the one file (as feedback.md), and goes on top of the
# branch's last commit, so the push is a normal fast-forward.
#
# Exit 0: sent, already up to date, or nothing to send. Exit 3: not a git repository.
# Exit 4: the feedback repo couldn't be reached, or the push failed. Exit 5: no commit author set.

set -euo pipefail
export LC_ALL=C

FEEDBACK_URL="${FEEDBACK_URL:-git@github.com:anderspetor/workbox-feedback.git}"
FILE=Instructions/TEMPLATE_FEEDBACK.md

if ! root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "not a git repository: template feedback is sent from a project's git repo" >&2
  exit 3
fi
cd "$root"

if [[ ! -f "$FILE" ]] || ! grep -qE '^### T[0-9]+' "$FILE"; then
  echo "no template feedback entries to send"
  exit 0
fi
if ! git config user.email >/dev/null || ! git config user.name >/dev/null; then
  echo "no commit author set in this repo (/start sets it)" >&2
  exit 5
fi

branch="$(basename "$root" | sed -E 's/[^A-Za-z0-9._-]+/-/g')"
if [[ "$branch" == main ]] || ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
  echo "project folder name '$(basename "$root")' doesn't make a valid branch name" >&2
  exit 4
fi

blob="$(git hash-object -w -- "$FILE")"
tree="$(printf '100644 blob %s\tfeedback.md\n' "$blob" | git mktree)"

for attempt in 1 2; do
  if ! heads="$(git ls-remote "$FEEDBACK_URL" "refs/heads/$branch" 2>&1)"; then
    echo "could not reach $FEEDBACK_URL: $heads" >&2
    exit 4
  fi
  parent=()
  if [[ -n "$heads" ]]; then
    if ! git fetch --quiet --no-tags "$FEEDBACK_URL" "refs/heads/$branch" 2>/dev/null; then
      echo "could not fetch branch $branch from $FEEDBACK_URL" >&2
      exit 4
    fi
    last="$(git rev-parse FETCH_HEAD)"
    if [[ "$(git rev-parse "$last^{tree}")" == "$tree" ]]; then
      echo "template feedback already sent (branch $branch)"
      exit 0
    fi
    parent=(-p "$last")
  fi
  commit="$(git commit-tree "$tree" "${parent[@]}" -m "Template feedback from $branch")"
  if git push --quiet "$FEEDBACK_URL" "$commit:refs/heads/$branch" 2>/dev/null; then
    echo "template feedback sent (branch $branch, $(grep -cE '^### T[0-9]+' "$FILE") entries)"
    exit 0
  fi
  # Rejected, most likely because another machine pushed in between: fetch again and retry once.
done
echo "could not push template feedback to $FEEDBACK_URL (branch $branch)" >&2
exit 4
