# zeriong-better-looper

장기 목표를 N회 점진적 사이클로 실행하는 루프 래퍼 플러그인입니다.

## 제공 기능

### Skills

| 스킬 | 설명 | 호출 |
|------|------|------|
| `better-looper` | N회 점진적 사이클 루프 (implement → validate → refactor → commit → reflect) | `/better-looper <goal>` |

## 동작 방식

1. **Phase 0 — Intake**: 목표, 도구, 리팩터 주기를 한 번 수집
2. **Phase 1 — Per-cycle**: slice 선택 → 구현 → 검증 → 리팩터 → 커밋 → 회고
3. **Escalation**: 실패 시 retry 5/10에서 WebSearch/WebFetch 에스컬레이션, retry 20에서 hard stop
4. **Checkpoints**: 첫/중간/마지막 사이클에서 리서치 기반 방향 제안

## 트리거 키워드

Korean: "점진적", "반복", "사이클", "loop으로", "n회"
English: "progressive", "iterative", "cycle", "incremental", "better-looper", "loop-refactor"
