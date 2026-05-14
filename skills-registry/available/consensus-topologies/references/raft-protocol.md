# Raft Protocol for Agent Swarms

Raft is a consensus algorithm designed for understandability (vs Paxos). Adapted here for agent coordination.

## Three Roles

- **Leader**: one at a time; handles all decisions and replication
- **Follower**: passive; responds to leader's directives
- **Candidate**: transitional; running for leader election

## Election

1. Followers expect heartbeat from leader every `T` ms
2. If no heartbeat for `random(T, 2T)`, follower becomes candidate
3. Candidate requests votes from all peers
4. Majority vote → new leader; otherwise retry with new random timeout

Randomized timeout prevents split-vote scenarios.

## Log Replication

1. Client sends command to leader
2. Leader appends command to its log
3. Leader sends `AppendEntries` to all followers
4. Once majority acknowledges, leader commits and replies to client
5. Followers commit asynchronously

## Failure Modes

- **Leader fails**: followers detect missing heartbeat → new election
- **Network partition**: minority partition becomes read-only; majority continues
- **Slow follower**: leader retries; follower eventually catches up

## Agent Mapping

| Raft Concept | Agent Concept |
|--------------|---------------|
| Leader | Orchestrator agent (e.g., Brain Maintenance) |
| Follower | Worker agent (e.g., Generator, Verifier) |
| Log entry | Task assignment |
| Term | Sync cycle |
| Heartbeat | Keep-alive ping |

## When Raft Works for Agents

- Single trust boundary (all agents trustworthy)
- Clear leader role (one agent designated coordinator)
- Sequential decisions matter (order of operations)

## When Raft Fails for Agents

- Adversarial agents present (use Byzantine instead)
- High agent churn (election overhead dominates work)
- Geographic distribution with high latency (slow consensus)
