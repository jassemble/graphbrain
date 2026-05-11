#!/usr/bin/env bash
set -euo pipefail

# Resolve package directory (supports npm install, direct clone, or env override)
SCRIPT_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")" && pwd)}"
CTX_DIR=".ctx"

# Verify Python 3.8+
if ! command -v python3 &>/dev/null; then
  echo "ERROR: Python 3 is required but not found." >&2
  echo "Install Python 3.8+ from https://python.org" >&2
  exit 1
fi
py_ver=$(python3 -c "import sys; v=sys.version_info; print(f'{v.major}.{v.minor}')")
py_major=$(echo "$py_ver" | cut -d. -f1)
py_minor=$(echo "$py_ver" | cut -d. -f2)
if [ "$py_major" -lt 3 ] || { [ "$py_major" -eq 3 ] && [ "$py_minor" -lt 8 ]; }; then
  echo "ERROR: Python 3.8+ required, found $py_ver" >&2
  exit 1
fi

# Make bundled brain CLI available
export PATH="$SCRIPT_DIR/bin:$PATH"

if [ -d "$CTX_DIR" ]; then
  echo ".ctx/ already initialized — skipping scaffold."
  exit 0
fi

echo "Creating .ctx/ directory structure..."

mkdir -p \
  "$CTX_DIR/graph/cache" \
  "$CTX_DIR/graph/wiki" \
  "$CTX_DIR/skills" \
  "$CTX_DIR/references" \
  "$CTX_DIR/concepts" \
  "$CTX_DIR/entities" \
  "$CTX_DIR/modules" \
  "$CTX_DIR/sources" \
  "$CTX_DIR/decisions" \
  "$CTX_DIR/archive"

echo ".ctx/ scaffold created."

# --- Place content files ---
python3 << PYEOF
import os
ctx = "$CTX_DIR"

# Shared template body
def tpl(title, category, extra_fm=""):
    return f"""---
title: "{title}"
category: {category}
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
{extra_fm}related_skills: []
related_templates: []
---

# {title}

## Definition

One-paragraph summary.

## Current Understanding

Detailed explanation.

## Phase Mapping

Which SDLC phases apply.

## Related Concepts

## Sources
"""

templates = {
    "concepts/_template.md": tpl("Concept Name", "concept"),
    "entities/_template.md": tpl("Entity Name", "entity", 'related_entities:\n  - name: "other-entity"\n    edge: EXTRACTED\n    confidence: 1.0\n'),
    "modules/_template.md": tpl("Module Name", "module", 'source-hash: ""\n'),
    "sources/_template.md": tpl("Source Name", "source"),
    "decisions/_template.md": tpl("Decision Title", "decision"),
}

core_files = {
    "protocol.md": """# Code Brain Protocol

## Core Principles

1. **Pointer-first**: satisfy queries from metadata before loading full pages
2. **Evidence over claims**: link assertions to source code or graph edges
3. **Additive only**: never delete confirmed knowledge -- archive instead
4. **Human partner**: the developer is "human partner", not "user"

## Navigation

- **Routing**: see routing.md for keyword-to-page mappings
- **Decisions**: see decisions.md for project decision log
- **Index**: see index.md for full page catalog with token counts

## Graph Queries

Query the knowledge graph via brain MCP server:
- query_graph -- BFS/DFS traversal with token budget
- god_nodes -- highest-degree abstractions
- get_neighbors -- immediate connections for an entity
- shortest_path -- trace relationship between two nodes

Budget: queries return < 2000 tokens by default.

## Loading Tiers

1. **Metadata** -- index.md fingerprint (name, summary, tokens)
2. **Snippet** -- routing.md keyword match, relevant section
3. **Full File** -- only when Tier 1-2 insufficient
""",
    "routing.md": """# Routing -- Keyword to Page

Route queries to the most relevant page using keyword matches.

## Format

\x60\x60\x60
keyword: -> [[type:name]] -- one-line summary
\x60\x60\x60

## Routes

### Modules

### Entities

### Concepts

### Sources
""",
    "index.md": """# Index -- Page Catalog

Categorized catalog of all .ctx/ pages with fingerprints.

## Format

\x60\x60\x60
- [[type:name]] -- Xt -- summary -- cluster:X
\x60\x60\x60

## Concepts

## Entities

## Modules

## Sources

## Decisions
""",
    "status.md": """# Status -- Module Lifecycle Tracker

Lifecycle: UNENRICHED -> FRESH -> STALE -> RESYNCED -> VERIFIED

| Module | Status | Last Sync | Source Hash |
|--------|--------|-----------|-------------|
""",
    "log.md": """# Log

## Recent Patterns

<!-- Promoted recurring patterns from activity history (semantic memory) -->

## Activity History

<!-- Append-only per-event entries (episodic memory) -->
""",
    "decisions.md": """# Decisions -- Consolidated Summary

Project decisions with links to detailed ADRs in decisions/.

## Active Decisions

## Superseded Decisions
""",
    "patterns.md": """# Patterns -- Cross-Cutting Codebase Patterns

<!-- Populated from brain hyperedge analysis and cross-community connections -->
""",
    "community_map.md": """# Community Map -- Responsibility Clusters

<!-- Generated from brain Leiden clustering output -->
""",
    "overview.md": """# Overview

## Codebase Patterns

## Active State

## Recent Activity
""",
}

