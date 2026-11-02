---
name: verify
description: Verify implemented behavior against acceptance conditions using the running app, existing project checks, or a reference UI. Use for user journeys, verification evidence, and visual parity; creating or maintaining verification skills is a separate explicit workflow.
---

# Verify

Establish what behavior must be proven. Read the project's existing run instructions, verification skills, harness, and checks. Use their setup and current artifact contracts. Read only applicable shared documents; relative links resolve from the document's directory.

## Plan coverage

Translate the request into observable conditions. With a feature map, reconcile the index and in-scope files, then inspect each journey's source entry point, prerequisites, actions, expected end state, and gotchas. A targeted check covers affected journeys; a requested full audit covers all mapped features. A source-only review is not live coverage. Do not generate a map or new launch framework just to perform a check.

For questionable assertions, read [test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation.md). For quantitative evidence, read [explain the number](${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number.md) and use [measure](${CLAUDE_PLUGIN_ROOT}/playbooks/measure.md) when a controlled measurement is needed. An existing formal check can be run under its own instructions; a bounded model or test pass does not establish the whole product.

## Exercise the behavior

Confirm readiness, build identity, authentication, seed state, and ownership of the instance before driving it. Use the actual user interface rather than internal setters. Capture the action, resulting state, and consequential side effects. After surprising behavior, health-check and reset or relaunch to a known state before continuing. Clean up instances and temporary state you created, including failed attempts, while preserving evidence.

For UI parity, fix the reference and capture meaningful interaction states and responsive sizes. Use [compare artifacts](${CLAUDE_PLUGIN_ROOT}/playbooks/compare-artifacts.md), holding viewport, scale, browser, fonts, fixtures, theme, and animation state consistent. Keep baselines and tolerances fixed; intentional design changes need an explicit changed expectation. Check interaction and accessibility behavior separately from pixels.

## Judge and report

Read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works.md) before interpreting the evidence. Separate documentation drift, a harness gap, a product regression, and an unavailable prerequisite. Correct verification docs or owned helpers only within scope and re-drive affected journeys; report product bugs unless fixing them was requested. Preserve existing artifact names, locations, section structure, commands for supported environments, and coverage meaning. Do not weaken expectations to fit broken behavior or silently replace shared pstack artifacts.

Report verified, failed, and blocked conditions with evidence locations, corrections, and remaining gaps. Distinguish a failed check from one that could not run.

## User-invoked creation and upkeep

These original workflows remain distinct, manual-only skills:

- `/ostack:create-verification-skill`: generate and prove an app-driving skill and seed its feature map.
- `/ostack:maintain-verification-skill`: audit and repair an existing app-driving skill and map.
- `/ostack:create-formal-verification-skill`: establish a formal check and generate its reusable project skill.
- `/ostack:maintain-formal-verification-skill`: reconcile existing formal checks with code changes.

If a required harness is missing, name the prerequisite and point to the appropriate creation workflow. Do not silently launch a generator, full upkeep campaign, or read a manual-only skill to bypass its invocation policy.
