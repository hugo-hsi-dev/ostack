---
name: technical-writing
description: Write or restructure developer documentation, READMEs, guides, and RFCs around the reader's task. Use for substantial technical prose rather than every chat reply.
---

# Technical writing

Resolve relative links in shared documents from that document’s directory, not the app checkout. Read only the files whose conditions apply.

Lead with what the reader needs to know or do. Use the repository's real commands, symbols, paths, and terminology. Verify examples against the implementation.

Choose the document's main purpose:

- A tutorial guides a learner to a visible result, with expected output at each significant step.
- A how-to solves a specific task for a competent reader. Put prerequisites and conditions before the affected steps.
- A reference describes options, defaults, formats, limits, and errors in a predictable structure.
- An explanation develops the reason for a design, including consequential alternatives and tradeoffs.

Separate substantial sections with different purposes when that improves navigation. Link to background rather than repeating it inside a procedure.

When editing existing prose for clarity and voice, read [unslop](${CLAUDE_PLUGIN_ROOT}/references/unslop.md). When writing about a feature or configuration change, inspect its actual implementation and affected callers before documenting it. For a dependency or tooling housekeeping task with little prose, use the `maintenance` Entry instead.

Use active voice, ordinary words, and concrete subjects. Keep names consistent and pronouns unambiguous. Split sentences that require backtracking, while preserving the conditions that make a statement true. Remove filler, unsupported claims, and figurative jargon. Follow the project's formatting and voice conventions.

For a PR description, lead with the concrete problem and resulting behavior. Include only design and validation details a reviewer needs; link large artifacts. Scale the description to the change.

Before delivery, check commands, local links, stated counts, and examples. State any execution prerequisite you could not verify. A short document that answers the reader's question is sufficient; no extra style pass or skill chain is required.
