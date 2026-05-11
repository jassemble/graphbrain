# Architecture: [Feature/System Name]

## Context
What system/feature this covers and why this document exists.

## Requirements Mapping
| PRD Requirement | Design Component | Status |
|----------------|------------------|--------|
| [requirement] | [component] | Covered |

## Components
```
[Component A] --> [Component B] --> [Component C]
       |                                  |
       v                                  v
  [Database]                        [External API]
```

### Component A
- Responsibility: [what it does]
- Interface: [inputs/outputs]
- Dependencies: [what it needs]

## Data Flow
1. User submits [action]
2. [Component A] validates input
3. [Component B] processes request
4. [Component C] persists result
5. Response returned to user

## API Contracts
### POST /api/[resource]
- Request: `{ field: type }`
- Response 200: `{ id: string, ... }`
- Response 400: `{ error: string }`

## Error Handling
- Input validation errors → 400 with field-level messages
- Business logic errors → 422 with explanation
- System errors → 500 with correlation ID, logged

## Non-Functional Requirements
- Performance: [target latency, throughput]
- Security: [auth, data access]
- Scalability: [growth path]
