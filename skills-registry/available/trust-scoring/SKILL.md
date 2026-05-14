---
name: trust-scoring
description: "Quantitative trust scoring for inter-agent privilege escalation."
author: graphbrain
version: "1.0"
tier: available
pattern: Reviewer
trigger_phrases:
  - "trust score"
  - "agent trust"
  - "privilege escalation"
  - "agent permissions"
paths:
  - "**/trust/**"
related_skills:
  - agent-federation
  - consensus-topologies
---

# Trust Scoring Skill

Quantitative trust formula for gating agent privileges in multi-agent systems. Use with `agent-federation` when remote agents need different access levels based on behavior.

## The Formula

```
trust = 0.4 × success
      + 0.2 × uptime
      + 0.2 × threat
      + 0.2 × integrity
```

Each component is a `[0, 1]` value:

- **success**: rolling success rate of agent's actions (e.g., 0.95 = 95% of recent actions succeeded)
- **uptime**: availability over recent window (e.g., 0.99 = 99% uptime in last 30 days)
- **threat**: inverse threat score (1.0 = clean, 0.0 = flagged for malicious behavior)
- **integrity**: signature verification rate (1.0 = all messages signed correctly)

Result is also `[0, 1]`.

## Privilege Tiers

| Trust Score | Allowed Actions |
|-------------|----------------|
| 0.0 – 0.3 | Read-only; quarantine candidate |
| 0.3 – 0.6 | Read + comment; no writes |
| 0.6 – 0.8 | Read + write to own resources |
| 0.8 – 0.95 | Read + write to shared resources |
| 0.95 – 1.0 | Full federation privileges |

## Score Updates

- **success**: update after every action completion (exponential moving average)
- **uptime**: heartbeat-based, computed continuously
- **threat**: updated by security monitor (IDS, AIDefence, etc.)
- **integrity**: updated per message verified

Decay all components: 7-day half-life. An agent that was trustworthy a month ago must re-prove itself.

## Known Limitations (Be Aware)

The weighting (0.4/0.2/0.2/0.2) is **not empirically justified** — it's a starting point.

- **Success is gameable**: an agent that only requests easy tasks inflates its success rate
- **Uptime conflates availability with trust**: a malicious always-on agent has high uptime
- **Threat lags behavior**: scores update after detection, not before
- **Integrity binary in practice**: signature either valid or invalid; not much middle ground

## Hardening

1. **Weight by action stakes**: high-stakes successes count more than low-stakes ones
2. **Penalize variety mismatches**: agent should attempt diverse tasks, not the same one
3. **Use cohort comparison**: trust relative to peers performing similar work
4. **Independent verification**: don't trust agent's own self-reports

## When NOT to Use

- Single trust boundary (overkill)
- Static permission systems (RBAC) work better when roles are known in advance
- Low-stakes coordination (gossip + last-write-wins is simpler)

## Composes With

- `agent-federation` — trust score gates federation actions
- `consensus-topologies` — Byzantine voting weighted by trust
- `security` skill — trust score reflects security posture
