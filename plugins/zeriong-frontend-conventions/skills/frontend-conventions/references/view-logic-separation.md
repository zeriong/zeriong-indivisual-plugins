# View-Logic / Business-Logic 분리 상세 규칙

## 원칙

컴포넌트(페이지) 파일은 **View-Logic(렌더링)**에만 집중하고, **Business-Logic**은 커스텀 훅으로 분리하여 연결합니다. 컴포넌트는 훅이 반환하는 값/핸들러를 바인딩하는 **연결자** 역할만 합니다.

## 프로젝트 아키텍처 판별

작업 전 프로젝트 디렉토리 구조를 확인하고, 아래 3가지 중 해당하는 패턴에 맞춰 적용합니다.

### 패턴 1: 일반 React 컨벤션

`hooks/` 디렉토리에 비즈니스 로직 훅을 배치합니다.

```
features/user/
├── components/
│   ├── UserProfile.tsx         ← View-Logic
│   └── UserSettings.tsx
├── hooks/
│   ├── useUserProfile.ts       ← Business-Logic
│   └── useUserSettings.ts
├── api/
│   └── userApi.ts
└── types/
    └── user.ts
```

```tsx
// components/UserProfile.tsx — View-Logic만
import { useUserProfile } from '../hooks/useUserProfile';

export default function UserProfile() {
  const { user, isLoading, handleUpdate } = useUserProfile();

  if (isLoading) return <Spinner />;

  return (
    <div>
      <h1>{user.name}</h1>
      <button onClick={handleUpdate}>수정</button>
    </div>
  );
}
```

```ts
// hooks/useUserProfile.ts — Business-Logic
export function useUserProfile() {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchUser().then(setUser).finally(() => setIsLoading(false));
  }, []);

  const handleUpdate = useCallback(async () => {
    await updateUser(user);
    // ...
  }, [user]);

  return { user, isLoading, handleUpdate };
}
```

### 패턴 2: 캡슐링 패턴

관심사별로 나누어진 훅 파일을 컴포넌트 인접에 배치합니다. 기존에 이 패턴으로 되어 있으면 나누어진 훅에 비즈니스 로직을 추가합니다.

```
features/user/
├── UserProfile.tsx
├── useUserForm.ts              ← 폼 관련 로직
├── useUserValidation.ts        ← 유효성 검증 로직
├── useUserPermission.ts        ← 권한 관련 로직
└── UserProfile.test.tsx
```

```tsx
// UserProfile.tsx
import { useUserForm } from './useUserForm';
import { useUserValidation } from './useUserValidation';

export default function UserProfile() {
  const { formData, updateField, submit } = useUserForm();
  const { errors, validate } = useUserValidation(formData);

  return (
    <form onSubmit={() => { validate() && submit(); }}>
      <input value={formData.name} onChange={e => updateField('name', e.target.value)} />
      {errors.name ? <ErrorText message={errors.name} /> : null}
      <button type="submit">저장</button>
    </form>
  );
}
```

### 패턴 3: FSD(Feature-Sliced Design) 유사 구조

`model/` 폴더에 훅을 배치합니다. 기존에 `model/` 폴더가 있으면 해당 폴더에 추가하고, 없으면 즉시 생성합니다.

```
features/user/
├── ui/
│   ├── UserProfile.tsx         ← View-Logic
│   └── UserAvatar.tsx
├── model/
│   ├── useUserProfile.ts       ← Business-Logic
│   ├── useUserForm.ts
│   └── types.ts
├── api/
│   └── userApi.ts
├── lib/
│   └── formatUserName.ts
└── index.ts
```

```tsx
// ui/UserProfile.tsx
import { useUserProfile } from '../model/useUserProfile';

export function UserProfile() {
  const { user, isLoading, error } = useUserProfile();

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorFallback error={error} />;

  return <UserCard user={user} />;
}
```

## 판단 기준: 컴포넌트에 남기는 것 vs 훅으로 분리하는 것

### 컴포넌트에 남겨도 되는 것 (View-Logic)

- JSX 렌더링, 조건부 UI
- 이벤트 핸들러 **바인딩** (`onClick={handler}`)
- 단순 UI 상태 (모달 열림/닫힘, 툴팁 표시, 아코디언 토글)
- props 전달, children 조합
- ref 바인딩 (스크롤, 포커스)

```tsx
// OK: 단순 UI 상태는 컴포넌트에 남김
const [isModalOpen, setIsModalOpen] = useState(false);
```

### 훅으로 분리해야 하는 것 (Business-Logic)

- API 호출 / 데이터 fetching
- 복합 상태 관리 (폼 데이터, 필터, 페이지네이션, 정렬)
- 데이터 가공 / 파생 데이터 계산
- 유효성 검증 로직
- 사이드이펙트 (타이머, 웹소켓, 이벤트 리스너 관리)
- 이벤트 핸들러 **구현** (가공/변환/API 호출 포함)

```tsx
// Bad: 컴포넌트에 비즈니스 로직 직접 작성
function UserList() {
  const [users, setUsers] = useState([]);
  const [filter, setFilter] = useState('');
  const [sortBy, setSortBy] = useState('name');
  const [page, setPage] = useState(1);

  useEffect(() => {
    fetchUsers({ filter, sortBy, page }).then(setUsers);
  }, [filter, sortBy, page]);

  const filteredUsers = useMemo(() =>
    users.filter(u => u.name.includes(filter)).sort(/* ... */),
    [users, filter, sortBy]
  );

  return <List items={filteredUsers} />;
}

// Good: 훅으로 분리
function UserList() {
  const { users, filter, setFilter, sortBy, setSortBy, page, setPage } = useUserList();

  return <List items={users} />;
}
```

## 아키텍처 판별 절차

1. 프로젝트 루트에서 `src/` 또는 `app/` 디렉토리 구조를 확인
2. 다음 단서로 패턴 판별:
   - `model/`, `ui/`, `lib/` 폴더가 feature 내부에 있음 → **FSD 패턴**
   - `hooks/` 폴더가 feature/component 옆에 있음 → **일반 React 패턴**
   - 컴포넌트와 같은 레벨에 `use*.ts` 파일이 있음 → **캡슐링 패턴**
3. 혼합된 경우 해당 feature/모듈의 기존 패턴을 따름
4. 신규 feature인 경우 프로젝트의 다수 패턴을 따름

## 훅 네이밍 규칙

- 컴포넌트/페이지와 1:1 대응: `useComponentName` (예: `useUserProfile`)
- 관심사별 분리: `useComponentName + 관심사` (예: `useUserForm`, `useUserValidation`)
- 공통 로직: `use + 기능명` (예: `usePagination`, `useDebounce`)
