# Model Profiles — Recommended Models by Phase

Use the most capable model for high-stakes phases, faster models for routine work.

## Recommendations

| Phase | Recommended Model | Why |
|-------|------------------|-----|
| Requirements (Inversion) | Opus / GPT-4o | Interview quality, nuance detection |
| Design (Architecture) | Opus / GPT-4o | Trade-off analysis, system thinking |
| Implementation (TDD) | Sonnet / GPT-4o-mini | Speed for red-green-refactor loops |
| Testing | Sonnet / GPT-4o-mini | Pattern matching, edge case generation |
| Deployment | Sonnet | Checklist execution, low creativity needed |
| Maintenance (Bug fix) | Opus for diagnosis, Sonnet for fix | Root cause needs depth |
| Brain Sync | Sonnet | Mechanical translation, high volume |
| Brain Verify | Haiku / GPT-4o-mini | Boolean checks, fast iteration |
| Brain Synthesis | Opus | Cross-cutting pattern recognition |
| Code Review | Opus | Nuance, convention awareness |

## Token Budget Guidelines

| Context | Budget | Rationale |
|---------|--------|-----------|
| protocol.md | < 500 tokens | Always loaded — must be tiny |
| routing.md | < 400 tokens | Always loaded — keyword index only |
| SKILL.md | < 500 lines | Progressive disclosure — details in references/ |
| AGENT.md | < 200 lines | Behavioral contract — not a tutorial |
| MCP query response | < 2000 tokens | Per-query budget to prevent context bloat |
| Single page | < 30K tokens | Beyond this, split via split-page.sh |
