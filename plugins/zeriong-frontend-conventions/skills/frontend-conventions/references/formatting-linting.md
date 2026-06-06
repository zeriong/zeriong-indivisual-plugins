# Formatting/Linting Tool Compliance Detailed Rules

## Principle

Project-configured formatting/linting rules **must** be followed. Project configuration takes precedence over personal style.

## Locating Config Files

Before writing or modifying code, check for the following config files at the project root:

### Prettier
- `.prettierrc`
- `.prettierrc.json` / `.prettierrc.yaml` / `.prettierrc.yml` / `.prettierrc.js` / `.prettierrc.cjs` / `.prettierrc.mjs`
- `prettier.config.js` / `prettier.config.cjs` / `prettier.config.mjs`
- The `"prettier"` field in `package.json`

### ESLint
- `.eslintrc` / `.eslintrc.js` / `.eslintrc.cjs` / `.eslintrc.json` / `.eslintrc.yml`
- `eslint.config.js` / `eslint.config.mjs` / `eslint.config.cjs` (flat config)

### Biome
- `biome.json`
- `biome.jsonc`

## Key Items to Check

| Item | Example Value | How to Check |
|------|---------|-----------|
| Indentation | `tabWidth: 2`, `useTabs: false` | Config file or existing code |
| Quotes | `singleQuote: true` | Config file |
| Semicolons | `semi: true` | Config file |
| Trailing comma | `trailingComma: 'all'` | Config file |
| Line width | `printWidth: 80` | Config file |
| Line break | `endOfLine: 'lf'` | Config file |
| JSX quotes | `jsxSingleQuote: false` | Config file |
| Bracket style | `arrowParens: 'always'` | Config file |

## Priority Among Tools

When formatting rules conflict:

1. **Biome** (integrated formatter + linter)
2. **Prettier** (formatting only)
3. **ESLint** (linting only; formatting rules are being deprecated)

## When No Config File Exists

If the project has no formatting/linting config files:
1. Analyze the existing code style and follow it
2. Prioritize consistency within the file
3. Match the style of surrounding files (same directory)

## Application Procedure

1. **Before starting work**: Check whether config files exist at the project root
2. **Read the config files**: Identify the key rules of each tool
3. **Write code**: Write according to the identified rules
4. **Verify**: Confirm that the written code matches the configuration

## Frequently Mistaken Patterns

```tsx
// Prettier: singleQuote: true, but
import { useState } from "react"  // Bad: double quotes
import { useState } from 'react'  // Good: single quotes

// Prettier: semi: false, but
const name = 'hello';  // Bad: semicolon present
const name = 'hello'   // Good: no semicolon

// Prettier: trailingComma: 'all', but
const obj = {
  a: 1,
  b: 2   // Bad: missing trailing comma
}
const obj = {
  a: 1,
  b: 2,  // Good: trailing comma
}
```
