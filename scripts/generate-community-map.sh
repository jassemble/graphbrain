#!/usr/bin/env bash
# Generate .ctx/community_map.md from graph.json Leiden clusters
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
if not os.path.exists(graph_path):
    graph_path = ".ctx/graph/graph.json"

with open(graph_path) as f:
    data = json.load(f)

nodes = data.get("nodes", [])
edges = data.get("edges", data.get("links", []))

# Group by community
communities = defaultdict(list)
for n in nodes:
    c = n.get("community", n.get("cluster", "unclustered"))
    communities[c].append(n)

# Compute degree per node
degree = defaultdict(int)
for e in edges:
    degree[e.get("source", "")] += 1
    degree[e.get("target", "")] += 1

# Find cross-community edges
cross_edges = []
node_community = {n.get("id", n.get("name", "")): n.get("community", n.get("cluster", "")) for n in nodes}
for e in edges:
    src_c = node_community.get(e.get("source", ""), "")
    tgt_c = node_community.get(e.get("target", ""), "")
    if src_c and tgt_c and src_c != tgt_c:
        cross_edges.append(e)

lines = ["# Community Map -- Responsibility Clusters", ""]

for cid in sorted(communities.keys(), key=lambda c: -len(communities[c])):
    members = communities[cid]
    modules = [n for n in members if n.get("type", n.get("node_type", "")).lower() in ("file", "module", "directory")]
    entities = [n for n in members if n.get("type", n.get("node_type", "")).lower() in ("class", "service", "function", "model", "interface", "component")]

    # God nodes: highest degree in community
    sorted_by_degree = sorted(members, key=lambda n: degree.get(n.get("id", n.get("name", "")), 0), reverse=True)
    god_nodes = sorted_by_degree[:3]

    # Cohesion score: ratio of internal edges to total possible edges
    member_ids = {n.get("id", n.get("name", "")) for n in members}
    internal_edges = sum(1 for e in edges if e.get("source","") in member_ids and e.get("target","") in member_ids)
    max_edges = len(members) * (len(members) - 1) / 2 if len(members) > 1 else 1
    cohesion = round(internal_edges / max_edges, 2) if max_edges > 0 else 0.0

    lines.append(f"## Cluster {cid} ({len(modules)} modules, {len(entities)} entities, cohesion: {cohesion})")
    lines.append("")

    if modules:
        mod_links = ", ".join(f'[[module:{n.get("label", n.get("name", n.get("id", ""))).lower().replace(" ","-")}]]' for n in modules[:10])
        lines.append(f"- Modules: {mod_links}")
    if entities:
        ent_links = ", ".join(f'[[entity:{n.get("label", n.get("name", n.get("id", ""))).lower().replace(" ","-")}]]' for n in entities[:10])
        lines.append(f"- Key entities: {ent_links}")
    if god_nodes:
        gn = ", ".join(f'{n.get("label", n.get("name", ""))} (degree {degree.get(n.get("id", n.get("name", "")), 0)})' for n in god_nodes)
        lines.append(f"- God nodes: {gn}")
    lines.append("")

# Surprising cross-community connections
if cross_edges:
    lines.append("## Surprising Connections (cross-community)")
    lines.append("")
    for e in cross_edges[:15]:
        conf = e.get("confidence", e.get("type", "INFERRED"))
        score = e.get("confidence_score", e.get("weight", "?"))
        src_c = node_community.get(e.get("source", ""), "?")
        tgt_c = node_community.get(e.get("target", ""), "?")
        lines.append(f"- {e.get('source','')} (cluster:{src_c}) <-> {e.get('target','')} (cluster:{tgt_c}) — confidence: {conf}/{score}")
    lines.append("")

with open(".ctx/community_map.md", "w") as f:
    f.write("\n".join(lines) + "\n")

print(f"generate-community-map: {len(communities)} communities, {len(cross_edges)} cross-edges")
PYEOF
