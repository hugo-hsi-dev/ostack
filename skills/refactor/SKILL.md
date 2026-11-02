---
name: refactor
description: Simplify code structure or migrate an internal API while preserving its observable behavior. Use for cleanup and behavior-preserving refactoring.
---

# Refactor

Name the behavior to preserve and the reading or maintenance cost to remove.

For the relevant structural decision, use the `principle-subtract-before-you-add`, `principle-minimize-reader-load`, or `principle-migrate-callers-then-delete-legacy-apis` skill. A newly discovered requirement can also call for `principle-redesign-from-first-principles`; that is not permission to change behavior outside this refactor.

1. Read the affected code, callers, and tests. Use existing coverage when it captures the contract. Add a focused characterization check only for important behavior otherwise unprotected.
2. Subtract first: remove dead paths, redundant validation, duplicate state, and wrappers that hide no meaningful decisions. Avoid unrelated cleanup.
3. Choose the smallest structure that removes the problem. Prefer domain types over repeated shape assumptions, derived values over synchronized copies, and narrow mutable scope over shared state. Three similar lines may be clearer than a new abstraction.
4. Move in units that can be checked. For an internal API with controlled callers, migrate them together and delete the obsolete path. For external consumers or independent deployments, honor compatibility requirements and plan a staged migration when needed.
5. Search for references outside symbol usages, including configuration, serialized names, docs, and scripts. Run the relevant checks and, where behavior warrants it, compare old and new outputs or drive the affected feature.

Use a codemod when repetition justifies it; do not build tooling for a handful of obvious edits. Keep discovered bugs separate unless the user authorized correcting them too.

Explain what became easier to understand, what contract stayed fixed, and how it was checked. If the new structure adds more coordination than it removes, reconsider it.
