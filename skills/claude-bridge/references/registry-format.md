# Project registry

The unit is a **Project package**: one Claude Project, the Claude cloud environment that belongs to it, and the bridge into it (relay routine, coordinator session, and the Grok Bot webhook routine that receives replies). The registry is keyed by Project. Each entry records everything about the package except the two secrets.

Every Grok Bot on a computer shares one filesystem and one set of secrets. The registry stops bots from taking over each other's Projects.

## Layout

```
/workspace/claude-bridge/
  <project-slug>/
    project.json     the package's registry entry (not secret)
    threads.jsonl    thread log, one JSON object per line
```

Set `CLAUDE_BRIDGE_HOME` to use another root. `bridge.mjs show` lists every Project package.

Each Project gets its own folder instead of a shared registry file:

- **Claiming a Project is atomic.** `bridge.mjs claim` creates the folder with one `mkdir`, which fails if the folder already exists. Two bots can't claim the same Project at once.
- **No lost writes.** Each bot writes only its own folders, so two bots can't overwrite each other's change to a shared file. Writes to `project.json` go through a temporary file and a rename.

## Project slug

The slug is the Claude Project's slug: its name in lowercase, with runs of other characters replaced by one hyphen. "Docs Site" becomes `docs-site`. The helper rejects anything that isn't lowercase letters, digits, and single hyphens. The rest of the package is named from it:

| Part of the package | Default name | For `docs-site` |
|---|---|---|
| Claude cloud environment | `<slug>-env` | `docs-site-env` |
| Claude relay routine | `<slug>-relay` | `docs-site-relay` |
| Grok Bot webhook routine | `Claude replies <slug>` | `Claude replies docs-site` |
| Thread ids | `<slug>:<name>-<time>` | `docs-site:json-flag-20260101-093000` |

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
  "version": 2,
  "slug": "docs-site",
  "claude_project": "Docs Site",
  "owner": { "name": "<Grok Bot name>", "agent_id": "<Grok Bot agent id>" },
  "approver": "<the user who approves tasks>",
  "repo": "owner/repo",
  "environment": "docs-site-env",
  "mode": "coordinator",
  "relay_routine": "docs-site-relay",
  "coordinator_session_id": "<session id, or null in direct mode>",
  "coordinator_updated_at": "<ISO time>",
  "webhook_routine": "<folder of the Grok Bot webhook routine>",
  "webhook_url": "https://api2.cursor.sh/automations/webhook/<id>",
  "env": {
    "fire_url": "CLAUDE_BRIDGE_DOCS_SITE_FIRE_URL",
    "token": "CLAUDE_BRIDGE_DOCS_SITE_TOKEN"
  },
  "created_at": "<ISO time>"
}
```

- `owner` is the Grok Bot that owns the package. Only it fires, updates, or receives replies for this Project.
- `environment` is the Project's Claude cloud environment. It holds the reply settings (allowlist and webhook key). The Project's threads and the relay routine both run in it. The default is `<slug>-env`. Pass `--environment` when the Project already has a dedicated environment under another name.
- `mode` is `coordinator` (the relay routine hands tasks to a coordinator session in the Project) or `direct` (the routine does the work itself).
- `relay_routine` is the name of the Claude routine the bot fires. The default is `<slug>-relay`.
- `coordinator_session_id` isn't secret. `fire` sends it in every coordinator-mode payload.
- `webhook_routine` is the folder id of the bot's webhook routine, as the routine list shows it. `webhook_url` isn't secret. The webhook key is never stored here.
- `approver` and the names above fill in the paste prompt that `bridge.mjs handoff` prints.

## threads.jsonl

The helper appends one line per event: `fired`, `fire_failed`, or `fire_unknown` for each fire, `coordinator_updated` for `update --coordinator`, and `reply` or `reply_unparsed` for each reply the webhook routine passes in.

```json
{"at": "<ISO time>", "thread_id": "docs-site:json-flag-20260101-093000", "event": "fired", "summary": "<first 200 characters of the task>", "session_id": "<routine session id>", "session_url": "<routine session URL>", "coordinator_session_id": "<id>"}
{"at": "<ISO time>", "thread_id": "docs-site:json-flag-20260101-093000", "event": "reply", "status": "done", "message": "<text>", "pr_url": "<url>"}
```

Thread ids start with the Project slug and a colon, so any reply can be traced back to its Project. The routine's `session_url` is the relay run. The work thread's URL arrives later as `session_url` in a reply.

`bridge.mjs reply` logs a reply. Pipe in the raw webhook body through a quoted heredoc, with a delimiter that has a new random suffix every time and that no line of the body equals, so that no text from the body runs as a shell command:

```bash
node bridge.mjs reply --slug <slug> --as <agent id> <<'CLAUDE_BRIDGE_BODY_<random>'
<the body string from the webhook_event, unchanged>
CLAUDE_BRIDGE_BODY_<random>
```

It accepts `summary` or `text` in place of `message`, `pr` in place of `pr_url`, and a bare `url` as the PR link only when it looks like one. It reads `session_id` as the coordinator's id only on `coordinator_online`. It appends the reply to the log and prints the normalized reply with these flags:

- `known_thread`: the thread id matches a fire in the log.
- `duplicate`: the same reply arrived before.
- `pr_in_repo`: the PR link is in the package's repository.
- On `coordinator_online`: `previous_coordinator_session_id` and `coordinator_changed`. In coordinator mode, a new id is written to `project.json`. In direct mode, the reply is logged with `ignored` set and the registry stays as it is.

## Rules

1. **Check before you claim.** Run `bridge.mjs show` before you set up a Project. If the Project already has a package owned by another bot, tell the user and stop. Don't reuse it.
2. **Use only Project packages you own.** `fire`, `update`, `handoff`, and `reply` refuse to run unless `--as` matches `owner.agent_id`. That check stops mistakes between bots that follow this skill. It isn't access control, because every bot on the computer can read the same files and secrets.
3. **Never move secrets between Projects.** Each Project has its own two secrets, its own environment, and its own webhook key, even when two Projects live in the same Claude account.
4. **Hand a Project over only when the user asks.** The current owner runs `update --new-owner-name <name> --new-owner-id <id>`. The new owner then requests fresh secrets under the same names.
