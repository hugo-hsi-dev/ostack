---
name: maintenance
description: "Load before upgrading dependencies, changing config, build or CI pipelines, cleaning up the repo, or adding a lint or check against a recurring mistake, even mid-task and alongside project skills."
---

# Maintenance

## Workflow

1. **Establish the task.** Identify the requested update or recurring failure and the affected project behavior. Inspect installed versions, not manifests alone.

2. **Inspect the change.** For a dependency update, read the target version's authoritative migration instructions and identify affected integrations. For configuration or tooling, locate the source and its consumers. For recurrence prevention, collect the named failure and relevant code or review evidence.

3. **Apply the maintenance.** Update affected manifests and lockfiles together, edit the owned configuration or tooling, or implement the chosen enforcement. Remove obsolete task-owned files.

4. **Verify.** Run the build, the tests, and the changed tool or config itself, and confirm its consumers still work. Leave unrelated upgrades and publication outside scope unless requested.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| A dependency or configuration change affects supported consumers | [Preserve contracts](<${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md>) |
| An integration's caller expectations or ownership are unclear | [Design from caller usage](<${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md>) |
| External input validation or adapter placement needs choosing | [Boundary discipline](<${CLAUDE_PLUGIN_ROOT}/principles/boundary-discipline/PRINCIPLE.md>) |
| Setup or operations can be retried or interrupted | [Make operations idempotent](<${CLAUDE_PLUGIN_ROOT}/principles/make-operations-idempotent/PRINCIPLE.md>) |
| A demonstrated recurring mistake needs prevention | [Encode lessons in structure](<${CLAUDE_PLUGIN_ROOT}/principles/encode-lessons-in-structure/PRINCIPLE.md>) |
| The task adds structure while obsolete paths remain | [Subtract before you add](<${CLAUDE_PLUGIN_ROOT}/principles/subtract-before-you-add/PRINCIPLE.md>) |
| The edit or check may warrant a reusable tool | [Build the lever](<${CLAUDE_PLUGIN_ROOT}/principles/build-the-lever/PRINCIPLE.md>) |
| Only indirect evidence (logs, self-reports, proxies) supports the result | [Prove it works](<${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md>) |

Report in plain words first: the update, compatibility consequences, checks run, and anything blocked. End with `Method: ostack:maintenance`.
