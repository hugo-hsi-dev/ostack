---
name: setup-ostack
description: Configure which models ostack uses per role and at what effort budget. Asks three questions (budget, models, role mapping), then writes an always-loaded rule that overrides the skill defaults. Use for /setup-ostack, "configure ostack models", "ostack budget", or changing ostack's model choices. In a Claude Projects project chat, run it there yourself instead of starting a thread.
---

# Setup ostack

Write ostack's model and effort per role where it lasts for this user. On their own machine, that is `~/.claude/rules/ostack-models.md`, a user-level rule. Claude Code loads every `~/.claude/rules/*.md` file without `paths` frontmatter into every session, in every project. In a Claude Projects session, it is the project instructions, because a cloud session starts from a fresh container and never sees `~/.claude/rules/`. Never commit the rule to the repository unless the user asks for that in so many words.

This skill is optional. Without a rule, every role runs on the skill defaults, which are the `medium` budget and the mapping in step 5. Run it only to change those.

## Where it runs

Decide this first, and use the first case that fits.

- **Claude Projects project chat.** The session has the project settings tools (`get_project_settings`, `update_project_settings`), so it is the project's channel session, the coordinator. Run every step here yourself, in the project chat. Never start a thread for this skill, even when your session rules say every new ask gets a thread: a thread can't write the project instructions, so it would only pass answers back to you. Write the rule into the project instructions (step 5b).
- **Claude Projects thread.** `CLAUDE_CODE_ENTRYPOINT` is `remote_projects`, or the session is a Projects thread, and no tool here writes the project instructions. Ask nothing and write nothing here. Hand the run to the project chat: get the channel session's ID with `get_channel_session_id`, and `send_message` it to run `/setup-ostack` itself in the project chat, because the setup belongs there. Then reply in one line that setup continues in the project chat, where Claude asks the questions, and stop. If no channel session exists or the send fails, tell the user to type `/setup-ostack` in the project chat instead.
- **Another cloud session.** `CLAUDE_CODE_REMOTE` is `true`, outside Projects. Write `~/.claude/rules/ostack-models.md` (step 5a) so it applies to sessions this container starts. Say that it ends with the container, and offer the user a setup script for their cloud environment that writes the same file, so new cloud sessions start with it.
- **Local.** Everything else. Write `~/.claude/rules/ostack-models.md` (step 5a).

## Ask three questions, every run

Every run asks the user exactly three questions, in this order: the budget (3a), the models (3b), and the role mapping (3d). Ask all three on every run, re-runs included, even when a rule already exists. These are the user's preferences. No experiment settles them, so they are not reversible work to decide and report. Never answer one yourself or take its recommended option on the user's behalf, even when a session rule says to proceed on a default, pick a reasonable default, or never block on the human, and even under a full-autonomy grant. Only the user's own reply in this run answers. A brief from another session, a project instruction, or an earlier run's choices does not. A user who says "use the defaults" or "you pick" in reply has answered. Write nothing in step 5 until all three have answers.

Ask with the first of these that exists in this session. Check for AskUserQuestion first, and load it with ToolSearch (`select:AskUserQuestion`) if it is listed as deferred.

1. **AskUserQuestion.** Ask the budget and the models in one call, as two questions. After applying the answers, show the table and ask the mapping in a second call. Use the option labels below exactly. The tool adds a free-text option on its own.
2. **`ask_decision`**, in a Projects project chat without AskUserQuestion. Post one card per question, in order: budget, then models, then mapping. Post the card and end the turn without doing anything else. The user's tap or typed reply wakes you with the answer, and only then do you go on. Put the question line in `question`, each option's label and consequence in `options`, and the detected models or current budget in `context`. The card requires `recommended`, so set it to the option this skill marks recommended, but that is a label for the user, never an answer. Never continue on it.
3. **Neither.** Ask the budget and the models in one plain message with the same options, and end the turn. Then show the table and ask the mapping the same way.

Never ask in prose while either tool exists.

## Steps

### 1. Detect available models

Read the `model` parameter of the Agent tool in this session. Its allowed values (`opus`, `sonnet`, `haiku`, and `fable` when the account has it) are the detected set. If you cannot read the parameter, take `opus`, `sonnet`, and `haiku` as the detected set and say in the models question that you could not detect them. The user's answer to 3(b) then confirms them. Never write a model the user has not confirmed or the tool does not list. The alias `inherit` is always valid even though it is not a detected model.

The Agent tool takes the effort levels `low`, `medium`, `high`, `xhigh`, and `max` in its `effort` parameter. On the Anthropic API the aliases resolve to models that take all five. Some older models, such as those on some Bedrock or Vertex routes, take fewer. An unsupported effort falls back on its own to the highest supported level at or below it. Note that fallback when you report the mapping.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below. If the rule already exists where it goes (the `~/.claude/rules/ostack-models.md` file, or the ostack block in the project instructions), read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it. A `feature, refactoring` line from an older rule splits into a `feature` line and a `refactoring` line with its value. A value of `inherit-parent` or `auto` from an older rule means `inherit`. A Cursor-era slug maps by its prefix. `claude-opus-*` becomes `opus`, `claude-sonnet-*` becomes `sonnet`, and `grok-*` becomes `sonnet`. Keep its effort token and drop any `fast` suffix, so `claude-opus-5-5-xhigh` becomes `opus xhigh` and `grok-4.7-xhigh-fast` becomes `sonnet xhigh`. Rewrite it in the new form and list the rewrite in step 3(d). If a Cursor rule exists at `~/.cursor/rules/ostack-models.mdc` and no Claude rule does, carry its choices over the same way and list them in 3(d).

