---
name: frontend-conventions
description: "Frontend code convention skill. Must be referenced when writing, modifying, or refactoring frontend code such as React, TypeScript, and Next.js. Includes rules for naming, SRP, the 270-line limit, component separation, layer separation, JSDoc/comments, defensive programming, JSX conditionals, formatter compliance, view/business-logic separation, effects, server components, server vs client state, memoization, TypeScript, accessibility, module boundaries, and async UI states. Must run at the start of every phase of any frontend task."
version: 2.0.0
---

# Frontend Code Conventions

This skill defines the conventions that must be followed when writing frontend code.

---

## Workflow Protocol

This skill operates according to the Task/Phase lifecycle:

1. **Phase start**: This skill is loaded. Internalize the conventions below and apply them to your work.
2. **Work in progress**: Adhere to the conventions below whenever writing or modifying code.
3. **Before phase end**: You must run the `convention-review` skill to review the work output.
   - If violations (P1-P2) are found during review, fix them immediately and re-run the review.
   - Only end the phase after the review PASSes.

This protocol repeats for every phase of every task. No exceptions.

---

## 1. Naming Conventions

Use the most common and intuitive form.

**Forbidden**: Using subjective adjectives as prefixes
- `Smart*`, `Cool*`, `Nice*`, `Awesome*`, `Magic*`, `Super*`, `Ultra*`, `Fancy*`

**Recommended**: Express the role/function intuitively
- `SafeLink`, `PrimaryButton`, `ConfirmModal`, `UserProfile`

**Detailed rules**: See `references/naming-rules.md`

---

## 2. Separation of Responsibility (SRP)

A single module/function/component should have only one responsibility.

- Do not handle multiple concerns in one file
- When the internal logic of a component becomes complex, extract it into a custom hook
- Separate data fetching logic into its own layer

---

## 3. 270-Line File Limit

Component files (view logic) must be kept **at or below 270 lines**.

- Blank lines and comments are excluded from the count
- Targets primarily JSX/TSX files
- When exceeded, consider splitting the component

```js
'max-lines': ['error', {
  max: 270,
  skipBlankLines: true,
  skipComments: true,
}]
```

**Detailed rules**: See `references/component-structure.md`

---

## 4. Component Separation

Infer the smallest meaningful units and separate them.

- Extract recurring UI patterns into independent components
- Split a component if it serves multiple roles
- 5 or more `useState` calls → consider extracting a custom hook
- Functions inside a component exceeding 100 lines → consider extraction

---

## 5. Layer Separation

Clearly distinguish the UI / Logic / Data / State layers.

| Layer | Role | Example location |
|--------|------|-----------|
| **UI** | Rendering, styling | `components/` |
| **Logic** | Business logic, event handling | `hooks/`, custom hooks |
| **Data** | API communication, data transformation | `api/`, `services/` |
| **State** | Global/local state management | `stores/`, zustand/jotai |

Exception: server components may fetch data directly (see §13).

**Detailed rules**: See `references/layer-separation.md`

---

## 6. JSDoc Rules

Favor JSDoc, but avoid excessive tags.

**Allowed tags (whitelist)**:
- `@param` — Parameter description
- `@returns` — Return value description
- `@deprecated` — Mark as scheduled for deprecation

All other tags are blocked. `check-tag-names` cannot express a whitelist (`definedTags` only adds tags), so enforce it with `no-restricted-syntax`:

```js
rules: {
  'jsdoc/no-restricted-syntax': ['error', {
    contexts: [{
      comment: 'JsdocBlock:has(JsdocTag:not([tag=/^(param|returns|deprecated)$/]))',
      context: 'any',
      message: 'Only @param, @returns, and @deprecated are allowed.',
    }],
  }],
}
```

**Detailed rules**: See `references/jsdoc-and-comment-rules.md`

---

## 7. Comment Rules

Use a short, clear, bullet-point style that **states only the essentials**, and finish **within 2 lines**.

**Good**:
```ts
// Auto-refresh on auth token expiry
// Redirect to the login page if refresh fails
```

**Bad**:
```ts
// This function checks whether the user's authentication token has expired,
// and if it has expired, it performs the logic of issuing a new access token
// using the refresh token. If the refresh token has also expired, it
// redirects the user to the login page.
```

**Detailed rules**: See `references/jsdoc-and-comment-rules.md`

---

## 8. Defensive Programming + DX Balance

If the result is the same, prioritize readable code (simple and clear).

- Do not harm readability with unnecessary defensive code
- Trust internal code and framework guarantees
- Validate only at system boundaries (user input, external APIs)

---

## 9. Declarative JSX Conditional Rendering

For conditional rendering, follow the **declarative UI** principle, but distinguish the roles of ternaries and `if` statements.

### Convert to ternary (inside return)

For a single boolean branch that **selects what to render**, absorb it into the return statement using a ternary.

