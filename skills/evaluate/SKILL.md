---
name: evaluate
description: Compare prompts, skills, models, or agent workflows with controlled trials and blinded output assessment. Use when asked to evaluate agent behavior or compare variants.
---

# Evaluate

Define the behavior and decision before running trials. Use realistic tasks and a small, discriminating rubric. Start with the fewest trials that could reveal a useful difference and expand only if uncertainty affects the decision. Confirm a cost bound before substantial paid runs when the user has not provided one.

Keep the experimental variable separate from nuisance differences: same task, starting artifacts, tool access, and budget where possible. Use isolated working copies so trials cannot see each other's changes.

Candidate prompts should resemble actual user requests. Keep the rubric, expected answer, variant identity, and other candidates out of candidate-visible context unless those are part of the intended task. Avoid evaluator-created filenames or instructions that reveal what is being tested; preserve natural project context rather than banning ordinary words.

Score outputs under anonymous labels using one rubric. For a comparison, assess both variants on the same scale. A separate judge is optional and requires available, authorized execution; do not assume a second model family exists. Do not claim independence when the evaluator produced the output too.

Verify important claims against produced artifacts and runnable checks. For tool or skill usage, use execution records provided by the current environment; do not scrape local chat databases. If cloud execution records are unavailable, mark process compliance unverified. Self-report is insufficient evidence.

Report trial count, budget used when available, rubric, results with examples, failures, and uncertainty. Distinguish a smoke comparison from evidence of a general improvement. No automatic multi-model panel or minimum trial count.
