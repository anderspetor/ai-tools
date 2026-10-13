#!/usr/bin/env bash
# Keep this project's template files in step with the template repo.
#
# Usage (from the project root): bash .claude/template-sync.sh check|apply
#   check  exit 0: up to date. Exit 10: an update is available (changes are listed).
#   apply  overwrite the template files with the template's versions, remove template files the
#          template has dropped, and add the template's missing .gitignore lines. Doesn't commit.
# Any other exit code is an error; the message says what's wrong.
#
# Which files are template files is defined by .claude/template-files.txt, as the template has it.
# The template repo is added as the git remote "template" on first use.

set -euo pipefail
export LC_ALL=C  # byte order, so sort and comm always agree

TEMPLATE_URL="${TEMPLATE_URL:-git@github.com:anderspetor/workbox.git}"
LIST=.claude/template-files.txt
REF=refs/remotes/template/main

mode="${1:-}"
if [[ "$mode" != check && "$mode" != apply ]]; then
  echo "usage: bash .claude/template-sync.sh check|apply" >&2
  exit 2
fi

if ! root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "not a git repository: template updates need git (run /github first)" >&2
  exit 3
fi
cd "$root"

if ! git remote get-url template >/dev/null 2>&1; then
  git remote add template "$TEMPLATE_URL"
fi
if ! git fetch --quiet template "+refs/heads/main:$REF"; then
  echo "could not fetch the template from $(git remote get-url template)" >&2
  exit 4
fi

# The template's own list decides what's a template file.
mapfile -t paths < <(git show "$REF:$LIST" | sed -e 's/[[:space:]]*$//' -e '/^#/d' -e '/^$/d')
if [[ ${#paths[@]} -eq 0 ]]; then
  echo "the template has no $LIST" >&2
  exit 5
fi

# Template files tracked here that the template no longer has.
removed() {
  comm -23 <(git ls-files -- "${paths[@]}" | sort) \
           <(git ls-tree -r --name-only "$REF" -- "${paths[@]}" | sort)
}

# Lines in the template's .gitignore that this project's .gitignore lacks (comments and blanks skipped).
missing_ignores() {
  local ours=""
  [[ -f .gitignore ]] && ours="$(cat .gitignore)"
  git show "$REF:.gitignore" 2>/dev/null | while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    grep -qxF -- "$line" <<<"$ours" || printf '%s\n' "$line"
  done
}

if [[ "$mode" == check ]]; then
  # -R: list what the update would do to this project (A = added, M = changed, D = removed).
  changed="$(git diff -R --name-status "$REF" -- "${paths[@]}")"
  ignores="$(missing_ignores)"
  if [[ -z "$changed" && -z "$ignores" ]]; then
    echo "template files are up to date ($(git rev-parse --short "$REF"))"
    exit 0
  fi
  echo "template update available ($(git rev-parse --short "$REF")):"
  [[ -n "$changed" ]] && printf '%s\n' "$changed" | sed 's/^/  /'
  [[ -n "$ignores" ]] && printf '%s\n' "$ignores" | sed 's/^/  .gitignore line to add: /'
  exit 10
fi

# apply
git checkout "$REF" -- "${paths[@]}"
gone="$(removed)"
[[ -n "$gone" ]] && printf '%s\n' "$gone" | xargs -d '\n' git rm --quiet --
ignores="$(missing_ignores)"
if [[ -n "$ignores" ]]; then
  { echo; echo "# Added by template update"; printf '%s\n' "$ignores"; } >> .gitignore
fi
echo "template files updated to $(git rev-parse --short "$REF")"
git status --short
