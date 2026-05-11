#!/usr/bin/env bash
# Phase 3: VERIFY — Run lint checks against .ctx/ state
# Exit 0 = pass, Exit 1 = errors found
set -euo pipefail

CTX=".ctx"
PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
SCRIPTS="$PACKAGE_DIR/scripts"
READ_ONLY="${1:-}"
START=$(python3 -c "import time; print(int(time.time()*1000))")

echo "Phase 3: VERIFY"

errors=0
warnings=0
infos=0
findings=""

add_finding() {
  local severity="$1" check="$2" msg="$3"
  findings="$findings
[$severity] $check: $msg"
  case "$severity" in
    ERROR) errors=$((errors + 1)) ;;
    WARNING) warnings=$((warnings + 1)) ;;
    INFO) infos=$((infos + 1)) ;;
  esac
}

# 1. Broken wikilinks
wl_result=$(bash "$SCRIPTS/wikilink-check.sh" 2>&1) || true
broken=$(echo "$wl_result" | { grep -c "^BROKEN:" || true; })
if [ "$broken" -gt 0 ]; then
  add_finding "ERROR" "Broken wikilinks" "$broken broken links found"
fi

# 2-14: Python-based checks
export AGENTCTX_SCRIPTS_DIR="$SCRIPTS"
py_findings=$(python3 -c "
import os, re, datetime, json, subprocess, hashlib

ctx = '$CTX'
findings = []

# Collect all md files
all_md = []
for root, dirs, files in os.walk(ctx):
    for f in files:
        if f.endswith('.md') and not f.startswith('_'):
            all_md.append(os.path.join(root, f))

# Load graph if available
graph_path = os.path.join(ctx, 'graph', 'graph.json')
graph_data = {}
if os.path.exists(graph_path):
    with open(graph_path) as f:
        graph_data = json.load(f)

edges = graph_data.get('edges', graph_data.get('links', []))
nodes = graph_data.get('nodes', [])
node_map = {n.get('id', n.get('name', '')): n for n in nodes}

# 2. Stale modules (source-hash mismatch)
modules_dir = os.path.join(ctx, 'modules')
if os.path.isdir(modules_dir):
    for f in os.listdir(modules_dir):
        if f.startswith('_') or not f.endswith('.md'): continue
        fpath = os.path.join(modules_dir, f)
        content = open(fpath).read()
        m = re.search(r'source-hash:\s*[\"'\\'']?([a-f0-9]+)', content)
        if m:
            stored_hash = m.group(1)
            # Check if source dir exists and compute current hash
            dir_name = f[:-3]
            if os.path.isdir(dir_name):
                try:
                    result = subprocess.run(['git', 'log', '-1', '--format=%H', '--', dir_name],
                                          capture_output=True, text=True, timeout=5)
                    current_hash = result.stdout.strip()[:12]
                    if current_hash and stored_hash and current_hash != stored_hash:
                        findings.append(('WARNING', 'Stale modules', f'module:{dir_name} hash mismatch: stored={stored_hash} current={current_hash}'))
                except:
                    pass

# 3. Orphan entities
entity_dir = os.path.join(ctx, 'entities')
if os.path.isdir(entity_dir):
    for f in os.listdir(entity_dir):
        if f.startswith('_') or not f.endswith('.md'): continue
        name = f[:-3]
        pattern = f'[[entity:{name}]]'
        found = any(pattern in open(md).read() for md in all_md if md != os.path.join(entity_dir, f))
        if not found:
            findings.append(('WARNING', 'Orphan entities', f'entity:{name} has no inbound wikilinks'))

# 4. Missing modules (every source dir with code should have a module page)
if graph_data and os.path.isdir(modules_dir):
    source_dirs = set()
    for n in nodes:
        fp = n.get('file', n.get('path', ''))
        if fp:
            source_dirs.add(os.path.dirname(fp) or '.')
    existing_modules = {f[:-3] for f in os.listdir(modules_dir) if f.endswith('.md') and not f.startswith('_')}
    for sd in source_dirs:
        slug = sd.replace('/', '-').replace('.', 'root')
        if slug not in existing_modules and sd not in existing_modules:
            findings.append(('ERROR', 'Missing modules', f'source dir {sd} has no module page'))

# 5. Pattern drift (claims in patterns.md should match graph)
patterns_path = os.path.join(ctx, 'patterns.md')
if os.path.exists(patterns_path) and graph_data:
    pc = open(patterns_path).read()
    # Check that referenced entities in patterns.md exist in graph
    pat_refs = re.findall(r'\[\[entity:([a-z0-9_-]+)\]\]', pc)
    for ref in pat_refs:
        if ref not in node_map:
            findings.append(('WARNING', 'Pattern drift', f'patterns.md references entity:{ref} not found in graph'))
    # Check cross-community claims
    cross_claims = re.findall(r'(\S+)\s*<->\s*(\S+)', pc)
    for src, tgt in cross_claims:
        edge_exists = any(
            (e.get('source','') == src and e.get('target','') == tgt) or
            (e.get('source','') == tgt and e.get('target','') == src)
            for e in edges
        )
        if not edge_exists:
            findings.append(('WARNING', 'Pattern drift', f'patterns.md claims {src} <-> {tgt} but no edge in graph'))

# 6. Token overflow with split suggestions
for fp in all_md:
    content = open(fp).read()
    words = len(content.split())
    tokens = int(words * 0.75)
    if tokens > 30000:
        sections = re.findall(r'^## (.+)$', content, re.MULTILINE)
        largest = sections[0] if sections else 'unknown'
        findings.append(('ERROR', 'Token overflow', f'{fp}: {tokens}t (>30K) — suggest split at ## {largest}'))

# 7. Protocol bloat
proto = os.path.join(ctx, 'protocol.md')
if os.path.exists(proto):
    words = len(open(proto).read().split())
    tokens = int(words * 0.75)
    if tokens > 500:
        findings.append(('ERROR', 'Protocol bloat', f'protocol.md: {tokens}t (>500)'))

# 7b. Routing budget
routing = os.path.join(ctx, 'routing.md')
if os.path.exists(routing):
    words = len(open(routing).read().split())
    tokens = int(words * 0.75)
    if tokens > 400:
        findings.append(('WARNING', 'Routing bloat', f'routing.md: {tokens}t (>400)'))

# 8. Contradiction check
try:
    scripts_dir = os.environ.get('AGENTCTX_SCRIPTS_DIR', 'scripts')
    result = subprocess.run(['bash', os.path.join(scripts_dir, 'detect-contradictions.sh')],
                          capture_output=True, text=True, timeout=10)
    output = result.stdout.strip()
    if 'Contradictions Detected' in output:
        count = re.search(r'Total:\s*(\d+)', output)
        n = count.group(1) if count else '?'
        findings.append(('WARNING', 'Contradiction', f'{n} contradictions detected between pages'))
except:
    pass

# 9. Orphan concepts
concept_dir = os.path.join(ctx, 'concepts')
if os.path.isdir(concept_dir):
    for f in os.listdir(concept_dir):
        if f.startswith('_') or not f.endswith('.md'): continue
        name = f[:-3]
        pattern = f'[[concept:{name}]]'
        found = any(pattern in open(md).read() for md in all_md if md != os.path.join(concept_dir, f))
        if not found:
            findings.append(('INFO', 'Orphan concepts', f'concept:{name} has no inbound wikilinks'))

# 10. Stale log
log = os.path.join(ctx, 'log.md')
if os.path.exists(log):
    dates = re.findall(r'(\d{4}-\d{2}-\d{2})', open(log).read())
    if dates:
        delta = (datetime.date.today() - datetime.date.fromisoformat(max(dates))).days
        if delta > 7:
            findings.append(('INFO', 'Stale log', f'last entry {delta} days old'))

# 11. Missing verification
status_path = os.path.join(ctx, 'status.md')
if os.path.exists(status_path) and os.path.isdir(modules_dir):
    sc = open(status_path).read()
    for f in os.listdir(modules_dir):
        if f.startswith('_') or not f.endswith('.md'): continue
        if f[:-3] not in sc:
            findings.append(('WARNING', 'Missing verification', f'module:{f[:-3]} not in status.md'))

# 12. Low-confidence edges
if os.path.isdir(entity_dir):
    for f in os.listdir(entity_dir):
        if f.startswith('_') or not f.endswith('.md'): continue
        c = open(os.path.join(entity_dir, f)).read()
        for m in re.finditer(r'confidence:\s*([\d.]+)', c):
            if float(m.group(1)) < 0.5:
                findings.append(('INFO', 'Low-confidence edges', f'{f}: edge with confidence {m.group(1)}'))
                break

# 13. EXTRACTED edge validity (edges with confidence=EXTRACTED should resolve to code refs)
for e in edges:
    if e.get('confidence', '') == 'EXTRACTED' or e.get('confidence_score', 0) == 1.0:
        src = e.get('source', '')
        tgt = e.get('target', '')
        src_file = e.get('source_file', e.get('file', ''))
        if src_file and not os.path.exists(src_file):
            findings.append(('WARNING', 'EXTRACTED edge validity', f'{src} -> {tgt}: source file {src_file} not found'))

# 14. Community map staleness
cmap_path = os.path.join(ctx, 'community_map.md')
if os.path.exists(cmap_path) and graph_data:
    cmap = open(cmap_path).read()
    graph_communities = set()
    for n in nodes:
        c = n.get('community', n.get('cluster', ''))
        if c: graph_communities.add(str(c))
    # Check if community_map references communities that exist in graph
    map_communities = set(re.findall(r'Community\s+(\d+)', cmap))
    if graph_communities and map_communities:
        stale = map_communities - graph_communities
        if stale:
            findings.append(('WARNING', 'Community map staleness', f'community_map.md references communities {stale} not in current graph'))
    elif graph_communities and not map_communities and 'Community' not in cmap:
        findings.append(('WARNING', 'Community map staleness', f'community_map.md has no communities but graph has {len(graph_communities)}'))

for sev, check, msg in findings:
    print(f'[{sev}] {check}: {msg}')
" 2>/dev/null) || true

# Parse python findings
while IFS= read -r line; do
  [ -z "$line" ] && continue
  case "$line" in
    \[ERROR\]*) add_finding "ERROR" "$(echo "$line" | sed 's/\[ERROR\] //' | cut -d: -f1)" "$(echo "$line" | cut -d: -f2-)" ;;
    \[WARNING\]*) add_finding "WARNING" "$(echo "$line" | sed 's/\[WARNING\] //' | cut -d: -f1)" "$(echo "$line" | cut -d: -f2-)" ;;
    \[INFO\]*) add_finding "INFO" "$(echo "$line" | sed 's/\[INFO\] //' | cut -d: -f1)" "$(echo "$line" | cut -d: -f2-)" ;;
  esac
