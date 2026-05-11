#!/usr/bin/env bash
# Agent installer — copies agent definitions into .ctx/agents/
set -euo pipefail

PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CTX=".ctx"
REGISTRY_DIR="$PACKAGE_DIR/agents-registry"
AGENTS_DIR="$CTX/agents"
MANIFEST="$AGENTS_DIR/manifest.json"

if [ ! -d "$CTX" ]; then
  echo "ERROR: .ctx/ not found. Run brain-init.sh first." >&2
  exit 1
fi

# --- Manual add-agent mode ---
if [ "${1:-}" = "add-agent" ] && [ -n "${2:-}" ]; then
  AGENT_NAME="$2"
  python3 -c "
import json, os, shutil

agent_name = '$AGENT_NAME'
registry_dir = '$REGISTRY_DIR'
agents_dir = '$AGENTS_DIR'
manifest_path = '$MANIFEST'

# Find agent in registry
found = None
for tier in ['brain', 'sdlc', 'community']:
    src = os.path.join(registry_dir, tier, agent_name)
    if os.path.isdir(src):
        found = (tier, src)
        break

if not found:
    print(f'ERROR: agent \"{agent_name}\" not found in registry')
    raise SystemExit(1)

tier, src = found
dst = os.path.join(agents_dir, agent_name)
os.makedirs(os.path.dirname(dst), exist_ok=True)
if os.path.exists(dst):
    shutil.rmtree(dst)
shutil.copytree(src, dst)

# Update manifest
manifest = {}
if os.path.exists(manifest_path):
    with open(manifest_path) as f:
        manifest = json.load(f)

manifest.setdefault('agents', {})[f'{tier}/{agent_name}'] = {
    'reason': 'manually installed via add-agent'
}

with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2)

print(f'Installed agent {agent_name} from {tier}/ into {dst}/')
"
  exit $?
fi

# --- Auto-install from registry ---
REGISTRY="$REGISTRY_DIR/registry.json"
if [ ! -f "$REGISTRY" ]; then
  echo "ERROR: agents registry.json not found" >&2
  exit 1
fi

mkdir -p "$AGENTS_DIR"

python3 -c "
import json, os, shutil, datetime

registry_dir = '$REGISTRY_DIR'
agents_dir = '$AGENTS_DIR'
manifest_path = '$MANIFEST'
registry_path = '$REGISTRY'

with open(registry_path) as f:
    registry = json.load(f)

today = datetime.date.today().isoformat()
manifest = {
    'installed': today,
    'agents': {},
    'available': []
}

installed = 0
for agent_name, info in registry.get('agents', {}).items():
    install = info.get('install', 'manual')
    tier = agent_name.split('/')[0]
    short = agent_name.split('/')[-1]

    src = os.path.join(registry_dir, agent_name)
    dst = os.path.join(agents_dir, short)

    if install == 'always' and os.path.isdir(src):
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        manifest['agents'][agent_name] = {'reason': f'{tier} — always installed'}
        installed += 1
    elif install == 'manual':
        manifest['available'].append(short)

with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2)

print(f'Installed {installed} agents to {agents_dir}/')
print(f'Available (manual): {len(manifest[\"available\"])} agents')
"
