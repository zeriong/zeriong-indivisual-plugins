---
name: frontend-conventions
description: "프론트엔드 코드 컨벤션 스킬. React, TypeScript, Next.js 등 프론트엔드 코드를 작성, 수정, 리팩토링할 때 반드시 참조. 네이밍, SRP, 270줄 제한, 컴포넌트 분리, 레이어 분리, JSDoc/주석, 방어적 프로그래밍 규칙을 포함. 모든 프론트엔드 작업의 phase 시작 시 실행되어야 함."
version: 1.0.0
---

# Frontend Code Conventions

이 스킬은 프론트엔드 코드 작성 시 반드시 준수해야 하는 컨벤션입니다.

---

## Workflow Protocol

이 스킬은 Task/Phase 생명주기에 따라 동작합니다:

1. **Phase 시작**: 이 스킬(`/frontend-conventions`)이 실행됩니다. 아래 컨벤션을 숙지하고 작업에 적용하세요.
2. **작업 진행**: 모든 코드 작성/수정 시 아래 컨벤션을 준수합니다.
3. **Phase 종료 전**: 반드시 `/convention-review` 스킬을 실행하여 작업 결과물을 검토합니다.
   - review에서 위반 사항(P1-P2)이 발견되면 즉시 수정 후 다시 review합니다.
   - review 통과(PASS) 후에만 해당 phase를 종료합니다.

이 프로토콜은 매 task의 매 phase마다 반복됩니다. 예외 없음.

---

## 1. 네이밍 컨벤션

가장 보편적이고 직관적인 형태를 사용합니다.

**금지**: 주관적 형용사를 접두어로 사용
- `Smart*`, `Cool*`, `Nice*`, `Awesome*`, `Magic*`, `Super*`, `Ultra*`, `Fancy*`

**권장**: 역할/기능을 직관적으로 표현
- `SafeLink`, `PrimaryButton`, `ConfirmModal`, `UserProfile`

**상세 규칙**: `references/naming-rules.md` 참조

---

## 2. 책임 분리 (SRP)

하나의 모듈/함수/컴포넌트는 하나의 책임만 가집니다.

- 한 파일에서 여러 관심사를 다루지 않음
- 컴포넌트 내부 로직이 복잡해지면 커스텀 훅으로 분리
- 데이터 fetching 로직은 별도 레이어로 분리

---

## 3. 파일 270줄 제한

컴포넌트 파일(view logic)은 **270줄 이하**로 유지합니다.

- 빈 줄과 주석은 카운트에서 제외
- JSX/TSX 파일이 주요 대상
- 초과 시 컴포넌트 분리를 검토

```js
'max-lines': ['error', {
  max: 270,
  skipBlankLines: true,
  skipComments: true,
}]
```

**상세 규칙**: `references/component-structure.md` 참조

---

## 4. 컴포넌트 분리

최대한 단위를 추론하여 분리합니다.

- 반복되는 UI 패턴은 독립 컴포넌트로 추출
- 한 컴포넌트가 여러 역할을 하면 분리
- `useState` 5개 이상 → 커스텀 훅 분리 검토
- 컴포넌트 내부 함수 100줄 초과 → 분리 검토

---

## 5. 레이어 분리

UI / Logic / Data / State 레이어를 명확히 구분합니다.

| 레이어 | 역할 | 위치 예시 |
|--------|------|-----------|
| **UI** | 렌더링, 스타일링 | `components/` |
| **Logic** | 비즈니스 로직, 이벤트 처리 | `hooks/`, custom hooks |
| **Data** | API 통신, 데이터 변환 | `api/`, `services/` |
| **State** | 전역/로컬 상태 관리 | `stores/`, zustand/jotai |

**상세 규칙**: `references/layer-separation.md` 참조

---

## 6. JSDoc 규칙

JSDoc을 지향하되 과도한 태그는 지양합니다.

**허용 태그 (화이트리스트)**:
- `@param` — 매개변수 설명
- `@returns` — 반환값 설명
- `@deprecated` — 폐기 예정 표시

그 외 태그는 차단합니다.

```js
'jsdoc/check-tag-names': ['error', {
  definedTags: ['param', 'returns', 'deprecated'],
}]
```

**상세 규칙**: `references/jsdoc-and-comment-rules.md` 참조

---

## 7. 주석 규칙

짧고 명료한 개조식으로 **핵심만 서술**, **2줄 이내**로 마무리합니다.

**Good**:
```ts
// 인증 토큰 만료 시 자동 갱신
// 갱신 실패 시 로그인 페이지로 리다이렉트
```

**Bad**:
```ts
// 이 함수는 사용자의 인증 토큰이 만료되었는지 확인하고,
// 만료된 경우에는 리프레시 토큰을 사용하여 새로운 액세스 토큰을
// 발급받는 로직을 수행합니다. 만약 리프레시 토큰도 만료된 경우에는
// 사용자를 로그인 페이지로 리다이렉트합니다.
```

**상세 규칙**: `references/jsdoc-and-comment-rules.md` 참조

---

## 8. 방어적 프로그래밍 + DX 균형

결과가 같다면 가독성 좋은 코드(간단명료)를 우선합니다.

- 불필요한 방어 코드로 가독성을 해치지 않음
- 내부 코드와 프레임워크 보장은 신뢰
- 시스템 경계(사용자 입력, 외부 API)에서만 검증

---

## Quick Reference Checklist

작업 완료 전 자체 점검:

- [ ] 컴포넌트/함수/변수 이름이 직관적인가? (주관적 형용사 없음)
- [ ] 파일이 270줄을 넘지 않는가?
- [ ] 하나의 컴포넌트가 하나의 책임만 가지는가?
- [ ] UI/Logic/Data/State 레이어가 분리되어 있는가?
- [ ] JSDoc 태그가 @param, @returns, @deprecated만 사용하는가?
- [ ] 주석이 개조식 2줄 이내인가?
- [ ] 불필요한 방어 코드로 가독성을 해치지 않았는가?
- [ ] `/convention-review`를 실행하여 검토를 완료했는가?
