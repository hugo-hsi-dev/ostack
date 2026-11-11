---
name: verify
description: "Load before calling a change done or opening its PR when the repo has a verify-* skill or feature map, and when asked to verify, test end to end, or check parity. Drives the real app alongside project skills and keeps evidence."
---

# Verify

## Workflow

1. **Define coverage.** Identify the acceptance conditions and the project's existing verification skill (`.claude/skills/verify-*` or `.agents/skills/verify-*`), run instructions, and harness. If there is a feature map, select affected journeys or the full map according to the requested scope and inspect their source, prerequisites, and expected results.

2. **Check the harness exists.** When it is missing, report the prerequisite and point to the appropriate user-invoked creation skill instead of launching a generator automatically.

3. **Exercise the conditions.** Run the selected journeys with [live run](<${CLAUDE_PLUGIN_ROOT}/playbooks/live-run/PLAYBOOK.md>). Use [compare artifacts](<${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts/PLAYBOOK.md>) for reference matching or UI parity, [measure](<${CLAUDE_PLUGIN_ROOT}/playbooks/measure/PLAYBOOK.md>) for quantitative checks, and the project's existing instructions for an already established formal check.

4. **Reconcile failures.** Correct verification docs or owned helpers only within scope; report product defects unless fixing them was requested.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Coverage or assertions are uncertain | [Test behavior](<${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md>) |
| Quantitative results need interpretation | [Explain the number](<${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number/PRINCIPLE.md>) |
| Only indirect evidence (logs, self-reports, proxies) supports the result | [Prove it works](<${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md>) |
| Existing verification artifacts are shared with other workflows | [Preserve contracts](<${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md>) |

Report each journey as verified, failed, or blocked in plain words, with evidence locations, corrections, and what could not be checked. End with `Method: ostack:verify`.
