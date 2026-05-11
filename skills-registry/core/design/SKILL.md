---
name: sdlc-design
description: Generate architecture docs and ADRs from requirements.
license: MIT
metadata:
  author: graphbrain
  version: "1.0"
  phase: design
  pattern: Generator
paths:
  - "**/*.md"
  - "**/architecture/**"
trigger_phrases:
  - "design architecture"
  - "write an ADR"
  - "architecture decision"
  - "system design"
  - "API design"
  - "data model"
related_skills:
  - "sdlc-design-verifier"
  - "sdlc-requirements"
  - "sdlc-implementation"
---

# Design & Architecture

## When to Use
- Translating PRD requirements into technical architecture
- Making architectural decisions that need documentation
- Designing APIs, data models, or system boundaries

## Instructions
1. MUST ingest PRD before starting design
2. MUST create ADR for every decision with >=2 viable options
3. MUST document tradeoffs for each architectural choice
4. SHOULD reference existing patterns from .ctx/patterns.md
5. SHOULD check decisions.md for prior decisions in this domain

## Phase Pipeline
1. Ingest PRD and extract requirements
2. Generate architecture document using templates/architecture.md
3. Create ADRs per decision using templates/adr.md
4. Verify architecture covers all PRD requirements
5. Gate: all requirements mapped, tradeoffs documented

## Gate Conditions
- PRE: PRD exists with boolean ACs
- POST: architecture.md covers all requirements; ADRs for major decisions

## Templates
- `templates/architecture.md` — Context, decisions, tradeoffs
- `templates/adr.md` — Option A vs B, decision, consequences
- `templates/api-spec.md` — API specification

## References
- `references/architecture-patterns.md`
- `references/api-design.md`
- `references/data-modeling.md`

## Verifier Handoff
Run SKILL-verifier.md after architecture generation. MAX_ITERATIONS=3.

## Three-Tier Boundaries
| Always | Ask | Never |
|--------|-----|-------|
| Map all PRD requirements | Add performance requirements | Skip tradeoff documentation |
| Create ADRs for choices | Propose alternative architectures | Premature optimization |
| Reference prior decisions | Split into microservices | Ignore existing patterns |
