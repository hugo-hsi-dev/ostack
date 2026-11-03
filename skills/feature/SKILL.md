---
name: feature
description: "Design and build a new feature, integration, endpoint, command, or UI, or extend existing behavior. Use when asked to add, implement, build, support, or design something, including design-only questions about how a new capability should be shaped."
---

# Feature

## Workflow

1. **Establish the outcome.** Identify the requested behavior, acceptance conditions, supported consumers, and unresolved product choices.

2. **Choose the design.** Sketch the affected usage and interfaces where the shape is unresolved. If an assumption needs an executable experiment, or a novel UI or architecture has no precedent in the codebase and depends on feel, use [prototype](${CLAUDE_PLUGIN_ROOT}/playbooks/prototype/PLAYBOOK.md). A design-only request ends with the recommendation and how it can be checked.

3. **Implement.** Update affected callers, documentation, and examples. Revisit unresolved design questions exposed by implementation.

4. **Verify.** Exercise the acceptance conditions through the existing harness. Drive affected mapped journeys with [live run](${CLAUDE_PLUGIN_ROOT}/playbooks/live-run/PLAYBOOK.md) when a feature map exists. For reference-matching UI work, use [compare artifacts](${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts/PLAYBOOK.md).

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Product experience or feature scope needs a tradeoff | [Experience first](${CLAUDE_PLUGIN_ROOT}/principles/experience-first/PRINCIPLE.md) |
| A new requirement changes an existing design | [Redesign from first principles](${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles/PRINCIPLE.md) |
| Caller usage, ownership, or interfaces remain unclear | [Design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md) |
| State variants or data representation need choosing | [Model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) |
| Types, function signatures, or external schemas need designing | [Type-system discipline](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline/PRINCIPLE.md) |
| Validation or framework-adapter placement is unclear | [Boundary discipline](${CLAUDE_PLUGIN_ROOT}/principles/boundary-discipline/PRINCIPLE.md) |
| Concurrent actors can write the same state | [Separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md) |
| Operations can be retried or interrupted | [Make operations idempotent](${CLAUDE_PLUGIN_ROOT}/principles/make-operations-idempotent/PRINCIPLE.md) |
| Interfaces or hidden state are becoming hard to follow | [Minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load/PRINCIPLE.md) |
| Supported consumers or persisted data may be affected | [Preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md) |
| The change adds structure while dead or redundant code remains | [Subtract before you add](${CLAUDE_PLUGIN_ROOT}/principles/subtract-before-you-add/PRINCIPLE.md) |
| A rewrite has explicit migration phases | [Outcome-oriented execution](${CLAUDE_PLUGIN_ROOT}/principles/outcome-oriented-execution/PRINCIPLE.md) |
| Multi-step work needs ordering or delivery boundaries | [Sequence verifiable units](${CLAUDE_PLUGIN_ROOT}/principles/sequence-verifiable-units/PRINCIPLE.md) |
| Acceptance-test assertions need choosing | [Test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) |
| Only indirect evidence (logs, self-reports, proxies) supports the result | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |

Report the delivered behavior, consequential design choices, verification evidence, and remaining gaps.
