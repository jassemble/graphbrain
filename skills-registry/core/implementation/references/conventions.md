# Implementation Conventions

## TDD Cycle (RED-GREEN-REFACTOR)
1. RED: Write a failing test that describes the desired behavior
2. GREEN: Write the minimum code to make the test pass
3. REFACTOR: Clean up while keeping tests green
4. Commit after each cycle — atomic, descriptive messages

## Commit Message Format
```
type(scope): description

- feat: new feature
- fix: bug fix
- refactor: code change that neither fixes a bug nor adds a feature
- test: adding or correcting tests
- docs: documentation only changes
```

## Code Quality Rules
- Functions: single responsibility, < 30 lines preferred
- Naming: descriptive, no abbreviations (except well-known: id, url, api)
- Comments: only for WHY, never for WHAT (code should be self-documenting)
- Error handling: never swallow errors silently; log or propagate
- No hardcoded secrets, URLs, or environment-specific values
- No `any` types (TypeScript) or equivalent type-system escapes

## File Organization
- One component/class per file
- Co-locate tests with source (file.ts → file.test.ts)
- Group by feature, not by type (avoid controllers/, models/, views/)
- Index files for public API only — no barrel exports of everything

## Security
- Validate all external input at system boundaries
- Parameterize all database queries (no string concatenation)
- Never log secrets, tokens, or PII
- Use principle of least privilege for all operations
