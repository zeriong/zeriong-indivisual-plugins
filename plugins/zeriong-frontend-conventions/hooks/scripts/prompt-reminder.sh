#!/usr/bin/env bash
# Re-inject a one-line workflow reminder on every user prompt (frontend projects only).

source "$(dirname "$0")/lib.sh"
HOOK_INPUT=$(cat)

is_frontend_project "$(project_root)" || exit 0

emit_context UserPromptSubmit "[Convention Workflow] Phase start: load frontend-conventions. Before ending a phase that changed frontend code: run convention-review and require PASS."
