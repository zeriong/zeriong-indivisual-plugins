# zeriong-claude-plugins

개인용 Claude Code 플러그인 마켓플레이스입니다.

## 플러그인 목록

| 플러그인 | 설명 | 버전 |
|----------|------|------|
| `zeriong-frontend-conventions` | 프론트엔드 코드 컨벤션 강제 + 워크플로우 프로토콜 | 1.0.0 |

## 설치 방법

1. Claude Code에서 `/plugin` 실행
2. Marketplaces → Add Marketplace
3. URL 입력: `https://github.com/zeriong/zeriong-claude-plugins.git`
4. 원하는 플러그인 설치

또는 `~/.claude/settings.json`에 직접 추가:

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
