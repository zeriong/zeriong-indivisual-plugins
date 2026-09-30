# zeriong-frontend-conventions

Claude Code와 Codex에서 쓰는 프론트엔드 코드 컨벤션 강제 플러그인입니다.

영문: [README.md](./README.md) 참조.

## 제공 기능

### Skills

| 스킬 | 설명 | 호출 |
|------|------|------|
| `frontend-conventions` | 19가지 컨벤션 규칙과 워크플로우 프로토콜 로드 | Claude Code: `/zeriong-frontend-conventions:frontend-conventions` · Codex: `$zeriong-frontend-conventions:frontend-conventions` |
| `convention-review` | 변경 사항을 규칙에 비춰 검토하고 P1–P5로 보고 (P1–P2가 있으면 FAIL) | Claude Code: `/zeriong-frontend-conventions:convention-review` · Codex: `$zeriong-frontend-conventions:convention-review` |

React / TypeScript / Next.js 코드를 다룰 때는 두 스킬이 알아서 트리거되기도 합니다.

### Hooks

훅은 프론트엔드 프로젝트에서만 동작합니다. `package.json`에 react / next / vue / nuxt / svelte / solid-js / preact / @angular/core 의존성이 있거나, git에 `tsx` / `jsx` / `vue` / `svelte` 파일이 있는 경우입니다. 그 밖의 프로젝트에서는 아무것도 출력하지 않습니다.

| 훅 | 시점 | 역할 |
|----|------|------|
| `SessionStart` | 세션 시작 | 19개 규칙 요약과 워크플로우 프로토콜을 모델 컨텍스트에 주입 |
| `UserPromptSubmit` | 매 프롬프트 | 한 줄짜리 워크플로우 리마인더 |
| `PostToolUse` | 파일 편집 후 (Claude Code `Write` / `Edit` / `MultiEdit`, Codex `apply_patch`) | 편집한 `ts/tsx/js/jsx` 파일 정량 검사: 270줄 초과, 주관적 형용사 네이밍, `useState` 5회 이상, 숫자 값에 대한 JSX `&&`. 결과는 모델에 전달됩니다 |
| `Stop` | 턴 종료 | 프론트엔드 파일이 바뀌었으면 턴을 한 번 이어가며 `convention-review`를 요청. 같은 diff에서는 다시 발동하지 않습니다 |

필요 도구: `bash`, `git`, `jq` (`PATH`에 있어야 함).

## 워크플로우 프로토콜

```
Phase 시작 → frontend-conventions  (규칙 로드)
  → 작업 진행                      (규칙 적용)
  → convention-review              (검토)
  → PASS 시 phase 종료
```

매 task의 매 phase마다 이 흐름을 반복합니다.

## 19가지 규칙

1. **네이밍**: 주관적 형용사(`Smart*`, `Cool*` 등) 금지, 직관적인 이름 사용
2. **SRP**: 하나의 모듈은 하나의 책임
3. **270줄 제한**: 컴포넌트 파일은 빈 줄·주석 제외 270줄 이하
4. **컴포넌트 분리**: 단위를 추론해 적극적으로 분리
5. **레이어 분리**: UI / Logic / Data / State 구분
6. **JSDoc**: `@param`, `@returns`, `@deprecated`만 허용
7. **주석**: 개조식으로 핵심만, 2줄 이내
8. **방어적 프로그래밍**: 결과가 같으면 가독성 우선
9. **선언적 JSX 조건부 렌더링**: 단순 분기는 삼항, 가드는 `if`, `&&` 대신 `? <X /> : null`
10. **포매터/린터 준수**: 프로젝트의 prettier / eslint / biome 설정을 따름
11. **View-Logic / Business-Logic 분리**: 컴포넌트는 렌더링만, 비즈니스 로직은 커스텀 훅으로
12. **useEffect 규율**: 파생 값은 렌더 중에 계산, effect는 외부 시스템 동기화에만
13. **서버 컴포넌트**: App Router 서버 컴포넌트는 직접 fetch 허용, `'use client'`는 leaf에만
14. **서버/클라이언트 상태 분리**: 쿼리 캐시 데이터를 전역 store에 복사하지 않음
15. **메모이제이션 규율**: 근거 없는 `useMemo` / `useCallback` / `memo` 금지
16. **TypeScript**: `any` 금지, `enum` 대신 `as const`, variant props는 discriminated union
17. **접근성 기본**: 시맨틱 태그, 클릭 가능한 `div` 금지, label과 `alt` 필수
18. **모듈 경계**: path alias 사용, slice는 public `index.ts`로만 import, 순환 참조 금지
19. **비동기 UI 상태**: loading / error / empty를 명시적으로 처리

규칙 전문은 `skills/frontend-conventions/SKILL.md`와 `references/`에 있습니다. 자동화 가능한 규칙을 ESLint flat config로 강제하는 방법은 `references/eslint-setup.md`를 보세요.

## 훅과 스킬의 역할

훅은 **결정적·정량적** 검사(줄 수, 정규식 패턴)와 리마인더를 맡고 자동으로 실행됩니다. 스킬은 SRP, 레이어 분리, effect 사용, 주석 품질처럼 모델의 **판단**이 필요한 규칙을 맡습니다.

- `PostToolUse` 검사는 파일 편집 도구만 대상으로 합니다. 셸 명령으로 바뀐 파일은 `git diff`를 읽는 `convention-review`가 잡아냅니다.
- `Stop` 훅은 리마인더일 뿐, 리뷰가 실제로 실행됐거나 통과했다는 증명은 아닙니다.

## Codex 참고

- Codex는 플러그인 훅을 실행하기 전에 검토·신뢰 절차를 요구합니다. 설치 후 Codex에서 `/hooks`를 열어 훅 4개를 trust한 다음 새 스레드를 시작하세요.
- 스킬은 이 절차 없이도 동작합니다.
