# Layer Separation Detailed Rules

## Four Layer Definitions

### UI Layer (Rendering)
- JSX/TSX components
- Styling (CSS Modules, styled-components, etc.)
- Layout, conditional rendering
- Receiving and displaying props

### Logic Layer (Business Logic)
- Custom hooks (`useAuth`, `useForm`, `useFilter`)
- Event handler logic
- Validation
- Data transformation/processing

### Data Layer (API Communication)
- API call functions
- Request/response type definitions
- Error handling
- Caching strategy (React Query, SWR)

### State Layer (State Management)
- Global state (Zustand, Jotai, Redux)
- State selectors
- State actions/mutations

## Example of Proper Separation

```
features/user/
├── components/          # UI Layer
│   ├── UserProfile.tsx
│   └── UserAvatar.tsx
├── hooks/               # Logic Layer
│   ├── useUserProfile.ts
│   └── useUserForm.ts
├── api/                 # Data Layer
│   └── userApi.ts
├── stores/              # State Layer
│   └── useUserStore.ts
└── types/
    └── user.ts
```

**Note**: For the concrete separation patterns between View-Logic and Business-Logic (plain React / encapsulation / FSD), see `view-logic-separation.md`.

## Anti-patterns

| Anti-pattern | Problem | Solution |
|----------|------|------|
| Direct fetch inside a component | UI and Data mixed | Extract into a custom hook or API layer |
| Complex state logic inside a component | UI and State mixed | Move to the state management layer |
| Manipulating UI state inside an API function | Data and State mixed | Keep each layer independent |
| Returning JSX directly from a hook | Logic and UI mixed | Hooks return data only; rendering happens in components |
