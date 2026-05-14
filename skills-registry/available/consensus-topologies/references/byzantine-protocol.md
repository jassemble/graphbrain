# Byzantine Fault Tolerance for Agent Swarms

Byzantine consensus tolerates agents that lie, malfunction, or are compromised. Required when crossing trust boundaries.

## The 3f+1 Rule

To tolerate `f` Byzantine (malicious or faulty) agents, you need `3f+1` total agents:
- `f = 1` → need 4 agents
- `f = 2` → need 7 agents
- `f = 3` → need 10 agents

This is the **minimum**; fewer agents cannot guarantee correctness if any are Byzantine.

## Three-Phase Voting (PBFT-style)

For each decision:

1. **Pre-prepare**: leader proposes decision, signs it, broadcasts
2. **Prepare**: each agent verifies signature, broadcasts its agreement
3. **Commit**: once an agent sees `2f+1` prepare messages, it broadcasts commit
4. **Decide**: once an agent sees `2f+1` commit messages, decision is final

The double round (`prepare` + `commit`) protects against equivocation (leader sending different proposals to different agents).

## Cryptographic Requirements

- Every message must be signed (use ed25519)
- Every agent has a known public key (use federation skill's mTLS setup)
- Replay protection via monotonic sequence numbers

## Cost

- Messaging: O(n²) per decision (every agent broadcasts to all others)
- Latency: at least 3 round trips per decision
- Bandwidth: ~3n² messages per decision

Practical limit: ~30 agents in a single Byzantine cluster.

## When to Use

- Cross-organizational agent communication
- Any environment where agents might be compromised
- High-stakes decisions where wrong answer is unacceptable

## When NOT to Use

- Single trust boundary (Raft is simpler and faster)
- High-throughput requirements (Byzantine is slow)
- Decisions that can be eventually consistent (use Gossip)

## Agent Mapping

| Byzantine Concept | Agent Concept |
|-------------------|---------------|
| 3f+1 minimum | Need 4+ agents for f=1 tolerance |
| Pre-prepare/prepare/commit | 3-round verification before action |
| Signed messages | Federation skill's ed25519 signing |
| Decision quorum | 2f+1 agents agree before action |