```tsx
// Good: simple branch selection → ternary
return variant === "a" ? <div>A</div> : <div>B</div>;

return (
  <div>
    {isLoggedIn ? <UserGreeting /> : <LoginButton />}
  </div>
);
```

### Keep `if` statements (early return)

Keep `if`/early return as-is in these cases:

- **Guard clauses**: `if (!data) return null;` — validity/existence checks
- **3+ levels of nested conditions**: Nested ternaries hurt readability
- **Different data preprocessing per branch**: Each branch needs unique variables/calculations
- **Branches with entirely different markup**: When the tag itself differs, early return expresses intent better

```tsx
// Good: keep guard clauses
if (!hasData) return null;
if (isLoading) return <Spinner />;
return <List data={data} />;
```

### Keep the `? <X /> : null` pattern

Use the `? <X /> : null` pattern to prevent falsy 0 from being rendered. Do not replace it with `&&`.

```tsx
// Good: prevents falsy rendering
{count ? <Badge count={count} /> : null}

// Bad: 0 may be rendered
{count && <Badge count={count} />}
```

### Side rules

- Class name constants use `UPPER_SNAKE_CASE` (e.g., `ROW_CLS`, `HEADING_CLS`)
- Extract duplicated JSX fragments into a temporary variable and reuse it inside the ternary

**Detailed rules**: See `references/jsx-conditional-rendering.md`

---

## 10. Compliance with Formatting/Linting Tools

When writing or modifying code, you must comply with the rules of the formatting/linting tools configured for the project.

**Configuration files to check**:
- **Prettier**: `.prettierrc`, `.prettierrc.*`, `prettier.config.*`
- **ESLint**: `.eslintrc`, `.eslintrc.*`, `eslint.config.*` (flat config)
- **Biome**: `biome.json`, `biome.jsonc`

**Application rules**:
- Check the configuration files at the project root before writing code
- Match the configured indentation (tabs/spaces, size), quotes (single/double), semicolons, trailing commas, etc.
- Conflict priority: Biome > Prettier > ESLint (for formatting)
- If no configuration files exist, follow the existing code style

**Detailed rules**: See `references/formatting-linting.md`. To enforce these conventions with ESLint, see `references/eslint-setup.md`.

---

## 11. View-Logic / Business-Logic Separation

Component (page) files should be responsible only for **View-Logic (rendering)**, and **Business-Logic** must be extracted into custom hooks and wired in.

### Principles

- Component file: handles only JSX rendering, event binding, and conditional UI
- Business logic: state management, data processing, side effects → extract into custom hooks
- The component plays the role of **wiring** the values/handlers returned by the hook

### Application by project architecture

Before working, check the project's directory structure and apply the rules according to the architecture.

**Standard React convention**: Place business logic hooks in the `hooks/` directory

```
features/user/
├── components/
│   └── UserProfile.tsx       ← View-Logic
├── hooks/
│   └── useUserProfile.ts     ← Business-Logic
└── ...
```

**Encapsulation pattern**: Add business logic to hooks divided by concern

```
features/user/
├── UserProfile.tsx
├── useUserForm.ts            ← form-related logic
├── useUserValidation.ts      ← validation logic
└── useUserPermission.ts      ← permission-related logic
```

**FSD (Feature-Sliced Design) style structure**: Place hooks in the `model/` folder

```
features/user/
├── ui/
│   └── UserProfile.tsx       ← View-Logic
├── model/
│   ├── useUserProfile.ts     ← Business-Logic
│   └── useUserForm.ts
├── api/
│   └── userApi.ts
└── index.ts
```

### Decision criteria

| May stay in the component | Must be extracted into a hook |
|---|---|
| JSX rendering | API calls / data fetching |
| Event handler binding (`onClick={handler}`) | Event handler implementation (including processing/transformation) |
| Simple UI state (modal open/close) | Complex state management (forms, filters, pagination) |
| Passing props | Derived data computation |

Exception: server components may fetch data directly (see §13); client components still follow this rule.

**Detailed rules**: See `references/view-logic-separation.md`

---

## 12. useEffect Discipline

Effects synchronize a component with an external system. They are not a place to compute values or to react to user actions.

- Derive values from props/state during render; do not mirror them into state from an effect
- Run user-triggered work in the event handler, not in an effect watching a flag
- Reset state when an identity changes with a `key`, not with an effect
- Legitimate effects: subscriptions, timers, imperative DOM/browser APIs, syncing with non-React widgets — return a cleanup whenever the effect subscribes, schedules, or connects

```tsx
// Bad: derived state via effect (extra render, can drift)
const [fullName, setFullName] = useState('');
useEffect(() => setFullName(`${first} ${last}`), [first, last]);

// Good: derive during render
const fullName = `${first} ${last}`;
```

**Detailed rules**: See `references/effects-and-state.md`

---

## 13. Server Components (Next.js App Router)

