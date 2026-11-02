# Measurement checks

Use these to evaluate the claim being made. A requested ballpark can use one run if you label it and still confirm correct outputs and actual work. For a decision between implementations, use comparable production settings and enough samples to resolve the effect.

1. **What limits it?** Use a profile or counters to identify CPU, I/O, locks, network, or another bottleneck. Check whether the load generator saturates first. Keep profiling overhead out of reported timing runs.
2. **Are the sides comparable?** Match versions, data, release settings, warmup, cache state, batching, and connection pools to the intended use. Explain unavoidable configuration differences. A debug build against a tuned release build cannot establish an implementation advantage.
3. **Is the result physically plausible?** Compare throughput to bandwidth and available cores. Removing 10% of elapsed work saves at most 10% of the total time unless it changes another bottleneck. An implausible result calls for checking caches, no-ops, and missing work.
4. **Did it succeed?** Count errors, timeouts, retries, and work completed. Verify correct outputs. Fast rejection is not faster processing.
5. **Does it reproduce?** Alternate sides to reduce drift; use several runs per side, extending only when needed to resolve noise. Report median and range or the harness's appropriate statistics. A gap within variation is no measurable difference. Note shared-machine contention.
6. **Does it matter end to end?** Measure the path users wait on. Relate a microbenchmark to its share of that path.
7. **Did the timed work happen?** Await asynchronous completion, consume lazy results, and verify effects. Ensure setup, teardown, cached answers, or discarded work did not dominate the metric.

Keep commands, environment details, and raw runs with the artifacts. Match the conclusion to the evidence. Label an unexplained improvement tentative and name the missing check.
