#!/usr/bin/env bash
# At turn end, if frontend files changed, continue once with a convention-review reminder.
# One reminder per diff state: the same uncommitted change never re-triggers (no loop).
# This is a reminder, not proof that the review ran or passed.

source "$(dirname "$0")/lib.sh"
command -v jq > /dev/null 2>&1 || exit 0
HOOK_INPUT=$(cat)

root=$(project_root)
git -C "$root" rev-parse --git-dir > /dev/null 2>&1 || exit 0
is_frontend_project "$root" || exit 0

spec=('*.ts' '*.tsx' '*.js' '*.jsx')
files=()
while IFS= read -r f; do
  [[ -n "$f" ]] && is_frontend_file "$root" "$root/$f" && files+=("$f")
done < <(
  {
    git -C "$root" -c core.quotePath=false ls-files --modified --others --exclude-standard -- "${spec[@]}"
    git -C "$root" -c core.quotePath=false diff --cached --name-only -- "${spec[@]}"
  } 2> /dev/null | sort -u
)
[[ ${#files[@]} -gt 0 ]] || exit 0

# Diff state = each changed file's current content (works with or without HEAD, staged or not).
state=$(
  for f in "${files[@]}"; do
    printf '%s ' "$f"
    git -C "$root" hash-object -- "$f" 2> /dev/null || echo deleted
  done | git hash-object --stdin
)

data_dir="${PLUGIN_DATA:-${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/zeriong-frontend-conventions}}"
mkdir -p "$data_dir" 2> /dev/null || exit 0
marker="$data_dir/stop-$(printf '%s' "$root" | git hash-object --stdin)"

[[ "$(cat "$marker" 2> /dev/null)" == "$state" ]] && exit 0
printf '%s' "$state" > "$marker" 2> /dev/null || exit 0

listed=$(printf '%s\n' "${files[@]}" | head -n 10 | tr '\n' ' ')
jq -n --arg reason "[Convention Review Gate] Frontend files changed: ${listed}. Run the convention-review skill on these files now and fix any P1-P2 findings before finishing." \
  '{decision: "block", reason: $reason}'
