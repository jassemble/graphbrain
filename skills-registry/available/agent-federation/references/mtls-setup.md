# mTLS Setup for Agent Federation

## Certificate Authority

- Each federation must have a root CA (or use a shared CA)
- Each org issues its own intermediate CA, signed by root
- Each agent gets a leaf certificate signed by its org's intermediate

## Certificate Rotation

- Leaf certificates: rotate every 90 days
- Intermediate certificates: rotate every 1 year
- Root certificate: rotate every 5 years (long-lived)
- Use overlap windows (old + new valid simultaneously) to avoid downtime

## Required Extensions

```
X.509v3 Extensions:
  Subject Alternative Name: DNS:agent-name.org.example
  Extended Key Usage: TLS Web Client + TLS Web Server (mutual auth)
  Key Usage: Digital Signature + Key Encipherment
```

## Message Signing (Independent of TLS)

Beyond mTLS, every message body should be signed with ed25519:
```
message: { ... }
signature: ed25519(sha256(message), agent_private_key)
public_key_fingerprint: sha256(agent_public_key)[:16]
```

Verifier:
1. Look up agent's public key by fingerprint
2. Verify signature against message hash
3. Accept only if signature valid AND TLS handshake succeeded

## Threat Model

- mTLS prevents: impersonation, MITM, eavesdropping
- ed25519 signing adds: non-repudiation, replay protection (with nonce)
- Neither prevents: compromised endpoint, malicious-but-authentic agent
