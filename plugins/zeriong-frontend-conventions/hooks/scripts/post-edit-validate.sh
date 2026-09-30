#!/usr/bin/env bash
# Post-edit quantitative convention checks (270-line cap, banned naming, etc.).
# Input: Claude Code Write/Edit/MultiEdit (tool_input.file_path) or Codex apply_patch (tool_input.command).
# Scope: file-edit tools only; shell-made edits are left to convention-review.

set -euo pipefail
source "$(dirname "$0")/lib.sh"
HOOK_INPUT=$(cat)

root=$(project_root)
is_frontend_project "$root" || exit 0
cwd=$(hook_cwd)

# Domain terms that start with a banned adjective but are not subjective.
ALLOWED_NAMES='SuperAdmin|SuperUser'

# Claude passes one file_path; a Codex patch can add, update, or move several files.
edited_files() {
  local file_path
  file_path=$(hook_field '.tool_input.file_path')
  if [[ -n "$file_path" ]]; then
    printf '%s\n' "$file_path"
    return
  fi
  hook_field '.tool_input.command' | tr -d '\r' | sed -n -E 's/^\*\*\* (Add File|Update File|Move to): (.*)$/\2/p'
}

check_file() {
  local f=$1 out="" count names lines

  # 270-line cap (excluding blank lines and comment lines).
  count=$(grep -cvE '^[[:space:]]*($|//|/\*|\*)' "$f" || true)
  if [[ "$count" -gt 270 ]]; then
    out+="- ${f}: ${count} lines (cap: 270, blank/comment lines excluded). Consider splitting components."$'\n'
  fi

  # Banned subjective-adjective naming.
  names=$({ grep -oE '(^|[^A-Za-z0-9_$])(Smart|Cool|Nice|Awesome|Magic|Super|Ultra|Fancy)[A-Z][A-Za-z0-9_]*' "$f" || true; } |
    sed -E 's/^[^A-Za-z]//' | { grep -vE "^(${ALLOWED_NAMES})" || true; } | sort -u | tr '\n' ' ')
  if [[ -n "$names" ]]; then
    out+="- ${f}: subjective-adjective naming (${names% }). Rename to something intuitive."$'\n'
  fi

  # useState overuse (>= 5 calls; the import line does not count).
  count=$({ grep -oE '(^|[^A-Za-z0-9_$])useState[[:space:]]*[<(]' "$f" || true; } | wc -l | tr -d ' ')
  if [[ "$count" -ge 5 ]]; then
    out+="- ${f}: useState called ${count} times. Consider extracting a custom hook."$'\n'
  fi

  # JSX `&&` with falsy-number risk (e.g. {arr.length && <X />}).
  lines=$({ grep -nE '\{[[:space:]]*[A-Za-z_$][A-Za-z0-9_$.]*\.(length|count|size)[[:space:]]*&&' "$f" || true; } |
    cut -d: -f1 | tr '\n' ',')
  if [[ -n "$lines" ]]; then
    out+="- ${f}:${lines%,}: JSX uses && with a numeric falsy value. Use '? <X /> : null' instead."$'\n'
  fi

  printf '%s' "$out"
}

warnings=""
while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  [[ "$path" == /* ]] || path="${cwd}/${path}"
  [[ "$path" =~ \.(tsx?|jsx?)$ ]] || continue
  [[ -f "$path" ]] || continue
  is_frontend_file "$root" "$path" || continue
  warnings+=$(check_file "$path")$'\n'
done < <(edited_files)

warnings=$(printf '%s' "$warnings" | sed '/^$/d')
[[ -n "$warnings" ]] || exit 0

emit_context PostToolUse "[Convention] post-edit checks:"$'\n'"${warnings}"
