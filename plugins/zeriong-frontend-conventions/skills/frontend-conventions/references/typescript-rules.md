# TypeScript Rules — Detailed

Covers rule 16.

## No `any`

`any` turns off type checking for everything it touches. Use `unknown` and narrow it before use.

```ts
// Bad
function parse(json: string): any {
  return JSON.parse(json);
}

// Good
function parseUser(json: string): User {
  const value: unknown = JSON.parse(json);
  if (!isUser(value)) throw new Error('Invalid user payload');
  return value;
}

function isUser(value: unknown): value is User {
  return typeof value === 'object' && value !== null && 'id' in value;
}
```

- External data (API responses, `localStorage`, `postMessage`) enters as `unknown` and is validated at the boundary (a type guard or a schema library such as zod)
- `catch (error)` is `unknown`; narrow with `error instanceof Error`
- ESLint: `@typescript-eslint/no-explicit-any: 'error'`

## `as const` Objects Instead of `enum`

`enum` emits runtime code, has surprising numeric behavior, and does not interoperate with plain string literals. A frozen object plus a derived union gives the same ergonomics with plain JavaScript.

```ts
// Bad
enum Status {
  Idle = 'idle',
  Loading = 'loading',
}

// Good
const STATUS = {
  idle: 'idle',
  loading: 'loading',
} as const;

type Status = (typeof STATUS)[keyof typeof STATUS]; // 'idle' | 'loading'
```

- Constant object names follow `UPPER_SNAKE_CASE` (naming rules)
- A plain union (`type Size = 'sm' | 'md' | 'lg'`) is enough when no runtime object is needed

## Discriminated Unions for Variant Props

A set of optional booleans allows impossible combinations. A discriminated union makes each variant's required props explicit and lets the compiler narrow.

```tsx
// Bad: `href` and `onClick` can both be missing or both be set
type ButtonProps = {
  isLink?: boolean;
  href?: string;
  onClick?: () => void;
};

// Good
type ButtonProps =
  | { variant: 'link'; href: string }
  | { variant: 'action'; onClick: () => void };

function Button(props: ButtonProps) {
  return props.variant === 'link'
    ? <a href={props.href}>…</a>
    : <button type="button" onClick={props.onClick}>…</button>;
}
```

- The same pattern applies to async state (`{ status: 'success'; data: T } | { status: 'error'; error: Error }`) and reducer actions
