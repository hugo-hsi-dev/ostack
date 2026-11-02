---
name: investigate
description: Explain how a subsystem works, why it has its current design, or what a runtime artifact shows. Use for read-only source, history, and runtime investigations.
---

# Investigate

Answer the named question from evidence, without changing product code. Identify the smallest path or artifact that can answer it. Read shared documents only when relevant; relative links resolve from the document's directory.

- **How it works:** follow input, ownership, transitions, output, and failure behavior from the relevant entry point. Use [model the domain](${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain.md) when representation and state ownership explain the mechanism. Cite concrete locations; a file inventory is navigation, not an explanation.
- **Why it exists:** distinguish its current effect from historical motivation. Inspect nearby comments, tests, and focused commits. Consult linked issues or documents through available connectors only to settle an unresolved question; do not infer author intent from code alone.
- **What happened at runtime:** inspect a supplied profile, trace, heap snapshot, or log before collecting another. Query the artifact with appropriate tooling, map observations to source, and make the cheapest targeted observation that distinguishes causes. Label an untested explanation as a hypothesis. For repeated failures of one explanation, read [attack the premise](${CLAUDE_PLUGIN_ROOT}/principles/attack-the-premise.md).

For large artifacts or repeated reads, use [guard the context window](${CLAUDE_PLUGIN_ROOT}/principles/guard-the-context-window.md), within available tools and delegation authorization. Requested brainstorming across areas may use [swarm](${CLAUDE_PLUGIN_ROOT}/playbooks/swarm.md), but ideas do not establish source coverage or verified defects.

Stop when the question is answered or the next observation requires an unavailable prerequisite. Give the answer first, supporting source or artifact links, consequential limits, and unresolved questions. Do not turn explanation into an implementation, a design exercise, or session-history mining.
