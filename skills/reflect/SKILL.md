---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

A **<name>** principle skill below sits at `${CLAUDE_SKILL_DIR}/../principle-<name>/SKILL.md`. Read it in full. If `${CLAUDE_SKILL_DIR}` appears literally, it is the directory that holds this file.

## When to invoke

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent finds its own transcript file before fanning out. The active project's transcript directory is `~/.claude/projects/<slug>/` for the current working directory, where `<slug>` is the absolute working directory with every character that is not a letter or digit turned into `-`. Use that path, called `<transcripts>` below. Do not glob across `~/.claude/projects/*/`. That crosses workspace boundaries and reads private chats from unrelated projects.

The current session's transcript is `<transcripts>/${CLAUDE_SESSION_ID}.jsonl`. If it is missing, list candidates:

```bash
ls -t <transcripts>/*.jsonl <transcripts>/*/subagents/*.jsonl 2>/dev/null | head -10
```

Two transcript layouts: session (`<session-id>.jsonl`) and subagent (`<session-id>/subagents/<child>.jsonl`).

For each candidate, read the first `"type":"user"` JSONL line and check that its message content contains the conversation's opening user prompt. Take the matching path. If no path resolves, write a tight digest of the session and pass that instead.

### 2. Spawn three reviewers in parallel

One message, three `Agent` calls, `subagent_type: "onyo-reader"`, with `model` and `effort` set as below. If `onyo-reader` is not installed, use `"general-purpose"` and put "Read-only. Do not edit, write, or commit files." in the brief. Reviewers need MCP access for context lookups (tickets, chat threads, observability traces referenced in the transcript). Read-only agents keep MCP.

Each reviewer and the synthesizer name a role line in the `~/.claude/rules/ostack-models.md` rule and a default. Pass that line's model and effort as the Agent tool's `model` and `effort`, or the default's when the rule or the line is missing. Omit both when the value is `inherit`. If the Agent tool rejects a model, use the default and say so. If it rejects the default, use the closest valid model from its error message.

| Lens | Role line | Default | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `opus xhigh` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `haiku xhigh` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `opus xhigh` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the `Agent` response body.

### 3. Synthesize

One `Agent` call, `subagent_type: "onyo-reader"` (same fallback as the reviewers), with `model` and `effort` from the `reflect judgment, divergent, synthesizer` line (default `opus xhigh`). The synthesizer's quality check includes spot-verifying citations, which can require MCP access. Read-only agents keep MCP. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the `skill-creator` skill (Anthropic's skill-authoring plugin, `/plugin install skill-creator@claude-plugins-official`) and run its draft / eval / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `skill-creator` and run its description-tuning loop.
- `new skill via skill-creator: <kebab-name>`: hand creation to `skill-creator`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
