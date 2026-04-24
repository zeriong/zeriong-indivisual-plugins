#!/usr/bin/env bash
# 세션 시작 시 전체 컨벤션 요약 + 워크플로우 프로토콜을 컨텍스트에 주입

cat << 'EOF'
{
  "additionalContext": "## [Frontend Convention Plugin] 컨벤션 + 워크플로우 프로토콜\n\n### 워크플로우 프로토콜 (필수)\n매 Task의 매 Phase마다 다음 흐름을 반드시 준수:\n1. Phase 시작 → /frontend-conventions 스킬 실행 (컨벤션 로드)\n2. 작업 진행 (컨벤션 준수)\n3. Phase 종료 전 → /convention-review 스킬 실행 (검토)\n   - FAIL 시 수정 후 재검토, PASS 시에만 phase 종료\n\n### 핵심 컨벤션 (10가지)\n1. 네이밍: 주관적 형용사 금지 (Smart*, Cool*, Nice*, Awesome*). 직관적이고 보편적인 이름 사용\n2. SRP: 하나의 모듈/함수/컴포넌트는 하나의 책임만\n3. 파일 270줄 제한: 컴포넌트 파일은 270줄 이하 (빈 줄/주석 제외)\n4. 컴포넌트 분리: 최대한 단위를 추론하여 분리\n5. 레이어 분리: UI / Logic(custom hooks) / Data(API) / State(store) 명확히 구분\n6. JSDoc: @param, @returns, @deprecated만 허용. 그 외 태그 차단\n7. 주석: 간단 명료한 개조식, 핵심만 서술, 2줄 이내 엄수\n8. 방어적 프로그래밍 + DX 균형: 결과가 같다면 가독성 좋은 코드 우선\n9. JSX 선언적 조건부 렌더링: 단순 분기→삼항으로 return 흡수, 가드 클로즈/중첩/마크업 상이→if 유지. ? <X /> : null 사용(&&는 falsy 위험)\n10. 포매팅/린팅 도구 준수: prettier/eslint/biome 설정 파일 확인 후 해당 규칙에 맞춰 코드 작성\n\n상세 규칙은 /frontend-conventions 스킬을 참조하세요."
}
EOF

exit 0
