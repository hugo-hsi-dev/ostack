---
name: refactor
description: Simplify code structure or migrate an internal API while preserving its observable behavior. Use for cleanup and behavior-preserving refactoring.
---

# Refactor

Resolve relative links in shared documents from that document’s directory, not the app checkout. Read only the files whose conditions apply.

Name the behavior to preserve and the reading or maintenance cost to remove.

For the relevant structural decision, read [subtract before you add](${CLAUDE_PLUGIN_ROOT}/principles/subtract-before-you-add.md), [minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load.md), or [migrate callers then delete legacy APIs](${CLAUDE_PLUGIN_ROOT}/principles/migrate-callers-then-delete-legacy-apis.md). A newly discovered requirement can also call for [redesign from first principles](${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles.md); that is not permission to change behavior outside this refactor. These are shared files, not skill invocations.

When tempted to add abstractions or preserve unnecessary layers, read [laziness protocol](${CLAUDE_PLUGIN_ROOT}/principles/laziness-protocol.md). For stateful branching, read [model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain.md). For a planned migration with explicit phase boundaries, read [outcome-oriented execution](${CLAUDE_PLUGIN_ROOT}/principles/outcome-oriented-execution.md).

1. Read the affected code, callers, and tests. Use existing coverage when it captures the contract. Add a focused characterization check only for important behavior otherwise unprotected.
2. Subtract first: remove dead paths, redundant validation, duplicate state, and wrappers that hide no meaningful decisions. Avoid unrelated cleanup.
3. Choose the smallest structure that removes the problem. Prefer domain types over repeated shape assumptions, derived values over synchronized copies, and narrow mutable scope over shared state. Three similar lines may be clearer than a new abstraction.
4. Move in units that can be checked. For an internal API with controlled callers, migrate them together and delete the obsolete path. For external consumers or independent deployments, honor compatibility requirements and plan a staged migration when needed.
5. Search for references outside symbol usages, including configuration, serialized names, docs, and scripts. For compatibility outside the diff, read [blast radius](${CLAUDE_PLUGIN_ROOT}/references/blast-radius.md). Run the relevant checks and, where behavior warrants it, compare old and new outputs or drive the affected feature. For a UI migration, read [visual parity](${CLAUDE_PLUGIN_ROOT}/references/visual-parity.md).

Use a codemod when repetition justifies it; do not build tooling for a handful of obvious edits. Keep discovered bugs separate unless the user authorized correcting them too.

Explain what became easier to understand, what contract stayed fixed, and how it was checked. If the new structure adds more coordination than it removes, reconsider it.
