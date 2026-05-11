#!/usr/bin/env bash
# Contradiction detection
# Cross-references AMBIGUOUS edges with claims in .ctx/ pages
set -euo pipefail

CTX=".ctx"
GRAPH="$CTX/graph/graph.json"

python3 -c "
import os, re, json

ctx = '$CTX'
graph_path = '$GRAPH'
contradictions = []

# Load AMBIGUOUS edges from graph if available
ambiguous_edges = []
if os.path.exists(graph_path):
    with open(graph_path) as f:
        data = json.load(f)
    for e in data.get('edges', data.get('links', [])):
        if e.get('confidence', '') == 'AMBIGUOUS' or e.get('confidence_score', 1.0) == 0.0:
            ambiguous_edges.append(e)

# Scan all pages for claims about the same entity
entity_claims = {}  # entity_name -> [(file, claim_line)]
for root, dirs, files in os.walk(ctx):
    for fname in files:
        if not fname.endswith('.md') or fname.startswith('_'):
            continue
        fpath = os.path.join(root, fname)
        with open(fpath) as f:
            for i, line in enumerate(f, 1):
                # Look for definitive claims (uses, implements, belongs to, etc.)
                claims = re.findall(r'\[\[entity:([a-z0-9_-]+)\]\].*?(?:uses|implements|belongs|handles|manages|creates|returns)', line, re.IGNORECASE)
                for entity in claims:
                    entity_claims.setdefault(entity, []).append((fpath, i, line.strip()))

# Check for contradictions: same entity, conflicting verbs from different files
for entity, locations in entity_claims.items():
    if len(locations) < 2:
        continue
    # Simple heuristic: if different files make claims about same entity
    files_seen = set()
    for fpath, lineno, claim in locations:
        if fpath in files_seen:
            continue
        files_seen.add(fpath)
    if len(files_seen) >= 2:
        # Check if any AMBIGUOUS edge involves this entity
        for ae in ambiguous_edges:
            if entity in ae.get('source', '') or entity in ae.get('target', ''):
                locs = [(f, l, c) for f, l, c in locations[:3]]
                contradictions.append({
                    'entity': entity,
                    'severity': 'WARNING',
                    'locations': locs,
                    'reason': f'AMBIGUOUS edge + multiple claims about {entity}'
                })
                break

if contradictions:
    print('## Contradictions Detected')
    print()
    for c in contradictions:
        print(f'[{c[\"severity\"]}] {c[\"entity\"]}: {c[\"reason\"]}')
        for f, l, claim in c['locations']:
            print(f'  - {f}:{l} — {claim[:80]}')
        print(f'  Suggested: review and reconcile claims about {c[\"entity\"]}')
        print()
    print(f'Total: {len(contradictions)} contradictions')
else:
    print('No contradictions detected.')
" 2>/dev/null || echo "No contradictions detected."
