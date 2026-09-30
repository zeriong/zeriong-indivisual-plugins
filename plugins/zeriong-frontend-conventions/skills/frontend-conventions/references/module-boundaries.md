# Module Boundaries — Detailed Rules

Covers rule 18.

## Path Aliases

When the project configures an alias (`tsconfig.json` `compilerOptions.paths`, plus the bundler equivalent), use it instead of climbing directories.

```ts
// Bad
import { Button } from '../../../../shared/ui/Button';

// Good
import { Button } from '@/shared/ui/Button';
```

- Relative imports are fine within the same module or slice (`./UserAvatar`, `../model/useUser`)
- Do not invent a new alias; use the ones already configured

## Public API per Slice

In FSD or feature-module structures, each slice exposes a public `index.ts`. Other slices import only from that entry point.

```
features/user/
├── ui/UserProfile.tsx
├── model/useUserProfile.ts
├── api/userApi.ts
└── index.ts        ← public API
```

```ts
// features/user/index.ts
export { UserProfile } from './ui/UserProfile';
export { useUserProfile } from './model/useUserProfile';
```

```ts
// Bad: deep import into another slice's internals
import { useUserProfile } from '@/features/user/model/useUserProfile';

// Good
import { useUserProfile } from '@/features/user';
```

- Inside a slice, import files directly (not through its own `index.ts`) to avoid self-cycles
- In FSD, imports go downward only: `app → pages → widgets → features → entities → shared`

## No Circular Imports

A cycle (A imports B, B imports A — directly or through a chain) causes `undefined` imports at load time and makes modules impossible to split.

Fixes, in order of preference:
1. Move the shared piece down into a lower module both can import (`shared/`, `entities/`)
2. Invert the dependency: pass the value in as a parameter or prop
3. Split the module so each side imports only what it needs

- ESLint: `import-x/no-cycle: 'error'` (or `import/no-cycle` with eslint-plugin-import)
