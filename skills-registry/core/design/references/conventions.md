# Design Conventions

## ADR Format (Architecture Decision Records)
```markdown
# ADR-NNNN: [Decision Title]
- Status: PROPOSED | ACCEPTED | SUPERSEDED
- Date: YYYY-MM-DD
- Context: Why this decision is needed (1-2 paragraphs)
- Decision: What was decided
- Alternatives:
  - Option A: [approach] — pros, cons
  - Option B: [approach] — pros, cons
- Consequences: What follows from this decision
```

## Architecture Document Structure
1. Context — what system/feature this covers
2. Requirements mapping — which PRD items this addresses
3. Component diagram — boxes and arrows (text description ok)
4. Data flow — how data moves through the system
5. API contracts — endpoint signatures, request/response shapes
6. Error handling strategy — how failures propagate
7. Non-functional requirements — performance, security, scalability

## Principles
- Prefer composition over inheritance
- Define clear interface contracts between modules before implementation
- Document the WHY, not just the WHAT — future readers need context
- Every architectural choice must reference 2+ alternatives considered
- Keep ADRs under 500 tokens — link to concepts/ for deep dives
- Validate design against requirements traceability matrix

## Anti-Patterns
- Premature optimization — don't design for scale before proving value
- Astronaut architecture — avoid abstractions without concrete use cases
- Undocumented decisions — if it's not in an ADR, it didn't happen
