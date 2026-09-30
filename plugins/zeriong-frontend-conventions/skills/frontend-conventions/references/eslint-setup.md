# ESLint Automation Setup Guide

Examples use the flat config format with a plain exported array, which every flat-config ESLint release accepts. The file is named `eslint.config.mjs` so the ESM syntax works whether or not `package.json` sets `"type": "module"`. Check the project's installed ESLint and plugin versions before copying; plugin preset names change between majors, so the examples register plugins and rules explicitly.

## 3-Stage Automation Model

### Stage 1: Automatic Validation (ESLint Core/Plugins)

Rules that can be applied immediately:

```js
// eslint.config.mjs
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import jsdoc from 'eslint-plugin-jsdoc';
import reactHooks from 'eslint-plugin-react-hooks';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import importX from 'eslint-plugin-import-x';
import prettier from 'eslint-config-prettier';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['**/*.{ts,tsx,js,jsx}'],
    plugins: {
      jsdoc,
      'react-hooks': reactHooks,
      'jsx-a11y': jsxA11y,
      'import-x': importX,
    },
    rules: {
      // Rule 1: Naming
      '@typescript-eslint/naming-convention': ['error', /* see naming-rules.md */],

      // Rule 3: 270-line per-file limit
      'max-lines': ['error', { max: 270, skipBlankLines: true, skipComments: true }],

      // Rule 6: JSDoc tag whitelist (`check-tag-names` definedTags only adds tags)
      'jsdoc/check-tag-names': 'error',
      'jsdoc/no-restricted-syntax': ['error', {
        contexts: [{
          comment: 'JsdocBlock:has(JsdocTag:not([tag=/^(param|returns|deprecated)$/]))',
          context: 'any',
          message: 'Only @param, @returns, and @deprecated are allowed.',
        }],
      }],

      // Rule 12: hooks correctness
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',

      // Rule 16: no any
      '@typescript-eslint/no-explicit-any': 'error',

      // Rule 17: accessibility baseline
      'jsx-a11y/alt-text': 'error',
      'jsx-a11y/label-has-associated-control': 'error',
      'jsx-a11y/click-events-have-key-events': 'error',
      'jsx-a11y/no-static-element-interactions': 'error',

      // Rule 18: no circular imports
      'import-x/no-cycle': 'error',
    },
  },
  prettier, // Must come last: turns off rules that conflict with Prettier
];
```

### Stage 2: Partial Automation (Custom Rules)

Convert recurring team review comments into rules:

- Limit number of exports per file
- Limit length of inner functions inside components
- Detect excessive `useState` usage (warn at 5 or more)
- Restrict mixing of default export and named export
- Forbid subjective-adjective prefixes (see `naming-rules.md`)

### Stage 3: Enforcement

```json
// package.json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  }
}
```

Flat config selects files through `files` patterns, so the legacy `--ext` flag is not used.

- Husky + lint-staged: pre-commit validation
- Block merges on lint failure in CI

## Recommended Repo Structure (ESLint Plugin Monorepo)

```
your-org-lint-config/
├── packages/
│   ├── eslint-plugin-yourorg/          # Custom rules
│   │   ├── lib/
│   │   │   ├── rules/
│   │   │   │   ├── naming-convention.js
│   │   │   │   ├── component-max-lines.js
│   │   │   │   ├── jsdoc-minimal.js
│   │   │   │   └── single-responsibility.js
│   │   │   └── index.js
│   │   └── package.json
│   ├── eslint-config-yourorg/          # Flat config preset (exports an array)
│   │   ├── index.js
│   │   ├── react.js
│   │   └── package.json
│   └── prettier-config-yourorg/        # Formatting
│       └── package.json
├── docs/
│   ├── conventions.md
│   └── examples/
└── package.json                        # pnpm workspace root
```

A shared preset is consumed by spreading it into the project's `eslint.config.mjs`:

```js
import yourorg from 'eslint-config-yourorg';

export default [...yourorg, /* project overrides */];
```

## Distribution (Private)

**Recommended order**: Git URL → GitHub Packages once stabilized

```json
{
  "devDependencies": {
    "eslint-plugin-yourorg": "git+ssh://git@github.com/org/repo.git#v1.0.0"
  }
}
```

## Caveats

- For custom rules, **minimizing false positives** is the top priority
- Avoid bulk-rewriting existing code; apply incrementally starting with new code
- Manage false-positive rate to prevent overuse of `eslint-disable`
