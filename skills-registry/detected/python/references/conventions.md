# Python Conventions

## Code Style
- Follow PEP 8 (enforced by ruff or black)
- Type hints on all function signatures (PEP 484)
- Docstrings on all public functions (Google style or NumPy style)
- Max line length: 88 (black default) or 120

## Naming
- snake_case: functions, variables, module names
- PascalCase: classes
- UPPER_SNAKE: constants
- _private: single underscore prefix for internal use

## Patterns
```python
# Dataclasses for structured data
from dataclasses import dataclass

@dataclass
class User:
    id: int
    name: str
    email: str

# Context managers for resource cleanup
from contextlib import contextmanager

@contextmanager
def database_connection():
    conn = create_connection()
    try:
        yield conn
    finally:
        conn.close()

# Type narrowing with TypeGuard
from typing import TypeGuard

def is_valid_user(data: dict) -> TypeGuard[User]:
    return 'id' in data and 'name' in data
```

## Error Handling
- Catch specific exceptions, never bare `except:`
- Use custom exception classes for domain errors
- Always include context in error messages
- Use `raise ... from ...` for exception chaining

## Testing
- pytest as test runner
- Fixtures for setup/teardown (not setUp/tearDown methods)
- parametrize for testing multiple inputs
- conftest.py for shared fixtures
