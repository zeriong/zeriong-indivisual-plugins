# zeriong-frontend-conventions

프론트엔드 코드 컨벤션 강제 플러그인입니다.

## 제공 기능

### Skills

| 스킬 | 설명 | 호출 |
|------|------|------|
| `frontend-conventions` | 8가지 핵심 컨벤션 규칙 로드 | `/frontend-conventions` |
| `convention-review` | 컨벤션 준수 여부 검토 (P1-P5) | `/convention-review` |

### Hooks

| 훅 | 시점 | 역할 |
|----|------|------|
| SessionStart | 세션 시작 | 컨벤션 + 워크플로우 프로토콜 주입 |
| UserPromptSubmit | 매 프롬프트 | 워크플로우 리마인더 |
| PostToolUse | 파일 편집 후 | 270줄 초과, 금지 네이밍 등 정량적 검증 |
| Stop | 작업 종료 전 | convention-review 실행 여부 확인 |

## 워크플로우 프로토콜

```
Phase 시작 → /frontend-conventions 실행
  → 작업 진행 (컨벤션 준수)
  → /convention-review 실행
  → PASS 시 phase 종료
```

매 task의 매 phase마다 이 흐름을 반복합니다.

## 8가지 핵심 컨벤션

1. **네이밍**: 주관적 형용사 금지, 직관적 이름 사용
2. **SRP**: 하나의 모듈은 하나의 책임
3. **270줄 제한**: 컴포넌트 파일 270줄 이하
4. **컴포넌트 분리**: 최대한 단위 추론하여 분리
5. **레이어 분리**: UI / Logic / Data / State 구분
6. **JSDoc**: @param, @returns, @deprecated만 허용
7. **주석**: 개조식 핵심 서술, 2줄 이내
8. **방어적 프로그래밍**: 가독성 우선