In App Router projects (`app/` directory + `next` dependency), components are Server Components by default.

- A server component may fetch data directly (async component). This is an allowed exception to rules 5 and 11
- Keep the data access itself in a server-only function (`lib/`, `api/`, or the FSD `api/` segment) and call it from the component
- Put `'use client'` on the smallest interactive leaf, not on pages or layouts
- Client components still follow rule 11 (business logic in custom hooks)
- Never import server-only code (DB clients, secrets) into a client component; mark such modules with `import 'server-only'`

**Detailed rules**: See `references/server-components.md`

---

## 14. Server State vs Client State

- **Server state** (data owned by the backend) lives in the query cache: TanStack Query, SWR, RTK Query, or RSC fetches
- **Client state** (UI state, drafts, selections) lives in local state or a client store (zustand / jotai / redux)
- Do not copy query results into a global store or into local state; read them from the query hook
- Query keys and fetchers belong to the Data layer, not inline in components

**Detailed rules**: See `references/effects-and-state.md`

---

## 15. Memoization Discipline

- Do not add `useMemo` / `useCallback` / `React.memo` speculatively
- Add memoization for a measured cost, or when referential identity is required (a dependency of another hook, a prop of a memoized child)
- React Compiler projects: do not add new manual memoization by default; keep or remove existing memoization only after verifying behavior and performance

**Detailed rules**: See `references/effects-and-state.md`

---

## 16. TypeScript Rules

- No `any`. Use `unknown` and narrow it
- Prefer `as const` objects with derived union types over `enum`
- Express variant props as discriminated unions, not as a set of optional booleans

```ts
// Good
const STATUS = { idle: 'idle', loading: 'loading' } as const;
type Status = (typeof STATUS)[keyof typeof STATUS];

type ButtonProps =
  | { variant: 'link'; href: string }
  | { variant: 'action'; onClick: () => void };
```

**Detailed rules**: See `references/typescript-rules.md`

---

## 17. Accessibility Baseline

- Use semantic elements (`button`, `a`, `nav`, `main`, `ul`/`li`, headings in order)
- No clickable `div`/`span`: `button` for actions, `a`/`Link` for navigation
- Every form control has a label (`<label htmlFor>`, or `aria-label` when there is no visible label)
- Every `img` has `alt` (`alt=""` for decorative images); icon-only buttons have an accessible name

```tsx
// Bad
<div onClick={handleDelete}><TrashIcon /></div>

// Good
<button type="button" onClick={handleDelete} aria-label="Delete item"><TrashIcon /></button>
```

---

## 18. Module Boundaries

- Use the project's path aliases (e.g. `@/…`) instead of deep relative paths (`../../../`) when an alias is configured
- In FSD or feature-module structures, import another slice only through its public `index.ts`; never deep-import its internals
- No circular imports between modules, slices, or layers

**Detailed rules**: See `references/module-boundaries.md`

---

## 19. Async UI States

Every UI that renders async data handles all three non-content states explicitly:

- **loading** — skeleton / spinner, or a Suspense boundary
- **error** — message (with retry where possible), or an error boundary
- **empty** — an explicit empty state, not a blank area

Order the guard clauses loading → error → empty → content (see rule 9).

```tsx
if (isLoading) return <UserListSkeleton />;
if (error) return <ErrorState error={error} onRetry={refetch} />;
if (!users.length) return <EmptyState message="No users yet" />;
return <UserList users={users} />;
```

---

## Quick Reference Checklist

Self-check before completing work:

- [ ] Are component/function/variable names intuitive? (No subjective adjectives)
- [ ] Does the file stay under 270 lines?
- [ ] Does each component have only a single responsibility?
- [ ] Are the UI/Logic/Data/State layers separated?
- [ ] Are JSDoc tags limited to @param, @returns, and @deprecated?
- [ ] Are comments in bullet-point style and within 2 lines?
- [ ] Has readability been preserved without unnecessary defensive code?
- [ ] Is JSX conditional rendering appropriate? (simple branch → ternary; guard/nesting/different markup → keep `if`)
- [ ] Is the code formatted according to the project's prettier/eslint/biome settings?
- [ ] Does the component (page) handle only View-Logic, with Business-Logic extracted into a hook?
- [ ] Are values derived during render instead of synced into state by an effect?
- [ ] In App Router projects, is `'use client'` limited to interactive leaves, with server-only code kept out of client components?
- [ ] Is server data read from the query cache instead of being copied into a store?
- [ ] Is every `useMemo` / `useCallback` / `memo` justified by a measured cost or an identity requirement?
- [ ] No `any`, no `enum`, and variant props as discriminated unions?
- [ ] Semantic elements, no clickable `div`, labels and `alt` present?
- [ ] Imports use path aliases and slices' public APIs, with no circular imports?
- [ ] Are loading / error / empty states handled explicitly?
- [ ] Have you completed the review by running the `convention-review` skill?
