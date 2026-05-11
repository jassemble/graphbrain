#!/usr/bin/env bash
# UserPromptSubmit hook
# Intent matching against skill trigger phrases + skill re-detection
# Arg: $1 = user prompt text
set -euo pipefail

CTX=".ctx"
[ ! -d "$CTX" ] && exit 0

PROMPT="${1:-}"
[ -z "$PROMPT" ] && exit 0

export BRAIN_PROMPT="$PROMPT"
export BRAIN_CTX="$CTX"

python3 -c "
import json, os, sys, re

ctx = os.environ.get('BRAIN_CTX', '.ctx')
prompt = os.environ.get('BRAIN_PROMPT', '').lower()
manifest_path = os.path.join(ctx, 'skills', 'manifest.json')

if not os.path.exists(manifest_path):
    sys.exit(0)

with open(manifest_path) as f:
    manifest = json.load(f)

# Build trigger phrase index from installed skills
matches = []
skills_dir = os.path.join(ctx, 'skills')

for skill_name, info in manifest.get('skills', {}).items():
    skill_dir = os.path.join(skills_dir, skill_name.split('/')[-1])
    skill_md = os.path.join(skill_dir, 'SKILL.md')
    if not os.path.exists(skill_md):
        continue

    with open(skill_md) as f:
        content = f.read()

    # Extract trigger_phrases from frontmatter
    if not content.startswith('---'):
        continue
    parts = content.split('---', 2)
    if len(parts) < 3:
        continue

    phrases = []
    in_triggers = False
    for line in parts[1].split('\n'):
        stripped = line.strip()
        if stripped.startswith('trigger_phrases:'):
            in_triggers = True
            continue
        if in_triggers:
            if stripped.startswith('- '):
                phrase = stripped[2:].strip().strip('\"').strip(\"'\").lower()
                phrases.append(phrase)
            elif stripped and not stripped.startswith('-'):
                in_triggers = False

    for phrase in phrases:
        if phrase in prompt:
            matches.append({'skill': skill_name, 'phrase': phrase, 'path': skill_dir})

if matches:
    # Load matched skills
    for m in matches:
        skill_md = os.path.join(m['path'], 'SKILL.md')
        if os.path.exists(skill_md):
            print(f'## Activated: {m[\"skill\"]} (matched: \"{m[\"phrase\"]}\")')
            with open(skill_md) as f:
                # Print just the body, not frontmatter
                content = f.read()
                if content.startswith('---'):
                    body = content.split('---', 2)[-1].strip()
                else:
                    body = content
                print(body[:2000])  # Cap output
            print()
" 2>/dev/null || true

# --- Skill re-detection (~5ms filesystem check) ---
PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
if [ -f "$PACKAGE_DIR/scripts/detect-skills.sh" ]; then
  AGENTCTX_PACKAGE_DIR="$PACKAGE_DIR" bash "$PACKAGE_DIR/scripts/detect-skills.sh" --quiet 2>/dev/null || true
fi
