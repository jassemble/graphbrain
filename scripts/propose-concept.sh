#!/usr/bin/env bash
# Concept proposal system
# Reads GRAPH_REPORT.md for surprising connections and proposes concept pages
# Outputs to stdout only — does NOT create files (human must approve)
set -euo pipefail

CTX=".ctx"
REPORT="$CTX/graph/GRAPH_REPORT.md"

if [ ! -f "$REPORT" ]; then
  echo "No GRAPH_REPORT.md found. Run brain extraction first." >&2
  exit 1
fi

python3 -c "
import os, re

ctx = '$CTX'
report_path = '$REPORT'

with open(report_path) as f:
    report = f.read()

# Extract surprising connections and god nodes
god_nodes = re.findall(r'god.node[s]?.*?:\s*(.+)', report, re.IGNORECASE)
surprises = re.findall(r'surprising.*?:\s*(.+)', report, re.IGNORECASE)
cross_community = re.findall(r'cross.community.*?:\s*(.+)', report, re.IGNORECASE)

# Collect existing concepts to avoid duplicates
concepts_dir = os.path.join(ctx, 'concepts')
existing = set()
if os.path.isdir(concepts_dir):
    existing = {f[:-3] for f in os.listdir(concepts_dir) if f.endswith('.md') and not f.startswith('_')}

proposals = []

# Propose concepts from god nodes (high-degree abstractions)
for line in god_nodes:
    nodes = re.findall(r'(\w[\w\s-]+)', line)
    for node in nodes[:5]:
        slug = node.strip().lower().replace(' ', '-')
        if slug not in existing and len(slug) > 2:
            proposals.append({
                'slug': slug,
                'evidence': f'God node in GRAPH_REPORT.md',
                'source': 'high-degree abstraction'
            })

# Propose from surprising cross-community connections
for line in surprises + cross_community:
    entities = re.findall(r'(\w[\w-]+)', line)
    for i in range(0, len(entities)-1, 2):
        slug = f'{entities[i]}-{entities[i+1]}'.lower()
        if slug not in existing and len(slug) > 4:
            proposals.append({
                'slug': slug,
                'evidence': f'Cross-community connection in GRAPH_REPORT.md',
                'source': 'surprising connection'
            })

if not proposals:
    print('No concept proposals generated. Graph may need more data.')
    exit(0)

# Self-clarification questions
print('## Self-Clarification (5 questions)')
print()
print('1. Does this concept already exist under a different name?')
print('2. Is there sufficient evidence (>= 2 modules/entities referencing it)?')
print('3. Would documenting this concept prevent repeated discovery?')
print('4. Is this concept stable or still evolving rapidly?')
print('5. Who would benefit from reading this concept page?')
print()

# Output proposals
print('## Proposed Concepts')
print()
for p in proposals[:10]:
    print(f'### concept:{p[\"slug\"]}')
    print(f'- Evidence: {p[\"evidence\"]}')
    print(f'- Source: {p[\"source\"]}')
    print(f'- Status: AWAITING REVIEW')
    print(f'- Suggested filename: .ctx/concepts/{p[\"slug\"]}.md')
    print()

print(f'Total: {len(proposals[:10])} proposals')
print()
print('To approve a proposal, create the file manually or run:')
print('  cp .ctx/concepts/_template.md .ctx/concepts/<slug>.md')
"
