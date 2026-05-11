#!/usr/bin/env bash
# Phase 1: EXTRACT — Run brain incremental extraction
set -euo pipefail

CTX=".ctx"
GRAPH="$CTX/graph/graph.json"
PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
export PATH="$PACKAGE_DIR/bin:$PATH"
START=$(python3 -c "import time; print(int(time.time()*1000))")

echo "Phase 1: EXTRACT"

if ! command -v brain &>/dev/null; then
  echo "ERROR: brain CLI not found at $SCRIPT_DIR/bin/brain" >&2
  exit 1
fi

# Run incremental extraction
brain_exit=0
brain . --update 2>&1 || brain_exit=$?

if [ "$brain_exit" -eq 10 ]; then
  echo "Phase 1: no changes detected"
  echo "duration_ms=$(($(python3 -c "import time; print(int(time.time()*1000))") - START))"
  exit 10
elif [ "$brain_exit" -ne 0 ]; then
  echo "ERROR: brain extraction failed (exit $brain_exit)" >&2
  exit 1
fi

if [ ! -f "$GRAPH" ]; then
  echo "ERROR: graph.json not produced at $GRAPH" >&2
  exit 1
fi

# Re-detect skills after extraction (task 4.6)
if [ -f "$PACKAGE_DIR/scripts/detect-skills.sh" ]; then
  delta=$(AGENTCTX_PACKAGE_DIR="$PACKAGE_DIR" bash "$PACKAGE_DIR/scripts/detect-skills.sh" --quiet 2>&1) || true
  if [ -n "$delta" ]; then
    echo "$delta"
  fi
fi

END=$(python3 -c "import time; print(int(time.time()*1000))")
DURATION=$((END - START))

# Report what changed
python3 -c "
import json, os
manifest = '$CTX/graph/manifest.json'
if os.path.exists(manifest):
    with open(manifest) as f:
        m = json.load(f)
    changed = m.get('changed_files', [])
    print(f'Phase 1: complete — {len(changed)} files processed')
else:
    print('Phase 1: complete')
" 2>/dev/null || echo "Phase 1: complete"
echo "duration_ms=$DURATION"
echo "graph=$GRAPH"
[ -f "$CTX/graph/GRAPH_REPORT.md" ] && echo "report=$CTX/graph/GRAPH_REPORT.md"

# Log graph stats
python3 -c "
import json, os
graph = '$GRAPH'
if os.path.exists(graph):
    with open(graph) as f:
        data = json.load(f)
    nodes = len(data.get('nodes', []))
    edges = len(data.get('edges', data.get('links', [])))
    comms = len(set(n.get('community', n.get('cluster', '')) for n in data.get('nodes', []) if n.get('community', n.get('cluster', ''))))
    print(f'graph_stats: nodes={nodes} edges={edges} communities={comms}')
" 2>/dev/null || true
