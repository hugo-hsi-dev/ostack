---
name: yolo
description: "Load when asked to /yolo or to merge your own verified work. Takes a branch from draft PR to merged, using Claude's automatic PR and auto-fix features when present and doing the same by hand otherwise."
---

# Yolo

Running this skill is the user's grant to merge without asking again. A branch rule that needs a human approval still holds: report the PR merge-ready and stop.

## Workflow

1. **Verify in your checkout.** Run the repo's lint, type check, and tests for what changed. If the repo has a verify-* skill, drive the affected journeys with `ostack:verify`. Fix what fails.

2. **Keep a draft PR.** Steps 1 and 2 can run in either order. After your first push, check whether the branch already has an open PR (some Claude settings open one on push); if not, open one as a draft. It stays draft while work continues.

3. **Mark it ready.** Once the work is done and verified at the current head, mark the PR ready for review. That starts CodeRabbit and other reviewers, so never summon a bot with a comment. Then enable auto-merge if the repo allows it.

4. **Clear CI and review.** If Claude's PR auto-fix is available (the session can subscribe to PR activity), subscribe and end your turn; handle each event as it wakes you. Otherwise watch checks and review threads yourself and do what auto-fix would: fix real failures and valid comments in one push per round, reply where a suggestion is wrong, resolve each thread, and resolve conflicts with the base. Re-verify after each push. Never skip or disable a test to get green.

5. **Merge.** When checks are green and every thread is resolved, auto-merge lands it. Without auto-merge, merge it yourself with a merge method the repo allows.

Hand back to the user if a human reviewer requests changes, a fix would widen the scope, or a check fails the same way after two fixes.

`gh pr ready` and `gh pr merge --auto` use GraphQL. Where that is blocked, as in Claude Code cloud sessions, use the GitHub MCP tools or the REST routes the error names.

Report from the PR's live state: the link, the merge commit or why it isn't merged, what was verified, and `Method: ostack:yolo`.
