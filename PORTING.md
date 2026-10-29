# Porting pstack to Claude Code

This file tracks every Cursor-only tool or tool field still in the skills. Delete each entry when it is resolved, and delete the file when it is empty.

[`docs/harness/claude-code.md`](./docs/harness/claude-code.md) still maps Cursor names at runtime. Shrink it as entries here close.

## Resolved

| Cursor | Claude Code | Sites |
| --- | --- | --- |
| `Task` tool | `Agent` | 24 |
| `AskQuestion` | `AskUserQuestion` | 6 |
| `subagent_type: generalPurpose`, `generalPurpose` | `subagent_type: "general-purpose"`, `general-purpose` | 8 |
| `Shell` | `Bash` | 3 |
| `run_in_background: true` | Dropped. Claude Code subagents run in the background by default. | 3 |
| `readonly: true`, `readonly: false`, agent mode | `subagent_type: "onyo-reader"`, a read-only agent that keeps MCP tools (`agents/onyo-reader.md`) | 6 |
| `environment: "cloud"`, `environment: "local"`, `cloud_base_branch` | `isolation: "worktree"`, or `isolation: "remote"` when the account offers it. The brief names the branch to check out. | 3 |
| The available-tools map and `mcps/` directory | The `mcp__<server>__<tool>` tools in the tool list and the deferred-tool list | 1 |

These need no change because Claude Code uses the same name or the wording is generic: `Read`, `Grep`, `Glob`, `Bash`, "open a todolist", "resume" a subagent (Claude Code continues one with `SendMessage`), and bare MCP tool names such as `search_issues`.

## Open gaps

None. `make-bot-ui` and benny were removed rather than ported, since both ran on Cursor Automations.

## Next passes

These are not tool names, but they change how a tool is called.

- **Model slugs.** 72 sites in 17 files pass Cursor slugs such as `claude-opus-5-5-xhigh` and `grok-4.7-xhigh-fast` as `model`. Claude Code's `Agent` takes `model` (`opus`, `sonnet`, `haiku`, `fable`) and `effort` separately, and has no Grok. This ties into `setup-ostack` and the defaults ostack wants.
- **Skill invocation.** 60 skills set `disable-model-invocation: true`, so Claude Code's `Skill` tool refuses them, and "the **name** skill" falls back to reading the file. Old ostack removed the flag from all but a few skills.
