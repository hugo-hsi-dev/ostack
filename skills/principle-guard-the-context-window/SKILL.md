---
name: principle-guard-the-context-window
description: "Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads."
---

Read [Codex compatibility](../onyo-mode/references/codex.md) before using this workflow. In a cloud skill reader, use the `onyo-mode` package from this same plugin and its `references/codex.md` resource; do not read a sibling resource through this skill’s package.

# Guard the Context Window

**Why:** Context overflow degrades reasoning quality, creates compression artifacts, and halts progress.

**Pattern:**
- **Size phases and cap scope.** Limit files per phase, set turn budgets, account for mechanism costs.
