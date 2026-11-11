---
name: maintain-verification-skill
description: "Audit and update an existing verify-<app> skill and its feature map against the current app, fixing drift and harness gaps. Run only when asked to maintain app verification."
disable-model-invocation: true
---

# Maintain a verification skill

## Workflow

1. **Locate the target.**

    Find the verification skill to maintain: the project-local skill whose body has launch/drive sections and a feature map (usually `.claude/skills/verify-*/` or `.agents/skills/verify-*/`). Several candidates → ask which one; none → stop and point at `/ostack:create-verification-skill` instead of inventing a target.

    Only edit the verification skill's own directory (its SKILL.md, features/, and any harness scripts it owns). Never edit product code during a run: a behavior the map describes that the app no longer does is either doc drift (fix the map) or a product regression (report it, don't paper over it in docs).

    Cover each feature rather than treating every documentation bullet as a separate live test.

2. **Index hygiene.**

    Read the feature map README and glob its sibling files. Fix missing, extra, duplicate, or dead entries. Lightweight; no generated inventory.

3. **Source pass.**

    For each feature file, explain "how does this user-facing feature work?" from source, flag likely doc drift with citations, and write one concise live-verification recipe. Do this yourself for a small map. For a large map, hand batches of feature files to read-only `Explore` subagents that never drive the app or edit files and return: feature summary / source entry points / likely drift or none / one recipe.

4. **Reconcile.**

    Confirm every feature file has a returned summary. Merge overlapping recipes into as few app states as practical. Spot-check cited drift; don't re-prove clean claims. Sweep recent churn for user-facing surfaces missing from the map — require a concrete source path before calling one missing.

5. **Live pass.**

    Required even when source looks clean. The main session drives every feature at least once with [live run](<${CLAUDE_PLUGIN_ROOT}/playbooks/live-run/PLAYBOOK.md>), following the verification skill's own launch model. A doctor failure caused by skill drift is drift: fix it under edit scope and retry once, restarting only what the fix invalidated, before calling the pass `blocked`. Report an unreachable feature as `verified-unreachable`; if the map omits its prerequisite, that's drift.

6. **Triage.**

    Fix doc drift and harness gaps found by the live run; a harness fix follows the same helpers rule as generation (scripts executable, invocation documented in the skill body). Record product defects for the user and keep them out of this change.

7. **Ship or stop.**

    Re-read every changed file before reporting.

    Pick one, and say which:

    - **clean** — every feature got source and live coverage; nothing worth shipping.
    - **changed** — proven doc, harness, or map corrections, kept as one change separate from product fixes.
    - **blocked** — coverage could not finish or a proven fix could not ship safely. Say exactly what blocked it.

    Keep concise run notes (features covered, unreachable prerequisites, confirmed drift, outcome) in the session scratchpad.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| The source or live evidence does not clearly establish coverage | [Prove it works](<${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md>) |
| A journey or harness assertion needs changing | [Test behavior](<${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md>) |
| A correction may change the shared verification artifact contract | [Preserve contracts](<${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md>) |

Report the outcome, source and live coverage, corrected drift, product gaps, unreachable prerequisites, and blocked work.
