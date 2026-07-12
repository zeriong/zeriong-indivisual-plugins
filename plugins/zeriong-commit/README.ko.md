# zeriong-commit

개인용 git 커밋 스킬 — header + body 형태의 커밋 메시지를 작성하고, 작성자(`jaeryong95@gmail.com`)를 강제 주입한 채 `git commit`을 실행한 뒤 remote로 push까지 수행합니다. Claude attribution은 모든 경로에서 차단됩니다.

영문: [README.md](./README.md) 참조.

## 제공 기능

| 스킬 | 역할 | 호출 |
|------|------|------|
| `zeriong-commit` | 프로젝트 커밋 룰을 탐지하고, 해석된 스타일로 header + body를 작성한 뒤 `jaeryong95@gmail.com` 명의로 `git commit` 실행 후 remote로 push | `/zeriong-commit` |

## 동작 방식

1. **프로젝트 룰 탐지** — `commitlint.config.*`, `.commitlintrc*`, `.husky/commit-msg`, `.pre-commit-config.yaml`, `CONTRIBUTING.md`, 그리고 최근 20개 커밋 subject를 순서대로 조사
2. **유효 룰셋 해석** — 우선순위 머지: 스킬 기본값 → 히스토리 패턴 → 문서 → 머신 강제 설정(뒤가 앞을 override). 작성 전에 사용자에게 한 줄로 출력
3. **Staged diff 읽기** — `git add -A`를 자동으로 하지 않음. staged 파일에 secret 패턴(`.env`, `*.pem`, `API_KEY=`)이 보이면 경고
4. **메시지 작성** — Conventional Commits 기본(`<type>(<scope>): <subject>`), header ≤ 50, body ≤ 72, body는 *왜*에 집중
5. **`git commit` 실행** — `-c user.name='zeriong' -c user.email='jaeryong95@gmail.com' --author='zeriong <jaeryong95@gmail.com>'` 사용. repo의 persistent git config는 절대 건드리지 않음
6. **검증 및 보고** — `git log -1` 출력으로 author + committer + header 확인 가능
7. **Push** — 커밋 검증 후 `git push` 실행 (최초 push 시 `-u origin <branch>`로 upstream 설정). fast-forward만 허용: reject되면 fetch 후 보고할 뿐 force하지 않음. 사용자가 commit-only를 요청하면 생략

## 절대 법령

1. Author와 committer는 **무조건** `jaeryong95@gmail.com`. `-c` flag로 매 invocation마다 주입되므로 work repo 설정을 건드리지 않음
2. **Claude attribution 완전 금지.** `Co-Authored-By: Claude`, 🤖 emoji, "Generated with Claude Code", Anthropic 언급 등 일체 금지
3. **프로젝트 룰 우선.** commitlint / husky / pre-commit이 강제하는 룰이 스킬 기본값과 충돌하면 프로젝트 룰 채택
4. **`--no-verify` 절대 금지.** Hook 실패는 사용자에게 보고하되 우회하지 않음
5. **`--amend` 절대 금지.** Hook 실패 후에도 new commit 생성. amend는 작업 손실 위험 존재
6. **Force-push 절대 금지.** `--force`, `--force-with-lease` 모두 금지. branch가 diverge하면 사용자에게 보고하며 remote history를 덮어쓰지 않음

## 기본 스타일 (프로젝트 룰이 없을 때만 적용)

- Format: Conventional Commits — `<type>(<선택 scope>): <subject>`
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `perf`, `build`, `ci`
- Header 길이: ≤ 50자
- Body 한 줄 길이: ≤ 72자 (Git/Linux kernel 관례)
- Header와 body 사이에 빈 줄 필수
- Subject 기본 언어: 영문 (Conventional Commits 관례 부합)
- Body 언어: repo의 기존 history에 맞춤

## 설치

이 플러그인은 [zeriong-claude-plugins](../../README.ko.md) 마켓플레이스의 일부입니다.

```
/plugin
→ Marketplaces → Add Marketplace
→ https://github.com/zeriong/zeriong-claude-plugins.git
→ zeriong-commit 설치
```

## 사용해야 할 때

- 작성자가 본인 identity로 lock되어야 하는 개인 repo
- 글로벌 `git config user.email`이 회사 메일로 잡힌 work + 개인 머신
- 메시지를 직접 타이핑하지 않고 빠르고 높은 품질로 커밋하고 싶을 때

## 건너뛰어도 될 때

- 페어 프로그래밍 / 팀 작업에서 실제 author가 본인이 아닌 경우
- 다른 identity로 attribute되어야 하는 repo
- 한 줄 cosmetic commit — 직접 메시지 치는 게 더 빠른 경우
