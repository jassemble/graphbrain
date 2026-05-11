# Deployment Runbook: [Release Name]

## Pre-Deploy
- [ ] All tests pass in CI
- [ ] Version bumped: [old] → [new]
- [ ] CHANGELOG updated
- [ ] DB migrations reviewed (if any)
- [ ] Rollback procedure tested
- [ ] Team notified: deploy starting

## Deploy Steps
1. Merge PR to main
2. CI builds and tests
3. Deploy to staging
4. Run smoke tests on staging
5. Deploy to production
6. Monitor for 15 minutes

## Post-Deploy Verification
- [ ] Health endpoint: GET /health → 200
- [ ] Smoke test: [critical user flow] works
- [ ] Error rate: stable (< 2x baseline)
- [ ] Latency: stable (P99 < [threshold])
- [ ] Logs: no new error patterns

## Rollback Trigger
If ANY of these occur within 30 minutes:
- Error rate > 2x baseline
- P99 latency > 2x baseline
- Health check failures > 10%
- Data corruption signal

## Rollback Steps
1. Revert deploy: [exact command]
2. Verify rollback: health check + smoke test
3. Notify team: rollback complete
4. Create incident ticket
5. Write postmortem (if P0/P1)
