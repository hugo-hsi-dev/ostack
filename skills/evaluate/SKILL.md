---
name: evaluate
description: Compare prompts, skills, models, or agent workflows using controlled trials and evidence-backed output assessment. Use for requested agent evaluations and variant comparisons.
---

# Evaluate

Define the behavior and decision before running trials. Read shared documents when their conditions apply; relative links resolve from the document's directory.

1. **Specify the comparison.** Choose realistic tasks and a small discriminating rubric. Identify the experimental variable and hold starting artifacts, tool access, and budgets comparable. Start with the fewest trials that can reveal a useful difference; confirm a cost bound before substantial paid execution without a supplied budget.
2. **Keep trials fair.** Use isolated working copies so candidates cannot see one another's changes. Give natural user requests and project context. Keep rubric, expected answers, variant identities, and rival outputs outside candidate context unless they belong to the intended task. Do not leak the tested condition through evaluator-created filenames or scaffolding.
3. **Assess the outputs.** Score anonymous outputs on one rubric. A separate judge requires available authorized execution; report when the evaluator also produced the output. Read [explain the number](${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number/PRINCIPLE.md) for quantitative conclusions and use [measure](${CLAUDE_PLUGIN_ROOT}/playbooks/measure/PLAYBOOK.md) when timing, throughput, or another measured result affects the decision. Read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) when a claimed result needs checking against actual artifacts.
4. **Check process claims.** Verify important outputs with runnable checks or produced artifacts. Use execution records supplied by the environment for tool or skill usage; never scrape local chat databases. Without records, mark process compliance unverified. Self-report and a brainstorm proposal are not execution evidence.
5. **Judge uncertainty.** Report trials, budget used when known, rubric, examples, failures, and limits. Expand only if unresolved uncertainty affects the decision. Distinguish a smoke comparison from evidence of a general improvement; no automatic model panel or minimum trial count.
