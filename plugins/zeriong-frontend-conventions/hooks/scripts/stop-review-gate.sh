#!/usr/bin/env bash
# Before turn end, remind Claude whether /convention-review was run.

cat << 'EOF'
{
  "systemMessage": "[Convention Review Gate] Before ending this phase, confirm /convention-review has been run. If frontend code changed in this phase, run the review and require a PASS before ending. If it was not run, run it now."
}
EOF

exit 0
