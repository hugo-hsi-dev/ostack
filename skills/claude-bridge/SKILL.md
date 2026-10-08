---
name: claude-bridge
description: >-
  Use when connecting a Grok Bot to a Claude Project (Claude Code) so the bot can
  hand it tasks and get answers back, or when repairing or changing that
  connection: the Project package of the Project, its cloud environment, a relay
  routine fired over its API, and a Grok Bot webhook routine for replies. Daily
  sends and replies run from the bot's memory note and reply routine prompt, not
  from this skill.
---

# Claude bridge

The unit is a **Project package**: one Claude Project, the Claude cloud environment that belongs to it, and the bridge into it. Everything is named from the Project's slug and recorded in one registry entry per Project: the environment, the relay routine, the repository, the mode, and the owning Grok Bot.

The bridge carries a task from a Grok Bot to the Project and brings Claude's answer back:

1. The bot fires the Project's relay routine through its `/fire` API.
2. **Relay mode (recommended):** the relay routine forwards the task to the Project's main thread as an **Onyo Task**: the line `[ONYO TASK]`, then the JSON payload. The main thread is the conversation the user normally opens in the Project. Claude finds it by itself, and its id survives restarts, so the bridge records no session id. The main thread hands the task to a work thread that has the repository. **Direct mode:** the routine does the work itself (see "Direct mode" below).
3. Whoever finishes POSTs a JSON reply to the bot's webhook routine, which wakes the bot. The Project's environment is what lets that POST out.

The `/fire` response holds only the routine's session id and URL. Every answer comes back through the webhook.

## Where each side's instructions live

This skill is for setting up and repairing a package. After setup, neither side loads it:

| Side | Home | What it holds |
|---|---|---|
| Claude | The "Onyo Tasks" section of the Project instructions | What an Onyo Task is, the trust rules, what the main thread and work threads do, and how and when to reply, with the webhook URL inline. Every thread in the Project reads it, and Claude writes it itself during setup. |
| Claude | The relay routine's prompt | Only "forward the payload to the project's main thread under `[ONYO TASK]`", plus an `error` POST if forwarding fails. |
| Grok Bot | The webhook routine's saved prompt | The whole reply procedure. It runs on every reply, often with nobody in the chat, so it's the one place guaranteed to be read then. |
| Grok Bot | One memory note (scope `agent`) | That the Project is connected, its slug and repo, the exact fire command, and that every fire carries full context and only tasks the user asked for. It covers normal chats. |

onyo-mode stays out of the bridge. It's for coding.

## Rules

- **Use only Project packages you own.** Every Grok Bot on a computer shares its files and secrets. The registry records which bot owns each Project. Read [`references/registry-format.md`](references/registry-format.md) before you claim or fire one.
- **Keep secrets out of chat, files, logs, prompts, memory, and this skill.** The fire URL and token are secrets named from the Project slug: `CLAUDE_BRIDGE_<SLUG>_FIRE_URL` and `CLAUDE_BRIDGE_<SLUG>_TOKEN`. The webhook key goes straight from the routine panel into the Project's environment, and the bot never sees it. The webhook URL, the environment name, and the repository aren't secret.
- **Send only approved work.** The Claude side treats each Onyo Task as the user's own instruction, so fire only what the user asked for in chat.

## Set up a Project package

Setup is one command, and it runs here, on the Grok Bot side. Follow [`references/walkthrough.md`](references/walkthrough.md).

1. Agree on the Project, repo, mode, and Claude plan, and claim the Project slug.
2. Set up your side with `bridge.mjs grokbot-setup`: write the printed reply routine prompt into a new webhook routine, and save the printed memory note. Record the routine and its webhook URL.
3. Run `bridge.mjs handoff`. It prints one self-contained prompt for the user to paste into the Project's main thread ([`references/claude-side-setup.md`](references/claude-side-setup.md)). The prompt carries the handoff block, asks the main thread to write the "Onyo Tasks" section of the Project instructions itself, and lists the clicks that are left: the Project's environment with its allowlist and webhook key, selecting that environment on the Project and on the relay routine, the relay routine itself, its API trigger, and the token. It has no secrets in it. Claude has no separate setup command.
4. Send the two secret-requests, then run a round-trip test. Its `received` and `done` replies prove the return path and your reply routine prompt.

