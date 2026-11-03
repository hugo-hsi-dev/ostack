---
name: feature
description: "Use this skill to design, build, or extend a feature or integration."
---

# Feature

## Workflow

1. **Establish the outcome.** Read the affected flow, callers, project instructions, and existing checks. Identify the requested behavior, acceptance conditions, supported consumers, and unresolved product choices.

2. **Choose the design.** Sketch the affected usage and interfaces where the shape is unresolved. Use the principles below for the decisions encountered. If an assumption needs an executable experiment, use [prototype](${CLAUDE_PLUGIN_ROOT}/playbooks/prototype/PLAYBOOK.md). For a requested comparison of competing ideas, use [arena](${CLAUDE_PLUGIN_ROOT}/playbooks/arena/PLAYBOOK.md); for requested brainstorming across separate areas, use [swarm](${CLAUDE_PLUGIN_ROOT}/playbooks/swarm/PLAYBOOK.md). A design-only request ends with the recommendation and how it can be checked.

3. **Implement.** Apply the chosen design and update affected callers, documentation, and examples. Revisit unresolved design questions exposed by implementation.

4. **Verify.** Exercise the acceptance conditions through the existing harness and run checks affected by the change. Include affected mapped journeys when a feature map exists. For reference-matching UI work, use [compare artifacts](${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts/PLAYBOOK.md) and check affected interactions separately. Clean up temporary instances while retaining useful evidence.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Product experience or feature scope needs a tradeoff | [Experience first](${CLAUDE_PLUGIN_ROOT}/principles/experience-first/PRINCIPLE.md) |
| A new requirement changes an existing design | [Redesign from first principles](${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles/PRINCIPLE.md) |
| Caller usage, ownership, or interfaces remain unclear | [Design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md) |
| State variants or data representation need choosing | [Model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) |
| Core structures or foundational work need sequencing | [Foundational thinking](${CLAUDE_PLUGIN_ROOT}/principles/foundational-thinking/PRINCIPLE.md) |
| Types, function signatures, or external schemas need designing | [Type-system discipline](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline/PRINCIPLE.md) |
| Validation or framework-adapter placement is unclear | [Boundary discipline](${CLAUDE_PLUGIN_ROOT}/principles/boundary-discipline/PRINCIPLE.md) |
| Concurrent actors can write the same state | [Separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md) |
| Operations can be retried or interrupted | [Make operations idempotent](${CLAUDE_PLUGIN_ROOT}/principles/make-operations-idempotent/PRINCIPLE.md) |
| Interfaces or hidden state are becoming hard to follow | [Minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load/PRINCIPLE.md) |
| Supported consumers or persisted data may be affected | [Preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md) |
| A novel design has no useful precedent | [Exhaust the design space](${CLAUDE_PLUGIN_ROOT}/principles/exhaust-the-design-space/PRINCIPLE.md) |
| A rewrite has explicit migration phases | [Outcome-oriented execution](${CLAUDE_PLUGIN_ROOT}/principles/outcome-oriented-execution/PRINCIPLE.md) |
| Multi-step work needs delivery boundaries | [Sequence verifiable units](${CLAUDE_PLUGIN_ROOT}/principles/sequence-verifiable-units/PRINCIPLE.md) |
| Large reads or outputs are filling the context | [Guard the context window](${CLAUDE_PLUGIN_ROOT}/principles/guard-the-context-window/PRINCIPLE.md) |
| Acceptance-test assertions need choosing | [Test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) |
| The completion evidence is uncertain | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |

Report the delivered behavior, consequential design choices, verification evidence, and remaining gaps.
