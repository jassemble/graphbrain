---
name: react
description: React conventions, hooks rules, component patterns.
license: MIT
metadata:
  author: graphbrain
  version: "1.0"
  phase: implementation
  pattern: Tool Wrapper
paths:
  - "**/*.tsx"
  - "**/*.jsx"
trigger_phrases:
  - "react component"
  - "hooks"
  - "useState"
  - "useEffect"
  - "JSX"
  - "component pattern"
  - "state management"
related_skills:
  - "typescript"
  - "sdlc-implementation"
---

# React

## When to Use
- Editing or creating React components
- Working with hooks, state, or lifecycle
- Component architecture decisions

## Instructions
1. MUST follow React hooks rules (no conditional hooks)
2. MUST prefer function components over class components
3. SHOULD use existing component patterns from the codebase
4. SHOULD keep components under 200 lines
5. Load `references/conventions.md` for project-specific patterns

## References
- `references/conventions.md` — React best practices, hooks rules
- `references/patterns.md` — Component patterns, state management
