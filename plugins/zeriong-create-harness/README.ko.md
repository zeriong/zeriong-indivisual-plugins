# zeriong-create-harness

대상 프로젝트에서 호출하면 그 프로젝트를 위한 **harness engineering 구조를 from-scratch로 빌드**하는 메타 스킬.

setup-guide 기반 뼈대(`.claude/{settings.json, hooks/, scripts/, skills/}`)를 그대로 찍어내는 게 아니라, **그 프로젝트의 계층/관심사 분리를 fact-based로 조사한 결과를 토대로 project-rules와 gate를 맞춤 생성**합니다.

## 트리거

```
/create-harness
/create-harness <옵션>
```

## 8-Phase 워크플로우

| Phase | 책임 | Fact-check |
|---|---|---|
| 0 | Intake — 패키지/모노레포/배포 형태 수집 | — |
| 1 | **Layer/Concern Reconnaissance** — 모든 claim에 file:line 인용 강제 | ✅ 절대 |
| 2 | Convention Extraction — Phase 1 결과 → 룰 도출 | ✅ |
| 3 | docs/conventions/<rule>.md — worse/better case 인덱싱 | ✅ repo 인용 |
| 4 | Gate Script (`review-gate.sh`) 생성 | — |
| 5 | Hook (`UserPromptSubmit`) 배선 | — |
| 6 | Skill 본문 (`project-rules` + `harness-engineering`) 생성 | — |
| 7 | Self-Verification — sample diff로 게이트 통과 확인 | — |
| 8 | Review Gate — Opus + Sonnet 1회성 review → 메인이 종합 → 패치 | — |

**Fail at any phase → Phase 1 회귀** (절대 법령 — side-effect로 인한 plan 무효화 가정)

## 8번 규칙 (가장 중요)

Phase 1의 모든 claim은 **재검토 루프**를 통과해야 합니다.

```
주장 → 정말 그런가? → 소스코드 직접 확인 → 같은 스코프 전수 grep
  → side-effect 후보 조사 → 단일 책임 검증 → 주장 확정 → 다음 phase
```

이 루프 없이 주장한 claim은 즉시 폐기, Phase 1 재시작.

## 산출물

대상 프로젝트 루트에 다음 구조가 생성됩니다:

```
.claude/
├── settings.json                    # UserPromptSubmit hook 배선
├── hooks/inject-context.sh          # project-rules + harness-engineering 주입
├── scripts/review-gate.sh           # 결정론적 gate (exit 0/1/2)
└── skills/
    ├── project-rules/SKILL.md       # Phase 1~2 결과로 도출된 룰
    └── harness-engineering/SKILL.md # 11-phase 워크플로우

docs/conventions/
├── <rule-1>.md                      # worse / better case + 키워드 인덱스
├── <rule-2>.md
└── ...
```

## 의존

- `git`, `jq`, `bash 4+`
- 대상 프로젝트가 git work tree여야 함
