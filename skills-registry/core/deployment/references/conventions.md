# Deployment Conventions

## Pre-Deploy Checklist
1. All tests pass in CI
2. Version bumped (semver: major.minor.patch)
3. CHANGELOG updated with user-facing changes
4. No secrets in committed code (scan with git-secrets or similar)
5. Database migrations reviewed and reversible
6. Rollback procedure documented and tested

## Deployment Strategies
- **Rolling**: Replace instances one at a time. Simple, some downtime risk.
- **Blue-Green**: Run two environments, switch traffic. Zero downtime, double cost.
- **Canary**: Route small % of traffic to new version. Lowest risk, complex monitoring.

## Rollback Triggers
- Error rate > 2x baseline
- P99 latency > 2x baseline
- Health check failures on > 10% of instances
- Any data corruption signal

## Post-Deploy Verification
1. Health endpoint returns 200
2. Smoke tests pass (critical user flows)
3. Error rate stable (no spike vs pre-deploy)
4. Key metrics nominal (latency, throughput)
5. Log check — no new error patterns

## Secret Management
- Use environment variables or secret managers (never config files)
- Rotate credentials on schedule (90 days max)
- Different credentials per environment (dev ≠ staging ≠ prod)
- Audit secret access logs
