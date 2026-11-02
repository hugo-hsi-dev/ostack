---
name: playbook-prototype
description: Build a small disposable experiment to resolve a concrete design, interaction, or implementation uncertainty before committing to production code.
---

# Prototype playbook

State the decision and the observation that would change it. If inspection can settle the question, use that evidence first.

For product-experience choices, use `principle-experience-first`. A novel interaction or architecture with no precedent can call for `principle-exhaust-the-design-space`. These principle skills also apply outside prototyping.

Build the smallest experiment that tests the uncertainty. Keep it separate from production changes. Use the real runtime or dependency when its behavior is the question; a stand-in must preserve the relevant constraints.

For a visual or interaction decision, render and drive the meaningful states. When comparing variants, use the same fixture and a simple way to switch between them. Two variants are enough when they resolve the fork; no fixed number of alternatives is required.

For an architectural or timing decision, probe the actual assumption with a small script or working slice. Record inputs, observations, and environment limits. A prototype that only illustrates the idea does not prove runtime behavior.

Present the artifact, observed result, recommendation, and remaining uncertainty. State whether it is disposable or suitable to develop further. Continue to production implementation only when that is within the user's request.
