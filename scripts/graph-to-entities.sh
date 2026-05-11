#!/usr/bin/env bash
# Generate .ctx/entities/ pages from graph.json
# Creates one entity page per class/service/function/model node.
# Includes confidence-scored edges from graph data.
set -euo pipefail

GRAPH="${1:-.ctx/graph/graph.json}"
ENTITIES_DIR=".ctx/entities"

if [ ! -f "$GRAPH" ]; then
  echo "Error: graph.json not found at $GRAPH" >&2
  exit 1
fi

python3 -c "
import json, os, sys

with open('$GRAPH') as f:
    data = json.load(f)

nodes = data.get('nodes', [])
edges = data.get('edges', data.get('links', []))

# Build adjacency
inbound = {}
outbound = {}
for e in edges:
    src = e.get('source', '')
    tgt = e.get('target', '')
    info = {
        'edge': e.get('confidence', e.get('type', 'INFERRED')),
        'confidence': e.get('confidence_score', 0.5),
        'relation': e.get('relation', 'related_to')
    }
    outbound.setdefault(src, []).append({**info, 'name': tgt})
    inbound.setdefault(tgt, []).append({**info, 'name': src})

entity_types = {'class', 'service', 'function', 'model', 'interface', 'component', 'method'}
created = 0

for n in nodes:
    ntype = n.get('type', n.get('node_type', '')).lower()
    if ntype not in entity_types:
        continue

    nid = n.get('id', n.get('name', ''))
    label = n.get('label', n.get('name', nid))
    slug = label.lower().replace(' ', '-').replace('/', '-')
    outfile = os.path.join('$ENTITIES_DIR', slug + '.md')

    if os.path.exists(outfile):
        print(f'SKIP:{slug}', file=sys.stderr)
        continue

    community = n.get('community', n.get('cluster', ''))
    degree = len(inbound.get(nid, [])) + len(outbound.get(nid, []))

    # Build related_entities YAML
    related = outbound.get(nid, [])[:10]
    rel_yaml = ''
    for r in related:
        edge_type = r['edge'] if r['edge'] in ('EXTRACTED','INFERRED','AMBIGUOUS') else 'INFERRED'
        rel_yaml += f\"\"\"
  - name: \"{r['name']}\"
    edge: {edge_type}
    confidence: {r['confidence']}\"\"\"

    # Build wikilinks
    in_links = inbound.get(nid, [])[:10]
    out_links = outbound.get(nid, [])[:10]
    in_wl = '\\n'.join(f'- [[entity:{r[\"name\"].lower().replace(\" \",\"-\")}]] (inbound)' for r in in_links)
    out_wl = '\\n'.join(f'- [[entity:{r[\"name\"].lower().replace(\" \",\"-\")}]] (outbound)' for r in out_links)

    from datetime import date
    today = date.today().isoformat()

    content = f\"\"\"---
title: \"{label}\"
category: entity
created: {today}
updated: {today}
tags: []
related_skills: []
related_templates: []
related_entities:{rel_yaml if rel_yaml else ' []'}
---

# {label}

## Definition

{ntype.title()} entity{f' in community {community}' if community else ''}.  Degree: {degree}.

## Current Understanding

Type: {ntype}
{f'Community: {community}' if community else ''}

## Phase Mapping

## Related Concepts

### Inbound
{in_wl if in_wl else '(none)'}

### Outbound
{out_wl if out_wl else '(none)'}

## Sources
\"\"\"
    with open(outfile, 'w') as f:
        f.write(content)
    created += 1

skipped = len([n for n in nodes if n.get('type', n.get('node_type', '')).lower() in entity_types]) - created
print(f'graph-to-entities: created={created} skipped={max(0, skipped)}')
"
