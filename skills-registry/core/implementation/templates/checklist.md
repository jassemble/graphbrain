# Implementation Checklist

## Before Starting
- [ ] Design doc or task spec read and understood
- [ ] Acceptance criteria are clear and boolean
- [ ] Relevant .ctx/modules/ and .ctx/entities/ pages reviewed
- [ ] Active skills checked for language/framework conventions

## During Implementation
- [ ] Failing test written BEFORE implementation code
- [ ] Minimum code written to pass (no gold-plating)
- [ ] Refactored after green (while tests stay green)
- [ ] One atomic commit per task

## Quality Gates
- [ ] All tests pass (including existing tests)
- [ ] Typecheck clean (no errors)
- [ ] Linter passes (no warnings)
- [ ] No hardcoded secrets or environment values
- [ ] Error handling covers all failure paths
- [ ] No `any` types or type-system escapes
