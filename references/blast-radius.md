# Blast radius

Find the assumption that makes the change safe, then try to disprove it.

1. Read the change and the contract it alters. Trace direct callers, then look beyond symbol search: serialized formats, database columns, other languages, feature flags, scheduled work, teardown, and pinned dependency behavior.
2. Identify the one or two facts that carry most of the safety claim. Examples include whether a removal affects only dead entries, whether a callback can run after teardown, or whether an older reader accepts a new payload.
3. Check those facts at the cheapest useful level. Read the actual dependency version and patches; use a small repro or existing test when execution can settle the question. Source evidence can establish a risk even when a live environment is unavailable.
4. Separate confirmed breakage, assumptions that remain unverified, and risks you checked and cleared. A search with no matches establishes only the scope searched.

Return the changed behavior, affected contracts, consequential risks with code locations and evidence, and the cheapest remaining check. Keep the pass proportional to the change. Do not launch a model panel or change product code as part of the assessment.
