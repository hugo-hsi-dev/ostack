# benny routine intent

## what i want to automate

i want two claude code routines that work together in one slack issue channel.

routines have no slack trigger. by default each routine runs on a schedule (hourly is the minimum interval), reads my source channel through the slack connector, and picks up new top-level reports that carry no benny marker yet. if my team can relay slack events, i may use each routine's api trigger instead, firing `/fire` with the report coordinates in `text`.

### routine 1: triage issue reports

- trigger: on each scheduled run, i want this routine to find new top-level reports in my configured source slack channel that have no benny marker and no 👀 reaction from the triage identity, claim each one with a 👀 reaction, and keep its original thread coordinates. with an api trigger, it starts on the report named in the fire payload.
- behavior: i want it to read the thread and attachments, classify the report as a bug or performance issue, feature request, question or feedback, or reroute, and trace the likely owning layer before routing.
- tracker: i want it to search my configured tracker for duplicates, update a confident duplicate, and create a ticket only for a clear net-new bug.
- tools: i want slack connector thread read, reaction, and reply access, my configured tracker integration, and my optional routing map.
- outcome: i want exactly one reply in the source thread with a short verdict and `[benny:bug]`, `[benny:performance]`, or `[benny:other]`. a bug or performance marker may include the tracker url.
- boundary: i never want this routine to post a root message in the source channel.

### routine 2: reproduce and fix confirmed bugs

- trigger: on each scheduled run, i want this routine to find a top-level report whose thread already holds a trusted `[benny:bug]` or `[benny:performance]` marker and no repro claim yet, then claim it. with an api trigger, it starts from the report named in the fire payload and waits for the trusted triage marker in the original thread.
- gates: i want it to stop when someone clearly owns the fix. if an existing pull request or merged commit may fix the report, i want verification instead of a competing change.
- behavior: i want it to use my configured control adapter and feature map, reproduce the exact symptom twice through the real ui, and capture screenshots, video, and a read-only state cross-check.
- fix: i want it to verify existing pull requests without authoring over them. after a confirmed repro, it may attempt one bounded root-cause fix, use tdd when the test is cheap, smoke the blast radius, and open a draft pull request only when before-and-after proof passes.
- tools: i want slack connector thread read, reaction, and reply access, repository and history access, draft pull request creation, my configured tracker, and my control adapter.
- outcome: i want evidence and a verified result in the source or optional operations threads, plus an optional draft pull request. updates should be concise.
- boundary: i never want this routine to post a root message in the source channel.

### shared rules

- i want the source channel and root thread coordinates to stay immutable for the whole run.
- each routine run starts from a fresh clone and remembers nothing. i want slack markers and claim reactions to be the only dedupe state, so a report is never handled twice.
- the claude.ai slack connector acts as the person who connected it. i want it connected with a dedicated slack account for benny, because repro trusts any marker in the verdict format from that account, even one typed by hand.
- if the slack connector has no reaction tool, i want dedupe to rely on the benny marker replies alone, with a short claim reply in the thread in place of each claim reaction.
- i treat utility and debug bots as evidence, not delegation or fix ownership.
- i allow subagents to help, but they cannot post to slack or receive slack credentials or slack connector write tools.
- i want this entire pack committed at `.claude/automations/benny/` in the target repository. its `SKILL.md` files are direct routine instructions, not registered plugin skills.
- i want ostack enabled through the target repository's committed `.claude/settings.json` only for shared dependencies such as `how`, `why`, `tdd`, `unslop`, and the required principle skills.
- i want each routine prompt to read its committed operational file directly. i do not want plugin cache paths, copied excerpts, or slash-skill discovery.
- i keep user-owned configuration, feature maps, routing maps, and secrets outside `.claude/automations/benny/` so pack refreshes cannot overwrite them.
- i want both routines to fail closed when channel coordinates, tracker access, the control adapter, or the feature map are missing or uncertain.
- i want draft pull requests only. do not merge or deploy.

### my configuration

- source slack channel: `<channel>`
- optional operations channel: `<channel or none>`
- repository and default branch: `<repo>`, `<branch>`
- tracker: `<type, team, project, labels, intake status>`
- routing map: `<path or none>`
- triage identity: `<slack identity the slack connector posts as>`
- scan: `<schedule (default) or api>`, `<schedule interval, hourly or longer>`, `<reports per run for triage and for repro>`
- control skill: `<configured skill or adapter>`
- feature map: `<committed same-repo path outside the copied pack, or behavior to paraphrase>`
- models: `<triage, reproduce, code, media review>`
- status emoji strings: `<seen, reproducing, reproduced, blocked, fixing, failed, pull request opened>`
- budgets: `<scan lookback, polling, verdict wait, follow-up, repro, rejection, fix>`
- optional bot token capability: `<none, file download, or editable operations status>`

start from [`configuration.example.yaml`](./templates/configuration.example.yaml) and [`feature-map.example.md`](./skills/reproduce-and-fix-issues/references/feature-map.example.md). copy and fill them outside this pack, for example under `.claude/benny/`. keep secret values in a secret manager or the routine's cloud environment.

## for the agent

the human enters setup by pointing claude code at this file. do not look for or invoke a discovered benny slash skill.

1. ask which repository will run the routines.
2. treat the directory containing this `FOR_AGENTS.md` as the source pack.
3. merge the entire source pack into `<target-repository>/.claude/automations/benny/`.
4. preserve every destination-only file. never delete unrelated files or overwrite user-owned configuration, feature maps, or routing maps.
5. when an existing destination file at a source-managed path differs, review the diff and merge without discarding local edits. if ownership is ambiguous, stop and ask before replacing it.
6. verify that the copied `FOR_AGENTS.md` and `skills/setup-benny/SKILL.md` exist in the target repository.
7. read and follow `.claude/automations/benny/skills/setup-benny/SKILL.md` directly from the target repository.

i want you to merge these entries into the target repository's `.claude/settings.json`:

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

preserve every unrelated setting, plugin, and marketplace.

i want verification from a fresh session rooted in the target repository. confirm that ostack's `how`, `why`, `tdd`, `unslop`, and the principle skills used by benny resolve in project scope. do not count skills loaded from the current session or a user-scoped install.

if project-scoped plugins are unavailable or any shared dependency does not resolve, stop and explain what failed. do not add `.claude/automations/benny/skills/` to a plugin manifest or expect its files to appear in the slash-skill list.

tell me that `.claude/settings.json`, `.claude/automations/benny/`, and any referenced secret-free configuration must be committed before either routine is enabled. do not create or update a routine until i explicitly ask.

for first-time creation, create one routine for triage and one for repro and fix, through the routine form at claude.ai/code/routines or `/schedule` in the cli. an api trigger can only be added on the web. finish the review and my save for the first routine before starting the second.

paraphrase this intent and the finished configuration into each routine prompt. the triage prompt must read and follow `.claude/automations/benny/skills/triage-issue-reports/SKILL.md`. the repro prompt must read and follow `.claude/automations/benny/skills/reproduce-and-fix-issues/SKILL.md`. use these repo-relative paths only after you confirm they are committed on the default branch of the repository the routine clones.

for existing routines, validate the configuration, then use the concise field checklist in the copied setup file so i can edit each routine directly in its routine form. do not create duplicates.
