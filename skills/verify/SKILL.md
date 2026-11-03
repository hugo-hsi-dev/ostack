---
name: verify
description: "Prove that a feature or fix actually works by driving the real app through its user journeys, capturing evidence, and comparing UI or output against a reference. Use after a change lands, or when asked to verify, test end to end, check parity, or confirm something works."
---

# Verify

## Workflow

1. **Define coverage.** Identify the acceptance conditions and the project's existing verification skill, run instructions, and harness. If there is a feature map, select affected journeys or the full map according to the requested scope and inspect their source, prerequisites, and expected results.

2. **Check the harness exists.** When it is missing, report the prerequisite and point to the appropriate user-invoked creation skill instead of launching a generator automatically.

3. **Exercise the conditions.** Run the selected journeys with [live run](${CLAUDE_PLUGIN_ROOT}/playbooks/live-run/PLAYBOOK.md). Use [compare artifacts](${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts/PLAYBOOK.md) for reference matching or UI parity, [measure](${CLAUDE_PLUGIN_ROOT}/playbooks/measure/PLAYBOOK.md) for quantitative checks, and the project's existing instructions for an already established formal check.

4. **Reconcile failures.** Correct verification docs or owned helpers only within scope; report product defects unless fixing them was requested.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Coverage or assertions are uncertain | [Test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) |
| Quantitative results need interpretation | [Explain the number](${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number/PRINCIPLE.md) |
| Only indirect evidence (logs, self-reports, proxies) supports the result | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |
| Existing verification artifacts are shared with other workflows | [Preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md) |

Include evidence locations, corrections, remaining gaps, and conditions that could not be checked.
