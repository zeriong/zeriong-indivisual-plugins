---
name: zeriong-commit
description: Author a git commit message (header + body), run `git commit`, then push to the remote. Detects project-level commit rules (commitlint, husky commit-msg, pre-commit) and prefers them over defaults. Default style is Conventional Commits with header ≤ 50 chars and body ≤ 72 chars per line. Author/committer is always jaeryong95@gmail.com — never Claude. No Claude-attribution footer (no `Co-Authored-By: Claude`, no "Generated with Claude Code", no robot emoji). Never force-pushes. Trigger keywords (Korean / English) — "commit", "커밋", "커밋해", "커밋 만들어", "zeriong-commit", "generate commit", "커밋하고 푸시", "commit and push".
---

# zeriong-commit

Authors a git commit message, executes `git commit`, and pushes the result to the remote on behalf of the user. The user is the sole author and committer; this skill never attributes the commit to Claude.

---

## Absolute laws

1. **Author / committer is always `jaeryong95@gmail.com`.** No exceptions. If `git config user.email` returns anything else for this commit, set it locally via `-c user.email=jaeryong95@gmail.com -c user.name=zeriong` on the `git commit` invocation. Do not modify the repo's persistent git config.
2. **Zero Claude attribution.** The commit message, trailers, and metadata must never contain:
   - `Co-Authored-By: Claude` (or any Claude variant)
   - `🤖 Generated with Claude Code`
   - `Generated with [Claude Code]`
   - Any line referencing Claude, Anthropic, or AI authorship
3. **Project rules > skill defaults.** If the repo enforces commit rules (commitlint, husky `commit-msg`, pre-commit `commit-msg`), those rules are authoritative. Defaults below only apply when no project rule is found.
4. **Never `--no-verify`.** Hooks exist for a reason. If a hook fails, surface the failure to the user — do not bypass.
5. **Never amend.** Always author a new commit, even when a previous commit's hook fails. Amending after a hook failure can destroy work.
6. **Never force-push.** No `--force`, no `--force-with-lease`. If the push is rejected, surface the rejection to the user — do not rewrite remote history.

---

## Default style (used only when no project rule is detected)

- **Format**: Conventional Commits — `<type>(<optional scope>): <subject>`
- **Types**: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `perf`, `build`, `ci`
- **Header line length**: ≤ 50 characters (subject + type + colon + scope)
- **Body line length**: ≤ 72 characters per line (Git/Linux kernel convention)
- **Blank line between header and body**: required
- **Body**: focuses on *why*, not *what* (the diff already shows what)
- **Language**: English header. Body may be Korean or English, matching the repo's existing history

Example:

```
feat(harness): add fact-check loop to phase 1

Every claim about layer separation must now cite file:line.
Claims without citation are discarded and phase 1 restarts.
This is the foundation rule the entire harness depends on.
```

---

## Workflow

### Step 1 — Detect project rules

Run these probes from the repo root in order. Stop at the first match (rules can override silently).

#### 1.1 commitlint config

Look for one of:
```
commitlint.config.js
commitlint.config.mjs
commitlint.config.cjs
commitlint.config.ts
.commitlintrc
.commitlintrc.json
.commitlintrc.yaml
.commitlintrc.yml
.commitlintrc.js
package.json  (the `commitlint` key)
```

If found, **read the file** and extract:
- The `extends` array (e.g. `@commitlint/config-conventional` → enforce Conventional Commits)
- The `rules` object (e.g. `'header-max-length': [2, 'always', 72]` → header cap is 72, not 50)
- `type-enum` (restricts allowed types)
- `scope-enum` (restricts allowed scopes)
- `subject-case` (e.g. `lower-case` requirement)

#### 1.2 husky commit-msg hook

```
.husky/commit-msg
```

If present, read it. It usually invokes commitlint or a custom validator. Note the exact command — that is the source of truth.

#### 1.3 pre-commit framework

```
.pre-commit-config.yaml
```

Look for hooks under `stages: [commit-msg]` or `repo: ...commitlint...`. Record the rules they reference.

