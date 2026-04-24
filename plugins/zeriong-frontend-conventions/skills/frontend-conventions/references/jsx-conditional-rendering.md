# JSX 선언적 조건부 렌더링 상세 규칙

## 원칙

JSX는 선언적 UI를 지향합니다. 단순 분기는 삼항으로 return문에 흡수하되, **가드 클로즈와 복잡한 조건은 if문으로 유지**합니다. 삼항 일변도가 아닌 **적재적소** 사용이 핵심입니다.

## 삼항연산자로 변환 (return문 내부)

다음 경우에 삼항연산자를 사용하여 return문에 흡수합니다:

### 단일 boolean 분기의 렌더 선택

```tsx
// Good: 단순 분기 선택 → 삼항
return variant === "a" ? <div>A</div> : <div>B</div>;

return (
  <div>
    {isLoggedIn ? <UserGreeting name={user.name} /> : <LoginButton />}
  </div>
);
```

### map/filter 콜백 내부의 분기

순수 선택이므로 삼항이 더 간결합니다.

```tsx
// Good
{items.map(item => (
  item.isActive ? <ActiveCard key={item.id} /> : <InactiveCard key={item.id} />
))}
```

### 조건부 prop 스프레드

```tsx
// Good
<a {...(external ? { target: "_blank", rel: "noopener" } : {})} href={url}>
  {children}
</a>
```

## if문(early return) 유지

다음 경우에는 if문/early return을 **반드시** 유지합니다:

### 가드 클로즈 (유효성/존재 체크)

의도를 명시적으로 전달합니다. 삼항으로 바꾸지 않습니다.

```tsx
// Good: 가드 클로즈 유지
if (!hasData) return null;
if (isLoading) return <Spinner />;
return <List data={data} />;
```

```tsx
// Bad: 가드를 삼항으로 강제 변환
return !hasData ? null : isLoading ? <Spinner /> : <List data={data} />;
```

### 3단 이상 중첩 조건

중첩 삼항은 가독성을 심각하게 저하시킵니다.

```tsx
// Bad: 중첩 삼항
return status === 'success' ? <Check /> : status === 'warning' ? <Alert /> : <Error />;

// Good: 변수 추출
const statusIcon = (() => {
  switch (status) {
    case 'success': return <CheckIcon color="green" />;
    case 'warning': return <AlertIcon color="yellow" />;
    case 'error': return <ErrorIcon color="red" />;
    default: return null;
  }
})();

return <div>{statusIcon}</div>;
```

### 분기마다 데이터 전처리가 다른 경우

각 분기에서 고유 변수/계산이 필요할 때 if문을 유지합니다.

```tsx
// Good: 분기별 전처리가 다름 → if 유지
if (isAdmin) {
  const adminStats = calculateAdminStats(data);
  return <AdminDashboard stats={adminStats} />;
}
const userSummary = summarizeForUser(data);
return <UserDashboard summary={userSummary} />;
```

### 분기 결과가 완전히 다른 마크업

태그 자체가 다르면 early return이 의도를 더 잘 드러냅니다.

```tsx
// Good: 태그가 완전히 다름 → early return
if (isExternal) {
  return <a href={url} target="_blank" rel="noopener">{children}</a>;
}
return <Link to={url}>{children}</Link>;
```

## `? <X /> : null` 패턴 (falsy 방지)

`&&`는 falsy 값(0, '', NaN)이 렌더링될 위험이 있습니다. `? <X /> : null` 패턴을 사용합니다.

```tsx
// Good: falsy 방지
{count ? <Badge count={count} /> : null}
{items.length ? <ItemList items={items} /> : null}

// Bad: 0이 렌더링됨
{count && <Badge count={count} />}
{items.length && <ItemList items={items} />}
```

**`&&` 허용 케이스**: 조건이 확실한 boolean일 때만

```tsx
// OK: 확실한 boolean 조건
{isVisible && <Modal />}
{hasPermission && <AdminPanel />}
```

## 부수 규칙

- 클래스 이름 상수는 `UPPER_SNAKE_CASE` (예: `ROW_CLS`, `HEADING_CLS`) — 전역 상수 관례
- 중복되는 JSX 조각은 `content` 같은 임시 변수로 추출 후 삼항 내부에서 재사용
- 맵 객체 활용으로 3분기 이상 조건을 선언적으로 처리 가능

```tsx
// Good: 맵 객체 활용
const STATUS_COMPONENTS = {
  success: CheckIcon,
  warning: AlertIcon,
  error: ErrorIcon,
} as const;

const StatusIcon = STATUS_COMPONENTS[status];
return <div>{StatusIcon ? <StatusIcon /> : null}</div>;
```

## 적용 절차

1. 파일에서 `if (조건) return <JSX>` 패턴을 스캔
2. 각 `if`에 대해 분류 기준 적용:
   - 가드/중첩/전처리 상이/태그 상이 → **유지**
   - 단일 분기 선택 → **삼항 변환**, return 안으로 흡수
3. 변환 후 `npx tsc --noEmit` (또는 프로젝트 빌드)로 타입 검증
4. 정적 분석 경고(key missing 등) 발생 시 해당 요소에 `key` 명시

## 판단 기준 요약

| 상황 | 패턴 | 위치 |
|------|------|------|
| 단순 2분기 (A or B) | 삼항연산자 | return문 내부 |
| 표시/숨김 (A or nothing) | `? <X /> : null` | return문 내부 |
| 확실한 boolean 표시/숨김 | `&&` 허용 | return문 내부 |
| 가드 클로즈 (null/로딩/에러) | early return | return문 이전 |
| 3분기 이상 | 변수 추출 / 맵 객체 | return문 이전 |
| 분기별 전처리 상이 | if문 | return문 이전 |
| 태그 자체가 다른 마크업 | early return | return문 이전 |
| 중첩 조건 | 컴포넌트 분리 | 별도 컴포넌트 |
