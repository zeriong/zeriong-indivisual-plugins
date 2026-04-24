#!/usr/bin/env bash
# 작업 종료 전 convention-review 실행 여부 확인 리마인더

cat << 'EOF'
{
  "systemMessage": "[Convention Review Gate] 이 phase의 작업을 종료하기 전에 /convention-review 스킬을 실행했는지 확인하세요. 프론트엔드 코드 변경이 있었다면 반드시 review를 실행하고 PASS를 받은 후에만 종료하세요. 실행하지 않았다면 지금 실행하세요."
}
EOF

exit 0
