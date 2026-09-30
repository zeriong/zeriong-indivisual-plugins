# zeriong-indivisual-plugins

**Claude Code**와 **Codex CLI**에서 함께 쓰는 개인용 플러그인 마켓플레이스입니다. 레포 하나, manifest 한 벌로 두 도구가 같은 플러그인을 설치합니다.

영문: [README.md](./README.md) 참조.

## 플러그인

| 플러그인 | 설명 | 구성 | 버전 |
|----------|------|------|------|
| [`indivisual-commit`](./plugins/indivisual-commit) | 프로젝트 커밋 룰에 맞춰 header + body 메시지를 작성하고, 처음 사용할 때 등록한 신원으로 커밋한 뒤 push합니다. AI attribution과 force-push는 하지 않습니다. | 스킬 1 | 2.0.0 |
| [`zeriong-frontend-conventions`](./plugins/zeriong-frontend-conventions) | React / TypeScript / Next.js용 19가지 프론트엔드 컨벤션과 phase 워크플로우입니다. phase 시작 시 규칙을 로드하고, 편집을 자동 검사하고, phase 종료 전에 리뷰합니다. | 스킬 2, 훅 4 | 2.0.0 |

## 설치

### Claude Code

```
/plugin marketplace add zeriong/zeriong-indivisual-plugins
/plugin install indivisual-commit@zeriong-indivisual-plugins
/plugin install zeriong-frontend-conventions@zeriong-indivisual-plugins
```

명령은 프롬프트 하나에 하나씩 보내세요. 터미널에서는 `claude plugin marketplace add …` / `claude plugin install …`로 같은 작업을 할 수 있습니다.

`~/.claude/settings.json`에 직접 선언해도 됩니다.

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

설치 후 `codex`를 실행해 `/hooks`를 열고, frontend-conventions 훅을 검토·trust한 다음 새 스레드를 시작하세요. Codex는 trust하기 전까지 플러그인 훅을 실행하지 않습니다. 스킬은 바로 쓸 수 있습니다.

### 업데이트 / 제거

| | Claude Code | Codex |
|---|---|---|
| 마켓플레이스 갱신 | `claude plugin marketplace update zeriong-indivisual-plugins` | `codex plugin marketplace upgrade zeriong-indivisual-plugins` |
| 플러그인 업데이트 | `claude plugin update <plugin>@zeriong-indivisual-plugins` | 갱신 후 `codex plugin add <plugin>@zeriong-indivisual-plugins` |
| 플러그인 제거 | `claude plugin uninstall <plugin>@zeriong-indivisual-plugins` | `codex plugin remove <plugin>@zeriong-indivisual-plugins` |
| 마켓플레이스 제거 | `claude plugin marketplace remove zeriong-indivisual-plugins` | `codex plugin marketplace remove zeriong-indivisual-plugins` |

## 스킬 호출

플러그인 스킬 이름에는 플러그인 이름이 앞에 붙습니다. 자연어로도 트리거됩니다(예: "커밋해줘", "commit and push").

| 스킬 | Claude Code | Codex |
|------|-------------|-------|
| indivisual-commit | `/indivisual-commit:indivisual-commit` | `$indivisual-commit:indivisual-commit` |
| frontend-conventions | `/zeriong-frontend-conventions:frontend-conventions` | `$zeriong-frontend-conventions:frontend-conventions` |
| convention-review | `/zeriong-frontend-conventions:convention-review` | `$zeriong-frontend-conventions:convention-review` |

## 레포 하나로 두 도구를 지원하는 방식

- **Manifest** — `.claude-plugin/marketplace.json`과 각 `plugins/<name>/.claude-plugin/plugin.json`만 둡니다. Codex는 Claude 호환 마켓플레이스 지원으로 이 구조를 그대로 읽기 때문에, 따로 맞춰야 할 두 번째 manifest가 없습니다.
- **스킬** — `plugins/<name>/skills/<skill>/SKILL.md`는 두 도구에서 같은 형식입니다. 스킬 본문은 특정 도구에 치우치지 않게 쓰고, 도구마다 다른 부분(질문 도구, sandbox 승인)은 본문에 따로 적어 두었습니다.
- **훅** — 플러그인마다 `hooks/hooks.json` 하나를 씁니다. 두 도구 모두 플러그인 경로를 `CLAUDE_PLUGIN_ROOT`로 넘겨주고, 같은 `hookSpecificOutput.additionalContext` / `decision: "block"` 출력을 받습니다. 편집 검사 훅은 Claude Code의 `file_path`와 Codex의 `apply_patch` 입력을 모두 읽습니다.

## 레포 구조

```
.claude-plugin/
  marketplace.json               # 마켓플레이스 카탈로그 (Claude Code + Codex)
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

## 유지보수

플러그인 변경을 배포할 때는 버전이 적힌 곳을 모두 올립니다.

1. `.claude-plugin/marketplace.json`의 해당 플러그인 `version`
2. `plugins/<name>/.claude-plugin/plugin.json`의 `version`
3. 플러그인 `SKILL.md` frontmatter의 `version:` (있는 경우)

그다음 검증합니다.

```bash
claude plugin validate .
claude plugin validate plugins/<name>
```

## 언어 정책

- 모델이 읽는 파일(`SKILL.md`, `references/*.md`, 훅 payload)은 지시가 모호하지 않도록 모델의 작업 언어인 **영어**로 씁니다.
- 각 플러그인과 마켓플레이스에는 영문 `README.md`(기준본)와 사람이 읽기 위한 한국어 `README.ko.md`가 함께 있습니다.
