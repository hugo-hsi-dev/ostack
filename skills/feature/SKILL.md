---
name: feature
description: Design, build, or extend a product feature, integration, or user-facing capability. Carry new behavior from requirements to a verified result; design-only requests stop at the recommendation.
---

# Feature

Own the requested outcome through design, implementation, and evidence. Read shared documents only at the conditions below; resolve their relative links from the document's directory.

## Establish the change

Read the affected flow, callers, tests, and project instructions. Identify the user outcome, observable acceptance conditions, and existing contracts. Ask only for product decisions the repo cannot answer and that block progress. For product or scope tradeoffs, read [experience first](${CLAUDE_PLUGIN_ROOT}/principles/experience-first/PRINCIPLE.md).

## Choose the shape

Before extending an existing design around a new requirement, read [redesign from first principles](${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles/PRINCIPLE.md). When ownership, representation, or interfaces are unresolved, read [design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md) and select the other principles relevant to the decision:

| Decision | Principle |
| --- | --- |
| Stateful branching or repeated shape assumptions | [Model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) |
| Core structures or scaffold-versus-feature sequencing | [Foundational thinking](${CLAUDE_PLUGIN_ROOT}/principles/foundational-thinking/PRINCIPLE.md) |
| Types and external schemas | [Type-system discipline](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline/PRINCIPLE.md); for TypeScript details, its [language applications](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline/references/typescript.md) |
| Validation and framework adapters | [Boundary discipline](${CLAUDE_PLUGIN_ROOT}/principles/boundary-discipline/PRINCIPLE.md) |
| Concurrent writers | [Separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md) |
| Retries or partial lifecycle runs | [Make operations idempotent](${CLAUDE_PLUGIN_ROOT}/principles/make-operations-idempotent/PRINCIPLE.md) |
| Interface depth or hidden state | [Minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load/PRINCIPLE.md) |
| Existing external consumers or persisted data | [Preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md) |

If observation is needed to choose a direction, use [prototype](${CLAUDE_PLUGIN_ROOT}/playbooks/prototype/PLAYBOOK.md). For a novel interaction or architecture without precedent, first read [exhaust the design space](${CLAUDE_PLUGIN_ROOT}/principles/exhaust-the-design-space/PRINCIPLE.md). A requested idea panel uses [arena](${CLAUDE_PLUGIN_ROOT}/playbooks/arena/PLAYBOOK.md); a requested brainstorm across independent areas uses [swarm](${CLAUDE_PLUGIN_ROOT}/playbooks/swarm/PLAYBOOK.md). Neither is a default design phase.

A design-only request ends with the chosen shape, consequential tradeoffs, and how to check it. Otherwise continue into implementation.

## Implement and prove the outcome

Build the smallest coherent change that meets the acceptance conditions. Update affected callers, docs, and examples; remove superseded paths within scope. Revisit the design if implementation repeatedly needs casts, caller coordination, or the same workaround.

Use existing tests and run the real affected user path, including its prerequisites and consequential side effects. If a project feature map exists, check its affected entry points rather than only the convenient path. Read [test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) when changing assertions. For reference-matching UI work, capture controlled states and use [compare artifacts](${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts/PLAYBOOK.md); check interactions separately.

For a phased rewrite, read [outcome-oriented execution](${CLAUDE_PLUGIN_ROOT}/principles/outcome-oriented-execution/PRINCIPLE.md). For a multi-step delivery, read [sequence verifiable units](${CLAUDE_PLUGIN_ROOT}/principles/sequence-verifiable-units/PRINCIPLE.md), within the user's branch constraints. If context fills with large reads, use [guard the context window](${CLAUDE_PLUGIN_ROOT}/principles/guard-the-context-window/PRINCIPLE.md), subject to available tools and authorized delegation.

Before reporting completion, read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md). Report the delivered behavior, evidence against the acceptance conditions, and remaining gaps. Do not silently turn a feature into a verification generator, maintenance campaign, or merge.
