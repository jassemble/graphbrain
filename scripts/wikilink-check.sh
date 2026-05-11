#!/usr/bin/env bash
# Find and validate all [[type:name]] wikilinks in .ctx/
# Exit 0 = all valid, Exit 1 = broken links found
set -euo pipefail

python3 -c "
import re, os, sys

ctx = '.ctx'
broken = []
total = 0
pattern = re.compile(r'\[\[([a-z]+):([a-z0-9_.-]+)\]\]')

# Map singular wikilink types to directory names (plural)
type_to_dir = {
    'entity': 'entities',
    'concept': 'concepts',
    'module': 'modules',
    'source': 'sources',
    'decision': 'decisions',
    'entitie': 'entities',  # common typo from index generator
}

for root, dirs, files in os.walk(ctx):
    for fname in files:
        if not fname.endswith('.md') or fname.startswith('_'):
            continue
        fpath = os.path.join(root, fname)
        with open(fpath) as f:
            for i, line in enumerate(f, 1):
                if line.strip().startswith(('\`\`\`',)) or '[[type:' in line:
                    continue
                for m in pattern.finditer(line):
                    total += 1
                    wtype, wname = m.group(1), m.group(2)
                    dir_name = type_to_dir.get(wtype, wtype + 's')
                    target = os.path.join(ctx, dir_name, wname + '.md')
                    if not os.path.exists(target):
                        broken.append(f'BROKEN: [[{wtype}:{wname}]] in {fpath}:{i}')

for b in broken:
    print(b)
print(f'Total: {total} wikilinks, {len(broken)} broken')
sys.exit(1 if broken else 0)
"
