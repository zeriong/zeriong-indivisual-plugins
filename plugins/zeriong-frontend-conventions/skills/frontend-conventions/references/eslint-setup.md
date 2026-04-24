# ESLint 자동화 설정 가이드

## 3단계 자동화 모델

### 1단계: 자동 검증 (ESLint 기본/플러그인)

즉시 적용 가능한 규칙:

```js
// .eslintrc.js
module.exports = {
  rules: {
    // 규칙 1: 네이밍
    '@typescript-eslint/naming-convention': ['error', /* ... */],

    // 규칙 3: 파일 270줄 제한
    'max-lines': ['error', {
      max: 270,
      skipBlankLines: true,
      skipComments: true,
    }],

    // 규칙 6: JSDoc 태그 제한
    'jsdoc/check-tag-names': ['error', {
      definedTags: ['param', 'returns', 'deprecated'],
    }],
  },
};
```

### 2단계: 부분 자동화 (커스텀 룰)

팀 리뷰에서 반복되는 코멘트를 룰로 전환:

- 파일당 export 개수 제한
- 컴포넌트 내부 함수 길이 제한
- `useState` 과다 사용 감지 (5개 이상 경고)
- default export + named export 혼재 제한

### 3단계: 강제성 확보

```json
// package.json
{
  "scripts": {
    "lint": "eslint . --ext .ts,.tsx",
    "lint:fix": "eslint . --ext .ts,.tsx --fix"
  }
}
```

- Husky + lint-staged: 커밋 전 검증
- CI에서 lint 실패 시 머지 차단

## 권장 레포 구조 (ESLint 플러그인 모노레포)

```
your-org-lint-config/
├── packages/
│   ├── eslint-plugin-yourorg/          # 커스텀 룰
│   │   ├── lib/
│   │   │   ├── rules/
│   │   │   │   ├── naming-convention.js
│   │   │   │   ├── component-max-lines.js
│   │   │   │   ├── jsdoc-minimal.js
│   │   │   │   └── single-responsibility.js
│   │   │   └── index.js
│   │   └── package.json
│   ├── eslint-config-yourorg/          # 프리셋
│   │   ├── index.js
│   │   ├── react.js
│   │   └── package.json
│   └── prettier-config-yourorg/        # 포맷팅
│       └── package.json
├── docs/
│   ├── conventions.md
│   └── examples/
└── package.json                        # pnpm workspace root
```

## 배포 방식 (Private)

**권장 순서**: Git URL → 안정화 후 GitHub Packages

```json
{
  "devDependencies": {
    "eslint-plugin-yourorg": "git+ssh://git@github.com/org/repo.git#v1.0.0"
  }
}
```

## Prettier 충돌 해결

```js
// ESLint와 Prettier 충돌 방지
module.exports = {
  extends: [
    'eslint-config-yourorg',
    'prettier', // 반드시 마지막
  ],
};
```

## 주의 사항

- 커스텀 룰은 **false positive 최소화**가 우선
- 기존 코드 일괄 수정 지양, 신규 코드부터 점진 적용
- `eslint-disable` 남발 방지를 위해 오탐률 관리
