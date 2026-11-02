---
name: review
description: Review a code change, branch, or design for correctness, regressions, compatibility, and consequential risks. Use for code review, design critique, or assessing what a change could break.
---

# Review

Produce evidence-backed findings about the requested change. Read shared documents only when the corresponding question arises; relative links resolve from the document's directory.

1. **Establish the contract.** Read the request, diff, tests, and surrounding code. For an unspecified branch review, compare against the merge base with its actual base branch and include relevant working changes. Keep product fixes outside the review unless requested.
2. **Trace consequences.** Follow direct callers and paths beyond symbol search: persisted data, wire formats, other languages, configuration, flags, scheduled work, and teardown. For compatibility questions, read [preserve contracts](${CLAUDE_PLUGIN_ROOT}/principles/preserve-contracts/PRINCIPLE.md). A search with no matches establishes only the scope searched.
3. **Challenge the safety claim.** Identify the one or two facts carrying most of it. Probe plausible invalid inputs, state transitions, partial failures, and races. For state representation, read [model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md); for interfaces and hidden state, [minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load/PRINCIPLE.md); for concurrent writers, [separate shared state](${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md). For type/schema decisions, read [type-system discipline](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline/PRINCIPLE.md), using its [TypeScript applications](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline/references/typescript.md) when needed. For an unresolved interface or representation in a design critique, read [design from caller usage](${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md); keep the review within its requested scope.
4. **Check each candidate finding.** Inspect actual dependency versions and patches; use a small reproduction or existing check when it can settle the issue. Keep scratch repros separate from the user's changes. For disputed assertions, read [test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md); for disputed evidence, [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md). Source can establish a failure without a runnable environment, but label unexecuted claims honestly.
5. **Filter and report.** Keep findings with a concrete trigger, consequence, location, and supporting path or reproduction. Merge duplicate root causes. Drop style preferences and hypothetical future failures. Distinguish confirmed defects, unresolved assumptions, cleared risks, and blocked checks. Say when no actionable findings remain.

Work in the current session by default. A request for multiple reviewers uses only available authorized tools and isolated inputs, then deduplicates evidence. A brainstorm panel is not a correctness audit or a reviewer quorum.
