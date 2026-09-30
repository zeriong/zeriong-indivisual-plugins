# Effects, State Ownership, and Memoization — Detailed Rules

Covers rule 12 (useEffect discipline), rule 14 (server state vs client state), and rule 15 (memoization discipline).

## Rule 12: useEffect Discipline

### Principle

An effect synchronizes a component with something outside React: a subscription, a timer, the DOM, a non-React widget. If there is no external system involved, there should be no effect.

### Anti-patterns and fixes

| Anti-pattern | Fix |
|------|------|
| Deriving a value into state from an effect | Compute it during render |
| Filtering/sorting a list into state from an effect | Compute during render (`useMemo` only if measured slow) |
| Watching a flag to run logic after a click | Run the logic in the event handler |
| Resetting state when a prop changes | Give the component a `key` tied to that prop |
| Fetching in an effect when the project uses a data library | Use the query hook (see rule 14) |
| Chains of effects that set each other's state | Compute the next state in one event handler |

```tsx
// Bad: effect reacts to a submit flag
const [submitted, setSubmitted] = useState(false);
useEffect(() => {
  if (submitted) postForm(form);
}, [submitted, form]);

// Good: the event handler does the work
const handleSubmit = () => postForm(form);
```

```tsx
// Bad: reset via effect
useEffect(() => setComment(''), [postId]);

// Good: reset via key
<CommentBox key={postId} />
```

### Legitimate effects

```tsx
useEffect(() => {
  const id = setInterval(tick, 1000);
  return () => clearInterval(id);
}, [tick]);
```

- Always return a cleanup for subscriptions, listeners, timers, and connections
- Keep effects inside custom hooks (rule 11), not in the component body

## Rule 14: Server State vs Client State

### Definitions

| Kind | Owner | Lives in |
|------|------|------|
| Server state | The backend | Query cache — TanStack Query, SWR, RTK Query, RSC fetch |
| Client state | The browser session | `useState` / `useReducer`, or a client store (zustand, jotai, redux) |

### Rules

- Read server data through its query hook wherever it is needed; the cache already deduplicates requests
- Do not copy query results into a global store or local state — the copy goes stale and needs manual invalidation
- Keep only client concerns in stores: UI flags, selections, form drafts, preferences
- Define query keys and fetchers in the Data layer (`api/`, `services/`, or FSD `api/`), then wrap them in hooks

```ts
// Bad: server data mirrored into a store
const { data } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
useEffect(() => {
  if (data) useUserStore.getState().setUsers(data);
}, [data]);

// Good: consumers read the query directly
export const useUsers = () => useQuery({ queryKey: userKeys.all, queryFn: fetchUsers });
```

- Editing server data: keep the draft in client state, submit it with a mutation, and let the query refetch or update from the mutation result

## Rule 15: Memoization Discipline

### Principle

Memoization has a cost (memory, dependency bookkeeping, readability). Add it when there is a reason, not by default.

### When memoization is justified

- A computation is measurably slow (profile it first)
- Referential identity is required: the value is a dependency of another hook, or a prop of a `React.memo` child that would otherwise re-render
- A context provider value would otherwise change on every render

```tsx
// Bad: speculative memoization of trivial work
const label = useMemo(() => `${count} items`, [count]);
const handleClick = useCallback(() => setOpen(true), []);  // passed to a plain <button>

// Good
const label = `${count} items`;
const handleClick = () => setOpen(true);
```

### React Compiler projects

- Do not add new manual `useMemo` / `useCallback` / `memo` by default — the compiler memoizes automatically
- Manual memoization is still valid for precise control (e.g. an effect dependency that must stay stable)
- Remove existing memoization only after verifying behavior and performance; do not bulk-delete it
