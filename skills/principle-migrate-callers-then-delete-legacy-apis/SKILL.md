---
name: principle-migrate-callers-then-delete-legacy-apis
description: "Apply when introducing a new internal API while old callers still exist. Migrate callers and delete the old API in the same wave instead of preserving compatibility layers."
---

Read [Codex compatibility](../onyo-mode/references/codex.md) before using this workflow. In a cloud skill reader, use the `onyo-mode` package from this same plugin and its `references/codex.md` resource; do not read a sibling resource through this skill’s package.

# Migrate Callers Then Delete Legacy APIs

- Update tests to assert the new contract, and delete tests that only protect pre-refactor implementation details

**When this applies:**
- No external users depend on backward compatibility
- The project can absorb coordinated breaking changes
- The new API is part of a simplification or refactor initiative
