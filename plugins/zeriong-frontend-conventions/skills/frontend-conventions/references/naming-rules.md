# Naming Convention Detailed Rules

## Forbidden Word List

The following adjectives are forbidden at the start of identifiers:

```
Smart, Cool, Nice, Awesome, Magic, Super, Ultra, Fancy
```

### ESLint Custom Rule Example

```js
// forbidden-adjectives.js
const FORBIDDEN = ['Smart', 'Cool', 'Nice', 'Awesome', 'Magic', 'Super', 'Ultra', 'Fancy'];
// Report when the start of a PascalCase identifier matches any entry in FORBIDDEN
```

### Using `@typescript-eslint/naming-convention`

```js
'@typescript-eslint/naming-convention': [
  'error',
  { selector: 'variable', format: ['camelCase', 'UPPER_CASE', 'PascalCase'] },
  { selector: 'function', format: ['camelCase', 'PascalCase'] },
  { selector: 'typeLike', format: ['PascalCase'] },
]
```

## Naming Rules by Category

| Target | Format | Example |
|------|------|------|
| Component | PascalCase | `UserProfile`, `ConfirmModal` |
| Function/Variable | camelCase | `getUserData`, `isLoading` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` |
| Type/Interface | PascalCase | `UserProfileProps`, `ApiResponse` |
| Custom Hook | use + camelCase | `useAuth`, `useUserProfile` |
| Event Handler | handle + Event | `handleClick`, `handleSubmit` |
| Boolean Variable | is/has/can/should prefix | `isVisible`, `hasPermission` |

## Good / Bad Examples

| Bad | Good | Reason |
|-----|------|------|
| `SmartLink` | `SafeLink` | Smart is subjective |
| `CoolButton` | `PrimaryButton` | Cool is subjective |
| `NiceModal` | `ConfirmModal` | Nice is subjective |
| `MagicFormatter` | `DateFormatter` | Magic is subjective |
| `data` | `userList` | Too abstract |
| `temp` | `pendingRequest` | Role unclear |
