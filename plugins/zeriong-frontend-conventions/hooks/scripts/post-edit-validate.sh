#!/usr/bin/env bash
# 파일 편집 후 정량적 컨벤션 검증 (270줄 제한, 금지 네이밍)

set -euo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# 프론트엔드 파일만 대상
if [[ -z "$file_path" ]] || [[ ! "$file_path" =~ \.(tsx?|jsx?)$ ]]; then
  exit 0
fi

if [[ ! -f "$file_path" ]]; then
  exit 0
fi

warnings=""

# 270줄 제한 검증 (빈 줄, 주석 제외)
line_count=$(sed '/^\s*$/d; /^\s*\/\//d; /^\s*\*/d; /^\s*\/\*/d' "$file_path" | wc -l | tr -d ' ')
if [[ "$line_count" -gt 270 ]]; then
  warnings="${warnings}[Convention] ${file_path}: ${line_count}줄 (제한: 270줄). 컴포넌트 분리를 검토하세요.\n"
fi

# 금지 네이밍 검증 (주관적 형용사)
if grep -qE '(Smart|Cool|Nice|Awesome|Magic|Super|Ultra|Fancy)[A-Z]' "$file_path" 2>/dev/null; then
  warnings="${warnings}[Convention] ${file_path}: 주관적 형용사 네이밍 감지 (Smart*/Cool*/Nice* 등). 직관적인 이름으로 변경하세요.\n"
fi

# useState 과다 사용 검증 (5개 이상)
useState_count=$(grep -c 'useState' "$file_path" 2>/dev/null || echo "0")
if [[ "$useState_count" -ge 5 ]]; then
  warnings="${warnings}[Convention] ${file_path}: useState ${useState_count}개 사용. 커스텀 훅으로 분리를 검토하세요.\n"
fi

# && 연산자에 falsy 값 렌더링 위험 검증 (JSX 내 {count && , {length && 등)
if grep -qE '\{[a-zA-Z_]+(\.(length|count|size))?\s*&&' "$file_path" 2>/dev/null; then
  # 숫자 변수가 && 조건으로 사용되는 패턴 탐지
  if grep -qE '\{[a-zA-Z_]+\.(length|count|size)\s*&&' "$file_path" 2>/dev/null; then
    warnings="${warnings}[Convention] ${file_path}: JSX에서 && 연산자에 숫자 falsy 값 렌더링 위험 감지. '? <X /> : null' 패턴을 사용하세요.\n"
  fi
fi

# 포매팅/린팅 설정 파일 존재 여부 알림 (프로젝트 루트 탐색)
project_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -n "$project_root" ]]; then
  has_formatter=""
  for cfg in .prettierrc .prettierrc.js .prettierrc.json .prettierrc.yaml .prettierrc.yml prettier.config.js prettier.config.mjs biome.json biome.jsonc; do
    if [[ -f "${project_root}/${cfg}" ]]; then
      has_formatter="$cfg"
      break
    fi
  done
  if [[ -n "$has_formatter" ]]; then
    warnings="${warnings}[Convention] ${file_path}: 프로젝트에 포매팅 설정(${has_formatter})이 있습니다. 해당 규칙에 맞게 코드를 작성했는지 확인하세요.\n"
  fi
fi

if [[ -n "$warnings" ]]; then
  echo -e "$warnings" >&2
fi

exit 0
