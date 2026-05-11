# Hook Configuration Guide

## Progressive Adoption

Enable hooks one at a time, starting with SessionStart:

1. **SessionStart** — Start here. Loads brain context at session start.
2. **UserPromptSubmit** — Skill routing on every prompt.
3. **PostToolUse** — Breadcrumbs and stale marking after file edits.
4. **PreToolUse** — Guardrails (blocks dangerous operations).
5. **Stop** — Checkpoint on pause.
6. **SessionEnd** — Persist observations and decisions.

## Disabling Hooks

### Disable all hooks at once
Add to `settings.local.json`:
```json
"disableAllHooks": true
```

### Disable individual hooks
Remove the hook entry from the `hooks` object in `settings.local.json`.
Keep a backup of the removed entry to re-enable later.

## Hook Reference

| Hook | Script | Input | Purpose |
|------|--------|-------|---------|
| SessionStart | `scripts/hooks/session-start.sh` | (none) | Load protocol + decisions + log + skill routing |
| UserPromptSubmit | `scripts/hooks/user-prompt-submit.sh` | `$PROMPT` — user's prompt text | Intent match + skill activation |
| PreToolUse | `scripts/hooks/guardrails.sh` | `$TOOL_INPUT` — tool name + args | Block dangerous operations, PII |
| PostToolUse | `scripts/hooks/post-tool-use.sh` | `$FILE` — file path edited/read | Breadcrumbs + stale marking |
| Stop | `scripts/hooks/stop.sh` | (none) | Checkpoint + log pause |
| SessionEnd | `scripts/hooks/session-end.sh` | (none) | Persist + decisions + consolidate |

## Parameters

Claude Code passes the following variables to hooks:

- `$PROMPT` — The user's prompt text (UserPromptSubmit only)
- `$TOOL_INPUT` — JSON string with tool name and arguments (PreToolUse only)
- `$FILE` — The file path that was read or edited (PostToolUse only)

These are passed as command-line arguments (`$1` in the script). The scripts internally export them as environment variables (`BRAIN_PROMPT`, `BRAIN_CTX`, etc.) for use in embedded Python blocks.

## Exit Codes

- `0` — Pass (with optional stdout message as warning/info)
- `2` — Block the operation (PreToolUse guardrails only)
