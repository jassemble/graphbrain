# React Conventions

## Component Design
- Prefer function components with hooks over class components
- One component per file, named export matching filename
- Co-locate styles, tests, and types with component
- Extract custom hooks for reusable logic (prefix with `use`)

## State Management
- Local state: `useState` for UI state, `useReducer` for complex state
- Server state: React Query / SWR — never store server data in global state
- Global state: Context for low-frequency updates, Zustand/Jotai for high-frequency
- Never derive state that can be computed from existing state

## Performance
- Wrap expensive computations in `useMemo`
- Wrap callback props in `useCallback` when passing to memoized children
- Use `React.memo` only when profiler shows re-render bottleneck
- Lazy-load routes and heavy components with `React.lazy` + `Suspense`
- Use `key` prop correctly — stable, unique identifiers (not array index)

## Patterns
- Composition over prop drilling — use children and render props
- Error boundaries for graceful failure (class component required)
- Controlled components for forms (value + onChange)
- Custom hooks for side effects (data fetching, subscriptions, timers)

## Anti-Patterns
- No `useEffect` for derived state — compute during render
- No state for values that don't trigger re-renders — use `useRef`
- No direct DOM manipulation — use refs only for focus/measurement
- No `any` in component props — define explicit interfaces
