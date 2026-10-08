# Project registry

The unit is a **Project package**: one Claude Project, the Claude cloud environment it runs in, and the bridge into it (the relay routine that forwards messages to the Project's main thread, and the Grok Bot webhook routine that receives replies). The registry is keyed by Project. Each entry records everything about the package except the two secrets.

Every Grok Bot on a computer shares one filesystem and one set of secrets. The registry stops bots from taking over each other's Projects.

## Layout

```
/workspace/claude-bridge/
  <project-slug>/
    project.json     the package's registry entry (not secret)
```

Set `CLAUDE_BRIDGE_HOME` to use another root. `bridge.mjs show` lists every Project package.

Each Project gets its own folder instead of a shared registry file:

- **Claiming a Project is atomic.** `bridge.mjs claim` creates the folder with one `mkdir`, which fails if the folder already exists. Two bots can't claim the same Project at once.
- **No lost writes.** Each bot writes only its own folders. Writes to `project.json` go through a temporary file and a rename.

There's no message log. The Project's main thread tracks its own work and keeps its context.

## Project slug

The slug is the Claude Project's slug: its name in lowercase, with runs of other characters replaced by one hyphen. "Docs Site" becomes `docs-site`. The helper rejects anything that isn't lowercase letters, digits, and single hyphens. The rest of the package is named from it:

| Part of the package | Default name | For `docs-site` |
|---|---|---|
| Claude cloud environment | `<slug>-env` | `docs-site-env` |
| Claude relay routine | `<slug>-relay` | `docs-site-relay` |
| Grok Bot webhook routine | `Claude replies <slug>` | `Claude replies docs-site` |

## Secret names

The fire URL and token are Grok Bot secrets, and Grok Bot exposes them to Shell as environment variables. Name them from the Project slug, uppercased, with hyphens turned into underscores:

| Value | Secret name |
|---|---|
| Relay routine fire URL | `CLAUDE_BRIDGE_<SLUG>_FIRE_URL` |
| Relay routine token | `CLAUDE_BRIDGE_<SLUG>_TOKEN` |

For example, `docs-site` uses `CLAUDE_BRIDGE_DOCS_SITE_FIRE_URL` and `CLAUDE_BRIDGE_DOCS_SITE_TOKEN`. Check that they arrived by listing names only: `compgen -e | grep '^CLAUDE_BRIDGE_'`. Never print the values.

## project.json

```json
{
  "version": 3,
  "slug": "docs-site",
  "claude_project": "Docs Site",
  "owner": { "name": "<Grok Bot name>", "agent_id": "<Grok Bot agent id>" },
  "repo": "owner/repo",
  "environment": "docs-site-env",
  "relay_routine": "docs-site-relay",
  "webhook_routine": "<folder of the Grok Bot webhook routine>",
  "webhook_url": "<the Grok Bot webhook routine's URL>",
  "env": {
    "fire_url": "CLAUDE_BRIDGE_DOCS_SITE_FIRE_URL",
    "token": "CLAUDE_BRIDGE_DOCS_SITE_TOKEN"
  },
  "created_at": "<ISO time>"
}
```

- `owner` is the Grok Bot that owns the package. Only it fires or updates this Project's package. Its name stays in the registry and never reaches the Claude side.
- `environment` is the Project's Claude cloud environment. It holds the reply settings (allowlist and webhook key). The Project's threads and the relay routine both run in it. The default is `<slug>-env`. It must be dedicated to this Project, never Default or one other Projects share, because it holds the webhook secret. Pass `--environment` only when that dedicated environment already exists under another name.
- `relay_routine` is the name of the Claude routine the bot fires. The Project's main thread creates it under this name. The default is `<slug>-relay`.
- `webhook_routine` is the folder id of the bot's webhook routine, as UpdateRoutine returns it. Setup builds the webhook URL and key links from it. It's `null` until setup records it with `update --webhook-routine`.
- `webhook_url` isn't secret, but it lives only here, never in the repository. `bridge.mjs handoff` fills it into the Project instructions. The webhook key is never stored here.

Older entries may also carry `approver`, `mode`, or a `threads.jsonl` log. The helper ignores all three, so old packages keep working. Run `grokbot-setup` and `handoff` again to replace the old texts.

## Rules

1. **Check before you claim.** Run `bridge.mjs show` before you set up a Project. If the Project already has a package owned by another bot, tell the user and stop. Don't reuse it.
2. **Use only Project packages you own.** `fire`, `update`, `handoff`, and `grokbot-setup` refuse to run unless `--as` matches `owner.agent_id`. That check stops mistakes between bots that follow this skill. It isn't access control, because every bot on the computer can read the same files and secrets.
3. **Never move secrets between Projects.** Each Project has its own two secrets, its own environment, and its own webhook key, even when two Projects live in the same Claude account.
4. **Hand a Project over only when the user asks.** The current owner runs `update --new-owner-name <name> --new-owner-id <id>`. The new owner then requests fresh secrets under the same names.
