# Component Structure Detailed Rules

## 270-line Limit

### Measurement Criteria
- Target: JSX/TSX files (component files)
- Exclude blank lines
- Exclude comment lines (`//`, `/* */`, `* `)
- Include import statements

### ESLint Configuration

```js
'max-lines': ['error', {
  max: 270,
  skipBlankLines: true,
  skipComments: true,
}]
```

### Response When Exceeding 270 Lines
1. Split into child components
2. Extract logic into a custom hook
3. Move utility functions into a separate file

## Export Rules

- Component files: prefer a single default export
- Restrict mixing default export and named exports
- Utility/type files: use named exports

## useState Limit

- 5 or more `useState` calls in one component → warning
- Group related state into an object or extract into a custom hook

```tsx
// Bad: too many useState
const [name, setName] = useState('');
const [email, setEmail] = useState('');
const [phone, setPhone] = useState('');
const [address, setAddress] = useState('');
const [zipCode, setZipCode] = useState('');

// Good: extracted into a custom hook
const { formData, updateField } = useUserForm();
```

## Internal Function Length

- Over 100 lines → consider splitting
- Separate render logic from event handlers
- Extract complex conditional logic into a separate function
