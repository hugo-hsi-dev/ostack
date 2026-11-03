---
name: bug-fix
description: "Diagnose and fix a bug, crash, error, failing test, flaky behavior, or regression: reproduce it, find the root cause, add a regression check, and prove the fix. Use when something is broken, wrong, or behaves differently than expected."
---

# Bug fix

## Workflow

1. **Reproduce.** Establish expected and actual behavior at the affected interface. Keep a concrete reproduction to repeat after the fix.

2. **Investigate.** Use history or runtime observations where they can resolve uncertainty.

3. **Prepare a regression check.** Before editing product code, add a focused test when requested or practical with the existing harness. Run it against the unfixed code. When a new test is impractical, retain the reproduction as the before-and-after check.

4. **Implement.** Apply the correction. Remove your rejected experimental changes and check affected paths for other instances of the same fault.

5. **Verify.** Rerun the original reproduction and the regression test. If the bug affects a mapped user journey, exercise that journey through the project's existing verification tooling. Clean up temporary instances created for the investigation while retaining useful evidence.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| The symptom's origin or correct intervention point is unclear | [Fix root causes](${CLAUDE_PLUGIN_ROOT}/principles/fix-root-causes/PRINCIPLE.md) |
| Repeated unsuccessful attempts depend on the same assumption | [Attack the premise](${CLAUDE_PLUGIN_ROOT}/principles/attack-the-premise/PRINCIPLE.md) |
| Regression-test coverage or assertions are unclear | [Test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) |
| Retries, restarts, or partial execution affect the bug | [Make operations idempotent](${CLAUDE_PLUGIN_ROOT}/principles/make-operations-idempotent/PRINCIPLE.md) |
| Multiple actors can write the affected state | [Separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md) |
| The fault involves state variants or representation choices | [Model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) |
| Caller expectations or responsibility boundaries are unclear | [Design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md) |
| The reported bug introduces a changed requirement | [Redesign from first principles](${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles/PRINCIPLE.md) |
| The user requests structural prevention of a recurring mistake | [Encode lessons in structure](${CLAUDE_PLUGIN_ROOT}/principles/encode-lessons-in-structure/PRINCIPLE.md) |
| Only indirect evidence (logs, self-reports, proxies) supports the result | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |

Report the cause, correction, and before-and-after evidence. Distinguish suspected causes and unverified corrections from what was demonstrated.
