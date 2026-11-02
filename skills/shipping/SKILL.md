---
name: shipping
description: Verify and land an existing pull-request stack in dependency order. Use when the user explicitly requests merging or landing a stack, not for ordinary implementation or PR status checks.
---

# Shipping

Use the existing PRs and native forge tools. This skill adds dependency and verification discipline to an authorized landing request; it does not recreate PR creation, CI monitoring, or project coordination.

1. Establish the requested PR set, actual target branch, dependency order, and user-owned gates. A ready-for-review request is not merge authorization. Keep PRs outside the set untouched.
2. For each candidate, identify what code and base were verified, the current head, required CI, and repository approval requirements. Check the behavior affected by the patch using the existing project harness. Green CI alone does not establish the intended behavior. Reuse valid evidence when it still covers the code and integration state; rerun only checks invalidated by a meaningful change. Do not infer equivalence from a matching patch ID alone.
3. Land only the contiguous verified sequence from the lowest unmerged dependency. A verified child waits for an unverified parent. Independent PRs can land separately only with evidence against their actual target state.
4. Merge one at a time through the supported native flow. Confirm the forge reports a completed merge into the intended target. Queued or auto-merge-enabled is not merged. A child still targeting its parent's branch needs the host's supported retargeting or restacking flow before it lands on trunk; reassess checks and evidence after that change.
5. Account for automated branch writers while landing. If the verified head changes, reconsider the affected evidence before proceeding. Respect required reviews and explicit human gates. Do not bypass a gate or rewrite a shared branch merely to finish.

Use native monitoring when waiting. There is no mandatory verifier per PR, swarm, watcher agent, fixed polling loop, or global settings change. Stop at the requested ceiling. Report what actually merged, remaining gaps, and the evidence that supports the result.
