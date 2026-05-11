# Data Modeling Conventions (Prisma)

## Schema Design
- Singular model names: `User`, not `Users`
- camelCase fields: `createdAt`, `firstName`
- Explicit relation names on both sides
- Always include `id`, `createdAt`, `updatedAt` on every model
- Use `@unique` constraints for natural keys (email, slug)

## Relations
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  posts     Post[]   @relation("UserPosts")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id       String @id @default(cuid())
  title    String
  author   User   @relation("UserPosts", fields: [authorId], references: [id])
  authorId String
}
```

## Migrations
- One migration per schema change (atomic)
- Review generated SQL before applying
- Test rollback on staging before production
- Never edit migration files after they've been applied

## Performance
- Add `@index` on frequently queried foreign keys
- Use `select` to fetch only needed fields
- Paginate with cursor-based pagination for large datasets
- Use transactions for multi-step writes

## Anti-Patterns
- No cascade deletes without explicit intent
- No JSON columns for structured, queryable data
- No optional foreign keys without clear null semantics
- No implicit many-to-many without a join model (for future metadata)
