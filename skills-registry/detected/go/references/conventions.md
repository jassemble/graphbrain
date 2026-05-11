# Go Conventions

## Code Style
- `gofmt` / `goimports` — non-negotiable
- Short variable names in narrow scopes (`i`, `r`, `w`)
- Descriptive names for exported types and functions
- Avoid stutter: `user.User` bad, `user.Account` good

## Error Handling
```go
// Always check errors — never ignore
result, err := doSomething()
if err != nil {
    return fmt.Errorf("doSomething failed: %w", err)
}

// Custom error types for domain errors
type NotFoundError struct {
    Resource string
    ID       string
}
func (e *NotFoundError) Error() string {
    return fmt.Sprintf("%s %s not found", e.Resource, e.ID)
}

// Use errors.Is and errors.As for checking
if errors.Is(err, sql.ErrNoRows) { ... }
```

## Patterns
- Accept interfaces, return structs
- Table-driven tests for multiple cases
- Context propagation for cancellation and deadlines
- Dependency injection via function parameters or struct fields

## Testing
```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 1, 2, 3},
        {"zero", 0, 0, 0},
        {"negative", -1, 1, 0},
    }
    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            got := Add(tc.a, tc.b)
            if got != tc.expected {
                t.Errorf("Add(%d, %d) = %d, want %d", tc.a, tc.b, got, tc.expected)
            }
        })
    }
}
```

## Anti-Patterns
- `panic` in library code — return errors instead
- Global mutable state — use dependency injection
- Premature channels — start with mutexes, upgrade when needed
- `interface{}` / `any` without type assertions
