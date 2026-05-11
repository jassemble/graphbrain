#!/usr/bin/env bash
# Generate .ctx/index.md catalog with fingerprints from graph.json
set -euo pipefail

GRAPH="${1:-.ctx/graph/graph.json}"
INDEX=".ctx/index.md"
CTX=".ctx"

export GRAPH_PATH="$GRAPH"

python3 << 'PYEOF'
import json, os, glob

graph_path = os.environ.get("GRAPH_PATH", ".ctx/graph/graph.json")
ctx = ".ctx"

# Load graph if available
nodes_by_id = {}
if os.path.exists(graph_path):
    with open(graph_path) as f:
        data = json.load(f)
    for n in data.get("nodes", []):
        nid = n.get("id", n.get("name", ""))
        nodes_by_id[nid] = n

def token_estimate(path):
    try:
        words = len(open(path).read().split())
        return f"{words * 75 // 100 / 1000:.1f}K"
    except:
        return "?K"

def get_cluster(name):
    n = nodes_by_id.get(name, {})
    c = n.get("community", n.get("cluster", ""))
    return f"cluster:{c}" if c else ""

edge_counts = {}
if os.path.exists(graph_path):
    with open(graph_path) as f2:
        gdata = json.load(f2)
    for e in gdata.get("edges", gdata.get("links", [])):
        s = e.get("source", "")
        t = e.get("target", "")
        edge_counts[s] = edge_counts.get(s, 0) + 1
        edge_counts[t] = edge_counts.get(t, 0) + 1

def get_degree(name):
    d = edge_counts.get(name, 0)
    return f"degree:{d}" if d else ""

sections = {
    "concepts": [],
    "entities": [],
    "modules": [],
    "sources": [],
    "decisions": [],
}

for section, entries in sections.items():
    dir_path = os.path.join(ctx, section)
    if not os.path.isdir(dir_path):
        continue
    for f in sorted(os.listdir(dir_path)):
        if f.startswith("_") or not f.endswith(".md"):
            continue
        name = f[:-3]
        fpath = os.path.join(dir_path, f)
        tokens = token_estimate(fpath)

        # Read first meaningful line for summary
        summary = ""
        with open(fpath) as fh:
            for line in fh:
                line = line.strip()
                if line and not line.startswith(("#", "---", "title:", "category:")):
                    summary = line[:60]
                    break

        cluster = get_cluster(name)
        degree = get_degree(name)
        dir_to_type = {"entities": "entity", "concepts": "concept", "modules": "module", "sources": "source", "decisions": "decision"}
        wtype = dir_to_type.get(section, section)
        parts = [f"[[{wtype}:{name}]]", f"{tokens} tokens"]
        if summary:
            parts.append(summary)
        if cluster:
            parts.append(cluster)
        if degree:
            parts.append(degree)
        entries.append("- " + " -- ".join(parts))

# Build output
lines = [
    "# Index -- Page Catalog",
    "",
    "Categorized catalog of all .ctx/ pages with fingerprints.",
    "",
    "## Format",
    "",
    "```",
    "- [[type:name]] -- Xt -- summary -- cluster:X",
    "```",
]

for section_name in ["Concepts", "Entities", "Modules", "Sources", "Decisions"]:
    lines.append("")
    lines.append(f"## {section_name}")
    lines.append("")
    key = section_name.lower()
    entries = sections.get(key, [])
    if entries:
        lines.extend(entries)

with open(".ctx/index.md", "w") as f:
    f.write("\n".join(lines) + "\n")

total = sum(len(v) for v in sections.values())
print(f"generate-index: {total} entries written to .ctx/index.md")
PYEOF
