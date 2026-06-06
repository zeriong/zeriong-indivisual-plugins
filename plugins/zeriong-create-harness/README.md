# zeriong-create-harness

Meta-skill that builds a **project-tailored Claude Code harness from scratch** by directly analyzing the target project's layer/concern separation.

For Korean: see [README.ko.md](./README.ko.md).

## What it does

Unlike a generic scaffolder, this skill does **not** copy a fixed template. It reads the target repo, derives the rules that actually fit it, then materializes the harness around those rules.

Output written into the target project:

```
.claude/
├── settings.json                    # UserPromptSubmit hook wiring
├── hooks/inject-context.sh          # Injects project-rules + harness-engineering
├── scripts/review-gate.sh           # Deterministic gate (exit 0 / 1 / 2)
└── skills/
    ├── project-rules/SKILL.md       # Rules derived in Phase 1–2
    └── harness-engineering/SKILL.md # 11-phase workflow

docs/conventions/
├── <rule-1>.md                      # Worse-case / better-case + keyword index
└── ...
```

## Trigger

```
/create-harness
```

Korean / English keywords: `harness 만들어`, `create harness`, `harness 셋업`, `프로젝트 룰 추출`, `review gate 깔아줘`, `create-harness`.

## 8-Phase workflow

| Phase | Responsibility | Fact-check loop required |
|-------|----------------|--------------------------|
| 0 | Intake — package manager, monorepo shape, existing scripts, user-recommended rules | — |
| 1 | **Layer / Concern Reconnaissance** — every claim must cite `file:line` | ✅ mandatory |
| 2 | Convention Extraction — Phase 1 verdicts become rules | ✅ |
| 3 | `docs/conventions/<rule>.md` — worse / better case indexed from real repo code | ✅ |
| 4 | Gate script (`review-gate.sh`) generation | — |
| 5 | Hook (`UserPromptSubmit`) wiring | — |
| 6 | Skill bodies (`project-rules` + `harness-engineering`) generation | — |
| 7 | Self-verification — sample diff exercises the gate | — |
| 8 | Review gate — Opus + Sonnet 1-shot review, main synthesizes patches | — |

**Any patch applied at Phase 8 forces regression back to Phase 1** (absolute rule — side-effects are assumed to invalidate prior verdicts). Iteration cap = 3.

## The fact-check loop (Phase 1's core)

Every layer/concern claim must pass:

```
Claim → "Really?" → Read tool (direct file open) → grep entire scope
      → side-effect probe → SRP test → Verdict with file:line
```

Claims without a citation are discarded and Phase 1 restarts. This is the single most important rule — every downstream phase derives from Phase 1 facts.

## Why this exists

The companion `setup-guide.md` (in the user's private config) describes how to scaffold a harness for a project whose rules are *already known*. `create-harness` covers the prior step: **deriving the rules from the project itself**, so that the same harness philosophy can be ported to any repo without copy-paste over-engineering.

## Dependencies

- `git`, `jq`, `bash 4+`
- Target project must be a git work tree.
