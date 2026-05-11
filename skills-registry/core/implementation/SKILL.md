---
name: sdlc-implementation
description: Implement features using TDD with atomic commits.
license: MIT
metadata:
  author: graphbrain
  version: "1.0"
  phase: implementation
  pattern: Generator + Pipeline (RED-GREEN-REFACTOR)
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rs"
trigger_phrases:
  - "implement feature"
  - "build component"
  - "write code"
  - "add functionality"
  - "fix bug"
  - "refactor"
related_skills:
  - "sdlc-implementation-verifier"
  - "sdlc-testing"
  - "sdlc-design"
---

# Implementation

## When to Use
- Building new features from design docs
- Fixing bugs with investigation-first approach
- Refactoring code with test safety net

## Instructions
1. MUST write failing test before implementation (RED)
2. MUST write minimum code to pass (GREEN)
3. MUST refactor after green (REFACTOR)
4. MUST create one commit per task (atomic)
5. SHOULD read relevant .ctx/modules/ and .ctx/entities/ pages first

## Phase Pipeline
1. RED: write failing test from acceptance criteria
2. Investigate: read relevant code, understand current behavior
3. GREEN: write minimum code to pass the test
4. REFACTOR: clean up while tests stay green
5. Quality gates: typecheck, lint, test suite
6. Commit: one atomic commit per task

## Gate Conditions
- PRE: design doc or task with boolean ACs exists
- POST: all tests pass, typecheck clean, lint clean

## Templates
- `templates/component.md` — Component scaffold
- `templates/api-handler.md` — API handler scaffold
- `templates/test-scaffold.md` — Test file scaffold

## References
- `references/coding-conventions.md`
- `references/error-handling.md`
- `references/security.md`

## Verifier Handoff
Run SKILL-verifier.md after implementation. MAX_ITERATIONS=3.

## Three-Tier Boundaries
| Always | Ask | Never |
|--------|-----|-------|
| Write tests first | Add unrelated improvements | Skip tests |
| Atomic commits | Refactor beyond task scope | Force push |
| Check existing patterns | Change public API | Ignore type errors |
