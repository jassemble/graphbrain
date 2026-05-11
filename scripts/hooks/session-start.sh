#!/usr/bin/env bash
# SessionStart hook
# Loads minimal context + builds skill routing table
set -euo pipefail

CTX=".ctx"
[ ! -d "$CTX" ] && exit 0

# Record session start time for duration tracking (avoid python for speed)
date +%s > "$CTX/.session_start" 2>/dev/null || true

# --- 2.1: Load core context ---
echo "## Brain Context (SessionStart)"
echo ""

if [ -f "$CTX/protocol.md" ]; then
  echo "### Protocol"
  cat "$CTX/protocol.md"
  echo ""
fi

if [ -f "$CTX/decisions.md" ]; then
  echo "### Decisions"
  cat "$CTX/decisions.md"
  echo ""
fi

if [ -f "$CTX/log.md" ]; then
  echo "### Recent Log (last 5)"
  # Extract last 5 non-empty, non-comment lines from Activity History
  { sed -n '/## Activity History/,$ p' "$CTX/log.md" | grep -v '^$' | grep -v '^#' | grep -v '^<!--' | tail -5; } || true
  echo ""
fi

# --- 2.2: Skill routing table ---
MANIFEST="$CTX/skills/manifest.json"
if [ -f "$MANIFEST" ]; then
  echo "### Skill Routing Table"
  python3 -c "
import json, os, glob, re

manifest_path = '$MANIFEST'
ctx = '$CTX'

with open(manifest_path) as f:
    manifest = json.load(f)

routing = {'trigger_phrases': {}, 'path_globs': {}}
detected_stack = manifest.get('detected_stack', [])

# Scan installed skills for SKILL.md frontmatter (no yaml import for speed)
skills_dir = os.path.join(ctx, 'skills')
for skill_dir in glob.glob(os.path.join(skills_dir, '*/')):
    skill_md = os.path.join(skill_dir, 'SKILL.md')
    if not os.path.exists(skill_md):
        continue
    with open(skill_md) as f:
        content = f.read()
    if not content.startswith('---'):
        continue
    parts = content.split('---', 2)
    if len(parts) < 3:
        continue
    fm_text = parts[1]
    skill_path = skill_dir.rstrip('/')
    # Parse trigger_phrases from YAML without importing yaml
    in_triggers = False
    in_paths = False
    for line in fm_text.split('\n'):
        stripped = line.strip()
        if stripped.startswith('trigger_phrases:'):
            in_triggers = True; in_paths = False; continue
        elif stripped.startswith('paths:'):
            in_paths = True; in_triggers = False; continue
        elif stripped and not stripped.startswith('-'):
            if ':' in stripped:
                in_triggers = False; in_paths = False
            continue
        if in_triggers and stripped.startswith('- '):
            phrase = stripped[2:].strip().strip('\"').strip(\"'\")
            routing['trigger_phrases'][phrase.lower()] = skill_path
        elif in_paths and stripped.startswith('- '):
            p = stripped[2:].strip().strip('\"').strip(\"'\")
            routing['path_globs'][p] = skill_path

print(json.dumps({'detected_stack': detected_stack, 'routing': routing}))
" 2>/dev/null || echo '{"detected_stack": [], "routing": {"trigger_phrases": {}, "path_globs": {}}}'
else
  echo '{"detected_stack": [], "routing": {"trigger_phrases": {}, "path_globs": {}}}'
fi
