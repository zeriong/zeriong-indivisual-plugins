# 레이어 분리 상세 규칙

## 4개 레이어 정의

### UI Layer (렌더링)
- JSX/TSX 컴포넌트
- 스타일링 (CSS Modules, styled-components 등)
- 레이아웃, 조건부 렌더링
- props 수신 및 표시

### Logic Layer (비즈니스 로직)
- 커스텀 훅 (`useAuth`, `useForm`, `useFilter`)
- 이벤트 핸들러 로직
- 유효성 검증
- 데이터 변환/가공

### Data Layer (API 통신)
- API 호출 함수
- 요청/응답 타입 정의
- 에러 핸들링
- 캐싱 전략 (React Query, SWR)

### State Layer (상태 관리)
- 전역 상태 (Zustand, Jotai, Redux)
- 상태 셀렉터
- 상태 액션/뮤테이션

## 올바른 분리 예시

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

**참고**: View-Logic과 Business-Logic의 구체적인 분리 패턴(일반 React / 캡슐링 / FSD)은 `view-logic-separation.md`를 참조하세요.

## 안티패턴

| 안티패턴 | 문제 | 해결 |
|----------|------|------|
| 컴포넌트 내 직접 fetch | UI와 Data 혼재 | 커스텀 훅 또는 API 레이어로 분리 |
| 컴포넌트 내 복잡한 상태 로직 | UI와 State 혼재 | 상태 관리 레이어로 분리 |
| API 함수에서 UI 상태 조작 | Data와 State 혼재 | 각 레이어 독립 유지 |
| 훅에서 직접 JSX 반환 | Logic과 UI 혼재 | 훅은 데이터만, 렌더링은 컴포넌트에서 |
