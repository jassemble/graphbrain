# Operational Tests for Behavioral Principles

These are quick self-checks you can run mid-task to verify you're following the principles.

## Test 1: Assumption Audit (Principle 1)

Before writing code, write down 1-3 assumptions you're making. Examples:
- "I assume the user wants this in TypeScript, not JavaScript"
- "I assume errors should be thrown, not returned as Result types"
- "I assume this needs to handle concurrent requests"

If any assumption is non-trivial, ask before proceeding.

## Test 2: Necessity Check (Principle 2)

For each new file, class, function, or abstraction, ask:
- Is this used in more than one place right now? (If no, inline it.)
- Could the caller do this themselves with less code? (If yes, do that.)
- Am I adding this for a "future" use case? (If yes, remove it.)

## Test 3: Diff Audit (Principle 3)

Before committing, read the diff line by line. For each changed line, ask:
- Does this line address the user's request?
- If I remove this line, does the feature still work?

Lines that don't address the request OR aren't required for the feature should be removed.

## Test 4: Goal Boolean Check (Principle 4)

Write the goal as a single boolean check:
- ✅ "Run `npm test` → exits with code 0"
- ✅ "POST /api/users with valid payload returns 201"
- ✅ "Page loads in < 2.5s (LCP via Lighthouse)"
- ❌ "Works correctly"
- ❌ "Is fast"
- ❌ "Handles errors gracefully"

If you can't write the boolean check, you don't have a goal — you have a wish.
