# zeriong-better-looper

A `/loop` wrapper that drives a long-running goal through N progressive cycles.

For Korean: see [README.ko.md](./README.ko.md).

## What it provides

### Skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `better-looper` | Run N cycles of *plan slice → implement → validate → refactor → commit → reflect*. Auto-wraps the built-in `/loop` so `ScheduleWakeup` paces iterations across model calls. | `/better-looper <goal>` |

## How it works

1. **Phase 0 — Intake** (one `AskUserQuestion` call): goal shape, tooling allowed, refactor cadence.
2. **Phase 1 — Per-cycle execution**: select smallest advancing slice → implement → validate with the chosen tool → refactor → commit → reflect.
3. **Stuck-debugging escalation ladder**: retries 1–4 are local; retry 5 calls `WebSearch`; retry 10 calls `WebFetch` on a different angle; retry 20 is a **hard stop** with a truthful failure report.
4. **Reflection checkpoints** at the first, middle, and last cycles — research-backed direction proposals.
5. **Pending-question handling**: every clarifying question schedules a 5-minute fallback wake-up so the loop never stalls. The user can defer with "10분 지연해줘" or pause cleanly with "답변 주면 이어서 진행해줘".

## Trigger keywords

- Korean: `점진적`, `반복`, `사이클`, `loop으로`, `n회`
- English: `progressive`, `iterative`, `cycle`, `incremental`, `better-looper`, `loop-refactor`

## When this plugin is the right tool

- Long-running goals that can't finish in one turn (e.g. "expand E2E coverage over 10 cycles").
- Work that benefits from forced reflection points (research at start / middle / end).
- Goals where retry-budget discipline matters — the hard stop at retry 20 prevents infinite spinning on a stuck slice.

## When to skip it

- Single-shot tasks. The cycle scaffolding is overhead if the work fits in one turn.
- Projects where hooks already enforce per-edit validation. `better-looper`'s value is cross-turn pacing and retry-state tracking, not convention enforcement — those overlap with hook-based harnesses.
