#!/usr/bin/env bash
# Skill installer (brain init Phase B)
# Detects project stack, copies matching skill packages into .ctx/skills/
set -euo pipefail

PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CTX=".ctx"
REGISTRY_DIR="$PACKAGE_DIR/skills-registry"
SKILLS_DIR="$CTX/skills"
MANIFEST="$SKILLS_DIR/manifest.json"

if [ ! -d "$CTX" ]; then
  echo "ERROR: .ctx/ not found. Run brain-init.sh first." >&2
  exit 1
fi

# --- Manual add-skill mode ---
if [ "${1:-}" = "add-skill" ] && [ -n "${2:-}" ]; then
  SKILL_NAME="$2"
  python3 -c "
import json, os, shutil, datetime

skill_name = '$SKILL_NAME'
registry_dir = '$REGISTRY_DIR'
skills_dir = '$SKILLS_DIR'
manifest_path = '$MANIFEST'

# Find skill in registry
found = None
for tier in ['core', 'detected', 'available']:
    src = os.path.join(registry_dir, tier, skill_name)
    if os.path.isdir(src):
        found = (tier, src)
        break

if not found:
    print(f'ERROR: skill \"{skill_name}\" not found in registry')
    raise SystemExit(1)

tier, src = found
dst = os.path.join(skills_dir, skill_name)
if os.path.exists(dst):
    shutil.rmtree(dst)
shutil.copytree(src, dst)

# Update manifest
manifest = {}
if os.path.exists(manifest_path):
    with open(manifest_path) as f:
        manifest = json.load(f)

manifest.setdefault('skills', {})[f'{tier}/{skill_name}'] = {
    'reason': f'manually installed via add-skill'
}
if skill_name in manifest.get('available', []):
    manifest['available'].remove(skill_name)

with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2)

print(f'Installed {skill_name} from {tier}/ into {dst}/')
"
  exit $?
fi

# Run detection
detection=$(AGENTCTX_PACKAGE_DIR="$PACKAGE_DIR" bash "$PACKAGE_DIR/scripts/detect-skills.sh" 2>&1)
echo "Detection result:"
echo "$detection"
echo ""

# Write detection to temp file to avoid shell injection issues
DETECT_TMP=$(mktemp)
echo "$detection" > "$DETECT_TMP"
trap 'rm -f "$DETECT_TMP"' EXIT

# Install skills
python3 -c "
import json, os, shutil, datetime

ctx = '$CTX'
registry_dir = '$REGISTRY_DIR'
skills_dir = '$SKILLS_DIR'
manifest_path = '$MANIFEST'

with open('$DETECT_TMP') as f:
    detection = json.load(f)
today = datetime.date.today().isoformat()

manifest = {
    'installed': today,
    'registry_version': '1.0',
    'detected_stack': [s.split('/')[-1] for s in detection.get('detected', [])],
    'skills': {},
    'available': [s.split('/')[-1] for s in detection.get('available', [])]
}

installed = 0

# Install core skills
for skill in detection.get('core', []):
    src = os.path.join(registry_dir, skill)
    dst = os.path.join(skills_dir, skill.split('/')[-1])
    if os.path.isdir(src):
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        manifest['skills'][skill] = {'reason': 'core — always installed'}
        installed += 1

# Install detected skills
for skill in detection.get('detected', []):
    src = os.path.join(registry_dir, skill)
    dst = os.path.join(skills_dir, skill.split('/')[-1])
    if os.path.isdir(src):
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        manifest['skills'][skill] = {'reason': f'detected: filesystem signal matched'}
        installed += 1

with open(manifest_path, 'w') as f:
    json.dump(manifest, f, indent=2)

print(f'Installed {installed} skills to {skills_dir}/')
print(f'Manifest written to {manifest_path}')
"
