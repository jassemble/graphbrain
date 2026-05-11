#!/usr/bin/env bash
# Sync pipeline orchestrator with 4-tier error recovery
set -euo pipefail

CTX=".ctx"
export AGENTCTX_PACKAGE_DIR="${AGENTCTX_PACKAGE_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
SYNC_DIR="$AGENTCTX_PACKAGE_DIR/scripts/sync"
MAX_RETRIES=3
TOTAL_START=$(python3 -c "import time; print(int(time.time()*1000))")

echo "=== Brain Sync Pipeline ==="
echo ""

# --- Phase 1: EXTRACT ---
phase1_exit=0
bash "$SYNC_DIR/phase1-extract.sh" || phase1_exit=$?

if [ "$phase1_exit" -eq 10 ]; then
  echo "No changes — running lightweight sync (verify + commit only)"
  bash "$SYNC_DIR/phase3-verify.sh" || true
  TOTAL_END=$(python3 -c "import time; print(int(time.time()*1000))")
  bash "$SYNC_DIR/phase4-commit.sh" "complete" "$((TOTAL_END - TOTAL_START))"
  echo ""
  echo "=== Sync complete (lightweight) ==="
  exit 0
elif [ "$phase1_exit" -ne 0 ]; then
  echo "Phase 1 FAILED (exit $phase1_exit)"
  TOTAL_END=$(python3 -c "import time; print(int(time.time()*1000))")
  bash "$SYNC_DIR/phase4-commit.sh" "blocked" "$((TOTAL_END - TOTAL_START))" || true
  exit 1
fi

echo ""

# --- Phase 2: UPDATE ---
if ! bash "$SYNC_DIR/phase2-update.sh"; then
  echo "Phase 2 FAILED — committing partial results from Phase 1"
  TOTAL_END=$(python3 -c "import time; print(int(time.time()*1000))")
  bash "$SYNC_DIR/phase4-commit.sh" "blocked" "$((TOTAL_END - TOTAL_START))" || true
  exit 1
fi

# Snapshot page count after Phase 2 for idle detection
pages_after_update=$(find "$CTX" -name "*.md" ! -name "_*" 2>/dev/null | wc -l | tr -d ' ')

echo ""

# --- Budget pause: check if approaching token limit ---
check_budget() {
  local elapsed=$(($(python3 -c "import time; print(int(time.time()*1000))") - TOTAL_START))
  # Pause if sync has been running > 5 minutes (proxy for 85% budget)
  if [ "$elapsed" -gt 300000 ]; then
    echo ""
    echo "WARNING: Sync running for ${elapsed}ms — approaching budget limit. Auto-pausing."
    bash "$SYNC_DIR/phase4-commit.sh" "paused" "$elapsed" || true
    exit 0
  fi
}

# --- Phase 3: VERIFY (with retry) ---
retry=0
verified=false
idle_count=0

while [ "$retry" -lt "$MAX_RETRIES" ]; do
  check_budget
  if bash "$SYNC_DIR/phase3-verify.sh"; then
    verified=true
    break
  fi

  retry=$((retry + 1))
  echo ""
  echo "--- Tier 1: Retry $retry/$MAX_RETRIES (re-run update + verify) ---"
  bash "$SYNC_DIR/phase2-update.sh" || true

  # Idle detection: if no new pages created/updated, count as idle
  pages_now=$(find "$CTX" -name "*.md" ! -name "_*" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$pages_now" -eq "$pages_after_update" ]; then
    idle_count=$((idle_count + 1))
  else
    idle_count=0
    pages_after_update="$pages_now"
  fi

  # Skip to Tier 3 if idle for too long
  if [ "$idle_count" -ge 5 ]; then
    echo "Idle detected: no new pages in $idle_count retries — skipping to Tier 3"
    break
  fi
done

# Tier 2: Forced reflection (skip if idle-detected)
if [ "$verified" = false ] && [ "$idle_count" -lt 5 ]; then
  echo ""
  echo "--- Tier 2: Reflection ---"
  echo "REFLECTION: What failed after $MAX_RETRIES retries? Attempting fresh approach."
  check_budget
  bash "$SYNC_DIR/phase2-update.sh" || true
  if bash "$SYNC_DIR/phase3-verify.sh"; then
    verified=true
  fi
fi

# Tier 3: Kill + reassign report
if [ "$verified" = false ]; then
  echo ""
  echo "--- Tier 3: Reassign Report ---"
  echo "Sync could not self-heal. Generating report for fresh agent."
  cat "$CTX/graph/brain-lint-report.md" 2>/dev/null || echo "(no lint report)"
fi

# Tier 4: Human escalation
if [ "$verified" = false ]; then
  echo ""
  echo "--- Tier 4: Human Escalation ---"
  cat << 'ESCALATION'
## Human Escalation Required

### What was attempted
- Phase 1 (EXTRACT): completed
- Phase 2 (UPDATE): completed
- Phase 3 (VERIFY): FAILED after retries + reflection

### Suggested actions
1. Review brain-lint-report.md for specific failures
2. Fix broken wikilinks or oversized pages manually
3. Re-run: bash scripts/sync/run-sync.sh
ESCALATION
fi

echo ""

# --- Phase 4: COMMIT ---
TOTAL_END=$(python3 -c "import time; print(int(time.time()*1000))")
DURATION=$((TOTAL_END - TOTAL_START))

if [ "$verified" = true ]; then
  bash "$SYNC_DIR/phase4-commit.sh" "complete" "$DURATION"
  echo ""
  echo "=== Sync complete ($DURATION ms) ==="
  exit 0
else
  bash "$SYNC_DIR/phase4-commit.sh" "blocked" "$DURATION"
  echo ""
  echo "=== Sync BLOCKED ($DURATION ms) ==="
  exit 1
fi
