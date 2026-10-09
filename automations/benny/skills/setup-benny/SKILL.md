---
name: setup-benny
description: Configure Benny and prepare its triage and repro routines. Use when installing Benny or changing its Slack, tracker, repository, trigger, routing, control, model, or budget settings.
disable-model-invocation: true
---

# Set up Benny

Benny ships as a dormant routine pack inside ostack. The plugin manifest exposes only ostack's normal skill root; this file and the two operational files are not slash skills.

The human enters setup by pointing Claude Code at the pack's `FOR_AGENTS.md`. The bootstrap flow copies the whole pack into the target repository, then reads this file directly at `.claude/automations/benny/skills/setup-benny/SKILL.md`.

Benny needs external configuration and two live Claude Code routines.

Routines have no Slack trigger. The default is a scheduled routine (hourly is the minimum interval) that reads the source channel through the Slack connector and picks up new top-level reports with no Benny marker or claim reaction yet. Teams that can relay Slack events may use each routine's API trigger instead, which fires `/fire` with the report coordinates in `text`. For interactive help inside a channel, point users at Claude Tag (Claude in Slack). It is not a substitute for these routines.

Do not create or update a routine until the user explicitly asks. Never put a secret value in plugin files, prompts, or committed configuration.

## 1. Copy the pack and enable shared ostack skills

Do this before asking for Benny configuration and before creating any routine.

Ask which repository will run the routines. The source pack is the directory containing `FOR_AGENTS.md`. The destination is `<target-repository>/.claude/automations/benny/`.

Merge the entire source pack into the destination:

1. Create the destination when it is absent.
2. Copy every source file to the same relative path.
3. Preserve destination-only files. Never delete unrelated files during install or refresh.
4. Keep user-owned configuration, feature maps, and routing maps outside the destination. Never overwrite them.
5. When an existing source-managed file differs, inspect the diff and merge without discarding local edits. If ownership is ambiguous, stop and ask before replacing it.
6. Verify that the destination contains `FOR_AGENTS.md`, this setup file, both operational files, their references, and the templates.

If this file is already being read from the target destination, treat the copy as complete and run the same verification before continuing.

Add ostack to the target repository's `.claude/settings.json`. If the file or `.claude` directory does not exist, create it.

Merge these entries into the existing JSON:

```json
{
	"enabledPlugins": {
		"ostack@ostack": true
	},
	"extraKnownMarketplaces": {
		"ostack": {
			"source": { "source": "github", "repo": "hugo-hsi-dev/ostack" }
		}
	}
}
```

Preserve every unrelated top-level setting, every other plugin entry, and every other marketplace. If `enabledPlugins["ostack@ostack"]` already exists, change only its value. Validate the file after editing it.

Start a fresh Claude Code session rooted in the target repository. Verify that these shared ostack skills resolve from project scope:

- `how`
- `why`
- `tdd`
- `unslop`
- `principle-separate-before-serializing-shared-state`
- `principle-minimize-reader-load`
- `principle-guard-the-context-window`
- `principle-sequence-verifiable-units`
- `principle-fix-root-causes`
- `principle-prove-it-works`

Do not count a skill loaded from the current session or a user-scoped plugin. The check must show that a fresh session in the target repository receives ostack through project settings. A routine run starts from a fresh clone, so project settings are the only way it gets ostack.

If project-scoped plugin installation is unavailable or any shared dependency does not resolve, stop and explain the failure.

The Benny files are read directly from `.claude/automations/benny/`. Do not add that directory to a plugin manifest or expect its `SKILL.md` files to appear in the slash-skill list.

Tell the user that `.claude/settings.json`, `.claude/automations/benny/`, and any referenced secret-free configuration must be committed to the default branch before either routine is enabled. Do not commit them unless the user asks.

Once this check passes, live routine prompts may read the committed operational files by their stable repository-relative paths. They must not embed a plugin cache path or copy the file contents.

## 2. Adapt the configuration

Open these copied examples:

- `../../templates/configuration.example.yaml`
- `../reproduce-and-fix-issues/references/feature-map.example.md`

Create user-owned copies outside `.claude/automations/benny/`. These are configuration files, not pack files. Example locations:

- Project config, such as `.claude/benny/configuration.yaml`
- Project feature map, such as `.claude/benny/feature-map.md`
- Project routing map, such as `.claude/benny/routing.md`

A routine runs in a cloud session from a fresh clone, so it cannot read user-level files such as `~/.config/benny/`. Commit the configuration or paraphrase it into the routine prompt.

Fill one feature-map section for every user-facing feature the routine may reproduce. Keep it at the user point of view. Do not freeze implementation details or current code paths in the map.

