# Changelog

## 0.1.0 (2026-05-11)

Initial release.

### Features
- Knowledge graph extraction from codebases (25+ languages, AST + regex, zero external deps)
- Governed wiki pages: modules, entities, concepts, decisions with token budgets
- 4-phase sync pipeline: EXTRACT -> UPDATE -> VERIFY -> COMMIT with 4-tier error recovery
- 14-point lint verification with swappable rubrics
- 6 lifecycle hooks: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop, SessionEnd
- Guardrails: blocks concept deletion, CONFIRMED page overwrites, PII leakage
- Skill system: 6 core SDLC skills (always installed) + 6 auto-detected stack skills + 3 available
- Stack detection: React, TypeScript, Python, Go, Prisma, security (.env)
- MCP server with 7 graph query tools and token budgeting (<2000t per response)
- CLI: `codebrain init|extract|sync|lint|serve|add-skill|uninstall`
- npm package with postinstall auto-init
- Claude Code slash commands: `/brain-sync`, `/brain-lint`, `/brain-add-skill`
