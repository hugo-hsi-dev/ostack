# Compare artifacts

Use to establish whether a candidate preserves or intentionally changes an observable reference: screenshots, generated files, command output, or structured results. Inputs are the reference, candidate, relevant states, and agreed comparison rule.

1. **Freeze the oracle.** Record the reference and expected differences before changing the candidate. Keep baselines, tolerances, and ignored regions fixed. An intentional requirement change needs a separately justified expectation change.
2. **Control inputs and environment.** Use the same fixtures, configuration, versions, and meaningful states. For screenshots, match viewport, scale, browser, fonts, theme, and animation state. For structured or text output, normalize only irrelevant differences whose removal cannot hide a regression.
3. **Capture both sides faithfully.** Exercise the actual producing path. Preserve the action and resulting artifact; internal setters or hand-written substitutes do not establish parity. If the reference environment cannot be reproduced, record the mismatch and its effect on confidence.
4. **Inspect the differences.** Use the appropriate image, text, or structural comparison and inspect consequential deltas. Require zero unexplained differences for exact parity. Do not loosen thresholds or hide changed regions until the check passes.
5. **Return evidence.** Report covered states, comparison settings, artifact locations, remaining differences, and accepted differences with their reasons. Stop an unbounded chase of nondeterministic noise and name the missing control.

A matching artifact establishes only the compared observations. A screenshot does not establish interaction or accessibility equivalence; the Entry chooses the additional behavior checks.