Do not edit the copied examples. Pack refreshes may update source-managed files after conflict review, but they must never touch the user-owned copies.

Prefer committed, secret-free files in the target repository, because each routine run reads a fresh clone. Otherwise paraphrase the required values into the routine prompt. Reference a repository file only after you confirm that it is committed on the default branch of the repository the routine clones.

Use stable repository-relative paths for committed pack and configuration files. Never reference the plugin source directory or a plugin cache path from a live routine.

## 3. Fill the required choices

Ask for or confirm:

- Source Slack channel ID
- Optional operations or status channel ID
- Repository URL and default branch
- Triage identity or Slack user ID. It must be the Slack account the routines' Slack connector acts as, because the claim reactions and verdicts come from it.
- Trigger type, `schedule` (default) or `api`, the schedule interval (hourly or longer), the scan lookback, and the per-run report limits
- Issue tracker type, team, project, labels, and intake status
- Tracker adapter skill or MCP actions
- Optional routing map path
- Required control skill name
- Required user-facing feature-map path
- Status emoji strings
- Pull request URL format
- Polling and effort budgets
- Model for triage, repro, code work, and media review

Use Claude Code model aliases (`opus`, `sonnet`, `haiku`, `fable`) or full model IDs the account can use. The routine form sets each run's model, so the triage and repro values go there. Subagents take the code and media-review values as the Agent tool's `model`, plus `effort` when the value names one, such as `opus xhigh`. Do not guess a model ID and do not carry over a private default.

The source channel, triage identity, repository, tracker adapter, control skill, and feature map must be explicit. Fail setup if any required value stays ambiguous.

Use ostack's `unslop` skill on the final routine names, descriptions, and prompts before saving them.

## 4. Check integration capabilities

Both routines reach Slack through the Slack connector. Include it in each routine's connectors.

The triage routine needs:

- Read access to the configured source Slack channel and its threads
- Reaction access on source-channel messages, for the claim reaction
- Thread-reply access in that channel
- Attachment metadata and file download access when reports include media
- Search, read, create, and update access through the configured issue-tracker adapter

The repro routine needs:

- Read access to the source channel and its threads
- Reaction access on source-channel messages, for the claim reaction
- Thread-reply access in the source channel
- Optional post and edit access in the configured operations channel
- Repository read and history access
- A pull request action that can open a draft pull request
- The configured control-adapter skill, runnable inside the routine's cloud environment

Prefer configured Slack connector tools for reads, reactions, and posts. The optional `BENNY_SLACK_BOT_TOKEN` may fill a narrow gap such as editing one operations status message or downloading an attachment. Store the value in the routine's cloud environment or a secret manager, not in YAML.

Claude Code subagents inherit the session's MCP tools, the Slack connector included. If the user wants delegated workers, have them define a project agent whose `tools` or `disallowedTools` removes every Slack connector write tool. Without one, the operational files keep that work in the coordinator.

Do not use undocumented integration endpoints.

## 5. Prepare the routing map

If the user wants reroutes or owner pings:

1. Copy `../triage-issue-reports/references/routing.example.md` outside `.claude/automations/benny/`.
2. Replace every placeholder with public or organization-local values.
3. Keep owner pings off by default.
4. Allow a ping only for a configured feature owner or a confirmed likely regression author.

If no routing map is configured, triage may classify a report but must not guess a destination or owner.

## 6. Verify the control adapter

Read `../reproduce-and-fix-issues/references/control-adapter.md` and the user's completed feature map.

Confirm that the named skill can:

- Bring up the target app
- Navigate every mapped feature through the real UI
- Exercise mapped states through declared adapter actions
- Inspect state without forcing the result
- Capture screenshots
- Start and stop a recording
- Clean up its processes and temporary data

If any capability is missing, leave the repro routine disabled. It must fail closed rather than claim a reproduction it did not perform.

## 7. Prepare the live routines

Ask whether this is first-time creation or configuration of existing routines.

Read `../../FOR_AGENTS.md` from the copied pack as the primary user-intent source for either path. Use it to understand the two triggers, tools, instructions, outcomes, and shared rules.

### First-time creation

Create one routine at a time, through the routine form at claude.ai/code/routines or `/schedule` in the CLI. `/schedule` covers schedule triggers. An API trigger can only be added on the web.

For each routine:

