#!/usr/bin/env bash
# Shared helpers for the convention hooks. Works under Claude Code and Codex (same input/output shape).
# Callers read stdin into HOOK_INPUT before using these.

FRAMEWORK_DEPS='"(react|next|vue|nuxt|svelte|@sveltejs/kit|solid-js|preact|@angular/core)"[[:space:]]*:'

hook_field() {
  printf '%s' "$HOOK_INPUT" | jq -r "$1 // empty" 2>/dev/null || true
}

hook_cwd() {
  local cwd
  cwd=$(hook_field '.cwd')
  printf '%s\n' "${cwd:-$PWD}"
}

# Git top-level of the hook cwd, else the cwd itself.
project_root() {
  local cwd
  cwd=$(hook_cwd)
  git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || (cd "$cwd" 2>/dev/null && pwd -P) || printf '%s\n' "$cwd"
}

has_framework_dep() {
  [[ -f "$1/package.json" ]] && grep -qE "$FRAMEWORK_DEPS" "$1/package.json"
}

# UI framework in the root or cwd package.json, or tracked tsx/jsx/vue/svelte files (monorepos).
is_frontend_project() {
  local root=$1
  has_framework_dep "$root" && return 0
  has_framework_dep "$(hook_cwd)" && return 0
  [[ -n "$(git -C "$root" ls-files -- '*.tsx' '*.jsx' '*.vue' '*.svelte' 2>/dev/null | head -n 1)" ]]
}

# Per file: tsx/jsx always count; otherwise the nearest package.json decides (backend packages in a monorepo do not).
is_frontend_file() {
  local root=$1 file=$2 dir
  [[ "$file" =~ \.(tsx|jsx)$ ]] && return 0
  dir=$(dirname "$file")
  while [[ ! -d "$dir" ]]; do dir=$(dirname "$dir"); done # deleted file/package: nearest existing parent
  dir=$(cd "$dir" && pwd -P) || return 0
  [[ "$dir" == "$root" || "$dir" == "$root/"* ]] || return 1 # outside the repo
  while :; do
    if [[ -f "$dir/package.json" ]]; then
      has_framework_dep "$dir"
      return
    fi
    [[ "$dir" == "$root" ]] && return 0
    dir=$(dirname "$dir")
  done
}

# Model-visible context (SessionStart / UserPromptSubmit / PostToolUse).
emit_context() {
  jq -n --arg event "$1" --arg context "$2" \
    '{hookSpecificOutput: {hookEventName: $event, additionalContext: $context}}'
}
