---
name: sdlc-testing
description: Generate test plans and implement comprehensive test suites.
license: MIT
metadata:
  author: codebrain
  version: "1.0"
  phase: testing
  pattern: Generator
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
  - "**/tests/**"
trigger_phrases:
  - "write tests"
  - "test coverage"
  - "test plan"
  - "add tests"
  - "integration test"
  - "e2e test"
related_skills:
  - "sdlc-testing-verifier"
  - "sdlc-implementation"
---

# Testing & Verification

## When to Use
- Writing test plans for new features
- Adding test coverage to existing code
- Setting up E2E or integration test suites

## Instructions
1. MUST self-clarify scope before writing tests
2. MUST cover unit, integration, and E2E scopes in test plan
3. MUST use production-like data, not hand-crafted fixtures
4. MUST cover edge cases, not just happy path
5. SHOULD use existing test patterns from the codebase

## Phase Pipeline
1. Self-clarify: what scope? what risk areas? what coverage target?
2. Generate test plan using templates/test-plan.md
3. Implement tests following given/when/then
4. Run suite and verify coverage
5. Gate: coverage meets threshold, no flaky tests

## Gate Conditions
- PRE: implementation exists with clear behavior
- POST: test plan covers all scopes; tests pass consistently

## Templates
- `templates/test-plan.md` — Scope, strategy, exit criteria
- `templates/test-case.md` — Given/when/then + AC

## References
- `references/test-taxonomy.md`
- `references/mocking-strategies.md`
- `references/test-data-patterns.md`

## Verifier Handoff
Run SKILL-verifier.md after test implementation. MAX_ITERATIONS=3.

## Three-Tier Boundaries
| Always | Ask | Never |
|--------|-----|-------|
| Cover edge cases | Increase coverage target | Ship flaky tests |
| Use realistic data | Add performance tests | Mock everything |
| Test error paths | Add browser automation | Skip integration tests |
