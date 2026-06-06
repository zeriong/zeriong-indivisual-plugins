#!/usr/bin/env bash
# Inject the full convention summary + workflow protocol at session start.

cat << 'EOF'
{
  "additionalContext": "## [Frontend Convention Plugin] Conventions + Workflow Protocol\n\n### Workflow Protocol (mandatory)\nFor every Phase of every Task, follow this flow:\n1. Phase start  →  invoke /frontend-conventions skill (load rules).\n2. Do the work, applying the rules live.\n3. Before Phase end  →  invoke /convention-review skill (audit).\n   - On FAIL: fix and re-audit. Only end the phase on PASS.\n\n### Core Conventions (11)\n1. Naming: no subjective adjectives (Smart*, Cool*, Nice*, Awesome*). Use intuitive, universal names.\n2. SRP: a module / function / component has exactly one responsibility.\n3. 270-line cap: component files stay under 270 non-blank, non-comment lines.\n4. Component decomposition: split aggressively along inferred units.\n5. Layer separation: UI / Logic (custom hooks) / Data (API) / State (store) are kept distinct.\n6. JSDoc: only @param, @returns, @deprecated are allowed; reject all other tags.\n7. Comments: terse bullet style, essentials only, max 2 lines.\n8. Defensive programming with DX balance: when behavior is equivalent, the more readable form wins.\n9. Declarative JSX conditionals: simple branch -> absorb into ternary in return; guard clause / nested / divergent markup -> keep if. Use `? <X /> : null` (`&&` risks falsy renders).\n10. Honor existing formatter/linter config: check prettier / eslint / biome configs and write code that matches them.\n11. View-Logic vs Business-Logic split: components render only; business logic lives in custom hooks. Placement follows the project's structure (vanilla React -> hooks/, FSD -> model/, encapsulated -> file-adjacent).\n\nFor full rule text, invoke the /frontend-conventions skill."
}
EOF

exit 0
