# zeriong-frontend-conventions

Frontend code convention enforcement plugin.

For Korean: see [README.ko.md](./README.ko.md).

## What it provides

### Skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `frontend-conventions` | Loads the 8 core convention rules. | `/frontend-conventions` |
| `convention-review` | Reviews the current change against the conventions (P1–P5). | `/convention-review` |

### Hooks

| Hook | Fires at | Role |
|------|----------|------|
| `SessionStart` | Session boot | Injects the convention set + workflow protocol. |
| `UserPromptSubmit` | Every user prompt | Re-injects the workflow reminder so each turn starts from the same baseline. |
| `PostToolUse` | After `Write` / `Edit` / `MultiEdit` | Quantitative checks: 270-line cap, banned naming, useState overuse, JSX falsy-render risk, formatter presence. |
| `Stop` | Just before the turn ends | Reminds Claude to run `/convention-review` if frontend code was touched. |

## Workflow protocol

```
Phase start  →  /frontend-conventions       (load rules)
             →  do the work                 (apply rules live)
             →  /convention-review          (audit)
             →  PASS  →  phase end
```

Repeated for every phase of every task.

## The 8 core conventions

1. **Naming** — no subjective adjectives (`Smart*`, `Cool*`, …); intuitive names only.
2. **Single responsibility** — one module, one reason to change.
3. **270-line cap** — component files stay under 270 non-blank, non-comment lines.
4. **Component decomposition** — split aggressively along inferred units.
5. **Layer separation** — UI / Logic / Data / State are distinct.
6. **JSDoc** — only `@param`, `@returns`, `@deprecated` are permitted.
7. **Comment style** — terse bullet-style essentials, ≤ 2 lines.
8. **Defensive programming** — readability beats cleverness.

## Note on hook vs skill enforcement

Hooks enforce the **deterministic, quantitative** checks (line counts, regex patterns) — these run automatically and cannot be skipped.

The skills (`/frontend-conventions`, `/convention-review`) carry the **qualitative, judgment-based** rules (SRP, layer separation, comment quality) that require Claude's reasoning. The `Stop` hook nudges Claude to invoke `convention-review` but does not block — actual enforcement is on the model's compliance with the injected reminder.
