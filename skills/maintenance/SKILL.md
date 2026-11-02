---
name: maintenance
description: Update dependencies, build or CI configuration, repository tooling, or routine project housekeeping. Also use to prevent a demonstrated recurring repo mistake; documentation prose belongs to technical-writing.
---

# Maintenance

Resolve relative links in shared documents from that document’s directory, not the app checkout. Read only the files whose conditions apply.

Identify the maintenance outcome and the behavior that must remain intact. Read the actual dependency versions, configuration, project instructions, and existing checks before changing them. Handle a small housekeeping task directly; do not manufacture a migration plan or hardening project.

Select supporting guidance only where it affects the work:

- For a dependency or configuration change with downstream consequences, read [blast radius](${CLAUDE_PLUGIN_ROOT}/references/blast-radius.md). Check the actual target version's release notes and migration instructions before relying on changed behavior.
- For a repeated demonstrated mistake, read [correct](${CLAUDE_PLUGIN_ROOT}/references/correct.md) and [encode lessons in structure](${CLAUDE_PLUGIN_ROOT}/principles/encode-lessons-in-structure.md). This is repo enforcement, not personal-memory management.
- When nontrivial edits or checks need a rerunnable tool, read [build the lever](${CLAUDE_PLUGIN_ROOT}/principles/build-the-lever.md). Keep the tool proportional to the task.
- For retried setup, commands, or partial lifecycle runs, read [make operations idempotent](${CLAUDE_PLUGIN_ROOT}/principles/make-operations-idempotent.md).
- For CLI, config, or external-data validation, read [boundary discipline](${CLAUDE_PLUGIN_ROOT}/principles/boundary-discipline.md).
- Before adding another layer or dependency, read [subtract before you add](${CLAUDE_PLUGIN_ROOT}/principles/subtract-before-you-add.md).
- For a reversible next step that needs no new authorization, read [never block on the human](${CLAUDE_PLUGIN_ROOT}/principles/never-block-on-the-human.md).

Make the requested change, update owned manifests and lockfiles together, and remove obsolete configuration within scope. Run checks that exercise the behavior affected: dependency resolution and relevant tests, config validation, or a representative tooling command. Read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works.md) before reporting completion.

Report the change, compatibility consequences, checks run, and anything blocked. Deployment, publication, merging, and unrelated upgrades require their own task authorization.
