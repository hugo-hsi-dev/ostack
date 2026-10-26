---
name: reflect
description: Spawn three parallel review subagents over the current conversation, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
---

Read [Codex compatibility](../../docs/harness/codex.md) before using this workflow.

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Reflect runs in the conversation being reflected on, locally or in a cloud thread. If a parent invokes it for the user, send the instruction to that target thread so it runs Reflect there. It is not background multi-chat mining. Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Use the invoking thread's context

Reviewers inherit the invoking thread's available conversation context through `fork_turns: "all"`. Inherited context may be compacted or incomplete; do not invent missing evidence.

## 2. Spawn three reviewers in parallel

One message, three native `spawn_agent` calls with `fork_turns: "all"`, agent mode (the parent’s authorized tools and permissions). Reviewers need MCP access to look up the tickets, chat threads, and observability traces the conversation references, and must have access to the authorized sources.

Omit `model` and `reasoning_effort`: full-context forks inherit the parent model and effort and do not accept per-reviewer overrides. Reflect does not apply the `reflect tooling` or `reflect judgment, divergent, synthesizer` model preferences. Keep three distinct review lenses and read-only research briefs; inherited permissions do not enforce read-only behavior. These are independent reviews, not cross-family model evidence.

| Lens | Prompt template |
|---|---|
| Judgment | `references/judgment-reviewer.md` |
| Tooling | `references/tooling-reviewer.md` |
| Divergent | `references/divergent-reviewer.md` |

Pass each template verbatim in its reviewer's message. The spawn response identifies the agent. Collect each reviewer’s terminal result through the exposed completion/wait mechanism before synthesis.

## 3. Synthesize

One native `spawn_agent` call with `fork_turns: "all"`, omitting `model` and `reasoning_effort`, agent mode (the parent’s authorized tools and permissions). It spot-verifies citations through MCP, and must have access to the authorized sources. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

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
