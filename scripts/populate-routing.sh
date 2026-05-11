#!/usr/bin/env bash
# Populate .ctx/routing.md with keyword->page mappings from graph.json
# Stays under 400 tokens by keeping only top entries by node degree.
set -euo pipefail

GRAPH="${1:-.ctx/graph/graph.json}"

if [ ! -f "$GRAPH" ]; then
  echo "Error: graph.json not found at $GRAPH" >&2
  exit 1
fi

export GRAPH_PATH="$GRAPH"

python3 << 'PYEOF'
import json, os
from collections import defaultdict

graph_path = os.environ.get("GRAPH_PATH", ".ctx/graph/graph.json")
with open(graph_path) as f:
    data = json.load(f)

nodes = data.get("nodes", [])
edges = data.get("edges", data.get("links", []))

degree = defaultdict(int)
for e in edges:
    degree[e.get("source", "")] += 1
    degree[e.get("target", "")] += 1

# Categorize nodes
modules = []
entities = []
concepts = []

for n in nodes:
    nid = n.get("id", n.get("name", ""))
    label = n.get("label", n.get("name", nid))
    ntype = n.get("type", n.get("node_type", "")).lower()
    d = degree.get(nid, 0)
    slug = label.lower().replace(" ", "-").replace("/", "-")

    if ntype in ("file", "module", "directory"):
        # Use directory slug for module routing (modules are per-directory)
        dir_name = os.path.dirname(n.get("file", label)).strip("/") or "root"
        dir_slug = dir_name.replace("/", "-").lower()
        modules.append((d, dir_slug, dir_name))
    elif ntype in ("class", "service", "function", "model", "interface", "component", "method"):
        entities.append((d, slug, label))
    # Skip other types (methods as standalone, etc.) — they have no pages

# Deduplicate modules (multiple files per directory)
seen_modules = {}
for d, slug, label in modules:
    if slug not in seen_modules or d > seen_modules[slug][0]:
        seen_modules[slug] = (d, slug, label)
modules = list(seen_modules.values())

# Sort by degree descending, keep top entries
modules.sort(reverse=True)
entities.sort(reverse=True)
concepts.sort(reverse=True)

def fmt(items, wtype, limit=8):
    lines = []
    for d, slug, label in items[:limit]:
        keyword = slug.split("-")[0] if "-" in slug else slug
        lines.append(f"{keyword}: -> [[{wtype}:{slug}]] -- {label}")
    return lines

out = ["# Routing -- Keyword to Page", "",
       "Route queries to the most relevant page using keyword matches.", "",
       "## Format", "", "```", "keyword: -> [[type:name]] -- one-line summary", "```", "",
       "## Routes", "",
       "### Modules", ""]
out.extend(fmt(modules, "module"))
out.extend(["", "### Entities", ""])
out.extend(fmt(entities, "entity"))
out.extend(["", "### Concepts", ""])
out.extend(fmt(concepts, "concept"))
out.extend(["", "### Sources", ""])

# Check token budget
content = "\n".join(out) + "\n"
words = len(content.split())
tokens_est = int(words * 0.75)
if tokens_est > 400:
    # Trim to fit
    while tokens_est > 400 and (modules or entities or concepts):
        if concepts:
            concepts.pop()
        elif entities:
            entities.pop()
        elif modules:
            modules.pop()
        out = ["# Routing -- Keyword to Page", "",
               "Route queries to the most relevant page using keyword matches.", "",
               "## Format", "", "```", "keyword: -> [[type:name]] -- one-line summary", "```", "",
               "## Routes", "", "### Modules", ""]
        out.extend(fmt(modules, "module"))
        out.extend(["", "### Entities", ""])
        out.extend(fmt(entities, "entity"))
        out.extend(["", "### Concepts", ""])
        out.extend(fmt(concepts, "concept"))
        out.extend(["", "### Sources", ""])
        content = "\n".join(out) + "\n"
        tokens_est = int(len(content.split()) * 0.75)

with open(".ctx/routing.md", "w") as f:
    f.write(content)

total = len(modules[:8]) + len(entities[:8]) + len(concepts[:8])
print(f"populate-routing: {total} entries, ~{tokens_est} tokens")
PYEOF
