---
name: verify
description: Verify an implemented feature or fix against its acceptance conditions using the running app, existing project checks, or a reference UI. Use to check behavior, user journeys, or visual parity; creating or maintaining verification skills is a separate explicit workflow.
---

# Verify

Resolve relative links in shared documents from that document’s directory, not the app checkout. Read only the files whose conditions apply.

State what behavior must be established and find the project's existing run instructions, verification skills, harness, and checks. Use its current setup; do not create a new verification framework just to run a check.

- For affected journeys with an existing feature map, read [verify a feature map](${CLAUDE_PLUGIN_ROOT}/references/verify-feature-map.md). A targeted check covers affected features; an explicit full audit covers the whole map.
- For matching a UI reference or checking visual regressions, read [visual parity](${CLAUDE_PLUGIN_ROOT}/references/visual-parity.md).
- For tests whose assertions or scope are in question, read [test behavior, not implementation](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation.md).
- For interpreting a measured result, read [explain the number](${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number.md).

Read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works.md) before interpreting the result. Drive the relevant real interface, capture the action and resulting state, check consequential side effects, and preserve evidence while cleaning up instances and scratch state you created. Follow an existing formal check when it is relevant; a passing test or bounded model does not prove the whole product.

Report verified, failed, and blocked conditions with evidence and limitations. Report a product regression without changing product code unless fixing it is also requested. Preserve existing generated verification artifacts as shared contracts.

## Separate user-invoked workflows

Keep these original skills distinct. This Entry does not automatically launch a generator or an upkeep campaign:

- `/ostack:create-verification-skill` creates and proves a project-local app-driving skill and seeds its feature map.
- `/ostack:maintain-verification-skill` audits and repairs an existing app-driving skill and feature map.
- `/ostack:create-formal-verification-skill` establishes a formal check and generates its project-local verification skill.
- `/ostack:maintain-formal-verification-skill` reconciles existing formal verification with code changes.

If the requested check lacks the necessary harness, explain the missing prerequisite and point to the appropriate creation workflow. Do not invoke these manual-only skills through a routing workaround.
