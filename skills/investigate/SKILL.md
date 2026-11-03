---
name: investigate
description: "Use this skill to investigate how code works, why it was designed that way, or what happened at runtime."
---

# Investigate

## Workflow

1. **Define the question.** Identify the mechanism, historical decision, or runtime event to explain. Keep product code unchanged unless implementation was also requested.

2. **Collect the relevant evidence.** Follow the affected source path. For historical questions, inspect nearby comments, tests, and commits; consult linked external records only where they can resolve an unanswered question. For runtime questions, inspect supplied traces, profiles, or logs before collecting another capture.

3. **Resolve uncertainty.** Map observations to source and identify the next observation needed to distinguish remaining explanations. For explicitly requested brainstorming across independent areas, use [swarm](${CLAUDE_PLUGIN_ROOT}/playbooks/swarm/PLAYBOOK.md); its proposals are inputs to investigation, not completed source coverage.

4. **Finish the investigation.** Stop when the question is answered or the next observation requires an unavailable prerequisite. Separate observed behavior, historical evidence, and unresolved explanations.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Ownership or state representation is central to the explanation | [Model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) |
| Repeated unsuccessful explanations depend on the same assumption | [Attack the premise](${CLAUDE_PLUGIN_ROOT}/principles/attack-the-premise/PRINCIPLE.md) |
| Large artifacts or repeated reads are filling the context | [Guard the context window](${CLAUDE_PLUGIN_ROOT}/principles/guard-the-context-window/PRINCIPLE.md) |
| It is unclear whether an observation supports the conclusion | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |

Give the answer, supporting source or artifact locations, consequential limits, and unresolved questions.
