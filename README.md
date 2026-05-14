# graphbrain — Code Brain for AI Agents

A project-level knowledge brain that gives AI agents persistent, structured context about your codebase.

## What It Does

- Extracts a knowledge graph from your codebase (AST + semantic analysis, 15+ languages)
- Generates governed wiki pages (modules, entities, concepts, decisions)
- Routes agents to relevant context automatically via lifecycle hooks
- Tracks decisions, patterns, and project evolution over time

## Quick Start

```bash
# Install
npm install graphbrain

# Or one-liner: install + init + extract
npx graphbrain init && npx graphbrain extract
```

That's it. Your `.ctx/` brain is ready.

### Manual Setup (no npm)

```bash
git clone https://github.com/jassemble/graphbrain .graphbrain-setup
cp -r .graphbrain-setup/{bin,scripts,skills-registry,brain-init.sh} .
bash brain-init.sh
./bin/brain .
```

> **Requirements**: Python 3.8+ (stdlib only, no pip install needed)

## CLI

```
graphbrain init          Initialize .ctx/ scaffold + detect skills
graphbrain extract       Extract knowledge graph from codebase
graphbrain extract -u    Incremental extraction (changed files only)
graphbrain sync          Full sync pipeline (extract -> update -> verify -> commit)
graphbrain lint          Read-only brain verification audit
graphbrain serve         Start MCP graph query server
graphbrain add-skill N   Install a skill by name from the registry
graphbrain uninstall     Remove .ctx/, hooks, and CLAUDE.md pointer
```

## Slash Commands (Claude Code)

- `/brain-sync` — Full sync pipeline (extract, update, verify, commit)
- `/brain-lint` — Read-only verification audit
- `/brain-add-skill <name>` — Install a skill from the registry

## Architecture

```
.ctx/                          # The Brain (per-project, generated)
  protocol.md                  # Entry point (<500 tokens)
  routing.md                   # Keyword -> page (<400 tokens)
  index.md                     # Page catalog with fingerprints
  graph/                       # Brain extraction output
  concepts/                    # Methodology pages (PROPOSED -> CONFIRMED)
  entities/                    # Code entities with confidence-scored edges
  modules/                     # Directory-level documentation
  decisions/                   # Architecture Decision Records
  skills/                      # Auto-detected skill packages
  references/                  # Swappable lint rubrics
```

## Skill Detection

On init, the brain detects your project stack and installs matching skills:

| Signal | Skills Activated |
|--------|-----------------|
| `package.json` with `react` | react, typescript |
| `tsconfig.json` | typescript |
| `go.mod` | go |
| `requirements.txt` | python |
| `prisma/schema.prisma` | data-modeling |
| `.env` | security |

Core SDLC skills (requirements, design, implementation, testing, deployment, maintenance) are always installed.

### Behavioral Skills

A separate tier of **behavioral skills** loads on every session, not on trigger phrases. They shape *how* the agent decides across all tasks (disposition over procedure). The bundled `karpathy-principles` skill encodes four task-agnostic rules: think before coding, simplicity first, surgical changes, goal-driven execution. Composes with all workflow skills.

## Lifecycle Hooks

Hooks are installed progressively. Enable them in `.claude/settings.local.json`:

1. **SessionStart** — Loads brain context (protocol + decisions + log)
2. **UserPromptSubmit** — Skill routing on every prompt
3. **PostToolUse** — Breadcrumbs and stale marking after edits
4. **PreToolUse** — Guardrails (blocks dangerous operations, PII)
5. **Stop** — Checkpoint on pause
6. **SessionEnd** — Persist observations and decisions

## MCP Server

```bash
npx graphbrain serve .ctx/graph/graph.json
```

Exposes: `query_graph`, `get_node`, `get_neighbors`, `get_community`, `god_nodes`, `graph_stats`, `shortest_path`. Token budget: < 2000 tokens per query.

## Coexistence

- Existing `.agentctx/` directories are untouched
- Existing `CLAUDE.md` gets a single pointer line appended
- Existing `.cursorrules` are never modified
- `.ctx/` can be added to `.gitignore` during evaluation

## License

MIT
