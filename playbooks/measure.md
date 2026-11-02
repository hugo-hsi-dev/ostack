# Measure a result

Use when a decision needs a trustworthy latency, throughput, resource-use, accuracy, or other quantitative result. Inputs are the workload or trial, metric, intended conclusion, and available budget. A requested ballpark may use one labeled run; a comparison needs enough samples to resolve the effect.

1. **Define the unit.** State what work completes, the metric and units, the relevant data size and state, and the user-visible path the number represents.
2. **Read the measuring path.** Confirm the work actually happens: await asynchronous completion, consume lazy results, and verify outputs and side effects. Count errors, timeouts, retries, and completed work. Fast rejection, cached no-ops, or missing work cannot establish faster processing.
3. **Establish comparability.** Match versions, fixtures, release settings, warmup, caches, batching, and connection pools to intended use. Explain unavoidable differences. A debug build against a tuned release build cannot establish an implementation advantage.
4. **Check the limiter and plausibility.** For timing and throughput, identify the limiting resource with a profile or counters, including whether the load generator saturates first. Keep profiling overhead out of reported timing runs. Compare the result to physical capacity and the fraction of work changed; an implausible gain calls for checking what was skipped.
5. **Repeat proportionally.** Alternate comparison sides to reduce drift and collect enough runs to distinguish the effect from variation. Note shared-machine contention. A gap within noise is no measurable difference. For accuracy or scored trials, record denominators and trial variation rather than reporting a bare percentage.
6. **Report what the data supports.** Keep commands, environment, and raw runs with the artifacts. Give run counts and median/range or the harness's appropriate statistics. Relate a microbenchmark to the end-to-end path. Label an unexplained gain tentative and name the missing check.

Stop when the evidence resolves the decision or the available budget cannot distinguish the candidates. A changed harness requires a new comparable baseline.
