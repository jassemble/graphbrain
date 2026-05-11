---
name: sdlc-maintenance-verifier
description: Verify bug fixes have regression tests and postmortems where needed.
metadata:
  phase: maintenance
  pattern: Reviewer
---

# Maintenance Verifier

## Rubric

| Check | Criterion | Severity |
|-------|-----------|----------|
| Root cause identified | 5 whys analysis completed, not just symptom | ERROR |
| Regression test added | Failing test demonstrates the bug, now passes | ERROR |
| Fix is minimal | Change addresses root cause only, no scope creep | WARNING |
| Postmortem written | P0/P1 incidents have timeline + root cause + prevention | WARNING |
| Changelog updated | Fix documented with issue reference | WARNING |
| Pattern checked | Same bug pattern searched for elsewhere in codebase | WARNING |
| Knowledge captured | .ctx/patterns.md or .ctx/modules/ updated if systemic | INFO |
| Decision updated | .ctx/decisions/ updated if fix changes an assumption | INFO |
| Related issues checked | Similar open issues reviewed for same root cause | INFO |

## Compound Learning Check
After every fix, verify at least one of:
- [ ] Pattern added to .ctx/patterns.md
- [ ] Module page updated in .ctx/modules/
- [ ] Lint rule or test added to prevent recurrence
- [ ] Decision recorded in .ctx/decisions/

## Output Format
```
Summary → Findings (by severity) → Score → Top 3 Recommendations
```
