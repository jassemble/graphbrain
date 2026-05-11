#!/usr/bin/env bash
# Skill detection engine
# Evaluates registry.json detect rules against project filesystem
# --quiet: only output if delta found vs existing manifest (~5ms)
set -euo pipefail

QUIET=false
[ "${1:-}" = "--quiet" ] && QUIET=true

PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
REGISTRY="$PACKAGE_DIR/skills-registry/registry.json"
MANIFEST=".ctx/skills/manifest.json"

if [ ! -f "$REGISTRY" ]; then
  echo "ERROR: registry.json not found" >&2
  exit 1
fi

python3 -c "
import json, os, sys, fnmatch

quiet = $( [ \"$QUIET\" = true ] && echo True || echo False )
registry_path = '$REGISTRY'
manifest_path = '$MANIFEST'

with open(registry_path) as f:
    registry = json.load(f)

core = []
detected = []
available = []

for skill_name, info in registry.get('skills', {}).items():
    tier = info.get('tier', 'available')
    detect = info.get('detect', 'manual')

    if detect == 'always':
        core.append(skill_name)
        continue

    if detect == 'manual':
        available.append(skill_name)
        continue

    # Evaluate detection rules (any match = detected)
    matched = False
    if isinstance(detect, list):
        for rule in detect:
            if 'file_exists' in rule:
                if os.path.exists(rule['file_exists']):
                    matched = True
                    break
            elif 'dir_exists' in rule:
                if os.path.isdir(rule['dir_exists']):
                    matched = True
                    break
            elif 'file' in rule and 'contains' in rule:
                fpath = rule['file']
                if os.path.exists(fpath):
                    with open(fpath) as f:
                        if rule['contains'] in f.read():
                            matched = True
                            break
            elif 'glob' in rule:
                import glob
                if glob.glob(rule['glob'], recursive=True):
                    matched = True
                    break

    if matched:
        detected.append(skill_name)
        # Also install dependencies
        for dep in info.get('also_installs', []):
            if dep not in detected:
                detected.append(dep)
    else:
        available.append(skill_name)

result = {
    'core': core,
    'detected': detected,
    'available': available
}

# Quiet mode: compare against existing manifest
if quiet and os.path.exists(manifest_path):
    with open(manifest_path) as f:
        manifest = json.load(f)
    existing_detected = set()
    for skill, info in manifest.get('skills', {}).items():
        if info.get('reason', '').startswith('detected'):
            existing_detected.add(skill)
    new_detected = set(detected) - existing_detected
    if new_detected:
        for s in new_detected:
            short = s.split('/')[-1]
            print(f'New stack detected: {short}. Run \`brain add-skill {short}\` to install.')
    sys.exit(0)

print(json.dumps(result, indent=2))
"