lint = """# Lint Checklist -- Brain Verifier Rubric

Swappable rubric: the Verifier reads this file to determine what gets checked.

| # | Check | Criterion | Severity | Machine-verifiable |
|---|-------|-----------|----------|--------------------|
| 1 | Broken wikilinks | Every [[type:name]] resolves to a file | ERROR | Yes |
| 2 | Stale modules | source-hash matches current git hash | WARNING | Yes |
| 3 | Orphan entities | Entity has >=1 inbound wikilink | WARNING | Yes |
| 4 | Missing modules | Every source dir has a module page | ERROR | Yes |
| 5 | Pattern drift | Claims in patterns.md match code | WARNING | Partial |
| 6 | Token overflow | No page exceeds 30K tokens | WARNING | Yes |
| 7 | Protocol bloat | protocol.md under 500 tokens | ERROR | Yes |
| 8 | Contradiction | No opposite facts about same entity | WARNING | Partial |
| 9 | Orphan concepts | Concept has >=1 inbound wikilink | INFO | Yes |
| 10 | Stale log | Last entry <=7 days old | INFO | Yes |
| 11 | Missing verification | status.md has entry for every module | WARNING | Yes |
| 12 | Low-confidence edges | INFERRED < 0.5 flagged for review | INFO | Yes |
| 13 | EXTRACTED edge validity | Edges resolve to code refs | WARNING | Yes |
| 14 | Community map staleness | Clusters match module relationships | WARNING | Partial |

## Severity Levels

- **ERROR**: Must fix before sync completes.
- **WARNING**: Should fix. Reported but does not block.
- **INFO**: Informational.
"""

for path, content in templates.items():
    full = os.path.join(ctx, path)
    with open(full, "w") as f:
        f.write(content)

for path, content in core_files.items():
    full = os.path.join(ctx, path)
    with open(full, "w") as f:
        f.write(content)

with open(os.path.join(ctx, "references", "lint-checklist.md"), "w") as f:
    f.write(lint)

print(f"  {len(templates)} templates + {len(core_files)} core files + lint checklist")
PYEOF

# CLAUDE.md integration
POINTER_LINE="# Read .ctx/protocol.md for project brain context"

if [ -f "CLAUDE.md" ]; then
  if ! grep -qF "$POINTER_LINE" CLAUDE.md; then
    echo "" >> CLAUDE.md
    echo "$POINTER_LINE" >> CLAUDE.md
    echo "Appended brain pointer to existing CLAUDE.md."
  else
    echo "CLAUDE.md already has brain pointer — skipping."
  fi
else
  echo "$POINTER_LINE" > CLAUDE.md
  echo "Created CLAUDE.md with brain pointer."
fi

# --- Install Claude Code hooks ---
mkdir -p .claude
if [ ! -f ".claude/settings.local.json" ]; then
  python3 -c "
import json, os

script_dir = '$SCRIPT_DIR'
hooks_dir = os.path.join(script_dir, 'scripts', 'hooks')

settings = {
    'hooks': {
        'SessionStart': [{'hooks': [{'type': 'command', 'command': f'bash {hooks_dir}/session-start.sh'}]}],
        'UserPromptSubmit': [{'hooks': [{'type': 'command', 'command': f'bash {hooks_dir}/user-prompt-submit.sh \"\$PROMPT\"'}]}],
        'PreToolUse': [{'hooks': [{'type': 'command', 'command': f'bash {hooks_dir}/guardrails.sh \"\$TOOL_INPUT\"'}]}],
        'PostToolUse': [{'hooks': [{'type': 'command', 'command': f'bash {hooks_dir}/post-tool-use.sh \"\$FILE\"'}]}],
        'Stop': [{'hooks': [{'type': 'command', 'command': f'bash {hooks_dir}/stop.sh'}]}],
        'SessionEnd': [{'hooks': [{'type': 'command', 'command': f'bash {hooks_dir}/session-end.sh'}]}],
    }
}

with open('.claude/settings.local.json', 'w') as f:
    json.dump(settings, f, indent=2)
print('Installed Claude Code hooks to .claude/settings.local.json')
"
else
  echo ".claude/settings.local.json already exists — skipping hook install."
  echo "See .claude/HOOKS.md for manual hook configuration."
fi

# Coexistence check
if [ -d ".agentctx" ]; then
  echo "Existing .agentctx/ detected — .ctx/ will coexist alongside it."
fi

# Phase B: Detect and install skills
INSTALL_SCRIPT="$SCRIPT_DIR/scripts/install-skills.sh"
if [ -f "$INSTALL_SCRIPT" ]; then
  echo ""
  echo "Phase B: Detecting project stack and installing skills..."
  AGENTCTX_PACKAGE_DIR="$SCRIPT_DIR" bash "$INSTALL_SCRIPT" || echo "Skill installation skipped (non-fatal)."
fi
