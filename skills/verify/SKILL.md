---
name: verify
description: "Use this skill to verify a feature or fix, check user journeys, or compare a UI against its reference."
---

# Verify

## Workflow

1. **Define coverage.** Identify the acceptance conditions and the project's existing verification skill, run instructions, and harness. If there is a feature map, select affected journeys or the full map according to the requested scope and inspect their source, prerequisites, and expected results.

2. **Prepare the environment.** Confirm the required build, readiness, authentication, fixtures, and instance ownership. When the harness is missing, report the prerequisite and point to the appropriate user-invoked creation skill instead of launching a generator automatically.

3. **Exercise the conditions.** Run the selected journeys and capture their actions, results, and side effects. Use [compare artifacts](${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts/PLAYBOOK.md) for reference matching or UI parity, [measure](${CLAUDE_PLUGIN_ROOT}/playbooks/measure/PLAYBOOK.md) for quantitative checks, and the project's existing instructions for an already established formal check. Include affected interaction and accessibility checks when pixels alone do not cover the request.

4. **Reconcile failures.** Identify documentation drift, a harness gap, a product defect, or an unavailable prerequisite. Correct verification docs or owned helpers only within scope; report product defects unless fixing them was requested. Rerun journeys affected by corrections.

5. **Conclude the run.** Clean up instances and scratch state created by the verification while retaining evidence. Report verified, failed, and blocked conditions. Full creation or upkeep remains an explicit invocation of create-verification-skill, maintain-verification-skill, create-formal-verification-skill, or maintain-formal-verification-skill; do not bypass their manual-only setting.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Coverage or assertions are uncertain | [Test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) |
| Quantitative results need interpretation | [Explain the number](${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number/PRINCIPLE.md) |
| It is unclear what the collected evidence establishes | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |
| Existing verification artifacts are shared with other workflows | [Preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md) |

Include evidence locations, corrections, remaining gaps, and conditions that could not be checked.
