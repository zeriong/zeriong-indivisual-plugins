---
name: better-looper
description: Drive a long-running goal through N progressive cycles where each cycle implements one slice, validates, refactors, and commits. Use this skill when the user wants iterative improvement (e.g. "scenarios incrementally", "10 cycles", "improve X over time", "build then refine"). The skill **wraps the built-in `/loop`** internally — when invoked as `/better-looper <goal>`, Claude immediately re-enters via `/loop /better-looper <goal>` so ScheduleWakeup paces iterations across model calls. Owns intake (5 example questions, package-aware tooling choice, refactor cadence), per-cycle execution, retry escalation (`WebFetch` at retries 5 and 10, **hard stop at retry 20**), and reflection checkpoints (first / middle / last). Pending-question handling auto-resumes after 5 minutes; reply "10분 지연해줘" to extend or "답변 주면 이어서 진행해줘" to fully pause until you reply. Trigger keywords (Korean / English): "점진적", "반복", "사이클", "loop으로", "n회", "progressive", "iterative", "cycle", "incremental", "better-looper", "loop-refactor".
---

# better-looper

Drives a long-running goal through `N` cycles of *plan one slice → implement → validate → refactor → commit → reflect*, with built-in escalation (`WebFetch` lookups after repeated failures), a **hard retry cap at 20 attempts** that breaks out of the loop with a truthful failure report, and three reflection checkpoints (first / middle / last) where Claude proposes research-backed direction changes.

This skill **wraps the built-in `/loop`** so the user only ever has to type one thing. Two trigger shapes both end up in the same place:

- `/better-looper <goal>` — direct trigger. On the **first** turn, Claude immediately schedules `/loop /better-looper <goal>` (dynamic mode) via `ScheduleWakeup`, then runs Phase 0 intake on the same turn. From the second turn onward the built-in `/loop` owns ScheduleWakeup pacing; this skill owns the *content* of each iteration.
- `/loop /better-looper <goal>` — already wrapped by the user. Skip the auto-wrap step and proceed straight to Phase 0 / Phase 1.

> **Hard requirement** — once intake is complete, the cycle MUST NOT lose its loop context across user replies. Pending questions never block the cycle. See *Pending-question handling* below.

---

## Auto-wrap with /loop on first invocation

When the skill fires from a bare `/better-looper <goal>` (no leading `/loop`), do this **before** any other work on that turn:

