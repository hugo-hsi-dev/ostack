---
name: review
description: Review a code change, branch, or design for correctness, regressions, compatibility, and consequential risks. Use for code review, design critique, and requests to assess what a change could break.
---

# Review

Resolve relative links in shared documents from that document’s directory, not the app checkout. Read only the files whose conditions apply.

Establish the requested change and its intended behavior. Keep this a review unless product fixes are also requested. For an unspecified branch review, compare against the merge base with its actual base branch and include relevant working changes.

Read only the mode needed:

- To challenge correctness or design assumptions, read [interrogate](${CLAUDE_PLUGIN_ROOT}/references/interrogate.md).
- To trace consequences beyond the diff, read [blast radius](${CLAUDE_PLUGIN_ROOT}/references/blast-radius.md).
- When indirection or hidden state makes the change hard to trace, read [minimize reader load](${CLAUDE_PLUGIN_ROOT}/principles/minimize-reader-load.md).
- For disputed test evidence, read [test behavior, not implementation](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation.md).
- For type or schema decisions, read [type-system discipline](${CLAUDE_PLUGIN_ROOT}/principles/type-system-discipline.md); use the [TypeScript reference](${CLAUDE_PLUGIN_ROOT}/references/typescript-best-practices.md) when relevant.

Check the most consequential claims against source or the cheapest faithful reproduction. Distinguish a demonstrated failure, an unverified assumption, and a check that could not run. Do not create a model panel or turn every review into a full audit.

Report actionable findings with location, trigger, consequence, and evidence. Merge duplicate root causes and drop unsupported speculation. Say when no actionable findings remain and state material coverage limits.
