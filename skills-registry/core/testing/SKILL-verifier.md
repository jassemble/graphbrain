---
name: sdlc-testing-verifier
description: Verify test coverage, data quality, and no flaky tests.
metadata:
  phase: testing
  pattern: Reviewer
---

# Testing Verifier

## Rubric

| Check | Criterion | Severity |
|-------|-----------|----------|
| Test plan exists | Unit, integration, E2E scopes defined | ERROR |
| Behavior tested | Tests verify behavior, not implementation details | ERROR |
| Edge cases covered | Null, empty, boundary, error cases tested | ERROR |
| Realistic data | Test data matches production shapes (not `{foo: 'bar'}`) | WARNING |
| No flaky tests | All tests pass 3 consecutive runs | WARNING |
| Error paths tested | Network failure, invalid input, timeout cases covered | WARNING |
| Tests are independent | No shared mutable state between tests | WARNING |
| Coverage threshold met | Meets project-defined coverage target | INFO |
| Anti-demo-trap check | Tests fail when feature is broken (not just pass when it works) | INFO |

## Anti-Demo-Trap Verification
For each test, confirm:
1. Remove/break the feature implementation
2. The test actually fails
3. The failure message is descriptive

## Output Format
```
Summary → Findings (by severity) → Score → Top 3 Recommendations
```
