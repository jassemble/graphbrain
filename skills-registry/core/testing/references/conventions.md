# Testing Conventions

## Test Taxonomy
- **Unit**: Single function/component in isolation. Fast, many, independent.
- **Integration**: Multiple components working together. Database, API calls.
- **E2E**: Full user workflow. Browser, CLI, or API client.

## Test Structure (Arrange-Act-Assert)
```
describe('ComponentName', () => {
  it('should [expected behavior] when [condition]', () => {
    // Arrange: set up test data and dependencies
    // Act: execute the behavior under test
    // Assert: verify the expected outcome
  });
});
```

## Naming Convention
- Test name describes behavior, not implementation
- Bad: "test handleClick" / Good: "should submit form when button clicked"
- Bad: "test processData" / Good: "should return 400 when input is empty"

## Data Patterns
- Use factories or builders for test data (not hand-crafted objects)
- Keep test data minimal — only include fields relevant to the test
- Never share mutable state between tests
- Use realistic data shapes (not `{ foo: 'bar' }`)

## Anti-Patterns to Avoid
- Testing implementation details (private methods, internal state)
- Flaky tests (timing, network, order-dependent)
- Happy-path-only testing (always test error paths and edge cases)
- Over-mocking (mock boundaries, not internals)
- Test that only passes when feature works (must also fail when broken)

## Coverage Guidelines
- Aim for behavioral coverage, not line coverage
- Critical paths: 100% — auth, payments, data persistence
- Business logic: 80%+
- UI components: test interactions, not rendering details
