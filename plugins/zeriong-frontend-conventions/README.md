# zeriong-frontend-conventions

Frontend code convention enforcement plugin for Claude Code and Codex.

For Korean: see [README.ko.md](./README.ko.md).

## What it provides

### Skills

| Skill | Purpose | Invoke |
|-------|---------|--------|
| `frontend-conventions` | Loads the 19 convention rules and the workflow protocol. | Claude Code: `/zeriong-frontend-conventions:frontend-conventions` · Codex: `$zeriong-frontend-conventions:frontend-conventions` |
| `convention-review` | Reviews the current change against the rules and reports P1–P5 findings (P1–P2 = FAIL). | Claude Code: `/zeriong-frontend-conventions:convention-review` · Codex: `$zeriong-frontend-conventions:convention-review` |

Both skills also trigger on their own when you work on React / TypeScript / Next.js code.

### Hooks

The hooks run only in frontend projects: a `package.json` that depends on react / next / vue / nuxt / svelte / solid-js / preact / @angular/core, or a repo with tracked `tsx` / `jsx` / `vue` / `svelte` files. Everywhere else they stay silent.

| Hook | Fires at | Role |
|------|----------|------|
| `SessionStart` | Session start | Injects the 19-rule summary and the workflow protocol into the model's context. |
| `UserPromptSubmit` | Every prompt | Adds a one-line workflow reminder. |
| `PostToolUse` | After a file edit (Claude Code `Write` / `Edit` / `MultiEdit`, Codex `apply_patch`) | Quantitative checks on edited `ts/tsx/js/jsx` files: 270-line cap, subjective-adjective names, `useState` ≥ 5, JSX `&&` with a numeric value. Findings go back to the model. |
| `Stop` | Turn end | If frontend files changed, continues the turn once and asks for `convention-review`. The same diff never triggers it twice. |

Requirements: `bash`, `git`, and `jq` on `PATH`.

## Workflow protocol

```
Phase start  →  frontend-conventions   (load rules)
             →  do the work            (apply rules live)
             →  convention-review      (audit)
             →  PASS  →  phase end
```

Repeated for every phase of every task.

## The 19 rules

1. **Naming** — no subjective adjectives (`Smart*`, `Cool*`, …); intuitive names only.
2. **Single responsibility** — one module, one reason to change.
3. **270-line cap** — component files stay under 270 non-blank, non-comment lines.
4. **Component decomposition** — split aggressively along inferred units.
5. **Layer separation** — UI / Logic / Data / State are distinct.
6. **JSDoc** — only `@param`, `@returns`, `@deprecated` are permitted.
7. **Comment style** — terse bullet-style essentials, ≤ 2 lines.
8. **Defensive programming** — readability beats cleverness.
9. **Declarative JSX conditionals** — ternary for simple branches, `if` for guards; `? <X /> : null` over `&&`.
10. **Formatter / linter compliance** — follow the project's prettier / eslint / biome config.
11. **View-Logic / Business-Logic split** — components render; business logic lives in custom hooks.
12. **useEffect discipline** — derive during render; effects only sync with external systems.
13. **Server components** — App Router server components may fetch directly; `'use client'` stays at the leaves.
14. **Server vs client state** — query-cache data is never copied into global stores.
15. **Memoization discipline** — no speculative `useMemo` / `useCallback` / `memo`.
16. **TypeScript** — no `any`, `as const` over `enum`, discriminated unions for variant props.
17. **Accessibility baseline** — semantic elements, no clickable `div`, labels and `alt`.
18. **Module boundaries** — path aliases, slices imported through their public `index.ts`, no cycles.
19. **Async UI states** — loading / error / empty handled explicitly.

Full rule text lives in `skills/frontend-conventions/SKILL.md` and its `references/`. `references/eslint-setup.md` shows how to enforce the automatable rules with an ESLint flat config.

## Hooks vs skills

Hooks carry the **deterministic, quantitative** checks (line counts, regex patterns) and the reminders; they run automatically. The skills carry the **judgment-based** rules (SRP, layer separation, effect usage, comment quality) that need the model's reasoning.

- The `PostToolUse` check covers file-edit tools only. Files changed through shell commands are picked up by `convention-review`, which reads `git diff`.
- The `Stop` hook is a reminder, not proof that the review ran or passed.

## Codex notes

- Codex asks you to review and trust plugin hooks before they run: open `/hooks` in Codex after installing, trust the four hooks, then start a new thread.
- Skills work without that step.
