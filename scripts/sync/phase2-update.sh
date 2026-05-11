#!/usr/bin/env bash
# Phase 2: UPDATE — Generate/update .ctx/ pages from graph.json
set -euo pipefail

CTX=".ctx"
GRAPH="${1:-$CTX/graph/graph.json}"
PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
SCRIPTS="$PACKAGE_DIR/scripts"
START=$(python3 -c "import time; print(int(time.time()*1000))")

echo "Phase 2: UPDATE"

if [ ! -f "$GRAPH" ]; then
  echo "ERROR: graph.json not found at $GRAPH" >&2
  exit 1
fi

created=0
updated=0
flagged=0

# Run translators
echo "  Running graph-to-modules..."
result=$(bash "$SCRIPTS/graph-to-modules.sh" "$GRAPH" 2>&1) || true
echo "  $result"

echo "  Running graph-to-entities..."
result=$(bash "$SCRIPTS/graph-to-entities.sh" "$GRAPH" 2>&1) || true
echo "  $result"

echo "  Running community map generator..."
result=$(bash "$SCRIPTS/generate-community-map.sh" "$GRAPH" 2>&1) || true
echo "  $result"

echo "  Running routing populator..."
result=$(bash "$SCRIPTS/populate-routing.sh" "$GRAPH" 2>&1) || true
echo "  $result"

echo "  Running index generator..."
result=$(bash "$SCRIPTS/generate-index.sh" "$GRAPH" 2>&1) || true
echo "  $result"

# Flag concepts whose description may no longer match code
python3 -c "
import os, json, re

ctx = '$CTX'
graph_path = '$GRAPH'
concepts_dir = os.path.join(ctx, 'concepts')

if os.path.exists(graph_path) and os.path.isdir(concepts_dir):
    with open(graph_path) as f:
        data = json.load(f)
    node_names = {n.get('id', n.get('name', '')).lower() for n in data.get('nodes', [])}
    edge_pairs = {(e.get('source','').lower(), e.get('target','').lower()) for e in data.get('edges', data.get('links', []))}

    flagged = 0
    for fname in os.listdir(concepts_dir):
        if fname.startswith('_') or not fname.endswith('.md'): continue
        fpath = os.path.join(concepts_dir, fname)
        content = open(fpath).read()
        # Check entity references in concept still exist in graph
        refs = re.findall(r'\[\[entity:([a-z0-9_-]+)\]\]', content)
        missing = [r for r in refs if r.lower() not in node_names]
        if missing:
            print(f'  FLAGGED: concept:{fname[:-3]} references missing entities: {missing}')
            flagged += 1
    if flagged:
        print(f'  {flagged} concepts flagged for review')
" 2>/dev/null || true

# Mark new entities as UNENRICHED in status.md
python3 -c "
import os, datetime

ctx = '$CTX'
status = os.path.join(ctx, 'status.md')
today = datetime.date.today().isoformat()
new_count = 0

with open(status) as f:
    existing = f.read()

# Find entity/module pages not in status.md
for subdir in ['modules', 'entities']:
    d = os.path.join(ctx, subdir)
    if not os.path.isdir(d):
        continue
    for fname in os.listdir(d):
        if fname.startswith('_') or not fname.endswith('.md'):
            continue
        name = fname[:-3]
        if name not in existing:
            existing = existing.rstrip() + f'\n| {name} | UNENRICHED | {today} | - |'
            new_count += 1

with open(status, 'w') as f:
    f.write(existing + '\n')

if new_count:
    print(f'  Marked {new_count} new entries as UNENRICHED')
" 2>/dev/null || true

# Count pages over budget
over_budget=$(python3 -c "
import os
ctx = '$CTX'
over = 0
for root, dirs, files in os.walk(ctx):
    for f in files:
        if f.endswith('.md') and not f.startswith('_'):
            fp = os.path.join(root, f)
            words = len(open(fp).read().split())
            if int(words * 0.75) > 30000:
                over += 1
print(over)
" 2>/dev/null || echo "0")

END=$(python3 -c "import time; print(int(time.time()*1000))")
echo "Phase 2: complete — duration_ms=$((END - START)) pages_over_budget=$over_budget"
