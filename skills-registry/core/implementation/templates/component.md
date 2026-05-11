# Component: [Name]

## Purpose
One sentence describing what this component does.

## Interface
```typescript
interface [Name]Props {
  // required props
}

// or for a service:
class [Name]Service {
  constructor(deps: { db: Database; logger: Logger })
  async create(input: CreateInput): Promise<Result<Entity>>
  async getById(id: string): Promise<Result<Entity>>
}
```

## Usage
```typescript
// Example usage
const result = await service.create({ name: "example" });
if (result.status === "error") {
  // handle error
}
```

## Error Handling
- Invalid input → returns Result with error, does not throw
- Not found → returns Result with error, does not throw
- System error → throws, caught by error boundary

## Testing
- Unit: test each method in isolation with mocked deps
- Integration: test with real database
