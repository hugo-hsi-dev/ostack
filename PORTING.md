# Porting pstack to Claude Code

This file tracks every Cursor-only tool or tool field still in the skills. Delete each entry when it is resolved, and delete the file when it is empty.

[`docs/harness/claude-code.md`](./docs/harness/claude-code.md) still maps Cursor names at runtime. Shrink it as entries here close.

## Swapped 1:1

| Cursor | Claude Code | Sites |
| --- | --- | --- |
| `Task` tool | `Agent` | 24 |
| `AskQuestion` | `AskUserQuestion` | 6 |
| `subagent_type: generalPurpose`, `generalPurpose` | `subagent_type: "general-purpose"`, `general-purpose` | 8 |
| `Shell` | `Bash` | 3 |
| `run_in_background: true` | Dropped. Claude Code subagents run in the background by default. | 3 |

These need no change because Claude Code uses the same name or the wording is generic: `Read`, `Grep`, `Glob`, `Bash`, "open a todolist", "resume" a subagent (Claude Code continues one with `SendMessage`), and bare MCP tool names such as `search_issues`.

## Open gaps

### 1. Read-only subagents

Cursor's `readonly: true` runs a subagent in Ask mode, which also strips its MCP tools. `readonly: false` is "agent mode". Claude Code's `Agent` tool has no read-only field, and its read-only agents keep MCP tools, so the skills' "readonly strips MCP" reasoning does not hold.

- Sites: `skills/how/SKILL.md:11`, `skills/arena/SKILL.md:28`, `skills/reflect/SKILL.md:25`, `skills/reflect/SKILL.md:39`, `skills/why/SKILL.md:13`, `skills/onyo-mode/SKILL.md:96`.
- Options:
  - Ship an `onyo-reader` agent with no `Edit`, `Write`, or `NotebookEdit`, as old ostack did.
  - Use the built-in `subagent_type: "Explore"`. Its prompt is tuned to locate code, not to explain or judge it.
  - Use `general-purpose` and say "read-only" in the brief.
- Recommendation: ship `onyo-reader`, then let `why` and `reflect` run read-only too, since they keep MCP access.

### 2. Cloud subagents

Cursor's `environment: "cloud"` runs a subagent on a fresh cloud VM. `environment: "local"` runs it on this machine, and `cloud_base_branch` picks the branch the VM checks out.

- Sites: `skills/swarm/SKILL.md:27`, `skills/swarm/SKILL.md:29`, `skills/onyo-mode/playbooks/orchestrate.md:10`.
- Options:
  - `isolation: "worktree"` gives each worker its own local checkout. It runs on this machine and shares its CPU.
  - `isolation: "remote"` runs the worker in a cloud environment. Availability is gated per account, and it always runs in the background.
- Recommendation: default to `worktree`. Use `remote` when the account has it and the work needs no local resource. Replace `cloud_base_branch` with "check out `<branch>` first" in the brief.

### 3. Cursor Automations tools in `make-bot-ui`

`update_state` (create a routine, confirm card) and `SendToUser` (ask the user for a secret) are Cursor Automations tools.

- Sites: `skills/make-bot-ui/SKILL.md:15`, `skills/make-bot-ui/SKILL.md:20`, `skills/make-bot-ui/SKILL.md:44`.
- Claude Code equivalent: routines created with `/schedule`, woken over their API trigger (`RemoteTrigger`). No tool asks the user for a secret, so the user pastes the token.
- Recommendation: port the skill to Claude Code routines, as old ostack did.

### 4. Cursor Slack actions in benny

benny forbids child agents from posting with `SendSlackMessage` and `PostToSlack`, which are Cursor's Slack actions. In Claude Code, Slack tools come from an MCP server, and their names depend on the server's configured name, as `mcp__<server>__<tool>`.

- Sites: `automations/benny/skills/reproduce-and-fix-issues/SKILL.md:21`, `automations/benny/skills/reproduce-and-fix-issues/SKILL.md:122`, `automations/benny/skills/triage-issue-reports/SKILL.md:23`, `automations/benny/skills/setup-benny/SKILL.md:136`, `automations/benny/templates/reproduce-automation-prompt.md:31`.
- Recommendation: forbid by capability ("every Slack write tool, including any `mcp__*slack*` send or post tool") instead of by name. This belongs with the larger decision on how benny runs without Cursor Automations.

### 5. MCP discovery in `why`

`why` lists MCP servers from Cursor's "available-tools map" or its `mcps/` directory. Claude Code shows MCP tools as `mcp__<server>__<tool>`, and may defer some behind `ToolSearch`.

- Site: `skills/why/SKILL.md:35`.
- Recommendation: list the `mcp__*` tools in the tool list and the deferred-tool list, and load any deferred ones with `ToolSearch`.

## Next passes

These are not tool names, but they change how a tool is called.

- **Model slugs.** 72 sites in 17 files pass Cursor slugs such as `claude-opus-5-5-xhigh` and `grok-4.7-xhigh-fast` as `model`. Claude Code's `Agent` takes `model` (`opus`, `sonnet`, `haiku`, `fable`) and `effort` separately, and has no Grok. This ties into `setup-ostack` and the defaults ostack wants.
- **Skill invocation.** 60 skills set `disable-model-invocation: true`, so Claude Code's `Skill` tool refuses them, and "the **name** skill" falls back to reading the file. Old ostack removed the flag from all but a few skills.
