# 포매팅/린팅 도구 준수 상세 규칙

## 원칙

프로젝트에 설정된 포매팅/린팅 도구의 규칙을 **반드시** 준수합니다. 개인 스타일보다 프로젝트 설정이 우선입니다.

## 설정 파일 탐색

코드 작성/수정 전 프로젝트 루트에서 다음 설정 파일을 확인합니다:

### Prettier
- `.prettierrc`
- `.prettierrc.json` / `.prettierrc.yaml` / `.prettierrc.yml` / `.prettierrc.js` / `.prettierrc.cjs` / `.prettierrc.mjs`
- `prettier.config.js` / `prettier.config.cjs` / `prettier.config.mjs`
- `package.json`의 `"prettier"` 필드

### ESLint
- `.eslintrc` / `.eslintrc.js` / `.eslintrc.cjs` / `.eslintrc.json` / `.eslintrc.yml`
- `eslint.config.js` / `eslint.config.mjs` / `eslint.config.cjs` (flat config)

### Biome
- `biome.json`
- `biome.jsonc`

## 주요 확인 항목

| 항목 | 예시 값 | 확인 방법 |
|------|---------|-----------|
| 들여쓰기 | `tabWidth: 2`, `useTabs: false` | 설정 파일 또는 기존 코드 |
| 따옴표 | `singleQuote: true` | 설정 파일 |
| 세미콜론 | `semi: true` | 설정 파일 |
| Trailing comma | `trailingComma: 'all'` | 설정 파일 |
| 줄 너비 | `printWidth: 80` | 설정 파일 |
| 줄바꿈 | `endOfLine: 'lf'` | 설정 파일 |
| JSX 따옴표 | `jsxSingleQuote: false` | 설정 파일 |
| 괄호 스타일 | `arrowParens: 'always'` | 설정 파일 |

## 도구 간 우선순위

포매팅 규칙이 충돌할 경우:

1. **Biome** (포매팅 + 린팅 통합 도구)
2. **Prettier** (포매팅 전용)
3. **ESLint** (린팅 전용, 포매팅 규칙은 deprecated 추세)

## 설정 파일이 없는 경우

프로젝트에 포매팅/린팅 설정 파일이 없으면:
1. 기존 코드의 스타일을 분석하여 따름
2. 파일 내 일관성을 최우선으로 유지
3. 주변 파일(같은 디렉토리)의 스타일과 통일

## 적용 절차

1. **작업 시작 전**: 프로젝트 루트에서 설정 파일 존재 여부 확인
2. **설정 파일 읽기**: 해당 도구의 주요 규칙 파악
3. **코드 작성**: 파악한 규칙에 맞게 작성
4. **검증**: 작성한 코드가 설정과 일치하는지 확인

## 자주 틀리는 패턴

```tsx
// Prettier: singleQuote: true 인데
import { useState } from "react"  // Bad: 큰따옴표
import { useState } from 'react'  // Good: 작은따옴표

// Prettier: semi: false 인데
const name = 'hello';  // Bad: 세미콜론
const name = 'hello'   // Good: 세미콜론 없음

// Prettier: trailingComma: 'all' 인데
const obj = {
  a: 1,
  b: 2   // Bad: trailing comma 누락
}
const obj = {
  a: 1,
  b: 2,  // Good: trailing comma
}
```
