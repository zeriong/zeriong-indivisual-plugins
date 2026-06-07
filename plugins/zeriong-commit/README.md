# zeriong-commit

A personal git commit skill — authors a header + body commit message and runs `git commit` with hardcoded author identity and zero Claude attribution.

For Korean: see [README.ko.md](./README.ko.md).

## What it provides

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `zeriong-commit` | Detect project commit rules, compose a header + body message in the resolved style, and run `git commit` as `jaeryong95@gmail.com` with no Claude footer. | `/zeriong-commit` |

## How it works

1. **Detect project rules** — probes `commitlint.config.*`, `.commitlintrc*`, `.husky/commit-msg`, `.pre-commit-config.yaml`, `CONTRIBUTING.md`, and the last 20 commit subjects in that order.
2. **Resolve effective ruleset** — merges in priority: skill defaults → history pattern → docs → machine-enforced configs (later overrides earlier). Prints the resolved ruleset to the user before composing.
3. **Read the staged diff** — refuses to silently `git add -A`; warns on staged secrets (`.env`, `*.pem`, `API_KEY=` patterns).
4. **Compose the message** — Conventional Commits default (`<type>(<scope>): <subject>`), header ≤ 50, body ≤ 72, body focuses on *why*, not *what*.
5. **Run `git commit`** — uses `-c user.name='zeriong' -c user.email='jaeryong95@gmail.com' --author='zeriong <jaeryong95@gmail.com>'`. The repo's persistent git config is never modified.
6. **Verify and report** — prints `git log -1` so the user can confirm author + committer + header before doing anything else.

## Absolute laws

1. Author and committer are **always** `jaeryong95@gmail.com`. Identity is injected per-invocation via `-c` flags so work-repo configs are not touched.
2. **Zero Claude attribution.** No `Co-Authored-By: Claude`, no robot emoji, no "Generated with Claude Code", no Anthropic references anywhere in the message or trailers.
3. **Project rules win.** When commitlint / husky / pre-commit enforce a rule that conflicts with the skill's defaults, the project rule is used.
4. **Never `--no-verify`.** Hook failures are surfaced, not bypassed.
5. **Never `--amend`.** Even after a hook failure, a new commit is authored — amending after a hook failure can destroy work.

## Default style (used when no project rule is detected)

- Format: Conventional Commits — `<type>(<optional scope>): <subject>`
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `perf`, `build`, `ci`
- Header line length: ≤ 50 characters
- Body line length: ≤ 72 characters per line (Git/Linux kernel convention)
- Blank line required between header and body
- Subject default language: English (matches Conventional Commits norms)
- Body language: matches the repo's existing history

## Install

This plugin is part of the [zeriong-claude-plugins](../../README.md) marketplace.

```
/plugin
→ Marketplaces → Add Marketplace
→ https://github.com/zeriong/zeriong-claude-plugins.git
→ Install zeriong-commit
```

## When to use it

- Personal repos where you want the commit author locked to your identity
- Mixed work + personal machine where the global `git config user.email` is set to a work address
- Quick high-quality commits without writing the message by hand

## When to skip it

- Pair programming or team work where the actual author is someone else
- Any repo where commits should be attributed to a different identity
- One-line cosmetic commits where typing the message yourself is faster than invoking a skill
