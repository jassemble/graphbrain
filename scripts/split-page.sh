#!/usr/bin/env bash
# Split oversized page by ## sections into sub-pages
# Usage: bash scripts/split-page.sh .ctx/entities/auth-service.md
set -euo pipefail

PAGE="${1:-}"
if [ -z "$PAGE" ] || [ ! -f "$PAGE" ]; then
  echo "Usage: split-page.sh <path-to-page>" >&2
  exit 1
fi

python3 -c "
import os, re

page = '$PAGE'
with open(page) as f:
    content = f.read()

# Extract frontmatter
fm = ''
body = content
if content.startswith('---'):
    parts = content.split('---', 2)
    if len(parts) >= 3:
        fm = '---' + parts[1] + '---\n'
        body = parts[2]

# Split by ## headers
sections = re.split(r'^(## .+)$', body, flags=re.MULTILINE)
if len(sections) < 3:
    print('Page has fewer than 2 sections — nothing to split.')
    exit(0)

base = page[:-3]  # remove .md
basename = os.path.basename(base)
dirpath = os.path.dirname(page)

# Build summary page and sub-pages
summary_links = []
created = []

i = 1
while i < len(sections):
    header = sections[i].strip()
    section_body = sections[i+1] if i+1 < len(sections) else ''
    slug = re.sub(r'[^a-z0-9]+', '-', header.lower().replace('## ', '')).strip('-')
    sub_name = f'{basename}-{slug}.md'
    sub_path = os.path.join(dirpath, sub_name)

    # Write sub-page
    sub_content = fm + f'# {basename} — {header.replace(\"## \", \"\")}\n\n{section_body.strip()}\n'
    with open(sub_path, 'w') as f:
        f.write(sub_content)
    created.append(sub_path)

    # Determine wikilink type from directory
    wtype = os.path.basename(dirpath).rstrip('s')
    if wtype in ('reference', 'graph', 'archive'):
        wtype = 'concept'
    summary_links.append(f'- [[{wtype}:{basename}-{slug}]] — {header.replace(\"## \", \"\")}')
    i += 2

# Rewrite original as summary
title_match = re.search(r'^# (.+)$', body, re.MULTILINE)
title = title_match.group(1) if title_match else basename
summary = fm + f'# {title}\n\nThis page has been split into sub-pages:\n\n' + '\n'.join(summary_links) + '\n'
with open(page, 'w') as f:
    f.write(summary)

print(f'Split {page} into {len(created)} sub-pages:')
for c in created:
    print(f'  {c}')

# Update index.md
index_path = os.path.join('.ctx', 'index.md')
if os.path.exists(index_path):
    with open(index_path, 'a') as f:
        for c in created:
            name = os.path.basename(c)[:-3]
            f.write(f'\n- [[{wtype}:{name}]] — split from {basename}')
    print(f'Updated {index_path}')
"
