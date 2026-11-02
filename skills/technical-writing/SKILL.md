---
name: technical-writing
description: Write, restructure, or edit developer documentation, READMEs, guides, RFCs, and substantial technical prose around the reader’s task.
---

# Technical writing

Determine what the reader needs to know or do, and whether the request is new writing, restructuring, or an edit. Inspect the real implementation for commands, paths, symbols, examples, and claims. Read shared documents only when relevant; relative links resolve from the document's directory.

1. **Choose the document's purpose.** A tutorial guides a learner to a visible result. A how-to gives prerequisites and actions for a specific task. A reference makes formats, options, defaults, limits, and errors easy to look up. An explanation develops the reason for a design and its tradeoffs. Separate substantial sections with different purposes when navigation benefits.
2. **Write for the reader's path.** Lead with the result or necessary fact. Put prerequisites before dependent steps. Keep terminology consistent, use concrete subjects and active verbs, and link background instead of copying it into procedures. Follow the project's voice and formatting.
3. **Edit within scope.** Preserve meaning, certainty, factual claims, deliberate voice, quotations, and technical terms. Remove filler, generic praise and conclusions, stock phrasing, rhetorical contrasts, and decorative formatting. Prefer ordinary words over fancy synonyms. Replace vague attributions with evidence or flag the gap; never invent a source. Split sentences and clarify pronouns when that reduces reader effort. Do not impose a second editing pass on every chat reply.
4. **Check the actual artifact.** Verify commands and examples against their source, local links against files, and counts against the current tree. Read [prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) when executable examples or artifact claims need proof. State execution prerequisites you could not verify.

For a PR description, explain the concrete problem and resulting behavior, then include only consequential design and validation details. For an edit, return the edited text; explain changes only when requested or an ambiguity needs the author's decision. A bounded document that answers the reader's task is enough.
