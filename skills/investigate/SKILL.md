---
name: investigate
description: "Explain how code works, why it was built that way, or what happened at runtime, without changing it. Use for questions like \"how does X work\", \"why is it like this\", \"where does this come from\", or reading logs, traces, and git history to explain an event."
---

# Investigate

## Workflow

1. **Define the question.** Identify the mechanism, historical decision, or runtime event to explain. Keep product code unchanged unless implementation was also requested.

2. **Collect the relevant evidence.** For historical questions, inspect nearby comments, tests, and commits; consult linked external records only where they can resolve an unanswered question. For runtime questions, inspect supplied traces, profiles, or logs before collecting another capture.

3. **Resolve uncertainty.** Identify the observation that distinguishes the remaining explanations.

4. **Finish the investigation.** Stop when the question is answered or the next observation requires an unavailable prerequisite. Separate observed behavior, historical evidence, and unresolved explanations.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Ownership or state representation is central to the explanation | [Model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) |
| Repeated unsuccessful explanations depend on the same assumption | [Attack the premise](${CLAUDE_PLUGIN_ROOT}/principles/attack-the-premise/PRINCIPLE.md) |
| It is unclear whether an observation supports the conclusion | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |

Give the answer, supporting source or artifact locations, consequential limits, and unresolved questions.
