---
name: review
description: "Use this skill to review code, assess a proposed design, or check what a change could break."
---

# Review

## Workflow

1. **Establish the scope.** Read the request, intended behavior, diff, tests, and surrounding code. For an unspecified branch review, compare with the merge base of its actual base branch and include relevant working changes. Keep product fixes outside scope unless requested.

2. **Trace the effects.** Follow affected callers and dependencies. Identify the assumptions carrying the change's safety claim and select the relevant principles below.

3. **Check candidate failures.** Probe the consequential paths against source or a focused reproduction. Keep scratch experiments separate from the user's changes. Use actual dependency versions when behavior depends on a library.

4. **Report findings.** Retain actionable findings with a location, trigger, consequence, and evidence. Combine findings with the same cause and distinguish confirmed defects, unresolved assumptions, and blocked checks. State when no actionable findings remain.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Supported callers, stored data, or external formats may be affected | [Preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md) |
| State variants or representation choices need judging | [Model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) |
| Indirection or hidden state obscures the change | [Minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load/PRINCIPLE.md) |
| Concurrent actors can write the same state | [Separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md) |
| Type signatures or schemas need assessing | [Type-system discipline](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline/PRINCIPLE.md) |
| Validation or adapter placement is disputed | [Boundary discipline](${CLAUDE_PLUGIN_ROOT}/principles/boundary-discipline/PRINCIPLE.md) |
| Caller interfaces or responsibilities need assessing | [Design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md) |
| The regression assertions are disputed | [Test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) |
| The evidence supporting a safety claim is uncertain | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |

Keep the response focused on findings, supporting evidence, and coverage limits. A requested design critique can include a recommendation.
