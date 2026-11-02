---
name: performance
description: Diagnose a performance regression, validate a benchmark claim, or optimize a measured bottleneck with controlled before-and-after runs.
---

# Performance

Let the measurement determine the change. A source-level guess is a hypothesis.

When the validity or interpretation of a number is uncertain, use the `principle-explain-the-number` skill. The measurement procedure below applies it to performance work.

1. Pick the user-visible workload and metric, including realistic data size, state, and concurrency. Record the target or decision that would justify further work.
2. Read the measurement command and establish a valid baseline using the [measurement checks](references/measurement.md). For diagnosis only, stop at the measured cause and recommendation.
3. Profile separately from reported timing runs. Locate the limiting resource or code path. For a supplied trace or heap snapshot, query the artifact directly and map hot frames or retainer chains to source; state missing symbols or capture limitations.
4. Try the cheapest relevant intervention: remove unused work, reuse results, reduce frequency, defer work, move it off the critical path, then consider concurrency or a cheaper implementation. Stop when a simpler intervention meets the goal.
5. Change one hypothesis at a time, rerun the same workload, and check correctness. Keep improvements that exceed noise; remove failed experiments while preserving unrelated changes.

For a requested optimization campaign, hold the measurement command and regression gate stable across attempts. Keep a short table of hypothesis, result, and keep/revert decision. Respect the user's budget; otherwise stop at the target or when remaining ideas cost more than the likely gain. No minimum iteration count or automatic wake loop. If the harness must change, establish a fresh comparable baseline.

Report baseline, final value, units, delta, run count and spread, identified limiter, correctness result, and artifact locations. Use "inconclusive" when the evidence cannot support the claim.
