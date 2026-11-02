---
name: performance
description: Diagnose a performance regression, validate a benchmark claim, or optimize a measured bottleneck with controlled before-and-after runs.
---

# Performance

Resolve relative links in shared documents from that document’s directory, not the app checkout. Read only the files whose conditions apply.

Let the measurement determine the change. A source-level guess is a hypothesis.

When the validity or interpretation of a number is uncertain, read [explain the number](${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number.md). The measurement procedure below applies it to performance work. This is a shared document, not another skill invocation.

1. Pick the user-visible workload and metric, including realistic data size, state, and concurrency. Record the target or decision that would justify further work.
2. Read the measurement command and establish a valid baseline using the [measurement checks](references/measurement.md). For diagnosis only, stop at the measured cause and recommendation.
3. Profile separately from reported timing runs. Locate the limiting resource or code path. For a supplied trace or heap snapshot, query the artifact directly and map hot frames or retainer chains to source; state missing symbols or capture limitations.
4. Try the cheapest relevant intervention: remove unused work, reuse results, reduce frequency, defer work, move it off the critical path, then consider concurrency or a cheaper implementation. Stop when a simpler intervention meets the goal.
5. Change one hypothesis at a time, rerun the same workload, and check correctness. Keep improvements that exceed noise; remove failed experiments while preserving unrelated changes.

For a requested optimization campaign, hold the measurement command and regression gate stable across attempts. Keep a short table of hypothesis, result, and keep/revert decision. Respect the user's budget; otherwise stop at the target or when remaining ideas cost more than the likely gain. No minimum iteration count or automatic wake loop. If the harness must change, establish a fresh comparable baseline.

If a runtime assumption needs a disposable experiment, read [prototype](${CLAUDE_PLUGIN_ROOT}/playbooks/prototype.md). For an explicitly requested idea panel, read [arena](${CLAUDE_PLUGIN_ROOT}/playbooks/arena.md); Haiku proposals remain hypotheses, and the owner measures selected ideas.

Report baseline, final value, units, delta, run count and spread, identified limiter, correctness result, and artifact locations. Use "inconclusive" when the evidence cannot support the claim.
