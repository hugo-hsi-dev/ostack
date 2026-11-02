---
name: refactor
description: Simplify code structure or migrate an internal API while preserving observable behavior. Use for cleanup, module-boundary changes, and behavior-preserving refactoring.
---

# Refactor

Name the behavior to preserve and the reading or maintenance cost to remove. Read affected callers, tests, and project constraints. Read shared documents only for the decision in front of you; relative links resolve from the document's directory.

1. **Establish the baseline.** Use existing coverage for the contract. Add a focused characterization check only for important unprotected behavior, following [test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation.md).
2. **Remove unnecessary structure.** Read [subtract before you add](${CLAUDE_PLUGIN_ROOT}/principles/subtract-before-you-add.md). Delete dead paths, duplicate state, redundant validation, and wrappers that hide no decisions. For abstraction pressure, read [laziness protocol](${CLAUDE_PLUGIN_ROOT}/principles/laziness-protocol.md); for indirection or hidden state, [minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load.md).
3. **Resolve the shape.** For stateful branching, read [model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain.md). For concurrent writers, read [separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state.md). Use [design](${CLAUDE_PLUGIN_ROOT}/playbooks/design.md) when ownership, representation, or interfaces need choosing, and [prototype](${CLAUDE_PLUGIN_ROOT}/playbooks/prototype.md) only for an assumption inspection cannot settle. A new requirement can call for [redesign from first principles](${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles.md); preserve behavior outside the authorized change.
4. **Migrate callers.** With controlled internal callers, read [migrate callers then delete legacy APIs](${CLAUDE_PLUGIN_ROOT}/principles/migrate-callers-then-delete-legacy-apis.md) and move them together. For external consumers or independent deployments, read [preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts.md) and honor the supported migration path. Search serialized names, configuration, docs, and scripts beyond symbol references. A phased rewrite can use [outcome-oriented execution](${CLAUDE_PLUGIN_ROOT}/principles/outcome-oriented-execution.md).
5. **Check equivalence.** Verify each coherent unit before building on it. Use [compare artifacts](${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts.md) when old/new outputs or UI states provide the behavior oracle; exercise affected interactions too. Run checks invalidated by the refactor and read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works.md) before claiming the contract survived.

Use a codemod when repetition warrants it. Keep unrelated cleanup and newly discovered bugs outside scope unless authorized. Explain what became easier to understand, what behavior stayed fixed, and the supporting evidence. Reconsider a reshape that adds more coordination than it removes.
