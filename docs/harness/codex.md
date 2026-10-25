# Codex compatibility for the pstack baseline

This is a first-stage harness port of pstack 0.15.32 at `99b609a72323b70204eab407c622f436e858e112`. It preserves pstack's skill names, planning, research, routing, project coordination, approval gates, and execution workflows. It does not add a planner or replace orchestration. The old ostack Claude hooks and onyo-projects workflow are not included. Text and schema checks do not establish runtime completeness.

Read this mapping before using a skill. A workflow instruction does not grant permissions beyond the user's request or the host's policy. Keep an unmet gate visible as blocked; never count unavailable runtime proof as a pass.

## Tools and roles

The following native-subagent names were observed in this porting session, not promised as universal Codex APIs or cloud-task controls. Inspect the current exposed schema before calling tools. Orchestrate’s isolated cloud-task path is described separately below.

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

Native subagents share this selected execution environment. They are not durable cloud tasks, do not get their own VM or worktree automatically, and cannot be assumed to survive a parent restart. Codex cloud is a separate product surface. Orchestrate uses ChatGPT Spaces/Pages for its durable project record as described below. That storage does not supply persistent coordinator execution. Orchestrate uses the coordinating parent’s exposed Codex cloud-task controls where available; this repository supplies no implementation of those controls. Missing placement, status, result or wake capabilities remain gaps, not reasons to substitute native subagents.

## Models, installation, and configuration

Install skills under `.agents/skills/` or `~/.agents/skills/` as described in the [setup guide](../guide/01-setup.md). Preserve the complete checkout because skills reference sibling files. Explicit Codex invocation uses `$skill-name`. Remaining `/skill-name` spellings in upstream workflow prose are skill labels: load that skill by name/path or use `$skill-name`, not an invented Codex slash command. `/loop` is an exception and remains an unsupported wake dependency.

Upstream `disable-model-invocation: true` is represented by `agents/openai.yaml` with `policy.allow_implicit_invocation: false`. `icon` and `color` frontmatter are removed from skill files; no equivalent visual behavior is claimed. Other skills keep upstream invocation policy. No always-on hook is installed.

Custom agent definitions are provided in `.codex/agents/*.toml`. They require a client that supports this documented configuration. They preserve the Markdown role bodies. In clients whose exposed spawn tool cannot select a configured role, include the Markdown instructions in the brief. Runtime loading of these definitions has not been tested in this environment.

`$setup-pstack` preserves the 17 role keys, budget/confirmation sequence, and panel counts. It writes user-level `$CODEX_HOME/pstack-models.md`, which workflows read explicitly. Resolve `CODEX_HOME` from the host environment, defaulting to `~/.codex`, so the default path is `~/.codex/pstack-models.md`. This preserves upstream user-level scope without adding a repository override hierarchy. This is a pstack data file, not native Codex config or an always-applied rule. Native configuration uses `.codex/config.toml` or `~/.codex/config.toml`; this port does not modify either.

Model IDs and reasoning effort are separate. Use only exposed supported choices. In this session, `model` and `reasoning_effort` overrides require `fork_turns: "none"`; full-history forks inherit. The pstack aliases `auto` and `inherit-parent` mean omit overrides, not model IDs. There is no verified exact substitute for upstream Grok/Claude families or suffix-based speed settings. Defaults therefore inherit. Panel seats remain independent, but same-model reviews do not satisfy cross-family diversity. Report that semantic limitation explicitly.

## Orchestrate records in Spaces

The [Orchestrate playbook](../../skills/poteto-mode/playbooks/orchestrate.md) uses Hsit/dot as the planning/routing coordinator and one authoritative project Page/index as its durable record. This names the coordinator role, not a private dot API. Current records are read before dispatch and reconciliation; scope changes, decisions and verified reports are saved through guarded updates. Workers receive self-contained briefs and return source-linked reports without needing Pages or shared filesystem access.

Native headings, checklists, tables and links hold unit IDs, upstream dependency context, branch/PR mappings, exact SHAs, verifier evidence, user gates, status and observed frontier snapshots. The coordinator reconciles these with the actual forge/task state; Pages do not calculate readiness or become live GitHub truth. A changed head invalidates verification. The inbox holds completion pointers. Preserve source reports and tool receipts while reconciling partial or uncertain saves, with tool-required guards and readback. This path adds no mandatory versioning, dependency-ID schema, event identity, or processed-event register. Single-writer ownership is a coordination convention, not a distributed lock. Preserve user edits and existing privacy; never store secrets or raw sensitive logs.

The existing `scripts/orch/` implementation still operates on local files. It is optional legacy/local tooling, not a Pages backend, and is not invoked by this Spaces path. No connector, new planner, scheduler, automatic edit-trigger subscription, or autopilot redesign is included. The cloud-task lifecycle below adapts the existing worker workflow without implementing infrastructure. Small-task collapse and all planning/review/acceptance gates remain.

Capability documentation checked on 2026-10-25: the active Pages plugin's `write-page` and `maintain-space` skills, `write-page/references/page-content.md`, and `write-page/references/edit-requests.md`, plus exposed `read_page`, `edit_page`, `patch_page`, and `create_page` tool descriptions. The skill package is `skill://plugin_connector_1p_4a72ddeef4c481918f92d8e8df18fb2c`. These document native formatting, read-derived block guards, per-operation receipts and recovery; they do not establish transactional multi-page writes. Consult the coordinator's current skills/tools for exact arguments. No user Page was read or changed to validate this repository port, and live persistence/access remains untested.

## Orchestrate cloud-task lifecycle

The parent assistant creates isolated Codex cloud tasks, retains their returned references, and reads status/results through its active task controls. Workers return their existing report in the final response; they generally have no parent-messaging API. Terminal callbacks from parent-created tasks are observed in the coordinating surface and feed the existing completion inbox. The parent still reads the report and verifies its SHA and evidence. A terminal turn is not proof of acceptance.

User-created or adopted tasks do not have a universally verified wakeup path. Nor does a restart prove that a callback relationship survives. During recovery the parent reads known tasks and reconciles their PR/branch state; reading is not a subscription or a continuation turn. Preserve upstream retry limits, timeboxes and fresh-worker defaults. Continue a returned task only under the existing narrow state-preservation exception and an available continuation control. Watcher wakeups and nested cloud-task controls remain capability gaps where unavailable; no retry scheduler or heartbeat protocol is added.

Evidence boundary on 2026-10-25: the coordinating parent reported observed parent-created terminal callbacks and parent-side result reads. This delegated execution environment receives task instructions and returns final results, but its exposed tool catalog does not include the parent's cloud-task creation/read schemas. Accordingly this port specifies those operations by capability and requires the parent's current tool contract; it does not invent method names, arguments, callback subscriptions or a child-to-parent send tool. This change did not run a new cloud-task lifecycle test.

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
- [Official Codex home convention](https://learn.chatgpt.com/docs/config-file/config-advanced#config-and-state-locations), checked on 2026-10-25.
- [Official configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference) and [AGENTS.md guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md).
- [Official hooks documentation](https://learn.chatgpt.com/docs/hooks), [Codex cloud](https://learn.chatgpt.com/docs/cloud), and [CLI commands](https://learn.chatgpt.com/docs/developer-commands?surface=cli).

The `developers.openai.com/codex/` documentation redirected to these official pages when checked. Session-specific tool field mappings above are based on the actual exposed schemas, not inferred from the product documentation.
