# Codex compatibility for the pstack baseline

This is a first-stage harness port of pstack 0.15.32 at `99b609a72323b70204eab407c622f436e858e112`. It preserves pstack's skill names, planning, research, routing, project coordination, approval gates, and execution workflows. It does not add a planner or replace orchestration. The old ostack Claude hooks and onyo-projects workflow are not included. Text and schema checks do not establish runtime completeness.

Read this mapping before using a skill. A workflow instruction does not grant permissions beyond the user's request or the host's policy. Keep an unmet gate visible as blocked; never count unavailable runtime proof as a pass.

## Tools and roles

The following names were observed in this porting session, not promised as universal Codex APIs. Inspect the current exposed schema before calling tools.

| Upstream requirement | Codex mapping and limit |
| --- | --- |
| `Task` | Native `collaboration.spawn_agent` with `task_name` and `message` in this surface. Calls are asynchronous. Read terminal results and review the work. |
| Resume/message/status/wait | `followup_task`, `send_message`, `list_agents`, `wait_agent`, and `interrupt_agent` where exposed. A follow-up can start work; use a read-only status check for liveness. Preserve pstack's fresh-agent and narrow reuse rules. |
| `subagent_type` | Configured custom agent when the client supports selection, otherwise read the corresponding `agents/*.md` and include its instructions in the brief. A task name does not load a role. |
| `readonly` | Explicit no-edit scope plus output/diff review. Parent permissions are inherited; no new sandbox is implied. |
| `run_in_background` | Omit. Native spawning here already returns asynchronously. |
| `environment`, `cloud_base_branch` | No native equivalents in the exposed spawn schema. Worktree setup is explicit. Isolated/durable cloud execution remains a separate requirement. |
| `AskQuestion` | `request_user_input` only when exposed and permitted by the current mode; `request_user_input_async` where exposed, otherwise a plain-text question. Preserve approval gates. |
| File read, Shell, Grep | Exposed shell execution (`exec_command` here), file tools, and `rg`. These are operations, not invented universal tool names. |
| Todo list | Use an exposed plan tool if available, otherwise maintain the same ordered checklist in the conversation or project artifact. This does not add a planning workflow. |
| MCP discovery | Inspect the exposed tools and discover authorized sources. No assumed Cursor `mcps/` directory. |

Native subagents share this selected execution environment. They are not durable cloud tasks, do not get their own VM or worktree automatically, and cannot be assumed to survive a parent restart. Codex cloud is a separate product surface. A playbook requiring cloud isolation, persistent coordination, or cloud status/wake behavior needs a verified adapter before that step runs. The project playbooks retain those requirements; this port supplies no adapter.

## Models, installation, and configuration

Install skills under `.agents/skills/` or `~/.agents/skills/` as described in the [setup guide](../guide/01-setup.md). Preserve the complete checkout because skills reference sibling files. Explicit Codex invocation uses `$skill-name`. Remaining `/skill-name` spellings in upstream workflow prose are skill labels: load that skill by name/path or use `$skill-name`, not an invented Codex slash command. `/loop` is an exception and remains an unsupported wake dependency.

Upstream `disable-model-invocation: true` is represented by `agents/openai.yaml` with `policy.allow_implicit_invocation: false`. `icon` and `color` frontmatter are removed from skill files; no equivalent visual behavior is claimed. Other skills keep upstream invocation policy. No always-on hook is installed.

Custom agent definitions are provided in `.codex/agents/*.toml`. They require a client that supports this documented configuration. They preserve the Markdown role bodies. In clients whose exposed spawn tool cannot select a configured role, include the Markdown instructions in the brief. Runtime loading of these definitions has not been tested in this environment.

`$setup-pstack` preserves the 17 role keys, budget/confirmation sequence, and panel counts. It writes repository-root `.agents/pstack-models.md`, which workflows read explicitly. This is a pstack data file, not native Codex config or an always-applied rule. Native configuration uses `.codex/config.toml` or `~/.codex/config.toml`; this port does not modify either.

Model IDs and reasoning effort are separate. Use only exposed supported choices. In this session, `model` and `reasoning_effort` overrides require `fork_turns: "none"`; full-history forks inherit. The pstack aliases `auto` and `inherit-parent` mean omit overrides, not model IDs. There is no verified exact substitute for upstream Grok/Claude families or suffix-based speed settings. Defaults therefore inherit. Panel seats remain independent, but same-model reviews do not satisfy cross-family diversity. Report that semantic limitation explicitly.

## Remaining compatibility gaps

- **Wake and custom modes:** no verified equivalent for Cursor's `/loop`, Option/Alt+Enter Custom Modes, restart-persistent coordinator, or cloud nesting guarantees in this surface. Preserve the predicate and wake requirement; report unattended steps blocked without a verified facility.
- **Transcripts:** accept a project-scoped path/export explicitly provided by the host or user. Inspect its format. Do not assume Cursor paths or search unrelated sessions. `worktree-audit.sh` accepts `PSTACK_TRANSCRIPTS_DIR`; without it LAST_CHAT evidence is unavailable. Never infer liveness from transcript mtime.
- **External skills:** `cursor-team-kit` deslop/control skills and Cursor's authoring skill are not bundled Codex tools. Use an available compatible skill or the workflow's stated review/proof method. Missing evidence remains a gap.
- **Benny and bot UI:** retain triage/reproduction and approval contracts, but activation requires a verified automation/webhook adapter. Native subagents do not implement the editor handoff, event runtime, or secret contract.
- **Hooks:** Codex has documented hooks. The prior fork's Claude-only hooks are excluded by scope, not because Codex lacks all hook support.

## Provenance and intentional Cursor references

`LICENSE` is the exact upstream MIT license, including Lauren Tan’s copyright. Retained ostack sync tooling keeps its MIT notice in `sync/LICENSE`, including Hugo Hsi’s copyright. Upstream author history, URLs, dependency names, archived manifests/Claude adapter under `docs/upstream/`, Bugbot identification and review fixtures, generic pagination cursors, and package identity remain where they denote real upstream facts. These references are not Codex installation instructions. `sync/patches` also records the original text on removed lines. Images are preserved upstream assets, not proof of Codex UI behavior.

## Sources checked on 2026-10-25

- [Official skills documentation](https://learn.chatgpt.com/docs/build-skills): discovery, explicit invocation, optional metadata and implicit invocation policy.
- [Official subagent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents): custom agent TOML and inherited permissions.
- [Official configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference) and [AGENTS.md guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md).
- [Official hooks documentation](https://learn.chatgpt.com/docs/hooks), [Codex cloud](https://learn.chatgpt.com/docs/cloud), and [CLI commands](https://learn.chatgpt.com/docs/developer-commands?surface=cli).

The `developers.openai.com/codex/` documentation redirected to these official pages when checked. Session-specific tool field mappings above are based on the actual exposed schemas, not inferred from the product documentation.
