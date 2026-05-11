---
name: mobile
tier: available
trigger_phrases:
  - "mobile app"
  - "react native"
  - "ios build"
  - "android build"
  - "expo"
paths:
  - "**/ios/**"
  - "**/android/**"
  - "**/app.json"
  - "**/*.swift"
  - "**/*.kt"
---

# Mobile Skill

## Conventions

- Offline-first: assume network is unreliable
- Minimize bundle size — lazy-load screens and heavy assets
- Handle all permission requests gracefully with fallbacks
- Test on real devices, not just simulators
- Use platform-specific UI patterns (iOS HIG, Material Design)
- Never block the main/UI thread with heavy computation

## Patterns

- **Navigation**: Use stack-based navigation with deep link support
- **State**: Keep local UI state separate from persisted/synced state
- **Assets**: Use responsive images (`@2x`, `@3x`) and vector icons
