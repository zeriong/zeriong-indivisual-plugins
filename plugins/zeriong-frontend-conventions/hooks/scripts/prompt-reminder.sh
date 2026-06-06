#!/usr/bin/env bash
# Re-inject the workflow reminder on every user prompt.

cat << 'EOF'
{
  "systemMessage": "[Convention Workflow] At phase start, invoke /frontend-conventions  →  do the work under those rules  →  before phase end, invoke /convention-review. Follow this protocol for every task and every phase."
}
EOF

exit 0