1. Call `ScheduleWakeup` once with:
   - `delaySeconds`: `1500` (25 min — past the cache window so we don't pay misses needlessly; the user can interrupt sooner).
   - `prompt`: `/loop /better-looper <goal>` (verbatim — preserves the wrapped form for every subsequent firing).
   - `reason`: short sentence noting auto-wrap, e.g. `auto-wrapping bare /better-looper into /loop dynamic mode`.
2. Tell the user in one line that the loop is now scheduled and that further firings will arrive via the built-in `/loop`.
3. Continue this same turn into Phase 0 (intake) — never end the turn after the wakeup call without progress.

If the trigger already starts with `/loop`, skip the auto-wrap and go straight to Phase 0.

---

## Phase 0 — Intake (collect once, then never again)

When the skill fires for the first time on a goal, **immediately ask three questions in a single `AskUserQuestion` call** (the user can answer in one round). Skip any question the user already answered in the trigger prompt.

### Question 1 — what gets improved over N cycles

Ask the user *what* they want to advance and show **five concrete example questions** so the user can pattern-match. Phrase it so the user sees they can paste any of the five or write their own. The five examples MUST cover distinct domains:

```
1) "E2E 시나리오를 10회에 걸쳐 점진적으로 늘려줘 (지금 2개만 있고, 10회 후엔 도메인별로 골고루 커버되면 좋겠다)"
2) "현재 list 렌더만 검증하는 e2e에 mutation user journey를 8회 보강해줘 (POST/PUT/PATCH/DELETE 흐름 검증까지)"
3) "성능 핫스팟을 6회에 걸쳐 점진적으로 최적화해줘 (lighthouse 점수 또는 vitest bench 기준)"
4) "라이브러리 컴포넌트 1개씩 12회에 걸쳐 storybook 등록 + 시각 회귀 베이스라인 잡아줘"
5) "타입 안전성을 5회 사이클로 강화해줘 (any 제거 → unknown narrowing → exhaustive switch → zod 경계 검증)"
```

### Question 2 — which tooling is allowed

Inspect the project's `package.json` files (root + each workspace) **before asking** to enumerate what is actually installed. Then offer up to four mutually exclusive options grouped by the user's likely intent. Always include an "Other / 기타 의견 적기" option so the user can free-text. Examples (pick the right shape per goal):

- E2E goal → `Playwright` (already in repo) / `Cypress` / `Vitest browser mode` / Other
- Perf goal → `Lighthouse CI` / `Vitest bench` / `Playwright trace` / Other
- Visual regression → `Storybook + Chromatic` / `Playwright snapshot` / `Loki` / Other
- Type safety → `tsc --strict` ratchet / `eslint-plugin-typescript-strict` / `zod` boundaries / Other

### Question 3 — refactor cadence at each cycle's end

Propose the **default rhythm based on what was found in the repo** (e.g. project-rules skill loaded → SRP / view-business split / kebab-case files → so the default is "P0–P3 fixes per cycle, P4 deferred"). Always end with: *"위 외에 우선 적용했으면 하는 방향성이 있다면 자유롭게 적어주세요"* so the user can append.

### After Phase 0

Persist the answers in a TodoWrite item titled `better-looper: intake locked` so future iterations don't re-ask. Now move to Phase 1.

---

## Phase 1 — Per-cycle execution (repeat N times)

Each cycle follows the **same rhythm** so the user sees a stable pattern:

1. **Slice selection** — pick the smallest unit that advances the goal (one user journey, one bottleneck, one component). Print a one-line summary: `Cycle k/N — <slice>`.
2. **Implement** — write the code/spec/config. Apply project-rules (SRP, kebab-case, comment style, etc.) live.
3. **Validate** — run the tool selected in Phase 0 (Playwright, vitest, lighthouse…). On failure, enter the *Stuck-debugging escalation ladder* below.
4. **Refactor** — apply the cadence agreed in Phase 0. Stop at P4-only.
5. **Commit** — `git add` only. Auto-run `git commit` is allowed for this project (per the user's earlier instruction in this repo); message is conventional, head ≤50 chars, body lines ≤50 chars, English-only, no author footer.
6. **Reflect** — one-line postmortem: what slice, what worked, what is the next slice. Update TodoWrite.

If a cycle reaches the work cap (e.g. >30 min wall time) without converging, stop the cycle, mark blocker, and tell the user. Do not silently extend.

### Stuck-debugging escalation ladder

When the same failure recurs, escalate predictably. **Track the retry counter on a per-slice basis** (TodoWrite field `retryCount` on the active slice item).

| Retry count | Action |
|---|---|
| 1–4 | Local hypothesis from current code: re-read the failing call site, narrow the assertion, fix. |
| **5** | First escalation — call `WebSearch` (or `WebFetch` on docs/issues you suspect). Re-derive a new hypothesis from the search results. Note in TodoWrite that escalation 1 happened (record the URL and the key sentence quoted). |
| 6–9 | Apply the new hypothesis. |
| **10** | Second escalation — call `WebFetch` on a different angle (different tool's docs, GitHub issues, blog posts). Re-derive again. Note in TodoWrite that escalation 2 happened (record the URL and the key sentence quoted). |
| 11–19 | Continue with the new lead. |
| **20 — HARD STOP** | Break out of the loop. See *Hard retry cap* below. **Do NOT increment past 20 in silence.** |

The escalation ladder is a **small loop inside the big cycle loop** — it keeps Claude from grinding on the same dead-end gradient.

### Hard retry cap (retry == 20)

When the same slice fails for the **20th** time, the loop must exit cleanly:

1. **Stop retrying immediately** — do not attempt fix #21.
2. **Do NOT call `ScheduleWakeup`** at the end of this turn. The wrapped `/loop` stops firing until the user re-engages.
3. **Park the cycle** — TodoWrite item: `better-looper: HARD STOP at cycle k slice "<slice>" — 20 retries exhausted`. Mark the slice `paused-blocked`.
4. **Emit a truthful failure report** to the user. The report MUST contain only **observed facts**, never speculation. Required sections:

   ```
   ## better-looper hard stop — cycle k/N, slice "<slice title>"

   ### What was being attempted
   <one sentence describing the slice goal — verbatim from intake / cycle plan>

   ### Most recent failure (verbatim)
   <paste the last command output / stderr / test failure exactly as captured —
    no paraphrasing, no "probably". If long, include the first 30 lines and
    the last 30 lines and mark the elision.>

   ### Failure location
   <file:line, function name, the exact code line that failed —
    read from disk, do not recall from memory>

   ### Hypotheses tried (all 20 attempts)
   1. <retry #1>: changed <X> in <file:line>. Result: <exact failure or partial pass>.
   2. <retry #2>: ...
   ...
   20. <retry #20>: ...

   ### Web research consulted
   - Retry 5 escalation: <URL> — quoted: "<one-sentence quote that drove the next hypothesis>"
   - Retry 10 escalation: <URL> — quoted: "<...>"

   ### What is NOT yet known (honestly)
   - <items where Claude does not have ground truth — e.g. "did not inspect
     the upstream library's source", "did not run with --debug flag",
     "could not reproduce locally outside the test runner">

   ### Suggested next moves (for user decision)
   - <up to 3 concrete next moves, each with a cost estimate and what would
     be learned. No "probably this will fix it" — frame as experiments.>
   ```

5. **Truthfulness rules for the report (project-rules §7 applies)**:
   - Every claim about code must come from a file actually read in this session — quote `file:line`.
   - Every claim about a failure must come from output actually captured — quote it verbatim.
   - Every web reference must be a URL actually fetched and a sentence actually present in the response.
   - If a hypothesis was based on a guess (no source consulted), label it `(unverified hypothesis)` in the list — don't pretend it had grounding.
   - **Banned phrases**: "probably", "likely the issue is", "this should fix it", "I think". Replace with observed evidence or label `(unverified hypothesis)`.

6. **Wait for the user's instruction**. Do not auto-resume. The loop only resumes when the user replies with one of: a corrective hint, "skip this slice and continue", "abandon the goal", or new context. When they do, treat their reply as the start of a fresh attempt with `retryCount` reset to 0 (since they introduced new information).

### Cycle checkpoints (first / middle / last)

At three predetermined points Claude pauses *before* writing code and offers a research-backed redirect:

- **First cycle (k = 1) — start checkpoint**: `WebFetch` the canonical docs of the selected tool to confirm the recommended setup. Compare to the in-repo state. Propose any deltas.
- **Middle cycle (k = ⌈N/2⌉) — direction checkpoint**: `WebSearch` for current best practices on the goal (e.g. "Playwright fixtures monorepo 2026"). Surface 2–3 ideas the user might want to absorb.
- **Last cycle (k = N) — exit checkpoint**: `WebSearch` for "next steps after <goal completed>" — what would the same team naturally do after finishing this loop. Suggest as a future `/loop` follow-up.

At each checkpoint Claude writes a short proposal and asks the user via `AskUserQuestion` (single question, 2–3 options + Other). If the user does not reply, fall back to *Pending-question handling*.

---

## Pending-question handling (loop must not stall)

This is the core of "loop must keep working even while waiting on user input."

1. When Claude asks a checkpoint question (or any clarifying question), it **also** prints exactly this notice on the same turn:

   > *응답이 5분 지연되면 권장 사항으로 강행됩니다. 더 기다려야 하는 상황이라면 "10분 지연해줘" 또는 "답변 주면 이어서 진행해줘" 처럼 답변해주세요. 후자의 경우 작업을 멈췄다가 답변이 오면 멈춘 지점부터 loop를 이어 갑니다.*

2. Then call `ScheduleWakeup` with `delaySeconds: 300` (5 minutes), `prompt: "/loop /better-looper <original goal>"`, and a `reason` mentioning the pending question. This is the wake signal.

3. **Three possible re-entry paths**:
   - **User replies before wake-up** → consume the answer, cancel the implicit fallback, continue normally.
   - **Wake-up fires (5 minutes elapsed) with no reply** → adopt the *recommended option* (the option marked "(Recommended)" or the first option), log a one-line note `auto-resumed at checkpoint k after 5m`, continue.
   - **User says "10분 지연해줘"** → re-issue `ScheduleWakeup` with `delaySeconds: 600`, restate the notice, do not advance the cycle.
   - **User says "답변 주면 이어서 진행해줘"** (or 동의하는 자연어) → cancel `ScheduleWakeup`. Park the loop with a TodoWrite item `better-looper: paused awaiting user`. Do **not** issue further `ScheduleWakeup`s for this checkpoint. When the user finally replies (their reply re-enters the conversation), Claude resumes from the parked TodoWrite — same goal, same cycle k, same slice — without re-asking the previous N–1 cycles' decisions.

4. **Single-shot user answers (not pause requests)** must keep the cycle alive. Even if the user replies tersely ("좋아 옵션 1로", "네"), Claude continues into the same cycle's next step on the same turn — never wait for an extra prompt to "continue". Loop semantics are preserved.

5. If the user instead provides totally new instructions mid-cycle, Claude offers to re-enter intake (Phase 0) only if those instructions invalidate the original goal; otherwise treat as a course correction inside the current slice.

---

## Output protocol per cycle

Every cycle emits the same shaped status line so the user can scan progress:

```
Cycle k/N — <slice title>
  ✓ implemented: <one-line summary of what code changed>
  ✓ validated: <tool> — <pass/fail counts>
  ✓ refactored: <P0–P3 items applied, P4 deferred: …>
  ✓ committed: <commit hash> <commit subject>
  → next: <peek at cycle k+1 slice, if known>
```

If a cycle is blocked, the line replaces `committed` with `blocked: <reason>` and the next-line slice is "awaiting decision". If the **hard retry cap** triggered, the line reads `HARD STOP: 20 retries exhausted — see failure report` and the loop terminates without scheduling the next wakeup.

---

## Termination conditions

Stop the loop when **any** of these are true:

- The N cycles agreed in Phase 0 have all completed.
- Only P4-or-below issues remain across the goal (per the refactor cadence). Surface a "done; remaining backlog" report.
- The user explicitly says "stop", "그만", "멈춰", "종료".
- A single slice hits the **hard retry cap (20)** — emit the truthful failure report and wait for user.

When stopping, also **omit the next `ScheduleWakeup`** so the wrapped `/loop` stops firing. Never stop silently — always emit a final report with: cycles completed, commits authored, blockers, suggested next `/loop` invocation (using the last-cycle exit checkpoint's research output).

---

## Worked example (one cycle, abridged)

```
Cycle 4/10 — admin pages e2e
  → slice: assert audit-logs renders seeded events, contact-mappings renders the link
  → implement: e2e/admin-pages.spec.ts (5 scenarios)
  → validate: pnpm exec playwright test e2e/admin-pages.spec.ts
       → 4 passed, 1 failed (audit-logs strict mode violation)
  → escalation: retry #1 — narrow selector to .first()
       → 5 passed
  → refactor: extract repeated 15s timeout to config (P3)
  → commit: c9bda91 test(ehr-admin): cover admin pages
  → next: phase-8 resource pages
```

---

## Notes for Claude when this skill loads

- This skill is a **content driver** that owns iteration content; the wrapped `/loop` (dynamic mode) owns `ScheduleWakeup` pacing. Always re-emit the wrapped prompt `/loop /better-looper <goal>` in every `ScheduleWakeup` so the wrap survives across firings.
- `WebSearch` and `WebFetch` are part of the loop, not exceptional events. Embrace them at retries 5 and 10, and at the three checkpoints.
- **Retry 20 is non-negotiable**. The cap exists specifically because the `/loop` wrap can otherwise spin forever on a stuck slice. Truthful evidence-based reporting at the cap is more valuable than another speculative attempt.
- Project rules (SRP, kebab-case, commit message limits, Truthful Logic Analysis) apply throughout. Project-specific overrides (e.g. "auto-commit allowed in this repo") take precedence when present in `CLAUDE.md`.
- Whenever you ask the user a question, simultaneously schedule the 5-minute fallback wake. Never end a turn with a question and no schedule.
- "Cancel `ScheduleWakeup`" here means "do not call `ScheduleWakeup` again for this question"; the runtime has no explicit cancel API, so simply omitting the call on subsequent turns is sufficient.
