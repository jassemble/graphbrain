---
name: kubernetes
tier: available
trigger_phrases:
  - "deploy to kubernetes"
  - "k8s manifest"
  - "helm chart"
  - "kubectl"
paths:
  - "**/k8s/**"
  - "**/kubernetes/**"
  - "**/helm/**"
---

# Kubernetes Skill

## Conventions

- Use declarative manifests over imperative commands
- Namespace all resources; never deploy to `default`
- Set resource requests and limits on every container
- Use ConfigMaps for config, Secrets for credentials
- Prefer Deployments over bare Pods
- Use liveness and readiness probes on all services
- Pin image tags — never use `:latest` in production

## Patterns

- **Rolling updates**: Set `maxUnavailable: 0` and `maxSurge: 1` for zero-downtime deploys
- **Health checks**: Liveness = "is the process alive?", Readiness = "can it serve traffic?"
- **Resource budgets**: Start with `requests: {cpu: 100m, memory: 128Mi}` and tune from metrics
