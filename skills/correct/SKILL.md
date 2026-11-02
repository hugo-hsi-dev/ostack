---
name: correct
description: Prevent a demonstrated recurring repository mistake with architecture, types, lint, or tests. Use when asked to make a repeated failure harder to reintroduce.
---

# Correct

The `principle-encode-lessons-in-structure` skill grounds this workflow; load it when choosing enforcement versus another instruction.

Start from the correction or failure the user names. Inspect relevant code, tests, commits, and available review evidence. Do not mine local session transcripts or build a preference-memory system. A one-off correction alone does not call for a repository-wide hardening pass.

Choose the smallest durable fix, in this order:

1. Remove the opportunity: one state owner, one authoritative schema, private internals, or deletion of an obsolete path.
2. Encode the invariant in types.
3. Add a targeted lint or check whose error explains the supported alternative.
4. Test the observable behavior.
5. Document a judgment call when it cannot be enforced.

Use existing enforcement before adding infrastructure. Prove a new guard catches the actual failure or a faithful broken variant, and confirm valid usage still works. Limit edits to the named problem; do not add rule tables, exception processes, or a commit per finding by default.

Report the evidence, what now prevents recurrence, and the check you ran. Let the host manage personal preferences and memory.
