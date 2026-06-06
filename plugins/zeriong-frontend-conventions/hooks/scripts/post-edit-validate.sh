#!/usr/bin/env bash
# Post-edit quantitative convention checks (270-line cap, banned naming, etc.).

set -euo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Frontend files only.
if [[ -z "$file_path" ]] || [[ ! "$file_path" =~ \.(tsx?|jsx?)$ ]]; then
  exit 0
fi

if [[ ! -f "$file_path" ]]; then
  exit 0
fi

warnings=""

# 270-line cap (excluding blank lines and comment lines).
line_count=$(sed '/^\s*$/d; /^\s*\/\//d; /^\s*\*/d; /^\s*\/\*/d' "$file_path" | wc -l | tr -d ' ')
if [[ "$line_count" -gt 270 ]]; then
  warnings="${warnings}[Convention] ${file_path}: ${line_count} lines (cap: 270). Consider splitting components.\n"
fi

# Banned subjective-adjective naming.
if grep -qE '(Smart|Cool|Nice|Awesome|Magic|Super|Ultra|Fancy)[A-Z]' "$file_path" 2>/dev/null; then
  warnings="${warnings}[Convention] ${file_path}: subjective-adjective naming detected (Smart*/Cool*/Nice* etc). Rename to something intuitive.\n"
fi

# useState overuse (>=5).
useState_count=$(grep -c 'useState' "$file_path" 2>/dev/null || echo "0")
if [[ "$useState_count" -ge 5 ]]; then
  warnings="${warnings}[Convention] ${file_path}: useState used ${useState_count} times. Consider extracting a custom hook.\n"
fi

# JSX `&&` with falsy-number risk (e.g. {arr.length && <X />}).
if grep -qE '\{[a-zA-Z_]+(\.(length|count|size))?\s*&&' "$file_path" 2>/dev/null; then
  if grep -qE '\{[a-zA-Z_]+\.(length|count|size)\s*&&' "$file_path" 2>/dev/null; then
    warnings="${warnings}[Convention] ${file_path}: JSX uses && with a numeric falsy value. Use '? <X /> : null' instead.\n"
  fi
fi

# Formatter / linter config presence reminder (project root).
project_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -n "$project_root" ]]; then
  has_formatter=""
  for cfg in .prettierrc .prettierrc.js .prettierrc.json .prettierrc.yaml .prettierrc.yml prettier.config.js prettier.config.mjs biome.json biome.jsonc; do
    if [[ -f "${project_root}/${cfg}" ]]; then
      has_formatter="$cfg"
      break
    fi
  done
  if [[ -n "$has_formatter" ]]; then
    warnings="${warnings}[Convention] ${file_path}: project ships a formatter config (${has_formatter}). Confirm the edit matches its rules.\n"
  fi
fi

if [[ -n "$warnings" ]]; then
  echo -e "$warnings" >&2
fi

exit 0
