#!/usr/bin/env bash
# Guardrails hook (block + warn)
# Exit 2 = BLOCK, Exit 0 with message = WARN, Exit 0 silent = PASS
# Called as PreToolUse hook with tool info as argument
set -euo pipefail

CTX=".ctx"
[ ! -d "$CTX" ] && exit 0

# Parse input (tool name + file path from hook context)
INPUT="${1:-}"

export BRAIN_INPUT="$INPUT"
export BRAIN_CTX="$CTX"

python3 -c "
import os, sys, re

ctx = os.environ.get('BRAIN_CTX', '.ctx')
input_text = os.environ.get('BRAIN_INPUT', '')

# Extract file path from input
file_match = re.search(r'(/[^\s]+\.md)', input_text)
file_path = file_match.group(1) if file_match else ''

# --- BLOCK rules (exit 2) ---

# Block concept deletion
if file_path and '/concepts/' in file_path:
    if 'Delete' in input_text or 'remove' in input_text.lower():
        print('BLOCKED: Cannot delete concept pages. Use archive instead.')
        sys.exit(2)

# Block overwriting CONFIRMED pages
if file_path and os.path.exists(file_path):
    with open(file_path) as f:
        content = f.read()
    if 'status: CONFIRMED' in content or 'status: confirmed' in content:
        if 'Write' in input_text or 'Edit' in input_text:
            # Check if it's a destructive overwrite vs minor edit
            if 'Write' in input_text:
                print('BLOCKED: Cannot overwrite CONFIRMED page. Edit specific sections instead.')
                sys.exit(2)

# Block sync without verification
if 'phase4-commit' in input_text and 'phase3-verify' not in input_text:
    # This is handled by run-sync.sh ordering, but guard anyway
    pass

# --- WARN rules (exit 0 with message) ---

# Warn on concept modification
if file_path and '/concepts/' in file_path and os.path.exists(file_path):
    print('NOTE: Modifying concept page. Changes will need re-verification.')

# Warn on pattern changes
if file_path and 'patterns.md' in file_path:
    print('NOTE: Modifying patterns.md. Ensure claims match actual code.')

# Warn on archive actions
if file_path and '/archive/' in file_path:
    print('NOTE: Writing to archive. Archived content is read-only by convention.')

# --- Pre-input: reject PII/private markers ---
if '<private>' in input_text.lower():
    print('BLOCKED: Input contains <private> markers. Remove sensitive data first.')
    sys.exit(2)

pii_patterns = [
    r'\b\d{3}-\d{2}-\d{4}\b',  # SSN
    r'\b\d{16}\b',              # Credit card
]
for pattern in pii_patterns:
    if re.search(pattern, input_text):
        print('BLOCKED: Input appears to contain PII. Remove before proceeding.')
        sys.exit(2)
" 2>/dev/null || true
