#!/usr/bin/env bash
# SessionEnd hook
# Persists observations, updates status, triggers lightweight sync
set -euo pipefail

CTX=".ctx"
[ ! -d "$CTX" ] && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_START_FILE="$CTX/.session_start"

# --- Persist observations to log.md ---
if [ -f "$CTX/log.md" ]; then
  # Build structured entry
  entry="- $TIMESTAMP — session ended"

  # List recently changed files in .ctx/ (last 30 min)
  changed=$(find "$CTX" -name "*.md" -newer "$CTX/log.md" -not -path "*/_template.md" 2>/dev/null | head -10)
  if [ -n "$changed" ]; then
    entry="$entry | changed: $(echo "$changed" | tr '\n' ', ' | sed 's/,$//')"
  fi

  # Session duration
  if [ -f "$SESSION_START_FILE" ]; then
    start_s=$(cat "$SESSION_START_FILE")
    end_s=$(date +%s)
    duration_s=$((end_s - start_s))
    entry="$entry | duration=${duration_s}s"
    rm -f "$SESSION_START_FILE"
  fi

  # Token cost (from CLAUDE_TOKEN_COST env if available, otherwise mark as unavailable)
  if [ -n "${CLAUDE_TOKEN_COST:-}" ]; then
    entry="$entry | token_cost=$CLAUDE_TOKEN_COST"
  else
    entry="$entry | token_cost=n/a"
  fi

  # Skill routing activations (count from session log)
  activations=0
  corrections=0
  if [ -f "$CTX/log.md" ] && [ -s "$CTX/log.md" ]; then
    activations=$(grep -c "skill activated:" "$CTX/log.md" 2>/dev/null || echo 0)
    corrections=$(grep -c "skill corrected:" "$CTX/log.md" 2>/dev/null || echo 0)
  fi
  entry="$entry | skill_activations=$activations corrections=$corrections"

  echo "" >> "$CTX/log.md"
  echo "$entry" >> "$CTX/log.md"
fi

# --- Update status.md with counts ---
if [ -f "$CTX/status.md" ]; then
  python3 -c "
import os

ctx = '$CTX'
status_path = os.path.join(ctx, 'status.md')

with open(status_path) as f:
    content = f.read()

counts = {'UNENRICHED': 0, 'FRESH': 0, 'STALE': 0, 'RESYNCED': 0, 'VERIFIED': 0}
for line in content.split('\n'):
    for s in counts:
        if s in line:
            counts[s] += 1

# Only print if there are entries
total = sum(counts.values())
if total > 0:
    summary = ', '.join(f'{k}={v}' for k, v in counts.items() if v > 0)
    print(f'Status: {summary}')
" 2>/dev/null || true
fi

# --- Decision capture ---
# Prompt about decisions + check for new ADR files
if [ -d "$CTX/decisions" ]; then
  # Proactive prompt: signal to the agent that decisions should be captured
  echo ""
  echo "## Decision Check"
  echo "Were any significant decisions made this session? If so, create an ADR in .ctx/decisions/"
  echo ""

  new_decisions=$(find "$CTX/decisions" -name "*.md" -not -name "_template.md" -newer "$CTX/log.md" 2>/dev/null)
  if [ -n "$new_decisions" ]; then
    python3 -c "
import os, re

ctx = '$CTX'
decisions_path = os.path.join(ctx, 'decisions.md')
decisions_dir = os.path.join(ctx, 'decisions')

# Find new ADRs
new_adrs = '''$new_decisions'''.strip().split('\n')
for adr_path in new_adrs:
    if not adr_path or not os.path.exists(adr_path):
        continue
    with open(adr_path) as f:
        content = f.read()
    title_match = re.search(r'title:\s*[\"'']?(.+?)[\"'']?\s*$', content, re.MULTILINE)
    title = title_match.group(1) if title_match else os.path.basename(adr_path)[:-3]
    did = os.path.basename(adr_path)[:-3]

    # Add to decisions.md
    if os.path.exists(decisions_path):
        with open(decisions_path) as f:
            existing = f.read()
        if did not in existing:
            # Append under Active Decisions
            entry = f'- **{title}** [{did}, active]\n'
            if '## Active Decisions' in existing:
                existing = existing.replace('## Active Decisions\n', f'## Active Decisions\n\n{entry}', 1)
            else:
                existing += f'\n{entry}'
            with open(decisions_path, 'w') as f:
                f.write(existing)
            print(f'Decision captured: {title}')

    # Check for contradictions with existing decisions
    if os.path.exists(decisions_path):
        with open(decisions_path) as f:
            all_decisions = f.read()
        # Simple: flag if title keywords overlap with superseded
        if '~~' in all_decisions and any(word in all_decisions for word in title.lower().split() if len(word) > 4):
            print(f'WARNING: New decision \"{title}\" may relate to a superseded decision. Review decisions.md.')
" 2>/dev/null || true
  fi
fi

# --- Trigger lightweight sync if source files changed ---
PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
export PATH="$PACKAGE_DIR/bin:$PATH"
if command -v brain &>/dev/null; then
  src_changed=$(find . -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" 2>/dev/null | head -1)
  if [ -n "$src_changed" ]; then
    brain . --update 2>/dev/null || true
  fi
fi

# --- Run log consolidation if enough entries ---
if [ -f "$PACKAGE_DIR/scripts/consolidate-log.sh" ]; then
  bash "$PACKAGE_DIR/scripts/consolidate-log.sh" 2>/dev/null || true
fi
