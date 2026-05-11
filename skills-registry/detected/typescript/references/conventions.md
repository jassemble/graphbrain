# TypeScript Conventions

## Type Safety
- Strict mode enabled: `"strict": true` in tsconfig.json
- Never use `any` — use `unknown` for truly unknown types, then narrow
- Prefer `interface` for object shapes, `type` for unions/intersections
- Use discriminated unions for state machines and variant types
- Make impossible states unrepresentable via the type system

## Naming
- Interfaces: PascalCase, no `I` prefix (`User`, not `IUser`)
- Types: PascalCase (`UserRole`, `ApiResponse<T>`)
- Enums: PascalCase members (`Status.Active`, not `Status.ACTIVE`)
- Generic parameters: descriptive (`TItem`, not just `T` when ambiguous)

## Patterns
```typescript
// Discriminated union for state
type Result<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }
  | { status: 'loading' };

// Exhaustive switch
function handle(result: Result<User>) {
  switch (result.status) {
    case 'success': return render(result.data);
    case 'error': return showError(result.error);
    case 'loading': return <Spinner />;
    // TypeScript ensures all cases handled
  }
}

// Branded types for type-safe IDs
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };
```

## Anti-Patterns
- `as` type assertions — narrow with type guards instead
- Optional chaining without null checks — handle the undefined case
- Barrel exports (`index.ts` re-exporting everything) — causes bundle bloat
- Mutable global state — use dependency injection or context