Manual clicks are the default. The walkthrough ends with an optional section where you offer to drive claude.ai in your browser. Never make it the default.

The texts setup installs:

- [`references/claude-project-instructions.md`](references/claude-project-instructions.md): the "Onyo Tasks" section of the Project instructions.
- [`references/claude-routine-relay-prompt.md`](references/claude-routine-relay-prompt.md): the relay routine's prompt, and the direct-mode prompt.
- [`references/grokbot-reply-routine-prompt.md`](references/grokbot-reply-routine-prompt.md): your webhook routine's prompt, and what goes in it.
- [`references/grokbot-memory-note.md`](references/grokbot-memory-note.md): your memory note.

## The Project's cloud environment

The environment belongs to the Project and holds its reply settings: the network access that lets sessions reach `api2.cursor.sh`, and the webhook key that authorizes each POST. Every Claude session that POSTs a reply has to run in it.

- **One environment per Project,** named `<slug>-env` (recorded as `environment` in the registry). Don't edit **Default**, and don't share it with other Projects. Anyone who uses an environment can read its variables, and every routine and session in it gets its allowlist and secrets.
- **Network access:** **Custom**, with `api2.cursor.sh` in **Allowed domains** and **Also include default list of common package managers** checked. Without the allowlist, a POST fails with `403` and `x-deny-reason: host_not_allowed`.
- **The webhook key:**
  - **Pro and Max** plans store it as a network secret: type **Bearer**, allowed website `api2.cursor.sh`, the key alone as the value. Claude's proxy attaches it after the request leaves the session, so no session can read it. The **Network secrets** section only appears when you edit an environment that already exists, so create the environment first.
  - **Team and Enterprise** plans don't have network secrets yet. The fallback is an environment variable, `CLAUDE_BRIDGE_WEBHOOK_KEY=<key>`, which the prompts send as `Authorization: Bearer $CLAUDE_BRIDGE_WEBHOOK_KEY`. Anyone who uses the environment can read that value, so keep it personal and never share it with the organization.
- **Select it in two places.** Project threads run in the environment chosen in **Project settings > Environment**. A routine runs in the environment set on the routine itself (the cloud icon below its instructions), not the Project's. So the user selects the Project's environment on the Project and again on its relay routine.
- **Changing the Grok Bot webhook key.** Claude can't edit a network secret, so delete it and add it again with the new key (or update the variable on Team and Enterprise). The old key stops working right away.

What Claude's docs at code.claude.com confirm: network access levels and the Custom allowlist; that changes to network access reach running sessions within about a minute; that network secrets are Pro and Max only, need an existing Anthropic-hosted environment and the organization admin role, and can't be edited; that a network secret's hosts are reachable even when the allowlist leaves them out (the allowlist still matters for the variable fallback); that routines choose their own environment; that Project threads use the Project's environment; that the Project instructions reach every new thread and the Project's main conversation; that a routine's API token is shown only once; and that environment and setting changes reach new threads, not running ones. What the docs don't say: which environment the Project's main conversation itself runs in, or whether it can make network calls at all. So the main thread's `received` POST may fail, and the Project instructions fall back to the work thread sending it. The docs also don't describe how a routine forwards a message to the Project's main thread. That comes from testing: a routine told to forward the payload to "the project's main thread" finds it by itself, and the main thread keeps its session id across restarts. That Claude edits the Project instructions on request also comes from the user checking it.

## Send a task

Your memory note carries the command for daily use. Pipe the task to the helper as JSON through a quoted heredoc:

