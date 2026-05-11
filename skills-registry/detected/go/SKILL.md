---
name: go
description: Go conventions, error handling, and project structure.
license: MIT
metadata:
  author: graphbrain
  version: "1.0"
  phase: implementation
  pattern: Tool Wrapper
paths:
  - "**/*.go"
trigger_phrases:
  - "golang"
  - "go module"
  - "goroutine"
  - "error handling go"
related_skills:
  - "sdlc-implementation"
  - "sdlc-testing"
---

# Go

## When to Use
- Writing or editing Go files
- Designing Go interfaces and error handling
- Working with concurrency patterns

## Instructions
1. MUST handle all errors explicitly (no _ for errors)
2. MUST follow Go naming conventions (exported = capitalized)
3. SHOULD use table-driven tests
4. SHOULD prefer composition over inheritance
5. Load `references/conventions.md` for project patterns

## References
- `references/conventions.md` — Go best practices
