# zeriong-indivisual-plugins

Personal plugin marketplace for **Claude Code** and **Codex CLI**. One repository, one set of manifests — both tools install the same plugins from it.

For Korean: see [README.ko.md](./README.ko.md).

## Plugins

| Plugin | What it does | Components | Version |
|--------|--------------|------------|---------|
| [`indivisual-commit`](./plugins/indivisual-commit) | Writes a header + body commit message that follows the project's commit rules, commits as the identity you register on first use, and pushes. No AI attribution, no force-push. | 1 skill | 2.0.0 |
| [`zeriong-frontend-conventions`](./plugins/zeriong-frontend-conventions) | 19 frontend convention rules (React / TypeScript / Next.js) with a phase workflow: rules at phase start, automated edit checks, review before phase end. | 2 skills, 4 hooks | 2.0.0 |

## Install

### Claude Code

```
/plugin marketplace add zeriong/zeriong-indivisual-plugins
/plugin install indivisual-commit@zeriong-indivisual-plugins
/plugin install zeriong-frontend-conventions@zeriong-indivisual-plugins
```

Send each command as a separate prompt. The same commands work from a terminal as `claude plugin marketplace add …` / `claude plugin install …`.

Or declare it in `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "zeriong-indivisual-plugins": {
      "source": { "source": "github", "repo": "zeriong/zeriong-indivisual-plugins" }
    }
  },
  "enabledPlugins": {
    "indivisual-commit@zeriong-indivisual-plugins": true,
    "zeriong-frontend-conventions@zeriong-indivisual-plugins": true
  }
}
```

### Codex

```bash
codex plugin marketplace add zeriong/zeriong-indivisual-plugins
codex plugin add indivisual-commit@zeriong-indivisual-plugins
codex plugin add zeriong-frontend-conventions@zeriong-indivisual-plugins
```

Then run `codex`, open `/hooks`, review and trust the frontend-conventions hooks, and start a new thread. Codex does not run plugin hooks until they are trusted; skills work right away.

### Update / remove

| | Claude Code | Codex |
|---|---|---|
| Refresh the marketplace | `claude plugin marketplace update zeriong-indivisual-plugins` | `codex plugin marketplace upgrade zeriong-indivisual-plugins` |
| Update a plugin | `claude plugin update <plugin>@zeriong-indivisual-plugins` | `codex plugin add <plugin>@zeriong-indivisual-plugins` after the refresh |
| Remove a plugin | `claude plugin uninstall <plugin>@zeriong-indivisual-plugins` | `codex plugin remove <plugin>@zeriong-indivisual-plugins` |
| Remove the marketplace | `claude plugin marketplace remove zeriong-indivisual-plugins` | `codex plugin marketplace remove zeriong-indivisual-plugins` |

## Using the skills

Plugin skills are namespaced by plugin. They also trigger from natural language (e.g. "커밋해줘", "commit and push").

| Skill | Claude Code | Codex |
|-------|-------------|-------|
| indivisual-commit | `/indivisual-commit:indivisual-commit` | `$indivisual-commit:indivisual-commit` |
| frontend-conventions | `/zeriong-frontend-conventions:frontend-conventions` | `$zeriong-frontend-conventions:frontend-conventions` |
| convention-review | `/zeriong-frontend-conventions:convention-review` | `$zeriong-frontend-conventions:convention-review` |

## How one repo serves both tools

- **Manifests** — `.claude-plugin/marketplace.json` and each `plugins/<name>/.claude-plugin/plugin.json`. Codex reads this layout through its Claude-compatible marketplace support, so there is no second set of manifests to keep in sync.
- **Skills** — `plugins/<name>/skills/<skill>/SKILL.md`, the same format on both tools. Skill text is written host-neutral; where the tools differ (question tool, sandbox approvals) the skill says so inline.
- **Hooks** — one `hooks/hooks.json` per plugin. Both tools expose the plugin root as `CLAUDE_PLUGIN_ROOT`, accept the same `hookSpecificOutput.additionalContext` / `decision: "block"` output, and the edit-check hook reads both Claude Code's `file_path` and Codex's `apply_patch` input.

## Repository layout

```
.claude-plugin/
  marketplace.json               # marketplace catalog (Claude Code + Codex)
plugins/
  indivisual-commit/
    .claude-plugin/plugin.json
    skills/indivisual-commit/SKILL.md
  zeriong-frontend-conventions/
    .claude-plugin/plugin.json
    hooks/hooks.json
    hooks/scripts/*.sh           # bash + git + jq
    skills/frontend-conventions/SKILL.md
    skills/frontend-conventions/references/*.md
    skills/convention-review/SKILL.md
```

## Maintaining

When releasing a plugin change, bump the version in every place it appears:

1. `.claude-plugin/marketplace.json` → the plugin's `version`
2. `plugins/<name>/.claude-plugin/plugin.json` → `version`
3. `version:` in the plugin's `SKILL.md` frontmatter, where present

Then validate:

```bash
claude plugin validate .
claude plugin validate plugins/<name>
```

## Language policy

- Files the model reads — every `SKILL.md`, `references/*.md`, and hook payload — are written in **English**, the model's working language, to keep instructions unambiguous.
- Each plugin and the marketplace ship an English `README.md` (canonical) and a Korean `README.ko.md` for human readers.
