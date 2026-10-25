---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
---

Read [Codex compatibility](../../docs/harness/codex.md) before using this workflow.

# Reflect

**Transcript compatibility.** Use only a transcript/export explicitly exposed for the active project. The directory names and JSONL examples below describe the upstream format, not a guaranteed Codex layout. Inspect the actual format first. If unavailable, report the evidence gap; do not infer transcript evidence from an agent summary.


Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Locate the active transcript

Before fanning out, find this conversation's transcript in the `agent-transcripts/` directory the system prompt names. Do not search unrelated session directories. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
ls -t <agent-transcripts>/*.jsonl <agent-transcripts>/*/*.jsonl <agent-transcripts>/*/subagents/*.jsonl 2>/dev/null | head -10
```

That covers the legacy flat (`<id>.jsonl`), current nested (`<id>/<id>.jsonl`), and subagent (`<parent>/subagents/<child>.jsonl`) layouts. For each candidate, read the first JSONL line. Take the file whose `message.content[0].text` contains the conversation's opening user prompt. If none matches, pass a tight digest of the session instead.

## 2. Spawn three reviewers in parallel

One message, three `spawn_agent` calls, a general native subagent, agent mode (the parent’s authorized tools and permissions). Reviewers need MCP access to look up the tickets, chat threads, and observability traces the transcript references, and must have access to the authorized sources.

Read `reflect tooling` and `reflect judgment, divergent, synthesizer` in the repository’s `.agents/pstack-models.md` explicitly. Use only session-supported models and reasoning settings, per poteto-mode’s Subagents section. Missing roles inherit the parent. Keep the role split and read-only research briefs; inherited permissions do not enforce read-only behavior. If distinct model families are unavailable, report that limitation rather than claiming multi-model evidence.

| Lens | Role line | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `inherit-parent` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `inherit-parent` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `inherit-parent` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. The spawn response identifies the agent. Collect each reviewer’s terminal result through the exposed completion/wait mechanism before synthesis.

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
