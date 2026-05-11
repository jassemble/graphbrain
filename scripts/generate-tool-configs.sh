#!/usr/bin/env bash
# Generate tool-specific config files (additive only)
set -euo pipefail

# --- .cursorrules ---
CURSORRULES=".cursorrules"
POINTER="# Read .ctx/protocol.md for project brain context"
if [ -f "$CURSORRULES" ]; then
  if ! grep -qF "$POINTER" "$CURSORRULES"; then
    echo "" >> "$CURSORRULES"
    echo "$POINTER" >> "$CURSORRULES"
    echo "Appended brain pointer to existing .cursorrules"
  else
    echo ".cursorrules already has brain pointer"
  fi
else
  cat > "$CURSORRULES" << 'EOF'
# Read .ctx/protocol.md for project brain context
# Query graph via brain MCP: brain serve .ctx/graph/graph.json
# Run /brain-sync to update project knowledge
# Run /brain-lint for read-only verification
EOF
  echo "Created .cursorrules with brain pointers"
fi

# --- .github/copilot-instructions.md ---
COPILOT_DIR=".github"
COPILOT="$COPILOT_DIR/copilot-instructions.md"
mkdir -p "$COPILOT_DIR"
if [ -f "$COPILOT" ]; then
  if ! grep -qF "protocol.md" "$COPILOT"; then
    echo "" >> "$COPILOT"
    echo "## Project Brain" >> "$COPILOT"
    echo "Read .ctx/protocol.md for project context, routing, and decisions." >> "$COPILOT"
    echo "Appended brain section to existing copilot-instructions.md"
  else
    echo "copilot-instructions.md already has brain pointer"
  fi
else
  cat > "$COPILOT" << 'EOF'
# Copilot Instructions

## Project Brain
Read .ctx/protocol.md for project context, routing, and decisions.
Use .ctx/routing.md to find relevant pages by keyword.
Check .ctx/decisions.md before making architectural choices.
EOF
  echo "Created .github/copilot-instructions.md"
fi

echo "Tool configs generated."
