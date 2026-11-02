---
name: performance
description: Diagnose a performance regression, validate a benchmark claim, or optimize a measured bottleneck with controlled before-and-after evidence.
---

# Performance

Name the workload, user-visible metric, and decision the measurement must support. Inspect existing captures and measurement commands before adding instrumentation. Read shared documents only at applicable conditions; relative links resolve from the document's directory.

1. **Establish trustworthy evidence.** Read [explain the number](${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number/PRINCIPLE.md), then use [measure](${CLAUDE_PLUGIN_ROOT}/playbooks/measure/PLAYBOOK.md) to confirm comparable settings, completed real work, correct outputs, and a reproducible baseline.
2. **Find the limiter.** Profile separately from reported timings. Map hot frames, resource saturation, or retainer chains to actual code. State missing symbols and capture limits. For diagnosis-only work, stop at the supported cause and recommendation.
3. **Choose an intervention.** Start with removing work, reusing results, reducing frequency, or deferring it. If the bottleneck comes from the representation or ownership, read [model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md) or [separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md), then read [design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md) for the unresolved shape. Use [prototype](${CLAUDE_PLUGIN_ROOT}/playbooks/prototype/PLAYBOOK.md) for a runtime assumption that needs a probe. A requested idea panel may use [arena](${CLAUDE_PLUGIN_ROOT}/playbooks/arena/PLAYBOOK.md); proposals remain hypotheses until measured.
4. **Test one hypothesis.** Change one thing, rerun the same workload, and check correctness. Keep gains that exceed noise and remove failed experiments without disturbing unrelated changes. If the harness changes, establish a fresh comparable baseline.
5. **Stop on evidence.** For a campaign, retain the workload and regression gate, respect the user's budget, and keep a short hypothesis/result/keep-or-revert record. Stop at the target or when remaining ideas cost more than their likely gain. No iteration floor or automatic wake loop.

Report baseline and final values, units, delta, run count and spread, the identified limiter, correctness checks, and artifact locations. Call an unexplained gain tentative and a gap within noise inconclusive.
