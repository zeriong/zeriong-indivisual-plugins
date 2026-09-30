# JSDoc and Comment Rules — Detailed

## JSDoc Rules

### Allowed Tags (Whitelist)

| Tag | Purpose | Required |
|------|------|-----------|
| `@param` | Parameter description | When the type is complex |
| `@returns` | Return value description | When non-obvious |
| `@deprecated` | Marks as deprecated | Required when applicable |

Other tags (`@author`, `@version`, `@see`, `@example`, `@typedef`, etc.) are not used.

### ESLint Configuration

`check-tag-names` cannot express a whitelist — its `definedTags` option only adds allowed tags. Enforce the whitelist with `no-restricted-syntax`, which reports any JSDoc block containing another tag:

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

### JSDoc Good / Bad Examples

```ts
// Good: concise, only the necessary info
/** @deprecated Prefer useNewAuth */
function useOldAuth() { ... }

/**
 * @param userId - ID of the user to look up
 * @returns User profile data
 */
function getUserProfile(userId: string): UserProfile { ... }
```

```ts
// Bad: excessive tags
/**
 * @author John Doe
 * @version 1.0.0
 * @see https://docs.example.com
 * @example
 * const profile = getUserProfile('123');
 * @typedef {Object} UserProfile
 * @param {string} userId - User ID
 * @returns {UserProfile} Profile
 */
function getUserProfile(userId: string): UserProfile { ... }
```

## Comment Rules

### Core Principles
- Write in a concise, **bullet-style** form
- **State only the essentials** (no background, no history)
- Keep within **2 lines maximum**

### Good Examples

```ts
// Auto-refresh when auth token expires
// Redirect to login page if refresh fails
const refreshToken = async () => { ... }

// Group search results by category
const groupByCategory = (items: Item[]) => { ... }

// Debounce applied (300ms)
const handleSearch = useMemo(() => debounce(search, 300), []);
```

### Bad Examples

```ts
// Bad: verbose explanation
// This function checks whether the user's authentication token has expired,
// and if so, uses the refresh token to obtain a new access token.
// If the refresh token has also expired, it redirects the user
// to the login page.

// Bad: restates the code
// Increment count by 1
setCount(count + 1);

// Bad: change history
// 2024-01-15: Kim - added error handling
// 2024-02-01: Park - changed timeout setting
```

### When Comments Are Needed
- Explaining the "why" behind business logic
- Reasoning behind a non-intuitive implementation
- Notes on a workaround / temporary fix

### When Comments Are Unnecessary
- When the code itself is sufficiently clear
- When the function/variable name already conveys intent
- Change history (managed via git)
