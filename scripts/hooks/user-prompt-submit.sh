#!/usr/bin/env bash
# UserPromptSubmit hook
# Intent matching against skill + agent trigger phrases, on-demand loading
# Arg: $1 = user prompt text
set -euo pipefail

CTX=".ctx"
[ ! -d "$CTX" ] && exit 0

PROMPT="${1:-}"
[ -z "$PROMPT" ] && exit 0

export BRAIN_PROMPT="$PROMPT"
export BRAIN_CTX="$CTX"

python3 -c "
import json, os, sys, re, glob as g

ctx = os.environ.get('BRAIN_CTX', '.ctx')
prompt = os.environ.get('BRAIN_PROMPT', '').lower()

def parse_trigger_phrases(content):
    \"\"\"Extract trigger_phrases from YAML frontmatter without yaml import.\"\"\"
    if not content.startswith('---'):
        return []
    parts = content.split('---', 2)
    if len(parts) < 3:
        return []
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
    return phrases

def load_body(content):
    \"\"\"Extract body (after frontmatter) from markdown.\"\"\"
    if content.startswith('---'):
        return content.split('---', 2)[-1].strip()
    return content

# --- Match skills ---
skills_manifest = os.path.join(ctx, 'skills', 'manifest.json')
if os.path.exists(skills_manifest):
    with open(skills_manifest) as f:
        manifest = json.load(f)
    skills_dir = os.path.join(ctx, 'skills')
    for skill_name, info in manifest.get('skills', {}).items():
        skill_dir = os.path.join(skills_dir, skill_name.split('/')[-1])
        skill_md = os.path.join(skill_dir, 'SKILL.md')
        if not os.path.exists(skill_md):
            continue
        with open(skill_md) as f:
            content = f.read()
        phrases = parse_trigger_phrases(content)
        for phrase in phrases:
            if phrase in prompt:
                print(f'## Skill Activated: {skill_name} (matched: \"{phrase}\")')
                print(load_body(content)[:2000])
                print()
                break

# --- Match agents ---
agents_manifest = os.path.join(ctx, 'agents', 'manifest.json')
if os.path.exists(agents_manifest):
    with open(agents_manifest) as f:
        manifest = json.load(f)
    agents_dir = os.path.join(ctx, 'agents')
    for agent_name, info in manifest.get('agents', {}).items():
        agent_short = agent_name.split('/')[-1]
        agent_md = os.path.join(agents_dir, agent_short, 'AGENT.md')
        if not os.path.exists(agent_md):
            continue
        with open(agent_md) as f:
            content = f.read()
        phrases = parse_trigger_phrases(content)
        for phrase in phrases:
            if phrase in prompt:
                print(f'## Agent Activated: {agent_short} (matched: \"{phrase}\")')
                print(load_body(content)[:3000])
                print()
                break
" 2>/dev/null || true

# --- Skill re-detection (~5ms filesystem check) ---
PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
if [ -f "$PACKAGE_DIR/scripts/detect-skills.sh" ]; then
  AGENTCTX_PACKAGE_DIR="$PACKAGE_DIR" bash "$PACKAGE_DIR/scripts/detect-skills.sh" --quiet 2>/dev/null || true
fi
