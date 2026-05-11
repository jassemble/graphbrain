---
name: sdlc-deployment
description: Deploy safely with rollback plans and verification steps.
license: MIT
metadata:
  author: codebrain
  version: "1.0"
  phase: deployment
  pattern: Pipeline
paths:
  - "**/Dockerfile"
  - "**/.github/workflows/**"
  - "**/deploy/**"
  - "**/k8s/**"
trigger_phrases:
  - "deploy to production"
  - "CI/CD"
  - "deployment plan"
  - "rollback plan"
  - "release"
related_skills:
  - "sdlc-deployment-verifier"
  - "sdlc-testing"
---

# Deployment

## When to Use
- Deploying features to staging or production
- Setting up CI/CD pipelines
- Creating rollback procedures

## Instructions
1. MUST verify all tests pass before deploy
2. MUST have documented rollback path
3. MUST NOT store secrets in config files
4. MUST verify deployment after completion
5. SHOULD follow existing deployment patterns

## Phase Pipeline
1. Verify: all tests pass, no blocking lint errors
2. Generate deploy plan using templates/deployment-plan.md
3. Verify readiness checklist
4. Execute deployment
5. Post-verify: smoke tests, monitoring checks
6. Gate: rollback path tested

## Gate Conditions
- PRE: all tests pass, deployment plan exists
- POST: deployment verified, monitoring active, rollback tested

## Templates
- `templates/deployment-plan.md` — Deploy steps
- `templates/runbook.md` — Pre-check, deploy, verify, rollback

## References
- `references/ci-cd-patterns.md`
- `references/rollout-strategies.md`
- `references/rollback-procedures.md`

## Verifier Handoff
Run SKILL-verifier.md before and after deployment. MAX_ITERATIONS=1.

## Three-Tier Boundaries
| Always | Ask | Never |
|--------|-----|-------|
| Verify tests pass | Blue/green vs canary | Deploy without tests |
| Document rollback | Change deploy target | Store secrets in code |
| Post-deploy verify | Scale configuration | Skip monitoring |
