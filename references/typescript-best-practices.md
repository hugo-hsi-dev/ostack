# TypeScript best practices

For a type-modeling decision, use the [type-system-discipline](../principles/type-system-discipline.md) document; the rules below apply it to TypeScript.

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

For focused examples, read [patterns](typescript-best-practices/patterns.md) only as needed. Keep compatibility, error handling, and logging consistent with the project.
