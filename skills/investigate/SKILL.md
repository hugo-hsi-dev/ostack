---
name: investigate
description: "Load before explaining how or why code, logs, data, or history works or happened, without changing it, including read-only research, \"is this a real fix?\" and \"look into it but don't change anything\", even mid-task and alongside project skills."
---

# Investigate

## Workflow

1. **Define the question.** Identify the mechanism, historical decision, or runtime event to explain. Keep product code unchanged unless implementation was also requested.

2. **Collect the relevant evidence.** First check commits and PRs for earlier work on the same question. For historical questions, inspect nearby comments and tests; consult linked external records only where they can resolve an unanswered question. For runtime questions, inspect supplied traces, profiles, or logs before collecting another capture.

3. **Resolve uncertainty.** Identify the observation that distinguishes the remaining explanations.

4. **Finish the investigation.** Stop when the question is answered or the next observation requires an unavailable prerequisite. Separate observed behavior, historical evidence, and unresolved explanations.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Ownership or state representation is central to the explanation | [Model the domain](<${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md>) |
| Repeated unsuccessful explanations depend on the same assumption | [Attack the premise](<${CLAUDE_PLUGIN_ROOT}/principles/attack-the-premise/PRINCIPLE.md>) |
| It is unclear whether an observation supports the conclusion | [Prove it works](<${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md>) |

Give the answer in plain words first, then source or artifact locations, limits that matter, and open questions. End with `Method: ostack:investigate`.
