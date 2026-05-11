# API Handler: [METHOD] /api/[resource]

## Request
```typescript
// Method: POST | GET | PUT | DELETE
// Path: /api/[resource]
// Auth: required | optional | none

interface RequestBody {
  field: string;    // description, constraints
}

interface QueryParams {
  page?: number;    // default: 1
  limit?: number;   // default: 20, max: 100
}
```

## Response
```typescript
// 200 OK
interface SuccessResponse {
  data: Resource;
}

// 400 Bad Request
interface ErrorResponse {
  error: string;
  fields?: Record<string, string>;
}

// 404 Not Found
// 500 Internal Server Error (correlation ID in response)
```

## Validation
- [ ] Input validated at handler boundary
- [ ] All fields have type + constraint checks
- [ ] Auth token verified before processing
- [ ] Rate limiting applied

## Implementation Checklist
- [ ] Handler function written
- [ ] Input validation middleware
- [ ] Error handling with proper status codes
- [ ] Unit tests for happy + error paths
- [ ] Integration test with real DB
