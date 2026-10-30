# Porting pstack to Claude Code

ostack is Claude Code only. This file tracks what changed from pstack and what still needs a decision. Delete each entry when it is resolved, and delete the file when it is empty.

## Resolved

| Cursor | Claude Code | Occurrences |
| --- | --- | --- |
| `Task` tool | `Agent` | 24 |
| `AskQuestion` | `AskUserQuestion` | 6 |
| `subagent_type: generalPurpose`, `generalPurpose` | `subagent_type: "general-purpose"`, `general-purpose` | 8 |
| `Shell` | `Bash` | 3 |
| `run_in_background: true` | Dropped. Claude Code subagents run in the background by default. | 3 |
| `readonly: true`, `readonly: false`, agent mode | `subagent_type: "onyo-reader"`, a read-only agent that keeps MCP tools (`agents/onyo-reader.md`) | 6 |
| `environment: "cloud"`, `environment: "local"`, `cloud_base_branch`, Cursor cloud agents | `isolation: "worktree"`, or `isolation: "remote"` when the account offers it. The brief names the branch to check out. | 8 |
| The available-tools map and `mcps/` directory | The `mcp__<server>__<tool>` tools in the tool list and the deferred-tool list | 1 |
| Cursor model names `claude-opus-5-5-xhigh`, `grok-4.7-xhigh-fast` | A fixed `<model> <effort>` default per role, listed in `skills/setup-ostack/SKILL.md`. ostack has no budget setting. | 51 |
| `auto`, `inherit-parent` | `inherit` | 20 |
| `~/.cursor/rules/ostack-models.mdc` | `~/.claude/rules/ostack-models.md` | 12 |
| `plugin.json`, `.cursor-plugin/plugin.json`, `/add-plugin ostack` | `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, installed with `/plugin marketplace add hugo-hsi-dev/ostack` | 3 |
| `.cursor/skills/`, `~/.cursor/skills/`, `~/.cursor/plugins/` | `.claude/skills/`, `~/.claude/skills/`, `~/.claude/plugins/` | 25 |
| `~/.cursor/projects/<slug>/agent-transcripts/` | `~/.claude/projects/<slug>/<session>.jsonl`, with each `/` and `.` in the workspace path changed to `-` | 11 |
| `cursor-team-kit` `/deslop`, `control-ui`, `control-cli` | Claude Code's `/simplify` and `/run`, or the project's `verify-<app>` skill | 45 |
| Cursor's `create-skill` | Anthropic's `skill-creator` plugin | 20 |
| Cursor's built-in babysit skill, the Babysit playbook, `watch-pr`, Bugbot triage | Claude Code's PR Auto-fix (`/autofix-pr`, or the desktop app's Auto-fix toggle). Status-only requests read `gh pr view` and `gh pr checks`. The playbook, the watcher script, and the Bugbot reference are deleted. | 4 |
| Cursor's `/loop`, Plan Mode, restart | Claude Code's `/loop`, plan mode, restart | 7 |
| Custom Modes | Start each task with `/onyo-mode`. In Claude Projects, the project instructions turn it on for the project chat and every thread. |
| Merging left implied: Orchestrate said only that "the owner merges only on that verifier's pass", and the grant came from the user's words to one coordinator chat | Stated outright in `orchestrate.md` and `setup-oproject`'s coordinator block. Owners merge once CI is green and the verifier passes at the current head, and every owner's kickoff carries the grant. Claude Code confirms outward-facing actions it isn't explicitly authorized for, and a Projects thread never sees the user's words. | 2 |
| Cursor's built-in PR tool, "open every PR ready, never draft" | Draft-first. The desktop app opens a draft PR on the first push (automatic PR creation on). Opening a PR takes it over and marks it ready for review only when the work is ready. Shipping turns Auto-fix off while a stack lands. The README lists the recommended app settings. | 4 |
| `docs/harness/claude-code.md` | Deleted. The skills now use Claude Code names directly. | 1 |
| `@cursor-skill/*` package names | `@ostack/*` | 3 |

These need no change because Claude Code uses the same name or the wording is generic: `Read`, `Grep`, `Glob`, `Bash`, "open a todolist", "resume" a subagent (Claude Code continues one with `SendMessage`), and bare MCP tool names such as `search_issues`. The `endCursor` and `cursor` variables in the scripts are GraphQL pagination, not Cursor.

## Needs your call

- **Projects and the Orchestrate playbook.** Resolved by hand-written project instructions, which `setup-oproject` writes: the project chat ignores its built-in routing, every session loads onyo-mode, and the project chat runs Orchestrate at a minimum and names each thread's playbook and skills. Hooks were dropped. They lost to the chat's built-in rules, and Claude Code keeps only 10,000 characters of one hook command's output. Project instructions hold at most 16,000 characters, so they copy `orchestrate.md` (about 7,000) and point at onyo-mode (about 20,000) instead of copying it. A coordinator that can't load onyo-mode still has the playbook it runs. Still open: the Project tracker and store in `orchestrate.md`, and confirming the thread tool names `get_channel_session_id`, `send_message`, and `set_thread_resolved`.
- **Long-lived subagents.** Autopilot-full PR owners and Shipping verifiers were Cursor cloud agents that build, babysit, and merge on their own. They are now subagents in a worktree, or a remote session when the account offers it. Check that a subagent can run that long, or move them to separate sessions.
- **`origin pr`.** 13 places prefer an `origin` CLI over `gh` when `command -v origin` succeeds. That looks like a Cursor-internal forge tool. If so, drop it and keep `gh`. Opening a PR already creates and readies PRs with `gh` only.
- **README voice and credit.** The README is Lauren Tan's first-person text ("i'm poteto", "ship high quality code at Cursor"). Decide whose voice it is in ostack and how to credit pstack. `LICENSE` keeps Lauren Tan's copyright, which MIT requires.
