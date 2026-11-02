---
name: maintenance
description: Update dependencies, build or CI configuration, repository tooling, or project housekeeping. Also use to prevent a demonstrated recurring repo mistake; substantial documentation prose belongs to technical-writing.
---

# Maintenance

Identify the maintenance outcome and the behavior that must remain intact. Inspect actual versions, configuration, project instructions, and existing checks. Read shared documents at the conditions below; their relative links resolve from the document's directory.

## Select the work

- **Dependency update:** inspect the target version's authoritative release notes and migration instructions. Trace consumers, configuration, build behavior, and serialized data affected by the change; read [preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md). Update owned manifests and lockfiles together. If adapting the integration leaves an ownership or interface question, read [boundary discipline](${CLAUDE_PLUGIN_ROOT}/principles/boundary-discipline/PRINCIPLE.md) and read [design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md) for that question.
- **Configuration, CI, or tooling:** change the authoritative source and verify the path that consumes it. For retries or partial setup runs, read [make operations idempotent](${CLAUDE_PLUGIN_ROOT}/principles/make-operations-idempotent/PRINCIPLE.md). For external inputs, read [boundary discipline](${CLAUDE_PLUGIN_ROOT}/principles/boundary-discipline/PRINCIPLE.md). Remove obsolete configuration within scope.
- **Recurring demonstrated mistake:** read [encode lessons in structure](${CLAUDE_PLUGIN_ROOT}/principles/encode-lessons-in-structure/PRINCIPLE.md). Start from the named failure and code/review evidence, not session-transcript mining. Prefer removing the opportunity, then encoding the invariant in types, then an existing lint/check, then an observable-behavior test. Document only judgments that cannot be enforced. Prove the guard catches the actual failure and permits valid use; do not expand a one-off correction into repo-wide hardening.
- **Housekeeping:** do the bounded cleanup directly. Read [subtract before you add](${CLAUDE_PLUGIN_ROOT}/principles/subtract-before-you-add/PRINCIPLE.md) before adding another layer or dependency. Nontrivial repetitive edits or checks can use [build the lever](${CLAUDE_PLUGIN_ROOT}/principles/build-the-lever/PRINCIPLE.md); keep the tool proportional to the task.

## Finish the requested result

Use [never block on the human](${CLAUDE_PLUGIN_ROOT}/principles/never-block-on-the-human/PRINCIPLE.md) when a reversible next step tempts an unnecessary permission question. Preserve explicit authorization limits.

Run checks that exercise the affected behavior: dependency resolution and relevant tests, actual config validation, a representative tooling command, or a guard's broken/valid cases. Read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) before reporting completion. Report the change, compatibility consequences, evidence, and blocked checks. Publication, deployment, merging, and unrelated upgrades are separate outcomes.
