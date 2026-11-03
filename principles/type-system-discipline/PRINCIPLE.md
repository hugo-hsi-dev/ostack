# Type System Discipline

Apply when designing types, reviewing a function signature, or writing code in any statically-typed language.

Make the compiler reject impossible states, mismatched primitives, and unhandled variants. Prefer defining errors and special cases out of existence over proliferating handlers. For TypeScript syntax, see the [TypeScript guidance](references/typescript.md).

- **Brand semantic primitives.** `UserId` and `OrderId` are strings underneath but should not be interchangeable. Give each its own type, such as a branded intersection in TypeScript or a newtype elsewhere. Validate once at creation, trust the type downstream. If two arguments share a primitive type but mean different things, brand them.
- **External data is untyped until parsed.** Have a parse function at every boundary that turns unstructured input into the typed model. [boundary-discipline](../boundary-discipline/PRINCIPLE.md) says where to put validation.
- **Derive types from authoritative schemas.** When a protocol buffer, OpenAPI spec, GraphQL schema, database migration, design-token file, or another file owns a shape, derive from it instead of hand-rolling a parallel type. See [encode-lessons-in-structure](../encode-lessons-in-structure/PRINCIPLE.md).
