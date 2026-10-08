# Bridge registry

Every Grok Bot on a computer shares one filesystem and one set of secrets. The registry stops bots from taking over each other's bridges, and it holds everything about a bridge except the two secrets.

## Layout

```
/workspace/claude-bridge/
  <slug>/
    bridge.json      registry entry (not secret)
    threads.jsonl    thread log, one JSON object per line
```

Set `CLAUDE_BRIDGE_HOME` to use another root. `bridge.mjs show` lists every bridge.

Each bridge gets its own folder instead of a shared `bridges.json`:

- **Claiming a slug is atomic.** `bridge.mjs claim` creates the folder with one `mkdir`, which fails if the folder already exists. Two bots can't claim the same slug at once.
- **No lost writes.** Each bot writes only its own folder, so two bots can't overwrite each other's change to a shared file. Writes to `bridge.json` go through a temporary file and a rename.

## Slug

Derive the slug from the Claude Project name: lowercase, with runs of other characters replaced by one hyphen. For example, "Docs Site" becomes `docs-site`. The helper rejects anything that isn't lowercase letters, digits, and single hyphens.

## Secret names

The fire URL and token are Grok Bot secrets, and Grok Bot exposes them to Shell as environment variables. Name them from the slug, uppercased, with hyphens turned into underscores:

| Value | Secret name |
|---|---|
| Routine fire URL | `CLAUDE_BRIDGE_<SLUG>_FIRE_URL` |
| Routine token | `CLAUDE_BRIDGE_<SLUG>_TOKEN` |

For example, `docs-site` uses `CLAUDE_BRIDGE_DOCS_SITE_FIRE_URL` and `CLAUDE_BRIDGE_DOCS_SITE_TOKEN`. Check that they arrived by listing names only: `env | cut -d= -f1 | grep '^CLAUDE_BRIDGE_'`. Never print the values.

## bridge.json

```json
{
  "version": 1,
  "slug": "docs-site",
  "owner": { "name": "<Grok Bot name>", "agent_id": "<Grok Bot agent id>" },
  "claude_project": "Docs Site",
  "approver": "<the user who approves tasks>",
  "claude_environment": "claude-bridge-docs-site",
  "repo": "owner/repo",
  "mode": "coordinator",
  "env": {
    "fire_url": "CLAUDE_BRIDGE_DOCS_SITE_FIRE_URL",
    "token": "CLAUDE_BRIDGE_DOCS_SITE_TOKEN"
  },
  "webhook_routine": "<folder of the Grok Bot webhook routine>",
  "webhook_url": "https://api2.cursor.sh/automations/webhook/<id>",
  "coordinator_session_id": "<session id, or null in direct mode>",
  "coordinator_updated_at": "<ISO time>",
  "created_at": "<ISO time>"
}
```

- `mode` is `coordinator` (the routine relays to a coordinator session) or `direct` (the routine does the work itself).
- `coordinator_session_id` isn't secret. `fire` sends it in every coordinator-mode payload.
- `webhook_routine` is the folder id of the bot's webhook routine, as the routine list shows it.
- `claude_environment` names the Claude cloud environment that holds the bridge's reply settings. It defaults to `claude-bridge-<slug>`. Both the routine and the Project must use it.
- `webhook_url` and `approver` fill in the paste prompt that `bridge.mjs handoff` prints. The URL isn't secret. The webhook key is never stored here.

## threads.jsonl

The helper appends one line per event, and the reply routine appends one line per reply:

```json
{"at": "<ISO time>", "thread_id": "docs-site:json-flag-20260101-093000", "event": "fired", "summary": "<first 200 characters of the task>", "session_id": "<routine session id>", "session_url": "<routine session URL>", "coordinator_session_id": "<id>"}
{"at": "<ISO time>", "thread_id": "docs-site:json-flag-20260101-093000", "event": "reply", "status": "done", "message": "<text>", "pr_url": "<url>"}
```

Thread ids start with the slug and a colon, so any reply can be traced back to its bridge. The routine's `session_url` is the relay run. The work thread's URL arrives later as `session_url` in a reply.

`bridge.mjs reply` logs a reply. Pipe in the raw webhook body through a quoted heredoc with an unusual delimiter, so that no text from the body runs as a shell command:

```bash
node bridge.mjs reply --slug <slug> --as <agent id> <<'CLAUDE_BRIDGE_BODY_7f3a'
<the body string from the webhook_event, unchanged>
CLAUDE_BRIDGE_BODY_7f3a
```

It accepts `summary` or `text` in place of `message`, and `pr` or `url` in place of `pr_url`. It appends the reply to the log, and on `coordinator_online` it writes the new coordinator id to `bridge.json`. It prints the normalized reply with `known_thread` and `duplicate` flags.

## Rules

1. **Check before you claim.** Run `bridge.mjs show` before you pick a slug. If the Project already has a bridge owned by another bot, tell the user and stop. Don't reuse it.
2. **Fire only bridges you own.** `fire`, `update`, and `reply` refuse to run unless `--as` matches `owner.agent_id`.
3. **Never move secrets between bridges.** Each bridge has its own two secrets, even when two bridges point at the same Claude account.
4. **Hand a bridge over only when the user asks.** The current owner runs `update --new-owner-name <name> --new-owner-id <id>`. The new owner then requests fresh secrets under the same names.