#### 1.4 CONTRIBUTING.md / .github/COMMIT_CONVENTION.md

Quick grep for `commit` in `CONTRIBUTING.md`, `.github/COMMIT_CONVENTION.md`, `docs/CONTRIBUTING*`. Human-written conventions may not be machine-enforced but are still binding.

#### 1.5 Recent commit history

```
git log -20 --pretty=format:'%s'
```

Look at the last 20 commit subjects. If a clear pattern exists (e.g. all use `feat:` / `fix:` prefixes, all are English, all under N characters), match it. History is a soft rule when no hard rule is configured.

### Step 2 — Resolve the effective ruleset

Merge in this priority order (later overrides earlier):
1. Skill defaults (header 50 / body 72 / Conventional Commits)
2. Recent history pattern (Step 1.5)
3. CONTRIBUTING / convention docs (Step 1.4)
4. pre-commit / husky / commitlint configs (Steps 1.1–1.3)

Print the resolved ruleset to the user in one line before composing the message:

```
Rules: header ≤ 50 / body ≤ 72 / Conventional Commits / lower-case subject
Source: commitlint.config.js (project-enforced)
```

### Step 3 — Read the staged diff

```
git diff --staged --stat
git diff --staged
```

If nothing is staged, **stop and ask** — never run `git add -A` or `git add .` unprompted (commits sensitive files). If the user explicitly says "stage everything", use `git add -A` but call out anything that looks like a secret (`.env`, `*.pem`, `credentials.*`).

### Step 4 — Compose the message

Produce a header + body that:
- Fits the resolved ruleset
- Explains *why* in the body, not *what* (the diff is the *what*)
- Uses the type that best matches the change shape (see "Type selection" below)
- Is in English for the header (matches Conventional Commits norms and most lint configs)
- Is in the language the repo already uses for the body (check `git log` to decide)

#### Type selection

| Type | When to use |
|------|-------------|
| `feat` | A whole new feature, capability, or user-visible surface area |
| `fix` | A bug fix that restores intended behavior |
| `refactor` | Restructures code without changing external behavior |
| `chore` | Tooling, config, dependencies, scaffolding |
| `docs` | Documentation only |
| `test` | Tests only |
| `style` | Formatting, whitespace, no logic change |
| `perf` | Performance improvement |
| `build` | Build system, bundler, package manifest |
| `ci` | CI pipeline / GitHub Actions |

**Default to the most conservative type that fits.** If a change is a small enhancement to an existing feature, prefer `refactor` or even `chore` over `feat`. Reserve `feat` for genuinely new capability.

### Step 5 — Author the commit

Use a HEREDOC for the message to preserve formatting. Inject the correct author/committer via `-c` flags so the local repo's git config is not modified:

```
git -c user.name='zeriong' -c user.email='jaeryong95@gmail.com' \
  commit \
  --author='zeriong <jaeryong95@gmail.com>' \
  -m "$(cat <<'EOF'
<header>

<body line 1>
<body line 2>
...
EOF
)"
```

The `--author=` flag sets the **author** explicitly; the `-c user.email/-c user.name` flags set the **committer**. Both must be `jaeryong95@gmail.com` / `zeriong` for this skill.

### Step 6 — Verify and report

After the commit succeeds:

```
git log -1 --pretty=full
```

Confirm to the user:
- The commit hash (short)
- Author + committer (both must show `jaeryong95@gmail.com`)
- Header line
- Did any hook run? Did it pass?

If a hook **failed**, the commit did NOT happen. Do not amend. Read the hook output, fix the underlying issue, re-stage, and create a **new** commit. Tell the user what failed and what you fixed.

### Step 7 — Push

Only after Step 6 confirms the commit succeeded. Skip this step entirely if the user said "commit only" / "푸시하지 마" / "push는 나중에".

1. Check the upstream:
   ```
   git rev-parse --abbrev-ref --symbolic-full-name @{upstream}
   ```
2. If an upstream exists:
   ```
   git push
   ```
3. If no upstream exists, set it on first push:
   ```
   git push -u origin <current-branch>
   ```
