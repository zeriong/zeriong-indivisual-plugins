# 컴포넌트 구조 상세 규칙

## 270줄 제한

### 측정 기준
- 대상: JSX/TSX 파일 (컴포넌트 파일)
- 빈 줄 제외
- 주석 줄 제외 (`//`, `/* */`, `* `)
- import 문 포함

### ESLint 설정

```js
'max-lines': ['error', {
  max: 270,
  skipBlankLines: true,
  skipComments: true,
}]
```

### 270줄 초과 시 대응
1. 하위 컴포넌트로 분리
2. 로직을 커스텀 훅으로 추출
3. 유틸리티 함수를 별도 파일로 분리

## Export 규칙

- 컴포넌트 파일: default export 1개 권장
- default export + named export 혼재 제한
- 유틸/타입 파일: named export 사용

## useState 제한

- 한 컴포넌트에서 `useState` 5개 이상 → 경고
- 관련 상태를 객체로 묶거나 커스텀 훅으로 분리

```tsx
// Bad: useState 과다
const [name, setName] = useState('');
const [email, setEmail] = useState('');
const [phone, setPhone] = useState('');
const [address, setAddress] = useState('');
const [zipCode, setZipCode] = useState('');

// Good: 커스텀 훅으로 분리
const { formData, updateField } = useUserForm();
```

## 컴포넌트 내부 함수 길이

- 100줄 초과 → 분리 검토
- 렌더 로직과 이벤트 핸들러 분리
- 복잡한 조건 로직은 별도 함수로 추출
