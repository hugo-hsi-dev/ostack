---
name: investigate
description: Explain how an unfamiliar subsystem works or why it has its current design, using source and relevant history. Use for read-only code investigations.
---

# Investigate

Resolve relative links in shared documents from that document’s directory, not the app checkout. Read only the files whose conditions apply.

Answer the named question without changing product code. Start with the relevant entrypoint, follow the data or control path, and inspect only the dependencies needed to explain it.

For "how," describe the input, state ownership, important transitions, output, and failure behavior. Cite concrete code locations. A file list is navigation, not an explanation.

For "why," distinguish the design's current effect from its historical motivation. Inspect nearby comments, tests, and focused commit history first. Consult linked issues or documents through available connectors only when they can settle an unresolved question. Do not query every connected service by default or infer author intent from code alone.

For runtime diagnosis, capture the smallest relevant profile, trace, heap snapshot, or log. If a capture already exists, inspect it before collecting another. Use the artifact's format-specific tooling; query or summarize large payloads instead of reading them wholesale. Map findings back to symbols and source. Confirm a causal hypothesis with a targeted observation when practical; otherwise label it a hypothesis.

Read shared guidance only when its condition occurs: [guard the context window](${CLAUDE_PLUGIN_ROOT}/principles/guard-the-context-window.md) for large artifacts or repeated reads; [attack the premise](${CLAUDE_PLUGIN_ROOT}/principles/attack-the-premise.md) for repeatedly failed explanations; [model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain.md) when ownership and state variants explain the subsystem. A requested parallel brainstorm can use [swarm](${CLAUDE_PLUGIN_ROOT}/playbooks/swarm.md), but idea proposals do not replace source evidence or establish audit coverage.

Give the answer first, followed by supporting code or artifact links, consequential caveats, and any unanswered question. Use a diagram only when it makes the mechanism easier to follow. Do not require a fixed report template, parallel source readers, or local chat-history access.
