---
name: reflect
description: Spawn three parallel review subagents over the current or explicitly selected conversation, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
---

Read [Codex compatibility](../../docs/harness/codex.md) before using this workflow.

# Reflect

Mine the current or explicitly selected single conversation for durable learnings, then route them into skill edits.

Invoke only when the user says "reflect" or "/reflect", including when a parent explicitly asks a specific thread to run Reflect on the user's behalf. This applies in local and cloud threads; it is not background multi-chat mining. Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Gather evidence for the selected conversation

Before fanning out, use the available conversation evidence or a supported read/export for that single thread. When its ID is known, read it directly rather than discovering other conversations. Do not crawl the filesystem, assume private session paths or JSONL layouts, or match opening prompts across transcript files.

Use only capabilities exposed in the current environment. A local host may expose `mcp__codex_app__read_thread` with `threadId` and optional `hostId`, `cursor`, `turnLimit`, `includeOutputs`, and `maxOutputCharsPerItem`; use the active tool schema. Its summaries and optional outputs are not a guaranteed lossless transcript. Describe the returned evidence accurately, including summary, pagination, omitted-output, or truncation limits. Do not assume this local tool or the parent's cloud-thread controls exist in a cloud worker. A parent may supply returned messages or excerpts for the selected thread in the worker's brief; the worker must not depend on unavailable parent access.

If a transcript is unavailable, pass a tight digest of the selected session from the evidence actually available, as upstream permits. Label it as a digest, not a transcript. Identify missing history or evidence limits; never reconstruct deleted or missing messages as facts. If no usable evidence for the selected conversation is available, report that gap.

Give all three reviewers the same scoped evidence and its limitations, inlined in their briefs or through an explicitly supplied export each can access. Do not assume a parent-local path is accessible to a worker. Preserve available turn identifiers or short quotes for citations; do not invent transcript turns from a summary.

## 2. Spawn three reviewers in parallel

One message, three `spawn_agent` calls, a general native subagent, agent mode (the parent’s authorized tools and permissions). Reviewers need MCP access to look up the tickets, chat threads, and observability traces the transcript references, and must have access to the authorized sources.

Read `reflect tooling` and `reflect judgment, divergent, synthesizer` in the user-level `$CODEX_HOME/pstack-models.md` explicitly. Use only session-supported models and reasoning settings, per poteto-mode’s Subagents section. Missing roles inherit the parent. Keep the role split and read-only research briefs; inherited permissions do not enforce read-only behavior. If distinct model families are unavailable, report that limitation rather than claiming multi-model evidence.

| Lens | Role line | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `inherit-parent` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `inherit-parent` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `inherit-parent` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the same selected-conversation evidence or accessible export path and its limitations where marked. The spawn response identifies the agent. Collect each reviewer’s terminal result through the exposed completion/wait mechanism before synthesis.

## 3. Synthesize

One `spawn_agent` call, a general native subagent, `model` from the `reflect judgment, divergent, synthesizer` line (default `inherit-parent`), agent mode (the parent’s authorized tools and permissions). It spot-verifies citations through MCP, and must have access to the authorized sources. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Never edit a skill under `plugins/cache/`. Before approval, show its destination, `.agents/skills/<skill>/` or `~/.agents/skills/<skill>/`. After approval, copy the skill folder there and edit the copy. Never open a PR or push.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to an installed skill-authoring skill (if unavailable, report the authoring-tool gap and retain the draft / test / iterate steps) and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to an installed authoring skill with description optimization. If unavailable, report the capability gap before this step.
- `new skill via create-skill: <kebab-name>`: hand creation to an installed authoring skill. If unavailable, report the capability gap; do not invent a replacement tool or skip its validation.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
