# benny

benny gives you two claude code routines for slack issue reports. one triages each report. the other reproduces confirmed bugs and may prepare a small draft fix.

routines have no slack trigger. by default each routine runs on a schedule, reads the source channel through the slack connector, and picks up new top-level reports that carry no benny marker yet. teams that can relay slack events may fire the routines through their api trigger instead.

the files in this directory are dormant setup and routine sources. they do not appear as slash skills.

## set it up

1. point claude code at [`FOR_AGENTS.md`](./FOR_AGENTS.md) and name the target repository.
2. let setup merge this whole directory into the target at `.claude/automations/benny/`. it must preserve destination-only files and review conflicts instead of overwriting local edits.
3. let setup enable ostack in the target repository's `.claude/settings.json` for shared dependencies:

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

4. keep user-owned configuration outside the copied pack, for example in `.claude/benny/`. adapt [`configuration.example.yaml`](./templates/configuration.example.yaml) and [`feature-map.example.md`](./skills/reproduce-and-fix-issues/references/feature-map.example.md).
5. commit `.claude/settings.json`, `.claude/automations/benny/`, and any secret-free configuration before enabling either routine. each routine run starts from a fresh clone of the default branch.
6. create each routine at [claude.ai/code/routines](https://claude.ai/code/routines), or with `/schedule` in the cli, or update existing routines in their routine form. then send a harmless test report and verify every source-channel post stays in the original thread.
