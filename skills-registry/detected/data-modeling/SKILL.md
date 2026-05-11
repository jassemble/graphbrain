---
name: data-modeling
description: Database schema design and Prisma conventions.
license: MIT
metadata:
  author: graphbrain
  version: "1.0"
  phase: design
  pattern: Tool Wrapper
paths:
  - "**/prisma/**"
  - "**/*.prisma"
  - "**/migrations/**"
trigger_phrases:
  - "prisma"
  - "database schema"
  - "migration"
  - "data model"
  - "relations"
related_skills:
  - "sdlc-design"
  - "sdlc-implementation"
---

# Data Modeling

## When to Use
- Designing or modifying database schemas
- Creating migrations
- Working with Prisma or other ORMs

## Instructions
1. MUST create migration for every schema change
2. MUST document relationship cardinality
3. SHOULD use explicit relation names in Prisma
4. SHOULD add indexes for frequently queried fields
5. Load `references/prisma-conventions.md` for project patterns

## References
- `references/prisma-conventions.md` — Prisma best practices
