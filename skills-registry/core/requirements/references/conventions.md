# Requirements Conventions

## PRD Structure
- Title as H1 with feature name
- Problem statement: 1 paragraph, max 3 sentences — who, what, why
- Success metrics: numeric thresholds only (no "improve" or "better")
- User stories: As a [role], I want [action], so that [outcome]
- Acceptance criteria: checkbox format, machine-verifiable boolean only
- Out of scope: explicit exclusions to prevent scope creep
- Dependencies: list blockers with owners and timelines

## Acceptance Criteria Rules
1. Every criterion is boolean (pass/fail) — no subjective language
2. Every criterion can be tested by running a command or checking a condition
3. Bad: "Works correctly" / Good: "Run `npm test` — exits code 0"
4. Bad: "Fast enough" / Good: "LCP < 2.5s measured by Lighthouse"
5. Bad: "Handles errors" / Good: "POST /api returns 400 with `{ error: string }` on invalid input"
6. Include error paths, not just happy path
7. Specify exact HTTP status codes, error formats, timeouts

## Sizing
- If a PRD has > 10 acceptance criteria, split into sub-features
- Each sub-feature should be completable in 1-3 days
- If you can't define acceptance criteria, the requirement isn't ready

## Priority Levels
- P0: Blocks launch — must pass before release
- P1: Important — should pass, documented workaround if not
- P2: Nice to have — can ship without

## Self-Clarification (Inversion Pattern)
Before generating any PRD, ask and answer these 5 questions:
1. What specific problem does this solve? (not "improve X")
2. Who are the users and what's their current workflow?
3. What does success look like? (numeric, measurable)
4. What are the constraints? (time, tech, scope, budget)
5. What is explicitly out of scope?
