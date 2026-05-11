# Maintenance Conventions

## Bug Triage Severity
- **P0 (Critical)**: System down, data loss, security breach → Fix immediately
- **P1 (High)**: Major feature broken, no workaround → Fix within 24h
- **P2 (Medium)**: Feature degraded, workaround exists → Fix within sprint
- **P3 (Low)**: Minor issue, cosmetic → Backlog

## Root Cause Analysis (5 Whys)
1. Why did the bug happen? → [immediate cause]
2. Why did [immediate cause] happen? → [deeper cause]
3. Why did [deeper cause] happen? → [systemic cause]
4. Why did [systemic cause] happen? → [process gap]
5. Why did [process gap] exist? → [root cause]

## Bug Fix Workflow
1. Reproduce the bug (write a failing test)
2. Investigate root cause (5 whys, not just symptom)
3. Fix the root cause (minimum change)
4. Verify fix (failing test now passes)
5. Check for same pattern elsewhere in codebase
6. Update .ctx/patterns.md if systemic pattern found
7. Write postmortem for P0/P1

## Compound Learning Ratchet
After every fix, ask:
- Is this a pattern? (If yes, add to .ctx/patterns.md)
- Does this change an assumption? (If yes, update .ctx/decisions/)
- Could this have been prevented? (If yes, add a lint rule or test)
- Does the module page need updating? (If yes, update .ctx/modules/)

## Technical Debt Tracking
- Log tech debt items with estimated effort
- Categorize: safety (must fix), improvement (should fix), cleanup (nice to have)
- Dedicate 20% of sprint capacity to debt reduction
- Never create new debt without logging it
