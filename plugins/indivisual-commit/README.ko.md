# indivisual-commit

Claude Code와 Codex에서 쓰는 개인용 git 커밋 스킬입니다. header + body 형태의 커밋 메시지를 작성하고, 사용자가 등록한 신원으로 `git commit`을 실행한 뒤 remote로 push까지 합니다. AI attribution은 어떤 경로로도 들어가지 않습니다.

영문: [README.md](./README.md) 참조.

## 제공 기능

| 스킬 | 역할 | 호출 |
|------|------|------|
| `indivisual-commit` | 등록된 신원을 확인하고, 프로젝트 커밋 룰을 탐지해 header + body 메시지를 작성한 뒤 본인 명의로 `git commit` 후 push | Claude Code: `/indivisual-commit:indivisual-commit` · Codex: `$indivisual-commit:indivisual-commit` · 또는 "커밋해줘" / "commit and push" |

## 커밋 신원

계정을 하드코딩하지 않습니다. 처음 사용할 때 이렇게 동작합니다.

1. `git config --global user.name` / `user.email`을 읽어 기본값으로 제안합니다.
2. 그대로 쓸지, 다른 name/email을 입력할지 묻습니다. 값이 비어 있으면 반드시 입력받고, 추측해서 채우지 않습니다.
3. `~/.config/indivisual-commit/identity`에 저장합니다(`$XDG_CONFIG_HOME`이 설정돼 있으면 그 경로를 씁니다). git-config 형식이고, Claude Code와 Codex가 같은 파일을 씁니다.

이후 모든 커밋은 repo-local이나 global git config와 상관없이 이 신원이 author와 committer로 들어갑니다. 바꾸고 싶으면 "커밋 계정 변경" / "change commit identity"라고 말하거나, 파일을 지워서 처음부터 다시 등록하면 됩니다.

```
# 직접 확인·수정
git config --file ~/.config/indivisual-commit/identity --list
```

## 동작 방식

0. **신원 확인** — 신원 파일을 읽고, name이나 email이 없으면 위의 최초 등록 절차를 진행합니다. 둘 다 있어야 커밋합니다.
1. **프로젝트 룰 탐지** — `commitlint.config.*`, `.commitlintrc*`, `.husky/commit-msg`, `.pre-commit-config.yaml`, `CONTRIBUTING.md`, 최근 20개 커밋 subject 순으로 조사합니다.
2. **유효 룰셋 해석** — 스킬 기본값 → 히스토리 패턴 → 문서 → 머신 강제 설정 순으로 머지합니다(뒤가 앞을 override). 작성 전에 사용자에게 한 줄로 보여줍니다.
3. **Staged diff 읽기** — `git add -A`를 알아서 하지 않습니다. staged 파일에 secret 패턴(`.env`, `*.pem`, `API_KEY=`)이 보이면 경고합니다.
4. **메시지 작성** — 기본은 Conventional Commits(`<type>(<scope>): <subject>`)이고 header ≤ 50, body ≤ 72입니다. body는 *무엇*보다 *왜*에 집중합니다.
5. **`git commit` 실행** — 신원 파일의 값으로 `GIT_AUTHOR_NAME/EMAIL`, `GIT_COMMITTER_NAME/EMAIL`을 지정하고 `--author`도 붙입니다. 환경변수는 repo/global config와 셸에 남아 있던 `GIT_*` 값보다 우선합니다. git config는 전혀 수정하지 않습니다.
6. **검증 및 보고** — 새 커밋의 hash, author, committer, header를 보여줍니다.
7. **Push** — 커밋 검증 후 `git push`합니다(최초 push면 `-u origin <branch>`). fast-forward만 허용하고, reject되면 fetch 후 보고할 뿐 force하지 않습니다. commit-only를 요청하면 생략합니다.

## 절대 법령

1. Author와 committer는 **항상** 등록된 신원입니다. 커밋마다 주입하고 repo/global git config는 건드리지 않습니다.
2. **AI attribution 완전 금지.** Claude·Codex 등 어떤 AI의 `Co-Authored-By`도, 🤖 emoji도, "Generated with …"도, Anthropic/OpenAI 언급도 넣지 않습니다.
3. **프로젝트 룰 우선.** commitlint / husky / pre-commit이 강제하는 룰이 기본값과 충돌하면 프로젝트 룰을 따릅니다.
4. **`--no-verify` 금지.** Hook 실패는 보고하고 우회하지 않습니다.
5. **`--amend` 금지.** Hook이 실패해도 새 커밋을 만듭니다.
6. **Force-push 금지.** `--force`, `--force-with-lease` 모두 쓰지 않습니다.
7. **신원이 없으면 커밋하지 않습니다.**

## 기본 스타일 (프로젝트 룰이 없을 때만 적용)

- Format: Conventional Commits — `<type>(<선택 scope>): <subject>`
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `perf`, `build`, `ci`
- Header 길이: ≤ 50자
- Body 한 줄 길이: ≤ 72자 (Git/Linux kernel 관례)
- Header와 body 사이에 빈 줄 필수
- Subject 기본 언어: 영문 (Conventional Commits 관례)
- Body 언어: repo의 기존 history에 맞춤

## 호스트별 차이

| | Claude Code | Codex |
|---|---|---|
| 최초 등록 질문 | `AskUserQuestion` | 대화로 질문 |
| `~/.config/...` 쓰기 | 일반 파일 쓰기 | workspace 밖이라 sandbox가 승인을 요청할 수 있습니다. 승인할 수 없는 환경이면 직접 실행할 명령을 안내합니다 |
| `git push` | 일반 실행 | 기본 sandbox가 네트워크를 막습니다. push를 승인하거나 직접 실행하세요 |

## 설치

[zeriong-indivisual-plugins](../../README.ko.md) 마켓플레이스에 포함되어 있습니다.

```
# Claude Code
/plugin marketplace add zeriong/zeriong-indivisual-plugins
/plugin install indivisual-commit@zeriong-indivisual-plugins

# Codex
codex plugin marketplace add zeriong/zeriong-indivisual-plugins
codex plugin add indivisual-commit@zeriong-indivisual-plugins
```

## 사용해야 할 때

- 작성자가 본인 신원으로 고정돼야 하는 개인 repo
- repo나 global `git config user.email`이 다른 주소(회사 메일 등)로 잡혀 있는 머신
- 메시지를 직접 치지 않고 빠르게, 품질 있게 커밋하고 싶을 때

## 건너뛰어도 될 때

- 페어 프로그래밍이나 팀 작업에서 실제 author가 본인이 아닌 경우
- 한 줄짜리 cosmetic commit처럼 직접 메시지를 치는 편이 더 빠른 경우
