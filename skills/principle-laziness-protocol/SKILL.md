---
name: principle-laziness-protocol
description: "Apply when refactoring, evaluating diff size, or tempted to add abstractions, layers, or signal threading. Bias toward deletion and the smallest change that solves the problem."
---

Read [Codex compatibility](../onyo-mode/references/codex.md) before using this workflow. In a cloud skill reader, use the `onyo-mode` package from this same plugin and its `references/codex.md` resource; do not read a sibling resource through this skill’s package.

# Laziness Protocol

- **Consolidate decisions.** Do not repeat the same choice in several places. Put it behind one source of truth and pass the result as a simple flag.
- **Minimize the diff.** Make the smallest change that solves the problem. Fewer lines beat "elegant" boilerplate.
