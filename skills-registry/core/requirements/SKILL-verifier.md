---
name: sdlc-requirements-verifier
description: Verify PRDs have complete acceptance criteria and no ambiguity.
metadata:
  phase: requirements
  pattern: Reviewer
---

# Requirements Verifier

## Rubric

| Check | Criterion | Severity |
|-------|-----------|----------|
| PRD has goal, scope, non-goals sections | All three sections present and non-empty | ERROR |
| Each requirement has boolean acceptance criteria | Every AC is machine-verifiable pass/fail | ERROR |
| No ambiguous language in ACs | No "should", "might", "could", "good", "proper" | ERROR |
| Stakeholders identified | At least one stakeholder role named | WARNING |
| Self-clarification answered | 5 questions answered or marked N/A | WARNING |
| Success metrics are numeric | No "improve" or "better" without threshold | WARNING |
| Error cases covered | At least one failure/edge case AC per feature | WARNING |
| Scope is bounded | Out of scope section non-empty | INFO |
| Dependencies listed | Blockers identified with owners | INFO |
| ACs follow standard format | Command/file/API/browser check pattern | INFO |

## Machine-Verifiable AC Patterns
```
Command:  "Run `[cmd]` — exits with code 0"
File:     "File `[path]` contains `[string]`"
API:      "POST `[url]` returns `[status]` with `[body]`"
Browser:  "Navigate to `[url]` — [element] is visible"
Console:  "No console errors on `[url]`"
```

## Output Format
```
Summary → Findings (by severity) → Score → Top 3 Recommendations
```
