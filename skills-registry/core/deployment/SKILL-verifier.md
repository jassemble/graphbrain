---
name: sdlc-deployment-verifier
description: Verify deployment readiness, rollback plans, and secret management.
metadata:
  phase: deployment
  pattern: Reviewer
---

# Deployment Verifier

## Rubric

| Check | Criterion | Severity |
|-------|-----------|----------|
| Tests pass | All tests pass in CI before deploy | ERROR |
| Rollback documented | Rollback procedure exists with exact steps | ERROR |
| No secrets in code | No API keys, passwords, or tokens in source | ERROR |
| Version bumped | Semver version incremented appropriately | WARNING |
| CHANGELOG updated | User-facing changes documented | WARNING |
| Migrations reversible | Database migrations can be rolled back | WARNING |
| Monitoring configured | Alerts set for error rate and latency | WARNING |
| Post-deploy verification | Health checks and smoke tests defined | WARNING |
| Runbook complete | Pre-check, deploy, verify, rollback steps documented | INFO |

## Output Format
```
Summary → Findings (by severity) → Score → Top 3 Recommendations
```