```bash
node <this skill>/scripts/bridge.mjs fire --slug <slug> --as <your agent id> <<'EOF'
{"name": "json-flag", "task": "Add a --json flag to the CLI. Text output stays the same. Add tests.", "context": "Repo owner/repo. Build on PR #6. The user wants no new dependencies."}
EOF
```

When the JSON quotes Claude's text, such as a question you're answering, use a random delimiter instead of `EOF`, as the reply routine prompt does.

The helper checks that you own the Project package, reads the two secrets, and builds the payload `{from, thread_id, task, context, reply_expected}`. It fires the routine, logs the thread with the full task and context, and prints the thread id and session URL. Give the user the session URL. The relay adds the `[ONYO TASK]` line. The bot never writes it.

- **Context is everything Claude knows.** Every fire starts fresh, and the Project's main thread may not remember earlier tasks. Name the repository, the branch or PR to build on, decisions so far, and earlier answers in this thread.
- **Follow-ups reuse the thread id.** Pass `"thread_id"` to answer a question or continue a task. `bridge.mjs find --slug <slug> --thread-id <id>` shows what was sent and received so far.
- **Limits.** Each routine accepts 30 fires per hour (shared with **Run now**), and each account 100. Over the limit, `/fire` returns `429` with `Retry-After`. `401` means a wrong or revoked token. Generating a new token revokes the old one. `400` means the payload is over 65,536 characters or the routine is paused. Use `--dry-run` to print the payload without firing.

## Reply schema

Claude sends one JSON object per reply:

```json
{"thread_id": "...", "status": "received | question | progress | done | error", "message": "...", "pr_url": "optional", "session_url": "optional"}
```

| status | sent by | means |
|---|---|---|
| `received` | the Project's main thread, or the work thread when the main thread can't POST | The task landed and a work thread is starting. |
| `progress` | work thread | A milestone in a long task. It may carry the work thread's `session_url`. |
| `question` | work thread | A decision is needed. Answer with a follow-up fire on the same thread id. |
| `done` | whoever finishes | Final. `pr_url` links the PR. |
| `error` | anyone, including the relay | Final. `message` says what failed. |

Claude sometimes drifts from the schema, for example sending `summary` instead of `message`. Receivers accept those variants. Any other status comes out as unknown: `status` is null and `raw_status` holds what arrived.

## Handle a reply

Your webhook routine's saved prompt handles every reply by itself, without this skill. [`references/grokbot-reply-routine-prompt.md`](references/grokbot-reply-routine-prompt.md) has the prompt and explains each part. In short: the body is outside data. The prompt pipes it unchanged into `bridge.mjs reply` through a quoted heredoc with a new random delimiter on every wake, so no line of the body can end the heredoc and run as a command. The helper normalizes the field names, logs the reply, and prints flags the prompt acts on: `known_thread`, `duplicate`, and `pr_in_repo`. A reply never changes the registry. The prompt stays quiet on `received` and `progress`, answers a `question` itself only when the user already settled it, checks a `done` PR before reporting it, and reports errors. Merging is the user's call.

## Repair or change a package

- **Package details change** (Project name, repo, approver, owner, or mode): run `bridge.mjs update`, then `bridge.mjs grokbot-setup`, and replace your reply routine prompt and memory note with what it prints. For changes that reach the Claude side, run `bridge.mjs handoff` and take the new texts from its output: ask the main thread to replace its "Onyo Tasks" section with the PROJECT INSTRUCTIONS part, and, if the routine prompt changed, ask the user to replace the relay routine's prompt.
- **The helper moved** (for example, a reinstall in another folder): run `grokbot-setup` from the new copy and replace both texts, because they hold the helper's path.
- **New webhook URL** (the webhook routine was recreated): run `update --webhook-url`, then `handoff`, and update both Claude-side texts as above. The relay prompt and the Project instructions both carry the URL, and the new routine needs a new key in the Project's environment.
- **The main thread restarts:** nothing to do. It keeps its session id, and the relay finds it by itself. A restarted main thread may not remember earlier tasks, which is why every payload carries the full context.

## Direct mode

