---
name: feature
description: Build or extend a product feature, integration, or user-facing capability from requirements through implementation and verification. Use for new behavior rather than bug fixes or behavior-preserving cleanup.
---

# Feature

Resolve relative links in shared documents from that document’s directory, not the app checkout. Read only the files whose conditions apply.

Own the requested feature through a usable result. Read the affected flow, callers, project instructions, and existing checks. Identify the user outcome, observable acceptance conditions, and compatibility constraints. Resolve ordinary implementation choices from the repo; ask only when an unresolved product decision blocks progress.

## Select guidance at the decision

Read the linked document when its condition occurs. These are shared Markdown files, not skills to invoke. Do not preload the collection or turn this list into mandatory phases.

| Situation | Read |
| --- | --- |
| A new requirement changes an existing design | [Redesign from first principles](${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles.md), before choosing how to extend the flow. |
| Ownership, data models, or interfaces need design | [Architect](${CLAUDE_PLUGIN_ROOT}/references/architect.md). |
| Product scope or interaction tradeoffs matter | [Experience first](${CLAUDE_PLUGIN_ROOT}/principles/experience-first.md). |
| Choosing types or representations | [Type-system discipline](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline.md); for TypeScript, [language guidance](${CLAUDE_PLUGIN_ROOT}/references/typescript-best-practices.md). |
| A runtime or interaction assumption needs an experiment | [Prototype](${CLAUDE_PLUGIN_ROOT}/playbooks/prototype.md). |
| The user requests competing idea proposals | [Arena](${CLAUDE_PLUGIN_ROOT}/playbooks/arena.md). |
| The user requests brainstorming across independent areas | [Swarm](${CLAUDE_PLUGIN_ROOT}/playbooks/swarm.md). |
| A planned rewrite has explicit phase boundaries | [Outcome-oriented execution](${CLAUDE_PLUGIN_ROOT}/principles/outcome-oriented-execution.md). |
| Multi-step delivery needs independently checkable units | [Sequence verifiable units](${CLAUDE_PLUGIN_ROOT}/principles/sequence-verifiable-units.md), subject to the user's branch and delivery constraints. |
| A reversible next step tempts an unnecessary permission question | [Never block on the human](${CLAUDE_PLUGIN_ROOT}/principles/never-block-on-the-human.md). |
| Context is filling with large files or outputs | [Guard the context window](${CLAUDE_PLUGIN_ROOT}/principles/guard-the-context-window.md); delegation remains subject to available tools and authorization. |

## Implement and finish

Build the smallest coherent change that satisfies the acceptance conditions. Migrate affected callers and remove superseded paths within scope. Preserve external contracts. Update the docs and examples that describe changed behavior.

Exercise the real affected path and run the relevant existing checks. When adding or changing tests, read [test behavior, not implementation](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation.md). If the project has a feature map, use the [targeted journey procedure](${CLAUDE_PLUGIN_ROOT}/references/verify-feature-map.md) for affected journeys. For a reference-matching UI change, use [visual parity](${CLAUDE_PLUGIN_ROOT}/references/visual-parity.md).

Before claiming completion, read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works.md). Report what changed, the evidence against the acceptance conditions, and material gaps. A feature request does not implicitly request a formal model, a generated verification skill, a brainstorm panel, or a merge.