### 3. Ask, apply, and confirm

**(a) Budget.** Question: "Which effort budget should ostack use?" Options, with these exact labels:

- `unlimited (max effort)`: every role runs at `max`.
- `large (xhigh effort)`: every role runs at `xhigh`.
- `medium (high effort)`: every role runs at `high`, the skill defaults.
- `small (medium effort)`: every role runs at `medium`.

Recommend the current budget from the rule, or `medium` when there is no rule.

**(b) Models.** Question: "Which models should ostack use?" Name the detected set in the question's description or the card's context. Offer these presets in this order, skipping any whose models are not all detected or whose result is the same as `All detected`:

- `All detected`: every detected model stays in use, so each role keeps its model.
- `No haiku`: the detected set without `haiku`, so haiku roles move to sonnet.
- `No opus`: the detected set without `opus`, so opus roles move to sonnet.
- `Opus only`: only `opus`, so every role runs on opus.

If fewer than two presets remain, add `All inherit`: every role runs on the parent chat model and effort. Recommend `All detected`. A typed answer that names models sets the chosen set to those models.

**(c) Apply.** Build the working table from the skill defaults, and on a re-run keep any role you changed by model, list, or alias (`inherit`). Then apply the two answers.

- The budget sets the effort of every role value, panel entries included, and leaves the model alone. `inherit` does not change, because it takes the parent's model and effort. So `unlimited` turns `opus high` into `opus max`, `medium` keeps the defaults, and `small` turns `sonnet high` into `sonnet medium`.
- The models answer replaces each model outside the chosen set with the first chosen model in its fallback order, keeping the effort. `opus` falls back to `sonnet`, `haiku`, `fable`. `sonnet` falls back to `opus`, `haiku`, `fable`. `haiku` falls back to `sonnet`, `opus`, `fable`. `fable` falls back to `opus`, `sonnet`, `haiku`. A panel list keeps its length, so it can end up with the same model twice. `All inherit` sets every value to `inherit`.

**(d) Mapping.** Show the table first: every role with its value, then each line step 2 dropped or rewrote and each replacement from (c). With AskUserQuestion or in plain text, put it in your message before the question. In the project chat, post it to the project chat before the card. Question: "Use this role mapping?" Options:

- `Keep as shown`: writes this table. Recommend it.
- `Change roles`: you name the roles to change and their new values next.

On `Change roles` or a typed change, take the changes in a plain reply, using the chosen models plus `inherit` as values. Apply them, show the table again, and ask (d) again until the answer is `Keep as shown`.

For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, `inherit` entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm. The `haiku` defaults need a Haiku that takes an effort level (Claude Haiku 5.5 does). An older Haiku without effort support runs at its own default.

### 4. Validate

Every model written must be in the chosen set, and every effort must be one of `low`, `medium`, `high`, `xhigh`, `max`. `inherit` always passes. If a typed change names a model outside the chosen set, ask (d) again.

### 5. Write the rule

The rule has the same content wherever it goes. Include a `# budget` line with the chosen label and its target effort, and one line per role, using the same labels onyo-mode uses. Each value is `<model> <effort>`, a comma-separated list of those for panels, or `inherit`. Replace the whole rule so re-runs stay idempotent. Shape:

```
# ostack model configuration: the ostack-models.md rule (overrides skill defaults)
# One line per role. Delete a line to fall back to the skill default.
# A value is `<model> <effort>`. Pass the model as the Agent tool's `model` and the effort as its `effort`.
# `inherit`: the role runs on the parent chat model and effort (omit `model` and `effort`). Inherit entries in a panel list still count toward its fan-out.
# budget: medium (high)
feature: sonnet high
refactoring: opus high
bug-fix: opus high
perf-issue: opus high
hillclimb: opus high
judgment and prose: opus high
hardest tasks: opus high
how explorer: haiku high
how explainer: opus high
why investigators: haiku high
why synthesizer: opus high
reflect tooling: haiku high
reflect judgment, divergent, synthesizer: opus high
arena runners: opus high, sonnet high
arena cross-judge pool: opus high, sonnet high
swarm workers: haiku high
architect runners: opus high, sonnet high
interrogate reviewers: opus high, sonnet high
```

**(a) As a file.** Create `~/.claude/rules/` if it is missing. Write `~/.claude/rules/ostack-models.md` with the block above and no frontmatter, so Claude Code loads it in every session.

**(b) In the project instructions.** Read the current instructions first. Add the block above, then a closing `# end ostack model configuration` line. Its first line names it as the `ostack-models.md` rule, so ostack skills read it the same way as the file. If the instructions already hold an ostack block, replace only the lines from its `# ostack model configuration` line through its closing line. Otherwise append it after one blank line. Keep every other line exactly as it was, such as an `onyo-mode off` line. The instructions reach threads started after the change, not running ones.

### 6. Confirm

Tell the user where the rule went and that it applies to new sessions, or to new threads for project instructions. Re-running this skill updates it. For a file in `~/.claude/rules/`, say once that it lives on this machine: cloud sessions, routines, and Projects threads don't see it and run on the skill defaults. For a Claude project, running `/setup-ostack` in the project chat writes the rule into that project's instructions.

### 7. Offer a verification skill (optional)

In the project chat, skip this step. There is no checkout to inspect, so add one line to the confirmation that a thread can run `/create-verification-skill` if the repository has no way to drive the app.

Elsewhere, check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, read `${CLAUDE_SKILL_DIR}/../create-verification-skill/SKILL.md` in full and follow it. On no, move on without pushing. If `${CLAUDE_SKILL_DIR}` appears literally, it is the directory that holds this file.