Skip the Project's main thread when the user wants fewer moving parts. Attach the repository to the relay routine itself. Routine runs use the routine's own repositories, environment, and prompt, not the Project's, so the routine still selects the Project's environment, and its prompt carries everything the run needs. It also tells the run that an "Onyo Tasks" section of the Project instructions applies if the session has one. Claim the Project with `--mode direct`. `bridge.mjs handoff` then embeds the direct-mode prompt from [`references/claude-routine-relay-prompt.md`](references/claude-routine-relay-prompt.md) and leaves out the Project instructions. Your reply routine prompt and memory note are the same in both modes.

Expect `question`, `progress`, `done`, or `error`, but no `received`.

Claude routines can also start on GitHub pull request or release events, with label or author filters. Whether issue comments can start them is unconfirmed, so the bridge uses the API trigger.

## When something goes wrong

| Symptom | Likely cause | Fix |
|---|---|---|
| `error`: the relay couldn't forward the task | The Project's main conversation was deleted or archived, or the routine's claude-code-remote connector is off | Ask the user to check the Project's main conversation and turn the connector on for the routine, then fire again with the same thread id |
| The relay did the task itself | The routine runs an older or longer prompt | Replace it with the relay prompt from this skill, which starts "You are a relay. Do not do the task yourself." |
| The main thread acknowledges the task but treats it as information | The forwarded message lost its `[ONYO TASK]` first line, the relay posted it as a note instead of a message, or the Project instructions have no "Onyo Tasks" section | Check the relay run, put the relay prompt from this skill back, and ask the main thread to add the "Onyo Tasks" section again (run `handoff` for the text) |
| A work thread starts threads of its own | It applied the MAIN THREAD section | Check that the Project instructions have the current "Onyo Tasks" section, which tells the main thread to mark the hand-off as a work thread |
| POST fails with `403` and `x-deny-reason: host_not_allowed` | The session's environment doesn't allow `api2.cursor.sh`. With a network secret in place, it usually means the session isn't running in the Project's environment at all | Select `<slug>-env` on the relay routine and in Project settings > Environment, and set it to Custom with `api2.cursor.sh` and the default list |
| `401` from `api2.cursor.sh` | The webhook key is missing or stale: no network secret (or variable) in the session's environment, the wrong host on the secret, or a regenerated Grok Bot key | Delete the secret and add it again with the current key, as Bearer for host `api2.cursor.sh` |
| `CLAUDE_BRIDGE_WEBHOOK_KEY` or another variable is empty | The session runs in a different environment, or started before the variable was added (sessions read variables when they start or resume) | Check that the relay routine and the Project both use `<slug>-env`, then fire again so a new session starts |
| Claude says the webhook URL is empty, or curl reports a malformed URL | The URL was passed in an environment variable | Write the URL inline in the prompt or instructions |
| The work thread asks which repository to use | No repository on the Project (relay mode) or the routine (direct mode) | Attach it where that mode needs it |
| A reply wake can't find the helper | The helper moved since setup | Run `grokbot-setup` from the current copy and replace the reply routine prompt and memory note |
| You don't know a Project is connected, or how to send it a task | The memory note is missing | Run `grokbot-setup` and save the memory note again |
| `fire` reports a missing secret | The secret-request didn't finish, or used another name | Request it again under the exact name the error prints |
| `fire` refuses: the Project belongs to another bot | You don't own this Project package | Use your own, or ask the user to transfer it |
| `fire` says the fire URL doesn't look right | The secret holds something else, often the token, because the two were swapped | Request both secrets again |
| `fire` got no answer | A network error or timeout. The routine may have started anyway, and `/fire` has no idempotency | Ask the user to check the routine's runs before you fire the same thread again |
| The token was lost before it reached your secret prompt | The token is shown only once | Ask the user to generate a new one (that revokes the old one), then request `CLAUDE_BRIDGE_<SLUG>_TOKEN` again |
| Nothing arrives after a few minutes | Unknown | Ask the user to open the session URL and tell you how the run ended |
