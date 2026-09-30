# Server Components (Next.js App Router) — Detailed Rules

Covers rule 13. Applies only to projects that use the App Router (`app/` directory + `next` dependency). In Pages Router or client-only React projects, rules 5 and 11 apply unchanged.

## Principle

Components in `app/` are Server Components unless a file opts into the client with `'use client'`. Server components run only on the server, so fetching data inside them is the idiomatic pattern — not a layer violation.

## Exception to Rules 5 and 11

| Component kind | May fetch data directly? | Where business logic lives |
|------|------|------|
| Server component | Yes (async component calling a server-only function) | Server-only functions in `lib/`, `api/`, or FSD `api/` |
| Client component | No | Custom hooks (rule 11) |

Keep the data access itself out of the component body even on the server:

```tsx
// app/users/page.tsx — server component
import { getUsers } from '@/features/user/api/getUsers';

export default async function UsersPage() {
  const users = await getUsers();
  return <UserList users={users} />;
}
```

```ts
// features/user/api/getUsers.ts
import 'server-only';

export async function getUsers() {
  const res = await fetch(`${process.env.API_URL}/users`, { next: { revalidate: 60 } });
  if (!res.ok) throw new Error('Failed to load users');
  return (await res.json()) as User[];
}
```

## `'use client'` Placement

- Put `'use client'` on the smallest interactive leaf (a button, a form, a dropdown), not on a page or layout
- Everything a client file imports becomes client code, so a high boundary drags whole subtrees into the bundle
- Pass server-rendered content into client components as `children` instead of importing it

```tsx
// Bad: whole page becomes client code for one toggle
'use client';
export default function ProductPage() { /* ... */ }

// Good: only the interactive part is a client component
export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await getProduct(id);
  return (
    <article>
      <ProductDetails product={product} />
      <AddToCartButton productId={product.id} />  {/* 'use client' inside */}
    </article>
  );
}
```

## Boundary Safety

- Never import DB clients, secrets, or server-only utilities into a client component
- Mark server-only modules with `import 'server-only'` so a wrong import fails the build
- Props passed from server to client components must be serializable: primitives, plain objects and arrays, `Date`, `Map`/`Set`, promises, JSX, and Server Functions are fine; other functions and class instances are not
- Server Actions (`'use server'`) follow the same rule as other server code: keep their logic in server-only functions

## Checklist

- [ ] `'use client'` only on interactive leaves
- [ ] Data access in server-only functions, called from server components
- [ ] No server-only imports in client components
- [ ] Serializable props across the boundary
