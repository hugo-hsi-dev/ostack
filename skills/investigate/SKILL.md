---
name: investigate
description: Explain how an unfamiliar subsystem works or why it has its current design, using source and relevant history. Use for read-only code investigations.
---

# Investigate

Answer the named question without changing product code. Start with the relevant entrypoint, follow the data or control path, and inspect only the dependencies needed to explain it.

For "how," describe the input, state ownership, important transitions, output, and failure behavior. Cite concrete code locations. A file list is navigation, not an explanation.

For "why," distinguish the design's current effect from its historical motivation. Inspect nearby comments, tests, and focused commit history first. Consult linked issues or documents through available connectors only when they can settle an unresolved question. Do not query every connected service by default or infer author intent from code alone.

For runtime diagnosis, capture the smallest relevant profile, trace, heap snapshot, or log. If a capture already exists, inspect it before collecting another. Use the artifact's format-specific tooling; query or summarize large payloads instead of reading them wholesale. Map findings back to symbols and source. Confirm a causal hypothesis with a targeted observation when practical; otherwise label it a hypothesis.

Give the answer first, followed by supporting code or artifact links, consequential caveats, and any unanswered question. Use a diagram only when it makes the mechanism easier to follow. Do not require a fixed report template, parallel source readers, or local chat-history access.
