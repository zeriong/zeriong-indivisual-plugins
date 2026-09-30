# indivisual-commit

A personal git commit skill for Claude Code and Codex — authors a header + body commit message, runs `git commit` as the identity you registered, with zero AI attribution, then pushes to the remote.

For Korean: see [README.ko.md](./README.ko.md).

## What it provides

| Skill | Purpose | Invoke |
|-------|---------|--------|
| `indivisual-commit` | Resolve your registered identity, detect project commit rules, compose a header + body message, run `git commit` as you, then push. | Claude Code: `/indivisual-commit:indivisual-commit` · Codex: `$indivisual-commit:indivisual-commit` · or just say "커밋해줘" / "commit and push" |

## Commit identity

The skill never hardcodes an account. On first use it:

1. Reads `git config --global user.name` / `user.email` as the suggested identity.
2. Asks you to confirm it or enter a different name/email (a missing value must be entered — it is never guessed).
3. Saves it to `~/.config/indivisual-commit/identity` (`$XDG_CONFIG_HOME` is honored). The file uses git-config format and is shared by Claude Code and Codex.

Every later commit uses that identity for both author and committer, regardless of the repo-local or global git config. To change it, say "커밋 계정 변경" / "change commit identity", or delete the file to start over.

```
# inspect or edit by hand
git config --file ~/.config/indivisual-commit/identity --list
```

## How it works

0. **Resolve identity** — read the identity file; run the first-use flow above if the name or email is missing. No commit happens without both.
1. **Detect project rules** — probes `commitlint.config.*`, `.commitlintrc*`, `.husky/commit-msg`, `.pre-commit-config.yaml`, `CONTRIBUTING.md`, and the last 20 commit subjects in that order.
2. **Resolve effective ruleset** — merges in priority: skill defaults → history pattern → docs → machine-enforced configs (later overrides earlier). Prints the resolved ruleset before composing.
3. **Read the staged diff** — refuses to silently `git add -A`; warns on staged secrets (`.env`, `*.pem`, `API_KEY=` patterns).
4. **Compose the message** — Conventional Commits default (`<type>(<scope>): <subject>`), header ≤ 50, body ≤ 72, body focuses on *why*, not *what*.
5. **Run `git commit`** — sets `GIT_AUTHOR_NAME/EMAIL` and `GIT_COMMITTER_NAME/EMAIL` from the identity file plus `--author`. Environment variables win over repo/global config and over stale `GIT_*` values in the shell. No git config is ever modified.
6. **Verify and report** — prints the new commit's hash, author, committer, and header.
7. **Push** — `git push` after the commit is verified (`-u origin <branch>` on first push). Fast-forward only: rejected pushes are fetched and reported, never forced. Skipped when you ask for commit-only.

## Absolute laws

1. Author and committer are **always** the registered identity, injected per commit — the repo and global git config are never touched.
2. **Zero AI attribution.** No `Co-Authored-By` for Claude, Codex, or any AI, no robot emoji, no "Generated with …", no Anthropic/OpenAI references.
3. **Project rules win.** When commitlint / husky / pre-commit enforce a rule that conflicts with the defaults, the project rule is used.
4. **Never `--no-verify`.** Hook failures are surfaced, not bypassed.
5. **Never `--amend`.** Even after a hook failure, a new commit is authored.
6. **Never force-push.** No `--force`, no `--force-with-lease`.
7. **No identity, no commit.**

## Default style (used when no project rule is detected)

- Format: Conventional Commits — `<type>(<optional scope>): <subject>`
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `perf`, `build`, `ci`
- Header line length: ≤ 50 characters
- Body line length: ≤ 72 characters per line (Git/Linux kernel convention)
- Blank line required between header and body
- Subject default language: English (matches Conventional Commits norms)
- Body language: matches the repo's existing history

## Host notes

| | Claude Code | Codex |
|---|---|---|
| First-use question | `AskUserQuestion` | asked in the conversation |
| Writing `~/.config/...` | normal file write | outside the workspace — the sandbox may ask for approval; if it can't, the skill prints the command for you to run |
| `git push` | normal | the default sandbox blocks network — approve the push, or run it yourself |

## Install

Part of the [zeriong-indivisual-plugins](../../README.md) marketplace.

```
# Claude Code
/plugin marketplace add zeriong/zeriong-indivisual-plugins
/plugin install indivisual-commit@zeriong-indivisual-plugins

# Codex
codex plugin marketplace add zeriong/zeriong-indivisual-plugins
codex plugin add indivisual-commit@zeriong-indivisual-plugins
```

## When to use it

- Personal repos where you want the commit author locked to your identity
- Mixed work + personal machine where the repo or global `git config user.email` is set to a different address
- Quick high-quality commits without writing the message by hand

## When to skip it

- Pair programming or team work where the actual author is someone else
- One-line cosmetic commits where typing the message yourself is faster than invoking a skill
