# Deployment Checklist

## Pre-Deploy
- [ ] All tests pass in CI
- [ ] Version bumped appropriately (semver)
- [ ] CHANGELOG updated
- [ ] No secrets in code (git-secrets scan)
- [ ] Database migrations reviewed and reversible
- [ ] Rollback procedure documented

## Deploy
- [ ] Deployment strategy selected (rolling/blue-green/canary)
- [ ] Monitoring dashboards open
- [ ] Team notified of deploy start

## Post-Deploy
- [ ] Health checks pass
- [ ] Smoke tests pass
- [ ] Error rate stable
- [ ] Latency nominal
- [ ] No new error patterns in logs
- [ ] Team notified of deploy success/failure
