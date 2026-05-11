---
name: sdlc-design-verifier
description: Verify architecture docs map to requirements and document tradeoffs.
metadata:
  phase: design
  pattern: Reviewer
---

# Design Verifier

## Rubric

| Check | Criterion | Severity |
|-------|-----------|----------|
| Requirements mapped | All PRD requirements traced to design components | ERROR |
| ADRs for decisions | ADR created for each decision with >=2 options | ERROR |
| Tradeoffs documented | Pros/cons listed for each architectural choice | WARNING |
| No premature optimization | No performance design without performance requirement | WARNING |
| Prior decisions checked | .ctx/decisions/ reviewed for conflicts | WARNING |
| API contracts defined | Request/response shapes specified for all endpoints | WARNING |
| Error strategy documented | Failure propagation and recovery described | WARNING |
| Component boundaries clear | Module responsibilities don't overlap | INFO |
| Security considered | Auth, data access, and input validation addressed | INFO |

## Output Format
```
Summary → Findings (by severity) → Score → Top 3 Recommendations
```
