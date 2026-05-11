---
name: sdlc-implementation-verifier
description: Verify implementation has tests, passes checks, and uses atomic commits.
metadata:
  phase: implementation
  pattern: Reviewer
---

# Implementation Verifier

## Rubric

| Check | Criterion | Severity |
|-------|-----------|----------|
| Tests exist | Test files cover all changed logic paths | ERROR |
| Tests pass | `npm test` (or equivalent) exits code 0 | ERROR |
| Typecheck clean | `npm run typecheck` (or equivalent) exits code 0 | ERROR |
| No type escapes | No `any`, `as unknown`, or equivalent | ERROR |
| Lint clean | No lint warnings or errors | WARNING |
| Atomic commits | One concern per commit, descriptive message | WARNING |
| No hardcoded secrets | No API keys, passwords, or tokens in source | WARNING |
| Error handling | All failure paths handled (no swallowed errors) | WARNING |
| Conventions followed | Matches patterns in .ctx/modules/ and active skills | INFO |
| Performance considered | No obvious N+1 queries or unbounded loops | INFO |

## Output Format
```
Summary → Findings (by severity) → Score → Top 3 Recommendations
```
