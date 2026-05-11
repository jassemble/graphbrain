---
name: sdlc-maintenance
description: Fix bugs, improve performance, and manage technical debt.
license: MIT
metadata:
  author: graphbrain
  version: "1.0"
  phase: maintenance
  pattern: Generator + Compound Learning
paths:
  - "**/*"
trigger_phrases:
  - "fix bug"
  - "improve performance"
  - "technical debt"
  - "deprecate"
  - "postmortem"
  - "triage"
related_skills:
  - "sdlc-maintenance-verifier"
  - "sdlc-implementation"
  - "sdlc-testing"
---

# Maintenance & Iteration

## When to Use
- Fixing reported bugs
- Performance optimization
- Managing deprecation and technical debt
- Writing postmortems

## Instructions
1. MUST classify issue (bug, performance, debt, deprecation)
2. MUST investigate root cause before fixing
3. MUST write regression test for every bug fix
4. SHOULD check .ctx/log.md for related past issues
5. SHOULD update decisions.md if fix changes prior assumptions

## Phase Pipeline
1. Ingest: receive issue, classify type
2. Investigate: reproduce, read relevant code and brain pages
3. Fix via implementation pipeline (RED-GREEN-REFACTOR)
4. If new feature needed: route to Phase 1 (requirements)
5. Gate: regression test passes, postmortem written for P0/P1

## Gate Conditions
- PRE: issue exists with reproduction steps
- POST: fix verified, regression test added, postmortem if P0/P1

## Templates
- `templates/bug-report.md` — Structured bug report
- `templates/postmortem.md` — Incident analysis
- `templates/improvement-proposal.md` — Tech debt proposal

## References
- `references/triage-procedures.md`
- `references/deprecation-strategies.md`
- `references/changelog-conventions.md`

## Verifier Handoff
Run SKILL-verifier.md after fix. MAX_ITERATIONS=3.

## Three-Tier Boundaries
| Always | Ask | Never |
|--------|-----|-------|
| Investigate root cause | Expand fix scope | Ship without regression test |
| Write regression test | Refactor surrounding code | Ignore related failures |
| Update changelog | Archive old code | Delete without deprecation |
