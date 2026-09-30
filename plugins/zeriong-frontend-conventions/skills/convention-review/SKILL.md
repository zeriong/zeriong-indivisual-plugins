---
name: convention-review
description: "A review skill for verifying frontend code convention compliance. Runs immediately before the end of every phase. Iterates through the 19 convention rules on changed files and reports violations with P1-P5 priorities. Use for code review, convention checks, and quality inspections."
allowed-tools: Read, Grep, Glob, Bash(wc:*), Bash(grep:*), Bash(git diff:*), Bash(git status:*), Bash(cat:*), Bash(ls:*)
version: 2.0.0
---

# Convention Review

This skill runs immediately before the end of each phase to verify that the frontend code written or modified in that phase complies with conventions.

---

## Review Protocol

### Review Procedure

1. **Identify changed files**: Get the list of `.ts`, `.tsx`, `.js`, `.jsx` files changed in the current phase (`git status` / `git diff` — this also covers files edited through the shell)
2. **Check formatting/linting config**: Look for prettier/eslint/biome config files at the project root and understand their rules
3. **Check project architecture**: Inspect the directory structure to determine whether the project uses plain React, encapsulation, or FSD patterns, and whether it is a Next.js App Router project (`app/` + `next`)
4. **Iterate the 19 rules**: Walk through the checklist below for each file
5. **Classify violations**: Categorize and output them by P1-P5 priority
6. **Verdict**:
   - If any P1-P2 violations exist, **FAIL** → fix required
   - If only P3 or lower exist, **PASS** (recorded as recommendations)
   - If there are no violations, **PASS**

### Flow on FAIL
1. Output the list of violations
2. Fix immediately
3. Re-review (run this skill again)
4. End the phase only on PASS

---

## Review Checklist

### 1. Naming Conventions
- [ ] No subjective adjective prefixes (Smart*, Cool*, Nice*, Awesome*, Magic*, Super*, Ultra*, Fancy*)
- [ ] PascalCase (components), camelCase (functions/variables), UPPER_SNAKE_CASE (constants) are observed
- [ ] Names intuitively express role/function

### 2. SRP (Single Responsibility)
- [ ] One file handles only one concern
- [ ] A component does not take on multiple roles

### 3. 270-line Limit
- [ ] Component files are 270 lines or fewer (excluding blank lines/comments)

### 4. Component Decomposition
- [ ] Repeated UI patterns are extracted into standalone components
- [ ] Fewer than 5 useState calls (extract into a custom hook if exceeded)
- [ ] Internal functions are under 100 lines

### 5. Layer Separation
- [ ] UI / Logic / Data / State are clearly separated
- [ ] No direct API calls inside components
- [ ] Hooks do not return JSX

### 6. JSDoc
- [ ] Only @param, @returns, @deprecated tags are used
- [ ] No excessive JSDoc

### 7. Comments
- [ ] Comments are written telegraphically, conveying only the essentials
- [ ] Comments are kept within 2 lines
- [ ] No comments that merely restate the code

### 8. Defensive Programming
- [ ] No unnecessary defensive code
- [ ] Readability is prioritized

### 9. Declarative Conditional Rendering in JSX
- [ ] Simple branch selection (single boolean) is absorbed into the return statement via a ternary operator
- [ ] Guard clauses (`if (!data) return null`) are kept as if/early return
- [ ] Conditions with 3 or more nested levels are handled with if statements or variable extraction, not ternaries
- [ ] When branches produce completely different markup (different tag entirely), keep early return
- [ ] Use the `? <X /> : null` pattern (avoiding falsy 0 rendering). Do not substitute with `&&`
- [ ] No nested ternary operators

### 10. Formatting/Linting Tool Compliance
- [ ] Project config files (prettier/eslint/biome) are checked and code conforms to those rules
- [ ] Indentation, quotes, semicolons, trailing commas, etc. match the configuration
- [ ] If no config files exist, maintain consistency with the existing code style

### 11. View-Logic / Business-Logic Separation
- [ ] The component (page) file is responsible only for View-Logic (rendering)
- [ ] Business-Logic (state management, data transformation, side effects) is extracted into a custom hook
- [ ] Hooks are placed in locations appropriate to the project architecture (hooks/, model/, or an encapsulation pattern)
- [ ] API calls, complex state management, and derived data calculations are not written directly inside a component
- [ ] Simple UI state (e.g., modal open/closed) is allowed to remain inside the component
- [ ] Server components fetching data directly are not flagged (rule 13 exception)

### 12. useEffect Discipline
- [ ] No state that is only a copy or derivation of props/state synced by an effect
- [ ] User-triggered work runs in event handlers, not in effects watching flags
- [ ] Effects that subscribe or schedule return a cleanup

### 13. Server Components (App Router projects only)
- [ ] `'use client'` sits on interactive leaves, not on pages/layouts without need
- [ ] Client components import no server-only code (DB clients, secrets)
- [ ] Data access called from server components lives in a server-only function

### 14. Server State vs Client State
- [ ] Query results are not copied into a global store or local state
- [ ] Query keys / fetchers are defined in the Data layer

### 15. Memoization Discipline
- [ ] Each new `useMemo` / `useCallback` / `memo` has a measured cost or identity reason

### 16. TypeScript
- [ ] No `any` (use `unknown` + narrowing)
- [ ] `as const` objects instead of `enum`
- [ ] Variant props are discriminated unions, not optional-boolean sets

### 17. Accessibility
- [ ] No clickable `div`/`span`; actions are `button`, navigation is `a`/`Link`
- [ ] Form controls have labels; images have `alt`; icon-only buttons have an accessible name

### 18. Module Boundaries
- [ ] Path aliases are used where configured instead of deep relative paths
- [ ] Other slices are imported only through their public `index.ts`
- [ ] No circular imports

### 19. Async UI States
- [ ] UIs rendering async data handle loading, error, and empty states explicitly

---

## Priority Definitions

| Grade | Meaning | Verdict Impact | Examples |
|------|------|-----------|------|
| **P1** | Must fix | FAIL | Forbidden naming, exceeding 270 lines, formatting/linting config violations |
| **P2** | Strongly recommended | FAIL | SRP violation, mixed layers, Business-Logic written directly in View, risk of rendering falsy values via `&&`, nested ternaries, state derived through an effect, server data copied into a store, `any`, clickable `div` / missing label or `alt`, circular import or deep import past a slice's public API, server-only code imported into a client component |
| **P3** | Recommended | PASS | Decomposable components, missing JSDoc, unnecessarily converting guard clauses to ternaries, missing loading/error/empty state, `enum` instead of `as const`, optional-boolean variant props, `'use client'` placed higher than needed |
| **P4** | Optional | PASS | Comment improvements, readability enhancements, improved conditional rendering patterns, speculative memoization, deep relative path where an alias exists |
| **P5** | Reference | PASS | Minor stylistic issues |

---

## Output Format

Include only the grades that have violations.

```
## Convention Review Result: [PASS/FAIL]

### P1 (Must fix)
- [file:line] Violation description
  Fix: How to fix

### P2 (Strongly recommended)
- [file:line] Violation description
  Fix: How to fix

### P3 (Recommended)
- [file:line] Improvement suggestion

### P4 (Optional)
- [file:line] Improvement suggestion

### P5 (Reference)
- [file:line] Style suggestion
```

No violations:
```
## Convention Review Result: PASS

All convention rules are observed.
```
