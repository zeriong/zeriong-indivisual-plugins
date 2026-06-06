---
name: create-harness
description: 대상 프로젝트의 계층/관심사 분리를 fact-based로 직접 조사한 뒤, 그 결과를 토대로 project-rules · review-gate.sh · UserPromptSubmit hook · harness-engineering 스킬을 from-scratch로 빌드한다. 이미 작성된 harness 템플릿을 복사-붙여넣기 하지 않는다. 트리거 키워드 (한/영) — "harness 만들어", "create harness", "harness 셋업", "프로젝트 룰 추출", "review gate 깔아줘", "create-harness". 8-Phase 워크플로우로 진행하며 어느 phase든 fail 시 Phase 1으로 회귀(절대 법령). Phase 1의 모든 claim에는 file:line 인용이 강제된다(fact-check 루프 미통과 claim은 즉시 폐기).
---

# create-harness

대상 프로젝트에서 호출되면 그 프로젝트를 위한 **harness engineering 구조를 from-scratch로 빌드**한다. setup-guide의 뼈대만 찍어내는 것이 아니라, **그 프로젝트의 계층/관심사를 직접 조사해 룰을 도출**하고, 그 룰을 gate로 강제하는 구조까지 한 호흡에 완성한다.

이 스킬의 출력은 다음 7개:

