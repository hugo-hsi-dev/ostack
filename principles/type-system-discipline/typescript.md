# Type-system discipline in TypeScript

Follow the repository's established conventions and strictness settings. Strengthen a type when it removes a real ambiguity or unsafe use, rather than adding brands or wrappers everywhere.

- Use discriminated unions for variants with different fields. Avoid optional-field bags that admit contradictory states.
- Treat external input as `unknown`. Parse at the boundary with the repository's existing schema library and derive the type from that schema. Do not add a dependency for a single simple guard.
- Derive types from authoritative generated schemas and existing signatures. Avoid maintaining a schema, interface, and guard for the same shape.
- Prefer narrowing and `satisfies` over unchecked assertions. Type assertions do not validate data; isolate unavoidable assertions and explain the invariant that justifies them. `as const` is useful for literal inference.
- A type guard must verify everything its predicate promises. Prefer compiler-visible discriminants where possible.
- Use exhaustiveness checks where adding a variant must force callers to handle it.
- Brand primitives only where mixing them up would be a meaningful bug. Reuse the repo's branding convention and validate construction.
- Keep `T[]` for total operations. Use a non-empty tuple when callers need a guaranteed first element, or return `undefined` when emptiness is legitimate.
- Validate semantic constraints the type cannot express, such as a finite, nonnegative duration. A plain number still permits negative values and `NaN`.

Keep compatibility, error handling, and logging consistent with the project.

## Examples

### Variants and exhaustiveness

```ts
type LoadState<T> =
  | { kind: "loading" }
  | { kind: "ready"; value: T }
  | { kind: "failed"; error: Error };

function label(state: LoadState<string>): string {
  switch (state.kind) {
    case "loading": return "Loading";
    case "ready": return state.value;
    case "failed": return state.error.message;
    default: {
      const unreachable: never = state;
      return unreachable;
    }
  }
}
```

The compiler rejects an unhandled variant. This does not validate data received at runtime.

### One schema owns validation and the type

When the project already uses Zod:

```ts
import { z } from "zod";

const UserSchema = z.object({
  id: z.string().uuid(),
  role: z.enum(["admin", "member"]),
});
type User = z.infer<typeof UserSchema>;
const parseUser = (input: unknown): User => UserSchema.parse(input);
```

Use the equivalent tools in the repo's existing schema library. Use a result-returning parser when invalid input is an expected branch.

### Total operations

```ts
type NonEmpty<T> = [T, ...T[]];
const first = <T>(items: NonEmpty<T>): T => items[0];
const sum = (items: number[]): number => items.reduce((a, b) => a + b, 0);
```

Empty input is legitimate for `sum`; it requires no stronger type. When an empty collection is valid for lookup, returning `T | undefined` can be the simpler contract.

### Runtime constraints

```ts
function parseDuration(input: unknown): number {
  if (typeof input !== "number" || !Number.isFinite(input) || input < 0) {
    throw new Error("Duration must be a finite nonnegative number");
  }
  return input;
}
```

Representing a range as start plus duration does not by itself prevent negative ranges. Validate the duration where it enters the system. Use a branded validated value only when the distinction needs to travel across interfaces.
