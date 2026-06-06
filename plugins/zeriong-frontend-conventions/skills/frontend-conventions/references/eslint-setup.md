# ESLint Automation Setup Guide

## 3-Stage Automation Model

### Stage 1: Automatic Validation (ESLint Core/Plugins)

Rules that can be applied immediately:

```js
// .eslintrc.js
module.exports = {
  rules: {
    // Rule 1: Naming
    '@typescript-eslint/naming-convention': ['error', /* ... */],

    // Rule 3: 270-line per-file limit
    'max-lines': ['error', {
      max: 270,
      skipBlankLines: true,
      skipComments: true,
    }],

    // Rule 6: JSDoc tag restriction
    'jsdoc/check-tag-names': ['error', {
      definedTags: ['param', 'returns', 'deprecated'],
    }],
  },
};
```

### Stage 2: Partial Automation (Custom Rules)

Convert recurring team review comments into rules:

- Limit number of exports per file
- Limit length of inner functions inside components
- Detect excessive `useState` usage (warn at 5 or more)
- Restrict mixing of default export and named export

### Stage 3: Enforcement

```json
// package.json
{
  "scripts": {
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix"
  }
}
```

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
│   ├── eslint-config-yourorg/          # Preset
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

## Distribution (Private)

**Recommended order**: Git URL → GitHub Packages once stabilized

```json
{
  "devDependencies": {
    "eslint-plugin-yourorg": "git+ssh://git@github.com/org/repo.git#v1.0.0"
  }
}
```

## Resolving Prettier Conflicts

```js
// Prevent ESLint and Prettier conflicts
module.exports = {
  extends: [
    'eslint-config-yourorg',
    'prettier', // Must come last
  ],
};
```

## Caveats

- For custom rules, **minimizing false positives** is the top priority
- Avoid bulk-rewriting existing code; apply incrementally starting with new code
- Manage false-positive rate to prevent overuse of `eslint-disable`