1. `.claude/settings.json` — `UserPromptSubmit` hook 배선
2. `.claude/hooks/inject-context.sh` — context 주입 스크립트
3. `.claude/scripts/review-gate.sh` — 결정론적 게이트 (exit 0/1/2)
4. `.claude/skills/project-rules/SKILL.md` — Phase 1~2로 도출된 프로젝트 고유 룰
5. `.claude/skills/project-rules/references/<rule>.md` — 각 룰의 세부
6. `.claude/skills/harness-engineering/SKILL.md` — 11-phase 워크플로우 (이 스킬과 별개)
7. `docs/conventions/<rule>.md` — worse/better case + 키워드 인덱스 (요구사항 #7)

---

## 절대 법령 (8개 규칙 — 시작 전 모두 내재화)

1. **계층/관심사 분리 이해 우선** — 룰은 분석 결과로부터 나온다. 분석 없이 룰을 도입하면 폐기.
2. **모든 룰은 gate화** — `.sh` 스크립트로 `exit 1` 강제할 수 없는 룰은 advisory로 강등(`project-rules` 본문에는 두되 gate에는 넣지 않음).
3. **Phase fail → 메인 + Opus 에이전트 + Sonnet 에이전트 브레인스토밍** — 각 에이전트는 1회성 fresh spawn으로 패치 제안만, 메인이 셋을 종합해 최종 패치 작성.
4. **"퀄리티 높음"의 정의** — 책임분리 / 간단명료 주석 / KISS / DRY / YAGNI / 인간 인지 용이성. 모든 패치는 이 6개로 self-grade한 뒤 적용.
5. **패치 적용 → Phase 1 회귀** — side-effect 가능성을 가정한 절대 법령. 단 한 줄이 바뀌었어도 처음부터 재검증.
6. **모든 Phase 완료 = task 완료** — Phase 7까지 통과한 순간이 done. 그 전 어떤 시점도 done이 아님.
7. **docs 인덱싱 필수** — 사용자가 권고로만 말한 항목도 `docs/conventions/<rule>.md`에 worse/better case로 인덱싱. 키워드 추출 후 grep 가능하도록 정리.
8. **모든 claim은 fact-check 루프 통과** (가장 중요) — 다음 protocol 미통과 claim은 폐기:

   ```
   [Claim] "이 소스코드는 책임분리 원칙을 따른다"
     ↓
   [Self-doubt] 정말로 따랐는가?
     ↓
   [Direct read] 해당 파일을 Read로 직접 확인 (memory/추론 금지)
     ↓
   [Scope sweep] 같은 스코프(같은 디렉토리/같은 layer)의 모든 소스 grep
     ↓
   [Side-effect probe] import/usage 그래프로 영향 범위 조사
     ↓
   [SRP test] 함수/모듈이 하나의 변화 이유만 가지는지 검증
     ↓
   [Verdict] "이 소스코드는 책임분리 원칙을 따른다 — 근거: <file:line>, <file:line>"
     ↓
   다음 Phase 진행
   ```

   파일 경로/라인 인용 없는 claim은 **immediate discard, Phase 1 재시작**.

---

## Phase 0 — Intake

`AskUserQuestion` **1회 호출**로 다음 4개를 한 번에 수집한다:

1. **Package manager** — pnpm / npm / yarn / bun / 기타
2. **Monorepo 여부** — turborepo / nx / pnpm workspace / 단일 / 기타
3. **이미 깔린 lint/typecheck 명령** — `package.json` scripts를 먼저 읽고 enumerate한 뒤 사용자 확인
4. **사용자 권고 룰** (free-text) — "이건 꼭 지켜야 한다고 생각하는 것들" — 요구사항 #7의 docs 인덱싱 대상

답변 후 TodoWrite에 `create-harness intake locked`로 고정. 이후 Phase에서 재질문 금지.

---

## Phase 1 — Layer/Concern Reconnaissance (절대 법령 8번 적용)

**이 Phase가 가장 중요하다. 여기서 도출된 fact가 전체 harness의 기반이 된다.**

### Step 1.1 — Directory layer map

`tree -L 3` 또는 `find` (find는 `.` 부터, `/` 금지)로 디렉토리 구조 enumerate. 각 디렉토리에 대해 다음을 **반드시 직접 read한 뒤** 분류:

| Layer 후보 | 식별 신호 (예시 — 프로젝트마다 다름) |
|---|---|
| presentation | `*.tsx` + JSX + hook 호출 |
| business | `use-*.ts` + state machine / 순수 함수 |
| data | `api/*`, `repository/*`, fetch 호출 |
| domain | type/schema/zod 정의 |
| infra | config / build / CI |

**각 분류 결정에는 file:line 인용을 같이 적는다.** 예:

```
- src/components/admin/audit-logs/page.tsx:14 → presentation (JSX root + useState)
- src/hooks/use-audit-logs.ts:1 → business (순수 hook, JSX 없음, fetch 위임)
- src/api/audit-logs.ts:8 → data (fetch + zod parse)
```

### Step 1.2 — Concern separation audit

각 layer 안에서 fact-check 루프를 돌린다. 예시:

```
[Claim] components/admin/audit-logs/page.tsx는 presentation만 가진다
  ↓
[Direct read] Read tool로 page.tsx 전체 확인
  ↓
[Scope sweep] grep "useState|useEffect|fetch" src/components/admin/audit-logs/
  ↓
[Side-effect probe] grep -r "audit-logs" src/  # 어디서 import 하는가
  ↓
[SRP test] page.tsx가 데이터 fetch도 하는가? 변환 로직도 가지는가?
  ↓
[Verdict 1] page.tsx:24-31에서 직접 fetch 수행 → presentation + data 혼재 (위반)
[Verdict 2] use-audit-logs.ts:14에서 sort 로직 보유 → business 정합
```

**Verdict는 항상 file:line 인용과 함께 작성한다.**

### Step 1.3 — Fact-check loop pass/fail

루프 통과 claim만 `phase1-findings.md`(임시 파일)에 누적. fail한 claim은 폐기하고 재조사. 모든 layer에 대해 동일 protocol.

### Step 1.4 — 출력

```markdown
## Phase 1 — Layer/Concern Reconnaissance (verdicts)

### Identified layers
- presentation: src/components/**, src/app/**
- business: src/hooks/use-*.ts
- data: src/api/**, src/lib/db.ts:1-40
- domain: src/types/**, src/schemas/**

### Violations found (fact-cited)
- src/components/admin/audit-logs/page.tsx:24-31 — presentation + data 혼재
- src/lib/utils.ts:88-120 — business + data 혼재 (fetch 직접 호출)

### Concerns confirmed clean (fact-cited)
- src/hooks/use-audit-logs.ts — business 단일 (sort 로직만, JSX/fetch 없음)
```

---

## Phase 2 — Convention Extraction

Phase 1의 verdict를 토대로 **그 프로젝트에 필요한 룰**을 도출한다. **이미 잘 지켜지는 항목**과 **위반이 발견된 항목**을 구분:

| 룰 종류 | 도출 트리거 | gate화 가능? |
|---|---|---|
| layer separation | Phase 1에서 layer 혼재 발견 | grep으로 가능 (presentation에 fetch 금지 등) |
| naming convention | repo의 다수 파일이 kebab-case면 룰화 | 정규식 grep |
| file length cap | 평균 line 수 기반 cap 설정 | wc -l |
| comment style | 기존 주석 패턴 sampling | 휴리스틱 grep |
| test colocation | `__tests__/` vs `*.test.ts` 패턴 | find |

도출 기준:
- **Phase 0의 사용자 권고 룰은 무조건 포함** (gate화 못 해도 advisory로)
- **Phase 1 verdict로 위반이 0건이고 사용자도 언급 안 한 룰은 도입 금지** (YAGNI)
- **gate화 가능한 룰은 gate에 넣고, advisory만 가능한 룰은 project-rules 본문에만 둔다**

출력은 `rules.json`(임시) — 각 룰에 `{id, title, gate: bool, severity: P0|P1|P2|P3|P4, source: "user-recommended" | "phase1-violation" | "phase1-pattern"}`.

---

## Phase 3 — docs/conventions/ worse/better case 인덱싱 (요구사항 #7)

각 룰에 대해 `docs/conventions/<rule-id>.md` 생성. **반드시 repo의 실제 코드를 인용**(가상 예제 금지).

템플릿:

```markdown
# <rule title>

## Index keywords
<grep으로 찾을 수 있는 키워드 5~10개 — 룰 위반/준수 코드에서 등장하는 식별자/패턴>

## Worse case (실제 repo 인용)
`src/components/admin/audit-logs/page.tsx:24-31` — presentation에서 직접 fetch
```tsx
<인용 코드 그대로>
```
문제: <왜 문제인지 1~2줄>

## Better case (실제 repo 인용 또는 Phase 2 권장 fix 후 코드)
`src/hooks/use-audit-logs.ts:14-28` — business hook이 fetch 위임
```tsx
<인용 코드 그대로>
```
이유: <왜 좋은지 1~2줄>

## Gate hook
- review-gate.sh `--rule=<rule-id>` 으로 검사
- 검사 정규식 / 명령: `<실제 명령>`
- 검출 시 P0~P4 분류: <severity>
```

**가상 예제 금지**. Phase 1에서 인용한 file:line만 사용한다. better case가 repo에 없으면 Phase 2의 권장 fix 후 코드를 명시("개선 후 예상 형태").

---

## Phase 4 — Gate Script 생성 (`.claude/scripts/review-gate.sh`)

setup-guide §7의 뼈대를 베이스로 하되, **Phase 2에서 gate=true로 분류된 룰만 포함**. 룰마다 검사 블록 하나씩 추가.

뼈대:

```bash
#!/usr/bin/env bash
# Generated by create-harness — Phase 4 output
# Rules covered: <rule-id-1>, <rule-id-2>, ...
set -euo pipefail
IFS=$'\n\t'

MODE="full"
BASE_REF="${BASE_REF:-origin/main}"

for arg in "$@"; do
  case "$arg" in
    --mode=*) MODE="${arg#--mode=}" ;;
    --base=*) BASE_REF="${arg#--base=}" ;;
    --rule=*) RULE="${arg#--rule=}" ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) printf 'unknown arg: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

REPO="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo 'not a git tree' >&2; exit 2; }
cd "$REPO"
errors=(); warnings=()

# Changed files (diff-scoped per setup-guide §7)
git fetch --quiet origin 2>/dev/null || warnings+=("git fetch origin failed")
changed=""
if git rev-parse --verify --quiet "$BASE_REF" >/dev/null; then
  changed=$(git diff --name-only "${BASE_REF}...HEAD" 2>/dev/null || true)
fi
[[ -z "$changed" ]] && changed=$(git diff --name-only HEAD 2>/dev/null || true)
[[ -z "$changed" ]] && changed=$(git diff --name-only 2>/dev/null || true)

printf '=== Changed files ===\n%s\n\n' "${changed:-(none)}"

# === Rule checks (one block per Phase 2 rule with gate=true) ===
# Example: layer-separation
printf '=== Rule: layer-separation ===\n'
if echo "$changed" | grep -qE '^src/components/.*\.tsx$'; then
  for f in $(echo "$changed" | grep -E '^src/components/.*\.tsx$'); do
    if grep -nE 'fetch\(|axios\.' "$f" >/dev/null 2>&1; then
      errors+=("layer-separation P1: presentation에서 직접 fetch — $f")
    fi
  done
fi

# Example: file-length-cap
printf '=== Rule: file-length-cap ===\n'
for f in $(echo "$changed" | grep -E '\.(tsx?|jsx?)$' || true); do
  [[ -f "$f" ]] || continue
  lines=$(sed '/^\s*$/d; /^\s*\/\//d' "$f" | wc -l | tr -d ' ')
  if (( lines > 270 )); then
    errors+=("file-length-cap P2: $f $lines줄 (cap 270)")
  fi
done

# CI checks (Phase 0 intake에서 잡은 명령)
if [[ "$MODE" != "refs-only" ]]; then
  printf '=== CI checks ===\n'
  for check in lint typecheck; do
    if pnpm -s "$check" >"/tmp/review-gate-$check.log" 2>&1; then
      printf -- '- %-10s PASS\n' "$check:"
    else
      printf -- '- %-10s FAIL (log: /tmp/review-gate-%s.log)\n' "$check:" "$check"
      errors+=("$check failed")
    fi
  done
fi

printf '=== Result ===\n'
for w in "${warnings[@]:-}"; do printf 'WARN: %s\n' "$w"; done
if (( ${#errors[@]} > 0 )); then
  for e in "${errors[@]}"; do printf 'FAIL: %s\n' "$e"; done
  printf 'Result: FAIL\n'
  exit 1
fi
printf 'Result: OK\n'
exit 0
```

`chmod +x .claude/scripts/review-gate.sh` 잊지 말 것.

---

## Phase 5 — Hook 배선

`.claude/settings.json`:

```jsonc
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/inject-context.sh\"" }
        ]
      }
    ]
  }
}
```

`.claude/hooks/inject-context.sh` — setup-guide §4를 그대로 사용 (project-rules + harness-engineering 본문 주입, `!` 또는 한/영 bypass 정규식 지원). `chmod +x` 적용.

---

## Phase 6 — Skill 본문 생성

### 6.1 `.claude/skills/project-rules/SKILL.md`

Phase 2의 `rules.json`을 markdown으로 펼친다:

```markdown
---
name: project-rules
description: <repo-name>의 코딩/구조 룰 (Phase 1 fact-check로 도출). 모든 task에 자동 주입.
---

# Project Rules

## §1 <rule-1 title>
- Severity: P<n>
- Gate: <yes / advisory>
- 참고: docs/conventions/<rule-1>.md

<룰 본문 — 3~6줄>

## §2 ...
```

각 §는 `docs/conventions/<rule>.md`와 1:1 매핑. references 디렉토리에 룰별 상세 두는 것도 가능.

### 6.2 `.claude/skills/harness-engineering/SKILL.md`

setup-guide §5의 11-phase 워크플로우를 그대로 둔다. 단 **Phase 8 Review Gate의 모델 ratio는 사용자 요구사항 #3에 맞춰 "Opus 1 + Sonnet 1, 1회성 fresh spawn, 메인이 종합"으로 축소**(setup-guide의 2 Opus + 3 Sonnet 5-agent 패널은 over-engineering으로 판단해 채택 안 함).

Phase 8 Step machine:

```
1. review-gate.sh --mode=full  → exit 0이면 Step 2로
2. Opus 1개 + Sonnet 1개 fresh spawn (단일 메시지에 병렬 Agent tool_use 2개)
   - 입력: git diff + project-rules 본문 + 검출된 위반 (있다면)
   - 출력 (strict JSON): { findings: [{severity, file, line, issue, suggested_fix}] }
3. 메인이 두 결과 + review-gate.sh 출력을 종합해 최종 패치 작성
   - "퀄리티 높음" 6 기준(SRP/주석/KISS/DRY/YAGNI/인지용이성)으로 self-grade
4. 패치 적용 → Phase 1 회귀 (절대 법령)
5. 다시 Step 1부터. iteration cap = 3.
```

---

## Phase 7 — Self-Verification

생성된 harness가 실제로 동작하는지 검증:

```bash
# 1. Hook이 본문을 주입하는가
bash .claude/hooks/inject-context.sh <<< '{"prompt":"sanity"}' \
  | jq -r '.hookSpecificOutput.additionalContext' \
  | grep -E "^## §[0-9]+" \
  || { echo "FAIL: project-rules not injected"; exit 1; }

# 2. Bypass가 동작하는가
bash .claude/hooks/inject-context.sh <<< '{"prompt":"!skip"}' \
  | jq -r '.hookSpecificOutput.additionalContext' \
  | grep -c "BYPASS MODE" \
  || { echo "FAIL: bypass not wired"; exit 1; }

# 3. Gate 스크립트가 exit 0/1을 정확히 내는가
.claude/scripts/review-gate.sh --mode=refs-only \
  || { echo "INFO: gate returned non-zero on current state (확인 필요)"; }

# 4. 일부러 위반을 만든 sample diff에 대해 gate가 exit 1을 내는가
#    (Phase 2에서 도출된 룰 중 하나를 골라 위반 케이스 작성 → gate 실행)
```

3개 verification 모두 통과해야 task done. 하나라도 fail하면 **Phase 1 회귀**.

---

## Phase 8 — Review Gate (요구사항 #3)

위 Phase 7이 한 차례 통과해도, **최종 done 선언 전에 1회 발사**한다.

1. **Opus 1 + Sonnet 1 fresh spawn** (단일 메시지에 병렬 Agent tool_use 2개)
   - subagent_type: `general-purpose`
   - model: `opus` / `sonnet`
   - description: "1회성 harness review (Opus|Sonnet)"
   - prompt: 아래 input bundle

2. **Input bundle (두 에이전트에 동일)**:

   ```
   You are reviewing a generated Claude Code harness for repo <name>.

   ARTIFACT:
   - .claude/settings.json
   - .claude/hooks/inject-context.sh
   - .claude/scripts/review-gate.sh
   - .claude/skills/project-rules/SKILL.md
   - .claude/skills/harness-engineering/SKILL.md
   - docs/conventions/*.md
   <각 파일의 내용을 inline으로 첨부>

   TASK:
   1. 룰 도출(Phase 1~2)이 실제로 fact-based인지 검증 — file:line 인용 누락된 룰이 있는가?
   2. gate script가 정말 그 룰을 차단하는가? 회피 가능한 패턴이 있는가?
   3. "퀄리티 높음" 6 기준(책임분리/주석/KISS/DRY/YAGNI/인지용이성)으로 0~5 채점 + 근거

   OUTPUT (strict JSON, no prose):
   {
     "fact_check_misses": [{"rule": "<id>", "missing_citation": "<what>"}],
     "gate_evasions": [{"rule": "<id>", "evasion": "<how to bypass the regex>"}],
     "quality_scores": {
       "srp": 0-5, "comment_clarity": 0-5, "kiss": 0-5,
       "dry": 0-5, "yagni": 0-5, "cognitive_ease": 0-5
     },
     "patches_suggested": [
       {"file": "<path>", "change": "<concrete diff or instruction>", "why": "<one line>"}
     ]
   }

   You have NO memory of prior reviewers. Treat this as first contact.
   ```

3. **메인 종합** — 두 JSON을 받아 다음 순서로 처리:
   - `fact_check_misses` 가 비어있지 않으면 → **Phase 1 회귀** (절대 법령 발동)
   - `gate_evasions` 가 비어있지 않으면 → Phase 4 회귀 (gate 보강)
   - `quality_scores` 중 평균 < 3.5 → 점수 낮은 항목에 대해 Phase 6 회귀
   - `patches_suggested` 는 메인이 6 기준으로 self-grade한 뒤 채택/기각 결정
   - 패치 1줄이라도 적용 → **Phase 1 회귀**

4. **회귀 cap = 3**. 3회 안에 모든 조건 통과 못 하면 truthful failure report를 사용자에게 출력(setup-guide §8 hard-stop과 같은 포맷). 폼:

   ```
   ## create-harness — Phase 8 hard stop
   ### Iterations attempted: 3
   ### Remaining issues
   - <issue 1>: <근거 file:line>
   - <issue 2>: ...
   ### What was tried (verbatim)
   <iteration별 패치 요약 + 결과>
   ### Recommended next moves
   <2~3개 구체적 다음 동작 — '아마' 금지>
   ```

---

## 종료 조건

다음을 **모두** 만족할 때만 done 선언:

- [ ] Phase 0~7이 순차적으로 통과
- [ ] Phase 8의 Opus + Sonnet 1회성 review가 fact_check_misses 0 / gate_evasions 0 / quality 평균 ≥ 3.5
- [ ] 회귀 cap을 소진하지 않음

done 선언 시 사용자에게 출력:

```
## create-harness 완료
### 생성 파일
- .claude/settings.json
- .claude/hooks/inject-context.sh
- .claude/scripts/review-gate.sh
- .claude/skills/project-rules/SKILL.md (+ references/)
- .claude/skills/harness-engineering/SKILL.md
- docs/conventions/<rule-1>.md ~ <rule-n>.md

### 도출된 룰 (gate / advisory 구분)
- gate: <rule-id-1>, <rule-id-2>, ...
- advisory: <rule-id-3>, ...

### Phase 8 review 결과 요약
- fact_check_misses: 0
- gate_evasions: 0
- quality avg: <n.n>

### 다음 단계
- 첫 prompt를 입력하면 hook이 자동 발사됨
- gate를 수동 실행: `.claude/scripts/review-gate.sh --mode=full`
- harness를 우회하려면 prompt 앞에 `!` 또는 "harness 빼고"
```

---

## Notes for Claude when this skill loads

- **이 스킬은 한 번에 끝나지 않는다.** Phase 1~8을 정직하게 돌면 turn이 여러 개 걸린다. cross-turn 진행이 필요하면 `/loop`로 감싸도 좋지만, **`/loop` 없이도 한 conversation 안에서 phase별로 진척**시킬 수 있어야 한다.
- **Phase 1의 fact-check 루프는 절대 약식 처리 금지.** `cat | head` 추론 금지, Read tool로 실제 파일을 보고 file:line을 명시한다.
- **YAGNI 절대 준수.** Phase 1에서 위반 0 + 사용자 언급 0인 룰은 도입하지 않는다. 5개 룰로 충분하면 5개로 멈춘다.
- **회귀 cap 3은 절대 깨지 않는다.** 무한 oscillation 방지 (research-foundation §2 원칙 5). 3회 안에 수렴 못 하면 사용자에게 실패 보고.
- **Opus + Sonnet 1회성 review는 fresh spawn.** `agentId` / `sessionId` 캡쳐 금지. `SendMessage` 금지. round 2 없음 (사용자 요구사항 #3은 "1회성").
- **모든 산출물은 대상 프로젝트 루트에 작성.** 이 스킬 자체(zeriong-create-harness)는 read-only로 사용된다.
