---
name: graphql
tier: available
trigger_phrases:
  - "graphql schema"
  - "write a resolver"
  - "graphql query"
  - "mutation"
  - "graphql api"
paths:
  - "**/*.graphql"
  - "**/*.gql"
  - "**/resolvers/**"
  - "**/schema/**"
---

# GraphQL Skill

## Conventions

- Schema-first design: define `.graphql` files before resolvers
- Use input types for mutations, not inline arguments
- Paginate all list fields with cursor-based pagination (Relay spec)
- Return union types for errors instead of throwing
- Use DataLoader for N+1 query prevention
- Keep resolvers thin — delegate to service layer

## Patterns

- **Naming**: `Query.user`, `Mutation.createUser`, `Subscription.onUserCreated`
- **Error handling**: Return `{ success, errors[], data }` union types
- **Auth**: Check permissions in directive or middleware, not in resolvers
