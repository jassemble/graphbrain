#!/usr/bin/env bash
# PostToolUse hook
# Validates .ctx/ changes, marks modules stale, injects breadcrumbs
# Arg: $1 = file path that was edited/read
set -euo pipefail

CTX=".ctx"
[ ! -d "$CTX" ] && exit 0
[ -z "${1:-}" ] && exit 0

FILE="$1"

# --- If file is in .ctx/: validate ---
case "$FILE" in "$CTX/"*)
  python3 -c "
import sys, os

f = '$FILE'
# Block concept deletion (exit 2 = block)
if '/concepts/' in f and not os.path.exists(f):
    print('BLOCKED: concept page deleted — archive instead')
    sys.exit(2)

# Block overwrite of CONFIRMED content
if os.path.exists(f):
    with open(f) as fh:
        content = fh.read()
    if 'status: CONFIRMED' in content.lower() or 'status: confirmed' in content:
        # Allow edits but warn
        print('WARNING: editing CONFIRMED page — changes will need re-verification')
" 2>/dev/null
  exit $?
  ;; esac

# --- If file is source code: breadcrumbs + stale marking ---
python3 -c "
import os, json, re, datetime

file_path = '$FILE'
ctx = '$CTX'
status_path = os.path.join(ctx, 'status.md')

# Find which module this file belongs to
file_dir = os.path.dirname(file_path).strip('/')
if not file_dir:
    file_dir = 'root'
slug = file_dir.replace('/', '-').lower()
module_page = os.path.join(ctx, 'modules', slug + '.md')

# Mark module stale in status.md
if os.path.exists(status_path) and os.path.exists(module_page):
    with open(status_path) as f:
        content = f.read()
    today = datetime.date.today().isoformat()
    if slug in content:
        # Update existing entry to STALE
        lines = content.split('\n')
        new_lines = []
        for line in lines:
            if slug in line and '|' in line:
                parts = [p.strip() for p in line.split('|')]
                if len(parts) >= 5:
                    parts[2] = ' STALE '
                    parts[3] = f' {today} '
                    line = '|'.join(parts)
            new_lines.append(line)
        with open(status_path, 'w') as f:
            f.write('\n'.join(new_lines))

# Inject breadcrumb context
breadcrumb_parts = []
if os.path.exists(module_page):
    breadcrumb_parts.append(f'Module: [[module:{slug}]]')

# Find related entities by scanning module page for entity wikilinks
if os.path.exists(module_page):
    with open(module_page) as f:
        mc = f.read()
    entities = re.findall(r'\[\[entity:([a-z0-9_-]+)\]\]', mc)
    if entities:
        breadcrumb_parts.append('Entities: ' + ', '.join(f'[[entity:{e}]]' for e in entities[:5]))

# Check skill path globs for matching conventions
manifest_path = os.path.join(ctx, 'skills', 'manifest.json')
if os.path.exists(manifest_path):
    import glob as g
    import fnmatch
    with open(manifest_path) as f:
        manifest = json.load(f)
    for skill_name, info in manifest.get('skills', {}).items():
        skill_dir = os.path.join(ctx, 'skills', skill_name.split('/')[-1])
        skill_md = os.path.join(skill_dir, 'SKILL.md')
        if not os.path.exists(skill_md):
            continue
        # Quick check: does this skill's paths match our file?
        with open(skill_md) as f:
            sc = f.read()
        if 'paths:' in sc:
            for line in sc.split('\n'):
                line = line.strip().lstrip('- ').strip('\"').strip(\"'\")
                if '*' in line and fnmatch.fnmatch(file_path, line):
                    conv = os.path.join(skill_dir, 'references', 'conventions.md')
                    if os.path.exists(conv):
                        with open(conv) as cf:
                            summary = cf.readline().strip()
                        breadcrumb_parts.append(f'Skill: {skill_name} — {summary}')
                    break

if breadcrumb_parts:
    print('## Breadcrumb')
    for p in breadcrumb_parts:
        print(f'- {p}')
" 2>/dev/null || true
