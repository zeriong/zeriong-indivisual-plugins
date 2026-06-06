# zeriong-claude-plugins

Personal Claude Code plugin marketplace.

For Korean: see [README.ko.md](./README.ko.md).

## Plugins

| Plugin | Purpose | Version |
|--------|---------|---------|
| `zeriong-frontend-conventions` | Frontend code convention enforcement + workflow protocol | 1.0.0 |
| `zeriong-better-looper` | `/loop` wrapper that drives a goal through N progressive cycles | 1.0.0 |
| `zeriong-create-harness` | Meta-skill that builds a project-tailored harness from fact-based analysis | 1.0.0 |

## Install

1. In Claude Code, run `/plugin`.
2. Marketplaces → Add Marketplace.
3. Enter URL: `https://github.com/zeriong/zeriong-claude-plugins.git`.
4. Install the plugins you want.

Or add to `~/.claude/settings.json` directly:

```json
{
  "extraKnownMarketplaces": {
    "zeriong-plugins": {
      "source": {
        "source": "git",
        "url": "https://github.com/zeriong/zeriong-claude-plugins.git"
      }
    }
  }
}
```

## Language policy

- Files that Claude consumes directly — every `SKILL.md` and `references/*.md` — are authored in **English**. This avoids tokenization overhead and keeps instructions unambiguous in the model's working language.
- Each plugin and the marketplace itself ship a Korean `README.ko.md` alongside the English `README.md`. The Korean version is for human readers; the English version is the canonical one.
- Hook scripts (`hooks/scripts/*.sh`) emit English `systemMessage` payloads for the same reason.