done <<< "$py_findings"

END=$(python3 -c "import time; print(int(time.time()*1000))")
DURATION=$((END - START))

# Score
total=$((errors + warnings + infos))
if [ "$total" -eq 0 ]; then
  score="100%"
else
  passed=$((14 - errors - warnings))
  [ "$passed" -lt 0 ] && passed=0
  score="$((passed * 100 / 14))%"
fi

echo ""
echo "--- Lint Report ---"
echo "Score: $score"
echo "Errors: $errors | Warnings: $warnings | Info: $infos"
echo "Duration: ${DURATION}ms"
echo "$findings"

# Write report (skip if read-only mode)
if [ "$READ_ONLY" != "--read-only" ]; then
  cat > "$CTX/graph/brain-lint-report.md" << EOF
# Brain Lint Report

Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Summary
- Score: $score
- Errors: $errors
- Warnings: $warnings
- Info: $infos
- Duration: ${DURATION}ms

## Findings
$findings

## Top 3 Recommendations
$(echo "$findings" | grep -m1 "\[ERROR\]" | sed 's/^/1. Fix: /' || echo "1. No errors")
$(echo "$findings" | grep -m2 "\[WARNING\]" | tail -1 | sed 's/^/2. Address: /' || echo "2. No warnings")
$(echo "$findings" | grep -m1 "\[INFO\]" | sed 's/^/3. Review: /' || echo "3. No info items")
EOF
fi

[ "$errors" -gt 0 ] && exit 1 || exit 0
