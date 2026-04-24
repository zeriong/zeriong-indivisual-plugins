# 네이밍 컨벤션 상세 규칙

## 금지어 사전

식별자 시작 부분에 다음 형용사 사용을 금지합니다:

```
Smart, Cool, Nice, Awesome, Magic, Super, Ultra, Fancy
```

### ESLint 커스텀 룰 예시

```js
// forbidden-adjectives.js
const FORBIDDEN = ['Smart', 'Cool', 'Nice', 'Awesome', 'Magic', 'Super', 'Ultra', 'Fancy'];
// PascalCase 식별자의 시작 부분이 FORBIDDEN에 매치되면 report
```

### `@typescript-eslint/naming-convention` 활용

```js
'@typescript-eslint/naming-convention': [
  'error',
  { selector: 'variable', format: ['camelCase', 'UPPER_CASE', 'PascalCase'] },
  { selector: 'function', format: ['camelCase', 'PascalCase'] },
  { selector: 'typeLike', format: ['PascalCase'] },
]
```

## 카테고리별 네이밍 규칙

| 대상 | 형식 | 예시 |
|------|------|------|
| 컴포넌트 | PascalCase | `UserProfile`, `ConfirmModal` |
| 함수/변수 | camelCase | `getUserData`, `isLoading` |
| 상수 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` |
| 타입/인터페이스 | PascalCase | `UserProfileProps`, `ApiResponse` |
| 커스텀 훅 | use + camelCase | `useAuth`, `useUserProfile` |
| 이벤트 핸들러 | handle + Event | `handleClick`, `handleSubmit` |
| boolean 변수 | is/has/can/should 접두어 | `isVisible`, `hasPermission` |

## Good / Bad 예시

| Bad | Good | 이유 |
|-----|------|------|
| `SmartLink` | `SafeLink` | Smart는 주관적 |
| `CoolButton` | `PrimaryButton` | Cool은 주관적 |
| `NiceModal` | `ConfirmModal` | Nice는 주관적 |
| `MagicFormatter` | `DateFormatter` | Magic은 주관적 |
| `data` | `userList` | 너무 추상적 |
| `temp` | `pendingRequest` | 역할 불명확 |
