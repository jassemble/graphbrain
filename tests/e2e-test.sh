#!/usr/bin/env bash
# End-to-end test — runs the full pipeline in a temp directory
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# Copy package files into temp dir (simulates npm install)
cp -r "$PACKAGE_DIR/bin" "$TEST_DIR/"
cp -r "$PACKAGE_DIR/scripts" "$TEST_DIR/"
cp -r "$PACKAGE_DIR/skills-registry" "$TEST_DIR/"
cp -r "$PACKAGE_DIR/agents-registry" "$TEST_DIR/"
cp "$PACKAGE_DIR/brain-init.sh" "$TEST_DIR/"
mkdir -p "$TEST_DIR/.claude"
cp "$PACKAGE_DIR/.claude/settings.local.json" "$TEST_DIR/.claude/" 2>/dev/null || true

cd "$TEST_DIR"
git init -q

PASS=0
FAIL=0
check() {
  local name="$1" result="$2"
  if [ "$result" = "0" ]; then
    echo "  PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $name"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== E2E Test (in $TEST_DIR) ==="
echo ""

# --- 1. brain-init.sh creates .ctx/ scaffold ---
echo "Step 1: Scaffold"
bash brain-init.sh > /dev/null 2>&1
check ".ctx/ directory exists" "$([ -d .ctx ] && echo 0 || echo 1)"
check ".ctx/graph/ exists" "$([ -d .ctx/graph ] && echo 0 || echo 1)"
check ".ctx/skills/ exists" "$([ -d .ctx/skills ] && echo 0 || echo 1)"
check ".ctx/concepts/ exists" "$([ -d .ctx/concepts ] && echo 0 || echo 1)"
check ".ctx/entities/ exists" "$([ -d .ctx/entities ] && echo 0 || echo 1)"
check ".ctx/modules/ exists" "$([ -d .ctx/modules ] && echo 0 || echo 1)"
check ".ctx/decisions/ exists" "$([ -d .ctx/decisions ] && echo 0 || echo 1)"
check ".ctx/archive/ exists" "$([ -d .ctx/archive ] && echo 0 || echo 1)"
check "CLAUDE.md exists" "$([ -f CLAUDE.md ] && echo 0 || echo 1)"

# --- 1b. Idempotency ---
echo ""
echo "Step 1b: Idempotency"
output=$(bash brain-init.sh 2>&1)
check "Second run says already initialized" "$(echo "$output" | grep -q 'already initialized' && echo 0 || echo 1)"

# --- 2. Template files ---
echo ""
echo "Step 2: Templates"
for t in concepts entities modules sources decisions; do
  check "$t/_template.md exists" "$([ -f .ctx/$t/_template.md ] && echo 0 || echo 1)"
done
check "Entity template has related_entities" "$(grep -q 'related_entities' .ctx/entities/_template.md && echo 0 || echo 1)"
check "Module template has source-hash" "$(grep -q 'source-hash' .ctx/modules/_template.md && echo 0 || echo 1)"

# --- 3. Protocol + routing budgets ---
echo ""
echo "Step 3: Token budgets"
proto_words=$(wc -w < .ctx/protocol.md | tr -d ' ')
proto_tokens=$((proto_words * 75 / 100))
check "protocol.md under 500 tokens ($proto_tokens)" "$([ "$proto_tokens" -lt 500 ] && echo 0 || echo 1)"

route_words=$(wc -w < .ctx/routing.md | tr -d ' ')
route_tokens=$((route_words * 75 / 100))
check "routing.md under 400 tokens ($route_tokens)" "$([ "$route_tokens" -lt 400 ] && echo 0 || echo 1)"

# --- 4. Metadata files ---
echo ""
echo "Step 4: Metadata files"
for f in index.md status.md log.md decisions.md patterns.md community_map.md overview.md; do
  check "$f exists" "$([ -f .ctx/$f ] && echo 0 || echo 1)"
done
check "log.md has Recent Patterns section" "$(grep -q 'Recent Patterns' .ctx/log.md && echo 0 || echo 1)"
check "log.md has Activity History section" "$(grep -q 'Activity History' .ctx/log.md && echo 0 || echo 1)"
check "status.md has lifecycle header" "$(grep -q 'UNENRICHED' .ctx/status.md && echo 0 || echo 1)"

# --- 5. Lint checklist ---
echo ""
echo "Step 5: Lint checklist"
check "lint-checklist.md exists" "$([ -f .ctx/references/lint-checklist.md ] && echo 0 || echo 1)"
lint_checks=$(grep -c '^| [0-9]' .ctx/references/lint-checklist.md 2>/dev/null || echo 0)
check "lint-checklist has 14 checks ($lint_checks)" "$([ "$lint_checks" -eq 14 ] && echo 0 || echo 1)"

# --- 6. Wikilink check ---
echo ""
echo "Step 6: Wikilink validation"
wl_result=$(bash scripts/wikilink-check.sh 2>&1) || true
check "No broken wikilinks" "$(echo "$wl_result" | grep -q '0 broken' && echo 0 || echo 1)"

# --- 7. Lint pass ---
echo ""
echo "Step 7: Brain lint"
lint_result=$(bash scripts/sync/phase3-verify.sh --read-only 2>&1) || true
check "Lint has 0 errors" "$(echo "$lint_result" | grep -q 'Errors: 0' && echo 0 || echo 1)"

# --- 8. Skills ---
echo ""
echo "Step 8: Skill registry"
check "registry.json exists" "$([ -f skills-registry/registry.json ] && echo 0 || echo 1)"
check "manifest.json exists" "$([ -f .ctx/skills/manifest.json ] && echo 0 || echo 1)"
check "Core skills installed" "$([ -d .ctx/skills/requirements ] && echo 0 || echo 1)"

# --- 9. Hooks ---
echo ""
echo "Step 9: Hooks"
for h in session-start.sh session-end.sh post-tool-use.sh user-prompt-submit.sh stop.sh guardrails.sh; do
  check "hooks/$h exists" "$([ -f scripts/hooks/$h ] && echo 0 || echo 1)"
done

# --- 10. Sync scripts ---
echo ""
echo "Step 10: Sync pipeline"
for s in phase1-extract.sh phase2-update.sh phase3-verify.sh phase4-commit.sh run-sync.sh; do
  check "sync/$s exists" "$([ -f scripts/sync/$s ] && echo 0 || echo 1)"
done

# --- 11. No page exceeds 30K tokens ---
echo ""
echo "Step 11: Page sizes"
oversized=0
while IFS= read -r f; do
  words=$(wc -w < "$f" | tr -d ' ')
  tokens=$((words * 75 / 100))
  if [ "$tokens" -gt 30000 ]; then
    echo "  OVERSIZED: $f ($tokens tokens)"
    oversized=$((oversized + 1))
  fi
done < <(find .ctx -name "*.md" 2>/dev/null)
check "No pages over 30K tokens" "$([ "$oversized" -eq 0 ] && echo 0 || echo 1)"

# --- 12. Observability ---
echo ""
echo "Step 12: Observability"
lint_report=$(bash scripts/sync/phase3-verify.sh --read-only 2>&1) || true
check "Lint report has Score" "$(echo "$lint_report" | grep -q 'Score:' && echo 0 || echo 1)"
check "Lint report has Duration" "$(echo "$lint_report" | grep -q 'Duration:' && echo 0 || echo 1)"

check "Core skill references/ populated" "$([ -f skills-registry/core/requirements/references/conventions.md ] && echo 0 || echo 1)"
check "Core skill templates/ populated" "$([ -f skills-registry/core/requirements/templates/checklist.md ] && echo 0 || echo 1)"

# Session-start records timestamp
bash scripts/hooks/session-start.sh > /dev/null 2>&1 || true
check "Session start records timestamp" "$([ -f .ctx/.session_start ] && echo 0 || echo 1)"

# --- 13. CLI entry point ---
echo ""
echo "Step 13: CLI"
check "bin/graphbrain exists" "$([ -f bin/graphbrain ] && echo 0 || echo 1)"
check "bin/graphbrain is executable" "$([ -x bin/graphbrain ] && echo 0 || echo 1)"
help_out=$(bash bin/graphbrain help 2>&1) || true
check "CLI help works" "$(echo "$help_out" | grep -q 'graphbrain' && echo 0 || echo 1)"

# --- 14. Generated hooks config ---
echo ""
echo "Step 14: Generated hooks"
check "settings.local.json generated" "$([ -f .claude/settings.local.json ] && echo 0 || echo 1)"
check "Hooks reference absolute paths" "$(grep -q 'scripts/hooks/session-start.sh' .claude/settings.local.json && echo 0 || echo 1)"
check "Hooks have all 6 entries" "$(python3 -c "
import json
with open('.claude/settings.local.json') as f:
    s = json.load(f)
hooks = s.get('hooks', {})
print(0 if len(hooks) == 6 else 1)
" 2>/dev/null || echo 1)"

# --- 15. Available skills have content ---
echo ""
echo "Step 15: Available skills"
for s in kubernetes graphql mobile; do
  check "available/$s has SKILL.md" "$([ -f skills-registry/available/$s/SKILL.md ] && echo 0 || echo 1)"
done

# --- 16. Agents ---
echo ""
echo "Step 16: Agents"
check "agents/manifest.json exists" "$([ -f .ctx/agents/manifest.json ] && echo 0 || echo 1)"
check "Core agents installed" "$([ -f .ctx/agents/generator/AGENT.md ] && echo 0 || echo 1)"
check "SDLC agents installed" "$([ -f .ctx/agents/requirements/AGENT.md ] && echo 0 || echo 1)"
check "Agent manifest has 10 core agents" "$(python3 -c "
import json
with open('.ctx/agents/manifest.json') as f:
    m = json.load(f)
print(0 if len(m.get('agents', {})) == 10 else 1)
" 2>/dev/null || echo 1)"
check "Community agents listed as available" "$(python3 -c "
import json
with open('.ctx/agents/manifest.json') as f:
    m = json.load(f)
print(0 if 'code-reviewer' in m.get('available', []) else 1)
" 2>/dev/null || echo 1)"

# --- 17. Uninstall ---
echo ""
echo "Step 16: Uninstall"
bash bin/graphbrain uninstall > /dev/null 2>&1
check "Uninstall removes .ctx/" "$([ ! -d .ctx ] && echo 0 || echo 1)"
check "Uninstall removes hooks" "$(python3 -c "
import json, os
if not os.path.exists('.claude/settings.local.json'):
    print(0)
else:
    s = json.load(open('.claude/settings.local.json'))
    print(0 if 'hooks' not in s else 1)
" 2>/dev/null || echo 1)"

# --- Summary ---
echo ""
echo "================================"
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "================================"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
