---
name: refactor
description: "Use this skill to refactor code or migrate an internal API without changing its intended behavior."
---

# Refactor

## Workflow

1. **Establish the contract.** Identify the behavior to preserve and the structural problem to address. Read affected callers and existing tests. Capture important uncovered behavior before changing it.

2. **Choose the change.** Identify the affected boundaries and callers, then consult the principles below for the structural decisions. If an assumption needs an executable experiment, use [prototype](${CLAUDE_PLUGIN_ROOT}/playbooks/prototype/PLAYBOOK.md).

3. **Apply the refactor.** Change the affected implementation, callers, configuration, and documentation. Track references beyond symbol usages where the migration touches serialized names or scripts. Keep unrelated bugs outside scope unless correcting them was requested.

4. **Check equivalence.** Run the affected checks against the behavior contract. When old/new artifacts supply a comparison, use [compare artifacts](${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts/PLAYBOOK.md); exercise affected interactions separately.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| An addition or rewrite must be sequenced with removals | [Subtract before you add](${CLAUDE_PLUGIN_ROOT}/principles/subtract-before-you-add/PRINCIPLE.md) |
| Abstractions, layers, or diff size need judging | [Laziness protocol](${CLAUDE_PLUGIN_ROOT}/principles/laziness-protocol/PRINCIPLE.md) |
| The code is difficult to trace or holds too much hidden state | [Minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load/PRINCIPLE.md) |
| State representation or branching needs changing | [Model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) |
| Concurrent actors can write the same state | [Separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md) |
| Caller expectations or boundaries need choosing | [Design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md) |
| A newly discovered requirement changes the design | [Redesign from first principles](${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles/PRINCIPLE.md) |
| A replacement internal API still has old callers | [Migrate callers then delete legacy APIs](${CLAUDE_PLUGIN_ROOT}/principles/migrate-callers-then-delete-legacy-apis/PRINCIPLE.md) |
| External consumers or independent deployments are involved | [Preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md) |
| A rewrite has explicit migration phases | [Outcome-oriented execution](${CLAUDE_PLUGIN_ROOT}/principles/outcome-oriented-execution/PRINCIPLE.md) |
| The migration includes repeated mechanical edits | [Build the lever](${CLAUDE_PLUGIN_ROOT}/principles/build-the-lever/PRINCIPLE.md) |
| The refactor needs separately checkable delivery units | [Sequence verifiable units](${CLAUDE_PLUGIN_ROOT}/principles/sequence-verifiable-units/PRINCIPLE.md) |
| Characterization-test assertions are unclear | [Test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) |
| The equivalence evidence is uncertain | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |

Report the structural change, preserved behavior, verification evidence, and any remaining compatibility questions.
