---
name: technical-writing
description: "Write, restructure, or edit technical documentation such as READMEs, guides, API references, design docs, changelogs, and PR descriptions. Use when the output is prose for readers rather than code."
---

# Technical writing

## Workflow

1. **Establish the reader's task.** Identify the audience, document purpose, and requested scope: new writing, restructuring, or an edit. Inspect the implementation and sources behind its commands, names, examples, and claims.

2. **Structure the document.** Choose a tutorial, how-to, reference, or explanation according to the reader's task. Place prerequisites before dependent actions and organize sections around what the reader needs to find or do.

3. **Write or edit.** Follow the project's terminology and voice. For an edit, preserve intended meaning, certainty, quotations, and technical terms while removing filler and clarifying difficult sentences. Resolve factual gaps from sources or identify them for the author. For a PR description, explain the problem and resulting behavior with the design and validation details needed for review.

4. **Check the document.** Verify commands, examples, links, and counts against their sources. Run executable examples where the environment permits and record prerequisites that prevented a check.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| Executable examples or artifact claims need evidence | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |

Return the document or requested edit. Explain changes only when requested or when an unresolved ambiguity affects the result.
