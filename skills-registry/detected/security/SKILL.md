---
name: security
description: Security review patterns and environment variable management.
license: MIT
metadata:
  author: codebrain
  version: "1.0"
  phase: implementation
  pattern: Reviewer
paths:
  - "**/.env*"
  - "**/auth/**"
  - "**/security/**"
trigger_phrases:
  - "security review"
  - "environment variables"
  - "secrets"
  - "authentication"
  - "authorization"
  - "OWASP"
related_skills:
  - "sdlc-implementation"
  - "sdlc-deployment"
---

# Security

## When to Use
- Reviewing code that handles auth, secrets, or user data
- Managing environment variables and secrets
- Security audits

## Instructions
1. MUST never commit secrets to version control
2. MUST validate all user input at system boundaries
3. MUST use parameterized queries (no SQL injection)
4. SHOULD check OWASP Top 10 for relevant vulnerabilities
5. Load `references/env-management.md` for secret handling

## References
- `references/env-management.md` — Environment variable patterns