4. If the push is **rejected** (non-fast-forward), the remote has commits you don't have locally. Do NOT force-push and do NOT auto-rebase. Run `git fetch` and report the divergence to the user — pulling/rebasing is their call.

After a successful push, report the remote branch and the pushed commit range (e.g. `origin/main: a1b2c3d..e4f5g6h`).

---

## Boundaries

### What this skill does
- Detects project commit rules and conforms to them
- Composes a header + body in the resolved style
- Stages-checks (refuses to silently `git add -A`)
- Runs `git commit` with the correct author / committer
- Pushes to the remote after a verified commit (sets upstream with `-u origin <branch>` on first push)
- Reports the result

### What this skill does NOT do
- **Force-push.** No `--force`, no `--force-with-lease`. A rejected push is reported, never overridden.
- **Auto-rebase / auto-pull.** When local and remote diverge, fetch and report — integrating is the user's call.
- **Amend.** Always a new commit. Hook failure → fix → new commit.
- **Bypass hooks.** No `--no-verify`. Ever.
- **Stage on its own.** Asks before staging when nothing is staged.
- **Touch persistent git config.** Use `-c` flags for one-shot identity injection.
- **Attribute to Claude.** Zero exceptions. No `Co-Authored-By: Claude`, no robot emoji, no "Generated with".

---

## Edge cases

### Empty diff
If nothing is staged AND nothing is modified, refuse:
```
Nothing to commit (working tree clean).
```

### Pre-commit hook modifies files
Some hooks (formatters, linters with --fix) modify files during commit, which aborts the commit. When this happens:
1. The hook output usually says which files were modified
2. Stage the modifications: `git add <files>`
3. Re-run `git commit` with the same message
4. Do NOT amend

### Mixed-language repo
If recent history shows both English and Korean commits, default header to English (lint configs usually require it) and match the body to whichever language was used in the last commit by the same author.

### Repo-local user.email is already correct
If `git config user.email` already returns `jaeryong95@gmail.com`, the `-c` flags are redundant but harmless. Use them anyway — it's defense in depth against a misconfigured global config.

### Secrets in staged files
If `git diff --staged` shows files like `.env`, `*.pem`, `id_rsa`, or strings matching `SECRET=`, `API_KEY=`, `password=`: STOP. Warn the user explicitly with the file path and the suspect line. Wait for their confirmation before continuing.

### Type ambiguity
When the change could plausibly be two types (e.g. a refactor that also fixes a bug), pick the **higher-impact** one (`fix` > `refactor`, `feat` > `refactor`). If genuinely 50/50, ask the user.

### No remote configured
If `git remote` returns nothing, the commit is complete but there is nowhere to push. Report:
```
Committed <hash>. No remote configured — skipped push.
```

### Push rejected (non-fast-forward)
The remote moved ahead of local. Do NOT force-push, do NOT auto-rebase. Run `git fetch`, then show the user how far the branches diverged (`git log --oneline HEAD..origin/<branch>`) and let them decide how to integrate. The local commit is safe either way.

### pre-push hook fails
Same policy as commit hooks: the failure is information. Read the output, report it to the user, and fix the cause if it's fixable (e.g. a failing test the change introduced). Never `--no-verify`.

---

## Notes for Claude when this skill loads

- This skill is for **the user's personal use** — author identity is non-negotiable.
- The `--author` flag and `-c user.email/-c user.name` flags must always be present on the `git commit` invocation, even if the repo's local config already matches. Defense in depth.
- Hook failures are **information**, not obstacles to bypass. Read the output, fix the cause, recommit.
- When `git config user.email` returns something else (e.g. a work email in a work repo), you are NOT changing the persistent config — you are only injecting identity for this one commit via `-c`. This is the correct behavior.
- Format the message body to focus on *why*, not *what*. The diff already shows the *what*; the body's job is the *why* and the surrounding context a future reader needs.
- Push is part of the default flow, but it is **fast-forward only**. Any push that would require rewriting remote history is out of scope — report and stop.
