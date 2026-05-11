---
name: sdlc-requirements
description: Gather requirements and generate PRDs with boolean acceptance criteria.
license: MIT
metadata:
  author: codebrain
  version: "1.0"
  phase: requirements
  pattern: Generator
paths:
  - "**/*.md"
trigger_phrases:
  - "gather requirements"
  - "write a PRD"
  - "product requirements"
  - "define scope"
  - "acceptance criteria"
  - "user stories"
related_skills:
  - "sdlc-requirements-verifier"
  - "sdlc-design"
---

# Requirements & Discovery

## When to Use
- Starting a new feature or project from scratch
- Translating stakeholder needs into structured requirements
- Writing PRDs, user stories, or epics

## Instructions
1. MUST run self-clarification (5 questions) before generating any PRD
2. MUST include boolean acceptance criteria for every requirement
3. MUST identify stakeholders and their priorities
4. SHOULD include non-goals to bound scope
5. SHOULD reference existing decisions from .ctx/decisions.md

## Phase Pipeline
1. Self-clarify: ask 5 questions about scope, users, constraints, success metrics, risks
2. Generate PRD using templates/prd.md
3. Explode into 8-15 atomic tasks with boolean ACs
4. Verify: each task has clear input/output and testable criteria
5. Gate: all ACs are boolean, no ambiguous language

## Gate Conditions
- PRE: stakeholder input or feature request exists
- POST: PRD has goal, scope, non-goals; every requirement has boolean AC

## Templates
- `templates/prd.md` — PRD with self-clarification block
- `templates/user-story.md` — As a/I want/so that + AC
- `templates/epic.md` — Epic grouping

## References
- `references/elicitation.md` — Elicitation techniques
- `references/acceptance-criteria.md` — Writing good ACs
- `references/stakeholder-mapping.md` — Identifying stakeholders

## Verifier Handoff
Run SKILL-verifier.md after PRD generation. Fix-and-retry, MAX_ITERATIONS=3.

## Three-Tier Boundaries
| Always | Ask | Never |
|--------|-----|-------|
| Include boolean ACs | Add stretch goals | Ship without ACs |
| Self-clarify first | Change project scope | Skip stakeholder ID |
| Reference decisions.md | Merge overlapping PRDs | Use ambiguous language |