1. Read the matching copied prompt template as secondary internal source material.
2. Turn `FOR_AGENTS.md`, the finished Benny configuration, and the template intent into a complete natural-language routine prompt.
3. Tell the prompt to read and follow its exact committed operational file under `.claude/automations/benny/`.
4. Use the stable repository-relative path, not a plugin source or cache path. Do not copy the operational file contents into the prompt.
5. Confirm that the copied pack, `.claude/settings.json`, and any referenced configuration files are committed on the default branch of the repository the routine clones.
6. Fill the routine form with the user. It takes the name, prompt, target repository, a cloud environment that can run the control adapter, the Slack connector and the tracker connector, the model, and the trigger.
7. For the default trigger, set a schedule of hourly or longer. For an API trigger, the user adds it on the routine's page, generates the token themselves, and stores it in the system that relays Slack events. The token is shown only once. Never ask for it in a chat.
8. Show the user the filled form and let them save it.
9. Finish this routine before starting the next one.

The triage routine, filled from configuration:

- Name `benny-triage`.
- Read and follow `.claude/automations/benny/skills/triage-issue-reports/SKILL.md` for every run.
- On a scheduled run, scan the configured source Slack channel for new top-level reports with no Benny marker and no `seen` reaction from the triage identity, and claim each with that reaction.
- On an API run, read the report coordinates from the `text` field in the routine-fire-payload block.
- Read each report's thread and reply only inside it.
- Use the configured issue-tracker integration.
- Classify, inspect evidence, trace cause, dedupe, and create only clear new bugs.
- End one thread-only verdict with the configured `[benny:bug]`, `[benny:performance]`, or `[benny:other]` marker and optional tracker URL.
- Never post a source-channel root message.

After the triage routine is saved, the repro and fix routine:

- Name `benny-reproduce`.
- Read and follow `.claude/automations/benny/skills/reproduce-and-fix-issues/SKILL.md` for every run.
- On a scheduled run, scan the configured source Slack channel for one report with a trusted bug or performance marker and no `reproducing` claim reaction, and claim it with that reaction.
- On an API run, read the report coordinates from the `text` field in the routine-fire-payload block.
- Use the configured repository and default branch.
- Read the source thread and reply only inside it.
- Include pull request creation and the configured tracker, control-adapter, and feature-map requirements. Paraphrase mapped user paths and states unless an eligible file is committed in the same repository.
- Wait for a trusted triage marker before acting.
- Reproduce the exact symptom twice through the mapped real UI and capture evidence.
- Verify an existing fix without authoring over it.
- Attempt an optional bounded fix only after confirmed repro, then open a draft pull request when proof and checks pass.
- Never post a source-channel root message.

The routine form sets the model for each run. Put the configured triage or repro model there.

### Existing routines

Do not create a new routine to inspect or update an existing one.

Finish configuration, routing, control-adapter, and feature-map validation. Then give the user this concise routine-form checklist.

For the existing triage routine, update:

- Name and description
- Direct instruction to read `.claude/automations/benny/skills/triage-issue-reports/SKILL.md`
- Trigger, scan and claim instructions, and source channel
- Slack connector with thread read, reaction, and reply capabilities
- Issue-tracker connector
- Model
- Paraphrased triage instructions, thread-only rule, and Benny verdict markers

For the existing repro routine, update:

- Name and description
- Direct instruction to read `.claude/automations/benny/skills/reproduce-and-fix-issues/SKILL.md`
- Matching trigger, scan and claim instructions, and source channel
- Repository and default branch
- Slack connector with thread read, reaction, and reply capabilities
- Pull request access
- Tracker, control-adapter, and feature-map requirements
- Model
- Paraphrased marker wait, evidence, verification, and bounded-fix instructions

Ask the user to update each existing routine directly in its routine form. Do not create replacements or duplicates.

### Creation boundary

Never call a routine backend API directly. Never put a routine token, Slack token, or other secret in a prompt, a chat, or committed configuration. For new routines, the only finish paths are the routine form the user saves at claude.ai/code/routines, or `/schedule` in the CLI after the user reviews the draft.

Do not point either routine at the real source channel until the thread-safety test passes after the save.

## 8. Test thread safety

Use a test channel or a harmless test report.

Before testing, confirm that the target repository's `.claude/settings.json`, `.claude/automations/benny/`, and every referenced secret-free configuration file are committed on the default branch the routine clones. Confirm that both routine prompts point at their exact committed operational files. If any check fails, stop. Tell the user that the routine cannot be enabled yet.

Verify:

1. Triage stores the root `thread_ts` and posts exactly one verdict as a reply.
2. The verdict contains one configured marker.
3. Repro accepts the marker only from the configured triage identity.
4. Repro keeps the same immutable source coordinates.
5. No source-channel root message appears.
6. A delegated worker cannot use any Slack write action.
7. Missing coordinates, a deleted parent, or a failed preflight produces no post and no tracker issue.
8. A second run skips a report that already carries a Benny marker or a claim reaction.

Enable normal traffic only after all eight checks pass.
