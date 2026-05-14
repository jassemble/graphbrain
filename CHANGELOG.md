# Changelog

## 0.3.0 (2026-05-15)

### Features
- **Behavioral skill tier** — sixth design pattern for task-agnostic disposition rules
- `behavioral/karpathy-principles` skill bundled by default (4 principles from Andrej Karpathy)
- SessionStart hook now injects behavioral skill bodies into every session (not trigger-matched)
- New `behavioral` tier in registry.json alongside core/detected/available
- Manifest entries include `tier` field for routing

### Pattern
Behavioral skills differ from the 5 workflow patterns (Tool Wrapper, Generator, Reviewer, Inversion, Pipeline):
- Task-agnostic scope (apply to every prompt)
- Disposition over procedure (shape decisions across all tasks)
- Compose with all 5 workflow patterns

## 0.2.1 (2026-05-12)

### Improvements
- Upgraded all 6 verifier rubrics (9-10 checks each, up from 4-5)
- Fleshed out all skill references with real conventions, code examples, anti-patterns
- Fleshed out all skill templates with actionable checklists
- Created all missing template files (adr.md, architecture.md, component.md, etc.)
- Added model profiles (profiles.md) with per-phase recommendations
- Fixed word-boundary matching in skill/agent routing
- Fixed PACKAGE_DIR resolution in serve-mcp.sh

## 0.2.0 (2026-05-12)

### Features
- Agent registry: 13 agents (4 brain, 6 SDLC, 3 community) with on-demand activation
- Agents activate via trigger phrases alongside skills in UserPromptSubmit hook
- `graphbrain add-agent <name>` CLI command for manual agent installation
- Agent installer (scripts/install-agents.sh) with registry.json

### Improvements
- Correct pattern labels on all skills (Inversion, Pipeline, RED-GREEN-REFACTOR, etc.)
- Available skills (kubernetes, graphql, mobile) populated with real content

## 0.1.0 (2026-05-11)

### Features
- Knowledge graph extraction from codebases (15+ languages via AST + regex)
- Governed wiki pages: modules, entities, concepts, decisions with token budgets
- 4-phase sync pipeline: EXTRACT -> UPDATE -> VERIFY -> COMMIT with 4-tier error recovery
- 14-point lint verification with swappable rubrics
- 6 lifecycle hooks: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop, SessionEnd
- Guardrails: blocks concept deletion, CONFIRMED page overwrites, PII leakage
- Skill system: 6 core SDLC skills + 6 auto-detected stack skills + 3 available
- Stack detection: React, TypeScript, Python, Go, Prisma, security (.env)
- MCP server with 7 graph query tools and token budgeting (<2000t per response)
- CLI: `graphbrain init|extract|sync|lint|serve|add-skill|uninstall`
- npm package with postinstall auto-init
- Claude Code slash commands: `/brain-sync`, `/brain-lint`, `/brain-add-skill`
