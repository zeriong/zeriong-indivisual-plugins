#!/usr/bin/env bash
# 매 프롬프트마다 워크플로우 리마인더 주입

cat << 'EOF'
{
  "systemMessage": "[Convention Workflow] Phase 시작 시 /frontend-conventions 실행 → 컨벤션 준수하며 작업 → Phase 종료 전 /convention-review 실행. 이 프로토콜을 매 task, 매 phase마다 반드시 준수하세요."
}
EOF

exit 0
