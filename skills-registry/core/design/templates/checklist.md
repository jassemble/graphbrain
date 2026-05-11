# Design Review Checklist

## Architecture
- [ ] All PRD requirements mapped to design components
- [ ] Component boundaries clearly defined
- [ ] Data flow documented (input → processing → output)
- [ ] Error handling strategy covers all failure modes
- [ ] API contracts defined with request/response shapes

## Decisions
- [ ] ADR created for each decision with >=2 options
- [ ] Tradeoffs documented for each architectural choice
- [ ] Prior decisions checked in .ctx/decisions/ for conflicts
- [ ] No premature optimization (performance not yet spec'd)

## Quality
- [ ] Design reviewed against existing patterns in .ctx/patterns.md
- [ ] Security considerations documented
- [ ] Scalability path identified (even if not implemented now)
- [ ] Dependencies between components minimized
