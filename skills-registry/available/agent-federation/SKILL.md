---
name: agent-federation
description: "Cross-organizational agent communication with cryptographic identity and content filtering."
author: graphbrain
version: "1.0"
tier: available
pattern: Tool Wrapper
trigger_phrases:
  - "agent federation"
  - "cross-org agent"
  - "agent to agent"
  - "federated agent"
  - "mtls agent"
paths:
  - "**/federation/**"
related_skills:
  - consensus-topologies
  - trust-scoring
  - security
---

# Agent Federation Skill

Patterns for **cross-organizational** agent communication where neither org fully trusts the other. Use this skill when building multi-org agent platforms (e.g., fraud signal sharing, supply chain coordination, regulated industries).

## Three Core Primitives

### 1. Cryptographic Identity (mTLS + ed25519)

- Every agent has a public/private ed25519 keypair
- Outbound messages signed with private key; inbound messages verified against published public keys
- Transport uses mTLS (mutual TLS) — both client and server present certificates
- Resolves "who said this?" — eliminates impersonation and replay attacks

### 2. Content Filtering at Boundary

- **Auto-redact PII** on outbound messages (don't trust the agent to remember)
- Detect 14 standard PII types: SSN, credit card, email, phone, address, IP, DOB, ID numbers, names, medical record numbers, financial account numbers, biometrics, passport numbers, driver's license
- Apply consistent redaction tokens (`<PII:type>`) so receiving agent knows something was stripped
- Log every redaction event for audit

### 3. Quantitative Trust Boundary

- Each remote agent has a trust score (see `trust-scoring` skill)
- Trust score gates which actions the remote agent can request
- Below threshold → demote or quarantine
- Above threshold → privileged operations unlocked

## When NOT to Use

- Single-team projects (use Session-layer skills instead)
- Single-org multi-team (Session + AGENTS.md hierarchy is enough)
- Demo or proof-of-concept (premature)

## Anti-Patterns

- **Trusting transport, not message**: TLS verifies the connection, not the agent. Always sign messages.
- **PII filtering once**: Filter on every outbound boundary, not just edge.
- **Static trust scores**: Trust must decay; an agent that was trusted yesterday can be compromised today.
- **LLM provider as covert channel**: Two federated agents using the same Claude/GPT account share context through the provider. Use different accounts per federation boundary.

## References

- `references/mtls-setup.md` — mTLS handshake and certificate rotation
- `references/pii-detection.md` — 14 PII types and detection patterns
