---
name: python
description: Python conventions, typing, and project structure.
license: MIT
metadata:
  author: graphbrain
  version: "1.0"
  phase: implementation
  pattern: Tool Wrapper
paths:
  - "**/*.py"
trigger_phrases:
  - "python"
  - "pip"
  - "pytest"
  - "type hints"
  - "virtualenv"
related_skills:
  - "sdlc-implementation"
  - "sdlc-testing"
---

# Python

## When to Use
- Writing or editing Python files
- Setting up project structure or dependencies
- Working with type hints or testing

## Instructions
1. MUST use type hints for function signatures
2. MUST follow PEP 8 style
3. SHOULD use dataclasses or Pydantic for data models
4. SHOULD prefer pathlib over os.path
5. Load `references/conventions.md` for project patterns

## References
- `references/conventions.md` — Python best practices
