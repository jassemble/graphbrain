# Test Plan: [Feature Name]

## Scope
What is being tested and what is explicitly NOT being tested.

## Strategy
| Level | What | Tool | Count |
|-------|------|------|-------|
| Unit | Individual functions/components | vitest/jest/pytest | ~N |
| Integration | Component interactions, DB queries | vitest/supertest | ~N |
| E2E | Full user workflows | playwright/cypress | ~N |

## Test Cases

### Unit Tests
- [ ] [function]: returns expected output for valid input
- [ ] [function]: throws/returns error for invalid input
- [ ] [function]: handles edge case (null, empty, boundary)

### Integration Tests
- [ ] [flow]: creates resource and persists to DB
- [ ] [flow]: returns 400 for invalid payload
- [ ] [flow]: handles concurrent requests

### Edge Cases
- [ ] Empty input
- [ ] Maximum length input
- [ ] Special characters / unicode
- [ ] Concurrent access
- [ ] Network timeout (if applicable)

## Exit Criteria
- All tests pass consistently (3 consecutive runs)
- Coverage meets threshold: [X]%
- No flaky tests
- Error paths covered (not just happy path)
