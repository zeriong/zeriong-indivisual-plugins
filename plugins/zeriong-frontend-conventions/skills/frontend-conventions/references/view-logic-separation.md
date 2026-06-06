# View-Logic / Business-Logic Separation — Detailed Rules

## Principle

Component (page) files focus only on **View-Logic (rendering)**, while **Business-Logic** is extracted into custom hooks and wired in. The component acts purely as a **connector** that binds the values/handlers returned by the hook.

## Identifying the Project Architecture

Before working, check the project's directory structure and apply the matching pattern from the three options below.

### Pattern 1: Conventional React

Place business-logic hooks in a `hooks/` directory.

```
features/user/
├── components/
│   ├── UserProfile.tsx         ← View-Logic
│   └── UserSettings.tsx
├── hooks/
│   ├── useUserProfile.ts       ← Business-Logic
│   └── useUserSettings.ts
├── api/
│   └── userApi.ts
└── types/
    └── user.ts
```

```tsx
// components/UserProfile.tsx — View-Logic only
import { useUserProfile } from '../hooks/useUserProfile';

export default function UserProfile() {
  const { user, isLoading, handleUpdate } = useUserProfile();

  if (isLoading) return <Spinner />;

  return (
    <div>
      <h1>{user.name}</h1>
      <button onClick={handleUpdate}>Edit</button>
    </div>
  );
}
```

```ts
// hooks/useUserProfile.ts — Business-Logic
export function useUserProfile() {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchUser().then(setUser).finally(() => setIsLoading(false));
  }, []);

  const handleUpdate = useCallback(async () => {
    await updateUser(user);
    // ...
  }, [user]);

  return { user, isLoading, handleUpdate };
}
```

### Pattern 2: Encapsulation Pattern

Place hooks split by concern next to the component. If the project already uses this pattern, add business logic to the existing split hooks.

```
features/user/
├── UserProfile.tsx
├── useUserForm.ts              ← Form-related logic
├── useUserValidation.ts        ← Validation logic
├── useUserPermission.ts        ← Permission-related logic
└── UserProfile.test.tsx
```

```tsx
// UserProfile.tsx
import { useUserForm } from './useUserForm';
import { useUserValidation } from './useUserValidation';

export default function UserProfile() {
  const { formData, updateField, submit } = useUserForm();
  const { errors, validate } = useUserValidation(formData);

  return (
    <form onSubmit={() => { validate() && submit(); }}>
      <input value={formData.name} onChange={e => updateField('name', e.target.value)} />
      {errors.name ? <ErrorText message={errors.name} /> : null}
      <button type="submit">Save</button>
    </form>
  );
}
```

### Pattern 3: FSD (Feature-Sliced Design)-like Structure

Place hooks in the `model/` folder. If a `model/` folder already exists, add to it; if not, create one immediately.

```
features/user/
├── ui/
│   ├── UserProfile.tsx         ← View-Logic
│   └── UserAvatar.tsx
├── model/
│   ├── useUserProfile.ts       ← Business-Logic
│   ├── useUserForm.ts
│   └── types.ts
├── api/
│   └── userApi.ts
├── lib/
│   └── formatUserName.ts
└── index.ts
```

```tsx
// ui/UserProfile.tsx
import { useUserProfile } from '../model/useUserProfile';

export function UserProfile() {
  const { user, isLoading, error } = useUserProfile();

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorFallback error={error} />;

  return <UserCard user={user} />;
}
```

## Decision Criteria: Keep in the Component vs Extract to a Hook

### What can stay in the component (View-Logic)

- JSX rendering, conditional UI
- Event handler **binding** (`onClick={handler}`)
- Simple UI state (modal open/closed, tooltip visibility, accordion toggle)
- Passing props, composing children
- Ref binding (scroll, focus)

```tsx
// OK: simple UI state can stay in the component
const [isModalOpen, setIsModalOpen] = useState(false);
```

### What must be extracted to a hook (Business-Logic)

- API calls / data fetching
- Composite state management (form data, filters, pagination, sorting)
- Data transformation / derived-data computation
- Validation logic
- Side effects (timers, websockets, event-listener management)
- Event handler **implementation** (including transformation / conversion / API calls)

```tsx
// Bad: business logic written directly in the component
function UserList() {
  const [users, setUsers] = useState([]);
  const [filter, setFilter] = useState('');
  const [sortBy, setSortBy] = useState('name');
  const [page, setPage] = useState(1);

  useEffect(() => {
    fetchUsers({ filter, sortBy, page }).then(setUsers);
  }, [filter, sortBy, page]);

  const filteredUsers = useMemo(() =>
    users.filter(u => u.name.includes(filter)).sort(/* ... */),
    [users, filter, sortBy]
  );

  return <List items={filteredUsers} />;
}

// Good: extracted into a hook
function UserList() {
  const { users, filter, setFilter, sortBy, setSortBy, page, setPage } = useUserList();

  return <List items={users} />;
}
```

## Architecture Identification Procedure

1. From the project root, inspect the `src/` or `app/` directory structure
2. Identify the pattern using the following cues:
   - `model/`, `ui/`, `lib/` folders exist inside a feature → **FSD pattern**
   - `hooks/` folder sits next to feature/component → **Conventional React pattern**
   - `use*.ts` files sit at the same level as the component → **Encapsulation pattern**
3. If mixed, follow the existing pattern of the relevant feature/module
4. For a new feature, follow the pattern that is most common in the project

## Hook Naming Rules

- 1:1 correspondence with a component/page: `useComponentName` (e.g. `useUserProfile`)
- Split by concern: `useComponentName + concern` (e.g. `useUserForm`, `useUserValidation`)
- Shared logic: `use + featureName` (e.g. `usePagination`, `useDebounce`)
