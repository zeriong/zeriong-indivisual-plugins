# Declarative JSX Conditional Rendering — Detailed Rules

## Principle

JSX aims for declarative UI. Absorb simple branches into the return statement using ternaries, but **keep guard clauses and complex conditions as `if` statements**. The key is using each form **in the right place** — not defaulting to ternaries everywhere.

## Convert to Ternary (Inside the return Statement)

Use a ternary and absorb it into the return statement in these cases:

### Single boolean branch for render selection

```tsx
// Good: simple branch selection → ternary
return variant === "a" ? <div>A</div> : <div>B</div>;

return (
  <div>
    {isLoggedIn ? <UserGreeting name={user.name} /> : <LoginButton />}
  </div>
);
```

### Branching inside map/filter callbacks

Since it is a pure selection, the ternary is more concise.

```tsx
// Good
{items.map(item => (
  item.isActive ? <ActiveCard key={item.id} /> : <InactiveCard key={item.id} />
))}
```

### Conditional prop spreading

```tsx
// Good
<a {...(external ? { target: "_blank", rel: "noopener" } : {})} href={url}>
  {children}
</a>
```

## Keep `if` (Early Return)

In the following cases you **must** keep `if` / early return:

### Guard clauses (validity / existence checks)

They convey intent explicitly. Do not convert to ternary.

```tsx
// Good: keep guard clauses
if (!hasData) return null;
if (isLoading) return <Spinner />;
return <List data={data} />;
```

```tsx
// Bad: forcing guards into a ternary
return !hasData ? null : isLoading ? <Spinner /> : <List data={data} />;
```

### 3 or more nested conditions

Nested ternaries severely hurt readability.

```tsx
// Bad: nested ternary
return status === 'success' ? <Check /> : status === 'warning' ? <Alert /> : <Error />;

// Good: extract to a variable
const statusIcon = (() => {
  switch (status) {
    case 'success': return <CheckIcon color="green" />;
    case 'warning': return <AlertIcon color="yellow" />;
    case 'error': return <ErrorIcon color="red" />;
    default: return null;
  }
})();

return <div>{statusIcon}</div>;
```

### Branches that require different data preprocessing

When each branch needs its own variables/computations, keep `if`.

```tsx
// Good: each branch has different preprocessing → keep if
if (isAdmin) {
  const adminStats = calculateAdminStats(data);
  return <AdminDashboard stats={adminStats} />;
}
const userSummary = summarizeForUser(data);
return <UserDashboard summary={userSummary} />;
```

### Branches that produce completely different markup

When the tags themselves differ, early return communicates intent better.

```tsx
// Good: tags are completely different → early return
if (isExternal) {
  return <a href={url} target="_blank" rel="noopener">{children}</a>;
}
return <Link to={url}>{children}</Link>;
```

## `? <X /> : null` Pattern (Falsy Guard)

`&&` can accidentally render falsy values (0, '', NaN). Use the `? <X /> : null` pattern instead.

```tsx
// Good: guards against falsy
{count ? <Badge count={count} /> : null}
{items.length ? <ItemList items={items} /> : null}

// Bad: 0 will be rendered
{count && <Badge count={count} />}
{items.length && <ItemList items={items} />}
```

**Cases where `&&` is allowed**: only when the condition is a definite boolean.

```tsx
// OK: definite boolean condition
{isVisible && <Modal />}
{hasPermission && <AdminPanel />}
```

## Auxiliary Rules

- Class name constants use `UPPER_SNAKE_CASE` (e.g. `ROW_CLS`, `HEADING_CLS`) — global-constant convention
- Extract repeated JSX fragments into a temporary variable like `content` and reuse it inside the ternary
- For 3+ branches, a map object can express the conditions declaratively

```tsx
// Good: using a map object
const STATUS_COMPONENTS = {
  success: CheckIcon,
  warning: AlertIcon,
  error: ErrorIcon,
} as const;

const StatusIcon = STATUS_COMPONENTS[status];
return <div>{StatusIcon ? <StatusIcon /> : null}</div>;
```

## Application Procedure

1. Scan the file for the `if (condition) return <JSX>` pattern
2. Apply the classification criteria to each `if`:
   - Guard / nested / different preprocessing / different tag → **keep**
   - Single-branch selection → **convert to ternary** and absorb into return
3. After conversion, verify types with `npx tsc --noEmit` (or the project build)
4. If static-analysis warnings appear (e.g. missing key), add an explicit `key` to the relevant element

## Decision Criteria Summary

| Situation | Pattern | Location |
|------|------|------|
| Simple 2-branch (A or B) | Ternary | Inside return |
| Show/hide (A or nothing) | `? <X /> : null` | Inside return |
| Definite boolean show/hide | `&&` allowed | Inside return |
| Guard clause (null / loading / error) | Early return | Before return |
| 3 or more branches | Variable extraction / map object | Before return |
| Different preprocessing per branch | `if` | Before return |
| Markup with different tags | Early return | Before return |
| Nested conditions | Split into a component | Separate component |
