---
name: interrogate
description: Adversarially review a change or design for concrete correctness failures. Use for requests to challenge a design, stress test code, or find blind spots.
---

# Interrogate

Try to break the stated intent. Review without applying product fixes unless asked.

For a disputed validation claim, use the `principle-prove-it-works` skill. It applies to evidence across task domains.

1. Establish the scope and intended behavior from the request, diff, tests, and surrounding code. For an unspecified branch review, use its merge base with the actual base branch and include working changes.
2. Follow the most consequential failure paths: invalid inputs, state transitions, partial failures, concurrency, and compatibility with callers outside the diff. Prioritize plausible failures over exhaustive speculation.
3. For each candidate finding, attempt the cheapest useful check against real code. Keep scratch repros separate from the user's changes. For a design, probe the assumption it depends on.
4. Keep findings supported by a repro or a concrete source path that demonstrates the failure. Label unexecuted evidence and runtime limitations honestly. Drop style preferences and hypothetical future problems. Merge findings with the same root cause.

Work in the current session by default. If the user requests multiple reviewers or models, use only available capabilities, provide isolated working copies including relevant uncommitted changes, and deduplicate the results. Do not invent model names, custom agent types, or a reviewer quorum.

Report each actionable finding with the location, trigger, consequence, and evidence. Say when no actionable findings remain. Distinguish a failed check from a check that could not run.
