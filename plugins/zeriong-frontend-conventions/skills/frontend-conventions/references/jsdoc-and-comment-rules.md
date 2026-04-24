# JSDoc 및 주석 규칙 상세

## JSDoc 규칙

### 허용 태그 (화이트리스트)

| 태그 | 용도 | 필수 여부 |
|------|------|-----------|
| `@param` | 매개변수 설명 | 복잡한 타입일 때 |
| `@returns` | 반환값 설명 | 비자명할 때 |
| `@deprecated` | 폐기 예정 | 해당 시 필수 |

그 외 태그(`@author`, `@version`, `@see`, `@example`, `@typedef` 등)는 사용하지 않습니다.

### ESLint 설정

```js
'jsdoc/check-tag-names': ['error', {
  definedTags: ['param', 'returns', 'deprecated'],
}]
```

### JSDoc Good / Bad 예시

```ts
// Good: 간결하고 필요한 정보만
/** @deprecated useNewAuth 사용 권장 */
function useOldAuth() { ... }

/**
 * @param userId - 조회 대상 사용자 ID
 * @returns 사용자 프로필 데이터
 */
function getUserProfile(userId: string): UserProfile { ... }
```

```ts
// Bad: 과도한 태그
/**
 * @author John Doe
 * @version 1.0.0
 * @see https://docs.example.com
 * @example
 * const profile = getUserProfile('123');
 * @typedef {Object} UserProfile
 * @param {string} userId - 사용자 ID
 * @returns {UserProfile} 프로필
 */
function getUserProfile(userId: string): UserProfile { ... }
```

## 주석 규칙

### 핵심 원칙
- 간단 명료한 **개조식**으로 작성
- **핵심만 서술** (배경 설명, 히스토리 불필요)
- **2줄 이내** 엄수

### Good 예시

```ts
// 인증 토큰 만료 시 자동 갱신
// 갱신 실패 시 로그인 페이지로 리다이렉트
const refreshToken = async () => { ... }

// 검색 결과를 카테고리별로 그룹핑
const groupByCategory = (items: Item[]) => { ... }

// 디바운스 적용 (300ms)
const handleSearch = useMemo(() => debounce(search, 300), []);
```

### Bad 예시

```ts
// Bad: 장황한 설명
// 이 함수는 사용자의 인증 토큰이 만료되었는지 확인하고,
// 만료된 경우에는 리프레시 토큰을 사용하여 새로운 액세스 토큰을
// 발급받는 로직을 수행합니다. 만약 리프레시 토큰도 만료된 경우에는
// 사용자를 로그인 페이지로 리다이렉트합니다.

// Bad: 코드 그대로 반복
// count를 1 증가시킨다
setCount(count + 1);

// Bad: 변경 이력
// 2024-01-15: 김OO - 에러 핸들링 추가
// 2024-02-01: 박OO - 타임아웃 설정 변경
```

### 주석이 필요한 경우
- 비즈니스 로직의 "왜?"를 설명할 때
- 비직관적인 구현의 이유가 있을 때
- 임시 해결책(workaround)에 대한 설명

### 주석이 불필요한 경우
- 코드 자체가 충분히 명확할 때
- 함수/변수명으로 의도가 드러날 때
- 변경 이력 (git으로 관리)
