---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

A **<name>** principle skill below sits at `${CLAUDE_SKILL_DIR}/../principle-<name>/SKILL.md`. Read it in full. If `${CLAUDE_SKILL_DIR}` appears literally, it is the directory that holds this file.

## 1. Locate the active transcript

Before fanning out, find this conversation's transcript. The active project's transcript directory is `~/.claude/projects/<slug>/` for the current working directory, where `<slug>` is the absolute working directory with every character that is not a letter or digit turned into `-`. Use that path, called `<transcripts>` below. Do not glob across `~/.claude/projects/*/`. That crosses workspace boundaries and reads private chats from unrelated projects.

The current session's transcript is `<transcripts>/${CLAUDE_SESSION_ID}.jsonl`. If it is missing, list candidates:

```bash
ls -t <transcripts>/*.jsonl <transcripts>/*/subagents/*.jsonl 2>/dev/null | head -10
```

That covers the session (`<session-id>.jsonl`) and subagent (`<session-id>/subagents/<child>.jsonl`) layouts. For each candidate, read the first `"type":"user"` JSONL line. Take the file whose message content contains the conversation's opening user prompt. If none matches, pass a tight digest of the session instead.

## 2. Spawn three reviewers in parallel

One message, three `Agent` calls, `subagent_type: "onyo-reader"`. If `onyo-reader` is not installed, use `"general-purpose"` and put "Read-only. Do not edit, write, or commit files." in the brief. Reviewers need MCP access to look up the tickets, chat threads, and observability traces the transcript references, and read-only agents keep MCP.

Each reviewer and the synthesizer name a role line in the `~/.claude/rules/ostack-models.md` rule and a default. Pass that line's model and effort as the Agent tool's `model` and `effort`, or the default's when the rule or the line is missing. Omit both when the value is `inherit`. If the Agent tool rejects a model, use the default and say so. If it rejects the default, use the closest valid model from its error message. Pick each subagent's reasoning level and fast or standard speed for the job, per the Subagents section of the **onyo-mode** skill.

| Lens | Role line | Default | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `opus xhigh` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `sonnet xhigh` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `opus xhigh` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the `Agent` response body.

## 3. Synthesize

One `Agent` call, `subagent_type: "onyo-reader"` (same fallback as the reviewers), `model` and `effort` from the `reflect judgment, divergent, synthesizer` line (default `opus xhigh`). It spot-verifies citations through MCP, which read-only agents keep. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the `skill-creator` skill (Anthropic's skill-authoring plugin, `/plugin install skill-creator@claude-plugins-official`) and run its draft / eval / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `skill-creator` and run its description-tuning loop.
- `new skill via skill-creator: <kebab-name>`: hand creation to `skill-creator`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
