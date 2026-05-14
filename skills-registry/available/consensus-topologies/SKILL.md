---
name: consensus-topologies
description: "Distributed-systems consensus patterns applied to multi-agent swarms."
author: graphbrain
version: "1.0"
tier: available
pattern: Tool Wrapper
trigger_phrases:
  - "agent consensus"
  - "swarm topology"
  - "raft agent"
  - "byzantine agent"
  - "gossip agent"
paths:
  - "**/swarm/**"
  - "**/consensus/**"
related_skills:
  - agent-federation
  - trust-scoring
---

# Consensus Topologies Skill

Four named topologies for multi-agent coordination. Choose based on consistency vs availability vs trust requirements.

## Topology Selection Matrix

| Topology | Consistency | Availability | Trust Required | Use When |
|----------|-------------|--------------|----------------|----------|
| **Queen-led (Raft)** | Strong | Medium | All agents trusted | Single-org orchestration, clear leader |
| **Mesh (Byzantine FT)** | Strong | High | Tolerates malicious | Cross-org, adversarial environment |
| **Gossip** | Eventual | Very high | Mutual trust | Status propagation, no critical decisions |
| **Adaptive** | Variable | High | Variable | Workload changes dynamically |

## 1. Queen-Led (Raft Consensus)

- One elected leader (queen agent) coordinates all decisions
- Workers follow leader's directives; report results back
- Strong consistency: every decision has a single authoritative source
- **Single point of coordination** — leader failure requires re-election
- Best for: classic planner-worker, single-org orchestration

**Failure mode**: leader compromise = full swarm compromise. Use within trust boundary only.

## 2. Mesh (Byzantine Fault Tolerance)

- Peer-to-peer; no central leader
- Decisions reached by voting; tolerates `⌊(n-1)/3⌋` malicious nodes
- Requires `3f+1` nodes to tolerate `f` Byzantine failures
- Strong consistency despite adversarial agents
- Best for: cross-org coordination, when some agents might be compromised

**Cost**: messaging overhead is `O(n²)`; doesn't scale past ~30 nodes.

## 3. Gossip

- Each agent randomly selects peers to exchange state with
- Eventually consistent; no central coordinator
- Very high availability; failure-tolerant
- Convergence time: `O(log n)` rounds for n agents
- Best for: status propagation, monitoring, non-critical decisions

**Limitation**: not suitable for ordered operations or strong consistency requirements.

## 4. Adaptive

- Switches topology dynamically based on:
  - Agent count (Mesh below 10, Raft 10-100, Gossip above)
  - Trust conditions (Mesh if any agent has trust < 0.7)
  - Workload type (Raft for sequential, Gossip for parallel observation)
- Requires meta-coordinator to decide topology
- Best for: production platforms with varying workloads

## Mapping to graphbrain Patterns

- **Planner-worker model** = Raft (Brain Maintenance Agent as leader, others as workers)
- **Agent teams** = Mesh (peer agents reviewing each other's output)
- **Subagent pattern** = single Raft worker (single leader, single executor)

## Anti-Patterns

- **Raft for cross-org**: leader is a single trust target — don't use across trust boundaries
- **Mesh for >30 nodes**: O(n²) message overhead becomes untenable
- **Gossip for ordered ops**: eventual consistency loses ordering
- **Adaptive without bounds**: meta-coordinator becomes new single point of failure

## References

- See `references/raft-protocol.md` for queen-led details
- See `references/byzantine-protocol.md` for mesh voting algorithm
