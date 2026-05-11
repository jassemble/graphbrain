---
name: typescript
description: TypeScript conventions and type safety patterns.
license: MIT
metadata:
  author: graphbrain
  version: "1.0"
  phase: implementation
  pattern: Tool Wrapper
paths:
  - "**/*.ts"
  - "**/*.tsx"
trigger_phrases:
  - "typescript"
  - "type error"
  - "interface"
  - "generic"
  - "type safety"
related_skills:
  - "sdlc-implementation"
---

# TypeScript

## When to Use
- Writing or editing TypeScript files
- Fixing type errors
- Designing type-safe interfaces

## Instructions
1. MUST prefer interfaces over type aliases for object shapes
2. MUST avoid `any` — use `unknown` and narrow
3. SHOULD use discriminated unions for state machines
4. SHOULD leverage inference, don't over-annotate
5. Load `references/conventions.md` for project patterns

## References
- `references/conventions.md` — TypeScript best practices
