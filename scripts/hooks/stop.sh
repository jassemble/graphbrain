#!/usr/bin/env bash
# Stop hook
# Checkpoints progress to status.md, logs pause to log.md
set -euo pipefail

CTX=".ctx"
[ ! -d "$CTX" ] && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Checkpoint progress to status.md
if [ -f "$CTX/status.md" ]; then
  python3 -c "
import os
ctx = '$CTX'
status_path = os.path.join(ctx, 'status.md')
with open(status_path) as f:
    content = f.read()
counts = {'UNENRICHED': 0, 'FRESH': 0, 'STALE': 0, 'RESYNCED': 0, 'VERIFIED': 0}
for line in content.split('\n'):
    for s in counts:
        if s in line:
            counts[s] += 1
total = sum(counts.values())
if total > 0:
    summary = ', '.join(f'{k}={v}' for k, v in counts.items() if v > 0)
    print(f'Checkpoint: {summary}')
" 2>/dev/null || true
fi

# Append pause entry to log.md
if [ -f "$CTX/log.md" ]; then
  echo "" >> "$CTX/log.md"
  echo "- $TIMESTAMP — session paused" >> "$CTX/log.md"
fi
