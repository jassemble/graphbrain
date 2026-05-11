#!/usr/bin/env bash
# Brain MCP server launcher
# Starts brain's MCP server for graph queries
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$SCRIPT_DIR/bin:$PATH"
GRAPH="${1:-.ctx/graph/graph.json}"

if [ ! -f "$GRAPH" ]; then
  echo "ERROR: graph.json not found at $GRAPH" >&2
  echo "Run 'brain .' first to generate the graph." >&2
  exit 1
fi

if ! command -v brain &>/dev/null; then
  echo "ERROR: brain CLI not found at $SCRIPT_DIR/bin/brain" >&2
  exit 1
fi

echo "Starting brain MCP server..."
echo "Graph: $GRAPH"
echo "Endpoints: query_graph, get_node, get_neighbors, get_community, god_nodes, graph_stats, shortest_path"
echo "Token budget: < 2000 tokens per query"
echo "Traversal modes: query_graph supports mode=bfs (breadth-first, default) and mode=dfs (depth-first)"
echo ""

brain serve "$GRAPH"
