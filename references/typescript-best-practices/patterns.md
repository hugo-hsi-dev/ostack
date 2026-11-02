# TypeScript patterns

## Variants and exhaustiveness

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

## One schema owns validation and the type

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

## Total operations

```ts
type NonEmpty<T> = [T, ...T[]];
const first = <T>(items: NonEmpty<T>): T => items[0];
const sum = (items: number[]): number => items.reduce((a, b) => a + b, 0);
```

Empty input is legitimate for `sum`; it requires no stronger type. When an empty collection is valid for lookup, returning `T | undefined` can be the simpler contract.

## Runtime constraints

```ts
function parseDuration(input: unknown): number {
  if (typeof input !== "number" || !Number.isFinite(input) || input < 0) {
    throw new Error("Duration must be a finite nonnegative number");
  }
  return input;
}
```

Representing a range as start plus duration does not by itself prevent negative ranges. Validate the duration where it enters the system. Use a branded validated value only when the distinction needs to travel across interfaces.
