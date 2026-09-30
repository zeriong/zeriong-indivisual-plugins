#!/usr/bin/env bash
# Inject the convention summary + workflow protocol at session start (frontend projects only).

source "$(dirname "$0")/lib.sh"
HOOK_INPUT=$(cat)

is_frontend_project "$(project_root)" || exit 0

emit_context SessionStart "$(cat << 'EOF'
## [Frontend Convention Plugin] Conventions + Workflow Protocol

### Workflow Protocol (mandatory)
For every Phase of every Task, follow this flow:
1. Phase start -> load the `frontend-conventions` skill (zeriong-frontend-conventions:frontend-conventions).
2. Do the work, applying the rules live.
3. Before Phase end -> run the `convention-review` skill (zeriong-frontend-conventions:convention-review).
   - On FAIL: fix and re-audit. Only end the phase on PASS.

### Core Conventions (19)
1. Naming: no subjective adjectives (Smart*, Cool*, Nice*, Awesome*). Use intuitive, universal names.
2. SRP: a module / function / component has exactly one responsibility.
3. 270-line cap: component files stay under 270 non-blank, non-comment lines.
4. Component decomposition: split aggressively along inferred units.
5. Layer separation: UI / Logic (custom hooks) / Data (API) / State (store) are kept distinct.
6. JSDoc: only @param, @returns, @deprecated are allowed; reject all other tags.
7. Comments: terse bullet style, essentials only, max 2 lines.
8. Defensive programming with DX balance: when behavior is equivalent, the more readable form wins.
9. Declarative JSX conditionals: simple branch -> ternary in return; guard / nested / divergent markup -> keep if. Use `? <X /> : null` (`&&` risks falsy renders).
10. Honor existing formatter/linter config (prettier / eslint / biome).
11. View-Logic vs Business-Logic split: components render only; business logic lives in custom hooks placed per project structure.
12. useEffect discipline: derive values during render; effects only synchronize with external systems.
13. Server components (Next.js App Router): may fetch data directly; keep 'use client' at the leaves.
14. Server state vs client state: query-cache data is never copied into global stores.
15. Memoization discipline: no speculative useMemo / useCallback / memo.
16. TypeScript: no `any` (use `unknown` + narrowing), `as const` objects over `enum`, discriminated unions for variant props.
17. Accessibility baseline: semantic elements, no clickable div, labels and alt text.
18. Module boundaries: path aliases, slices imported only through their public index, no circular imports.
19. Async UI states: loading / error / empty are handled explicitly.

For full rule text, load the frontend-conventions skill.
EOF
)"
