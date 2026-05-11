#!/usr/bin/env bash
# Generate .ctx/modules/ pages from graph.json
# Groups code nodes by source directory, creates one module page per directory.
# Incremental: skips directories whose source-hash matches.
set -euo pipefail

GRAPH="${1:-.ctx/graph/graph.json}"
MODULES_DIR=".ctx/modules"
TEMPLATE="$MODULES_DIR/_template.md"

if [ ! -f "$GRAPH" ]; then
  echo "Error: graph.json not found at $GRAPH" >&2
  exit 1
fi

created=0
updated=0
skipped=0

# Extract code-type nodes grouped by directory
# Output: dir_name \t source_hash \t entities (comma-separated)
groups=$(python3 -c "
import json, os, hashlib
from collections import defaultdict

with open('$GRAPH') as f:
    data = json.load(f)

nodes = data.get('nodes', [])
dir_entities = defaultdict(list)
dir_files = defaultdict(set)

for n in nodes:
    sf = n.get('source_file', n.get('file', ''))
    if not sf:
        continue
    d = os.path.dirname(sf).strip('/')
    if not d:
        d = 'root'
    dir_entities[d].append(n.get('label', n.get('name', n.get('id', ''))))
    dir_files[d].add(sf)

for d in sorted(dir_entities):
    files_str = '|'.join(sorted(dir_files[d]))
    h = hashlib.sha256(files_str.encode()).hexdigest()[:12]
    ents = ','.join(dir_entities[d][:20])
    print(f'{d}\t{h}\t{ents}')
")

while IFS=$'\t' read -r dir_name source_hash entities; do
  slug=$(echo "$dir_name" | tr '/' '-' | tr '[:upper:]' '[:lower:]')
  outfile="$MODULES_DIR/$slug.md"

  # Check existing hash for incremental skip
  if [ -f "$outfile" ]; then
    existing_hash=$(grep '^source-hash:' "$outfile" | head -1 | awk '{print $2}' | tr -d '"')
    if [ "$existing_hash" = "$source_hash" ]; then
      skipped=$((skipped + 1))
      continue
    fi
    updated=$((updated + 1))
  else
    created=$((created + 1))
  fi

  # Build entity wikilinks
  entity_links=""
  IFS=',' read -ra ent_arr <<< "$entities"
  for e in "${ent_arr[@]}"; do
    [ -z "$e" ] && continue
    e_slug=$(echo "$e" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    entity_links="$entity_links
- [[entity:$e_slug]]"
  done

  cat > "$outfile" <<EOF
---
title: "$dir_name"
category: module
created: $(date +%Y-%m-%d)
updated: $(date +%Y-%m-%d)
tags: []
source-hash: "$source_hash"
related_skills: []
related_templates: []
---

# $dir_name

## Definition

Module covering the \`$dir_name/\` directory.

## Current Understanding

Source directory: \`$dir_name/\`

## Phase Mapping

## Related Concepts
$entity_links

## Sources
EOF

done <<< "$groups"

echo "graph-to-modules: created=$created updated=$updated skipped=$skipped"
