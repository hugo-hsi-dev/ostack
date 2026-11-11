---
name: bug-fix
description: "Load before fixing a bug, crash, error, failing or flaky test, broken build or deploy, or regression, even mid-task and alongside project skills. Reproduces it, finds the root cause, adds a failing regression check, and proves the fix."
---

# Bug fix

## Workflow

1. **Reproduce.** Establish expected and actual behavior at the affected interface. Keep a concrete reproduction to repeat after the fix.

2. **Investigate.** Check commits and PRs for an earlier fix of the same symptom, then use runtime observations where they resolve uncertainty.

3. **Prepare a regression check.** Before editing product code, add a focused test when requested or practical with the existing harness. Prove it fails on the unfixed code with [negative control](<${CLAUDE_PLUGIN_ROOT}/playbooks/negative-control/PLAYBOOK.md>). When a new test is impractical, retain the reproduction as the before-and-after check.

4. **Implement.** Apply the correction. Remove your rejected experimental changes and check affected paths for other instances of the same fault.

5. **Verify.** Rerun the original reproduction and the regression test. If the repo has a verify-* skill (in `.claude/skills/` or `.agents/skills/`), drive the affected journeys with [live run](<${CLAUDE_PLUGIN_ROOT}/playbooks/live-run/PLAYBOOK.md>) before opening the PR.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| The symptom's origin or correct intervention point is unclear | [Fix root causes](<${CLAUDE_PLUGIN_ROOT}/principles/fix-root-causes/PRINCIPLE.md>) |
| Repeated unsuccessful attempts depend on the same assumption | [Attack the premise](<${CLAUDE_PLUGIN_ROOT}/principles/attack-the-premise/PRINCIPLE.md>) |
| Regression-test coverage or assertions are unclear | [Test behavior](<${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md>) |
| Retries, restarts, or partial execution affect the bug | [Make operations idempotent](<${CLAUDE_PLUGIN_ROOT}/principles/make-operations-idempotent/PRINCIPLE.md>) |
| Multiple actors can write the affected state | [Separate shared state](<${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md>) |
| The fault involves state variants or representation choices | [Model the domain](<${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md>) |
| Caller expectations or responsibility boundaries are unclear | [Design from caller usage](<${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md>) |
| The reported bug introduces a changed requirement | [Redesign from first principles](<${CLAUDE_PLUGIN_ROOT}/principles/redesign-from-first-principles/PRINCIPLE.md>) |
| The user requests structural prevention of a recurring mistake | [Encode lessons in structure](<${CLAUDE_PLUGIN_ROOT}/principles/encode-lessons-in-structure/PRINCIPLE.md>) |
| Only indirect evidence (logs, self-reports, proxies) supports the result | [Prove it works](<${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md>) |

Report in plain words first: the cause, the fix, and before-and-after evidence. Mark suspected causes and unverified fixes as such. End with `Live run: done | skipped (reason)` and `Method: ostack:bug-fix`.
