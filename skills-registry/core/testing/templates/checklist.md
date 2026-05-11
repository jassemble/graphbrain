# Testing Checklist

## Test Plan
- [ ] Unit test scope defined (which functions/components)
- [ ] Integration test scope defined (which boundaries)
- [ ] Edge cases identified (null, empty, boundary, concurrent)
- [ ] Error paths covered (network failure, invalid input, timeout)

## Test Quality
- [ ] Tests are independent (no shared mutable state)
- [ ] Tests use realistic data (not `{ foo: 'bar' }`)
- [ ] Test names describe behavior, not implementation
- [ ] Tests fail when feature is broken (not just pass when it works)
- [ ] No flaky tests (run 3x to confirm)

## Coverage
- [ ] Critical paths covered (auth, payments, data)
- [ ] Error paths tested (not just happy path)
- [ ] Edge cases tested (null, empty, boundary)
- [ ] Coverage meets project threshold
