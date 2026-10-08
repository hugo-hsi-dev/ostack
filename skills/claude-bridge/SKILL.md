---
name: claude-bridge
description: >-
  Use when connecting a Grok Bot to a Claude Project (Claude Code) so the bot can
  send it messages and get answers back, or when repairing or changing that
  connection: the Project package of the Project, its cloud environment, a relay
  routine fired over its API, and a Grok Bot webhook routine for replies. Daily
  sends and replies run from the bot's memory note and reply routine prompt, not
  from this skill.
---

# Claude bridge

The unit is a **Project package**: one Claude Project, the Claude cloud environment it runs in, and the bridge into it. Everything is named from the Project's slug and recorded in one registry entry per Project: the environment, the relay routine, the repository, and the owning Grok Bot.

Both sides read plain text, so the bridge carries plain Markdown both ways:

1. The bot fires the Project's relay routine through its `/fire` API with a Markdown message whose first line is exactly `# ONYO MESSAGE`. The message may be a task, a question, an answer, or a follow-up.
2. The relay routine forwards the message unchanged to the Project's main thread, the conversation the user normally opens in the Project. The main thread is the bridge and the orchestrator: it answers, or hands work to threads as it normally would, and tracks which thread is doing what. The bot tracks no threads.
3. Claude POSTs Markdown replies to the bot's webhook routine, which wakes the bot. The Project's environment is what lets that POST out.

The `/fire` response holds only the routine's session id and URL. Every answer comes back through the webhook.

## Where each side's instructions live

This skill is for setting up and repairing a package. After setup, neither side loads it:

| Side | Home | What it holds |
|---|---|---|
| Claude | The "ONYO messages" section of the Project instructions | What an ONYO message is, that the main thread orchestrates, how to reply (the webhook URL inline), and when work threads reply directly. Claude writes it itself during setup. It names no bot and no person. |
| Claude | The relay routine's prompt | "You are a relay": forward the message unchanged to the main thread, and notify the user if that fails. The main thread creates the routine itself during setup. |
| Grok Bot | The webhook routine's saved prompt | Summarize Claude's reply for the user, carry on with next steps that are part of what the user asked for, and take anything new (open questions, unrequested work) to the user first. It names no Project, so it's the same for every package. |
| Grok Bot | One memory note (scope `agent`) | That the Project is connected, its slug and repo, the exact fire command, that it sends only what the user asked for, and that the main thread keeps its context. |

onyo-mode stays out of the bridge. It's for coding.

## Rules

- **Use only Project packages you own.** Every Grok Bot on a computer shares its files and secrets. The registry records which bot owns each Project. Read [`references/registry-format.md`](references/registry-format.md) before you claim or fire one.
- **Keep secrets out of chat, files, logs, prompts, memory, and this skill.** The fire URL and token are secrets named from the Project slug: `CLAUDE_BRIDGE_<SLUG>_FIRE_URL` and `CLAUDE_BRIDGE_<SLUG>_TOKEN`. The webhook key goes straight from the routine panel into the Project's environment, and the bot never sees it. The webhook URL isn't secret, but it lives only in the registry and the Claude-side texts, never in a repository.
- **Send only what the user asked for.** The Claude side treats each ONYO message as the user's own words, so fire only what the user asked for in chat.

## Set up a Project package

Setup runs here, on the Grok Bot side. Follow [`references/walkthrough.md`](references/walkthrough.md).

1. Agree on the Project and repo, and claim the Project slug. The Project needs a dedicated environment, never Default or one other Projects share.
2. Set up your side with `bridge.mjs grokbot-setup`: write the printed reply routine prompt into a new webhook routine, and save the printed memory note. Record the folder id UpdateRoutine returns, then send the user the webhook URL and key links built from it (`grokbot://app/v1/sidebar?target=webhook-url&automation=<folder id>` and `target=webhook-key`), and record the webhook URL. Never send a generic Routines tab link.
3. Run `bridge.mjs handoff`. It prints one self-contained prompt for the user to paste into the Project's main thread ([`references/claude-side-setup.md`](references/claude-side-setup.md)). The main thread writes the "ONYO messages" section of the Project instructions and creates the relay routine itself, as a Project-owned routine in the Project's environment. The user does the environment clicks (creating it, adding the webhook key as the "Onyo Key" network secret, and selecting it on the Project) and one routine click: open the relay routine from the direct link the main thread gives (the routine list in the left sidebar at claude.ai/code is the fallback), add an API trigger, and generate its token, copying the fire URL and token straight into your secret prompts. The prompt has no secrets in it, and the Project never generates or shows the token.
4. Send the two secret-requests, then send a test message.

Manual clicks are the default. The walkthrough ends with an optional section where you offer to drive claude.ai in your browser. Never make it the default.

The texts setup installs:

- [`references/claude-project-instructions.md`](references/claude-project-instructions.md): the "ONYO messages" section of the Project instructions.
- [`references/claude-routine-relay-prompt.md`](references/claude-routine-relay-prompt.md): the relay prompt.
- [`references/grokbot-reply-routine-prompt.md`](references/grokbot-reply-routine-prompt.md): your webhook routine's prompt.
- [`references/grokbot-memory-note.md`](references/grokbot-memory-note.md): your memory note.

## The Project's cloud environment

The environment holds the webhook key that authorizes each POST to `api2.cursor.sh`. Every Claude session that POSTs a reply has to run in it.

- **A Project uses whatever environment is selected** in **Project settings > Environment**, which is **Default** unless the user picks another. A Project doesn't get its own environment automatically, and Claude can't create or edit environments or secrets, so those stay user clicks.
- **A dedicated environment is required,** named `<slug>-env` (recorded as `environment` in the registry), because it holds the secret that reaches the Grok Bot's webhook. Never use **Default** or an environment other Projects share: every session and routine in it would get the webhook secret. The user creates it and selects it on the Project.
- **Where to set it:** **Project settings > Environment**, then the **Cloud environment** menu, then the gear beside the selected environment. That's where Network secrets are set. An organization-owned environment opens read-only, and only an organization admin can change it. Unverified: whether creating a new environment from that menu works the same as **Add cloud environment** from the cloud icon.
- **Network access stays at its default.** A network secret's allowed host is reachable even when the allowlist leaves it out, so the secret alone lets replies through.
- **The webhook key** is a network secret named **Onyo Key**: type **Bearer**, allowed website `api2.cursor.sh`, the key alone as the value. There's one per environment, so the name carries no slug. Claude's proxy attaches it after the request leaves the session, so no session can read it, and the Claude-side texts tell Claude not to set the header. The **Network secrets** section only appears when you edit an environment that already exists, so create the environment first.
- **No Network secrets section.** Some accounts don't offer it. Don't ask the user which subscription they have: they check when they edit the environment, and only if the section isn't there, use the alternative. It's an environment variable, `CLAUDE_BRIDGE_WEBHOOK_KEY=<key>`, with `api2.cursor.sh` added to the environment's allowlist (a variable doesn't get the secret's host exception), plus one changed sentence in the Claude-side reply paragraph so Claude sends `Authorization: Bearer $CLAUDE_BRIDGE_WEBHOOK_KEY` itself. The walkthrough's step 5 has the exact wording. Anyone who uses the environment can read the variable, so keep it personal and never share it with the organization.
- **Select it in two places.** Project threads run in the environment chosen in **Project settings > Environment**. A routine runs in the environment set on the routine itself, not the Project's, so the main thread creates the relay routine with the Project's environment id and a new session on each fire.
- **Changing the Grok Bot webhook key.** Claude can't edit a network secret, so delete it and add it again with the new key. The old key stops working right away.

What Claude's docs at code.claude.com confirm: network access levels and the allowlist; that network secrets aren't offered on every account, need an existing Anthropic-hosted environment and the organization admin role, and can't be edited; that a network secret's hosts are reachable even when the allowlist leaves them out (the allowlist still matters for the variable alternative); that routines choose their own environment; that Project threads use the Project's environment; that the Project instructions reach every new thread and the Project's main conversation; that a routine's API token is shown only once; and that environment and setting changes reach new threads, not running ones. What the docs don't say: which environment the Project's main conversation itself runs in, or how a routine forwards a message to it. That comes from testing: a routine told to forward to "the project's main thread" finds it by itself, and the main thread keeps its session id across restarts.

## Send a message

Your memory note carries the command for daily use. Pipe Markdown to the helper through a quoted heredoc:

```bash
node <this skill>/scripts/bridge.mjs fire --slug <slug> --as <your agent id> <<'EOF'
Add a --json flag to the CLI in owner/repo, building on PR #6. Text output stays the same. Add tests. No new dependencies.
EOF
```

When the message quotes Claude's text, use a random delimiter instead of `EOF`, so no quoted line can end the heredoc.

The helper checks that you own the Project package, makes `# ONYO MESSAGE` the first line if it isn't already, reads the two secrets, and fires the routine with `{"text": <message>}`. It prints the routine's session id and URL.

- **Short messages are enough.** The Project's main thread keeps its context, so answers and follow-ups can be short. New work should still name the repository and the branch or PR to build on.
- **Limits.** Each routine accepts 30 fires per hour (shared with **Run now**), and each account 100. Over the limit, `/fire` returns `429` with `Retry-After`. `401` means a wrong or revoked token. Generating a new token revokes the old one. `400` means the message is over 65,536 characters or the routine is paused. Use `--dry-run` to print the message without firing.

## Handle a reply

Your webhook routine's saved prompt handles every reply by itself, without this skill. Claude's replies are free-form Markdown: it writes when the work starts, when it has a question, when it finishes (with a link), or when it fails, and each reply names what it's about. The prompt summarizes the reply for the user and relays questions, then sends the user's answer back the way the memory note says. Next steps that are part of what the user already asked for, such as reviewing the PR Claude opened or answering a question the user already settled, go ahead without asking. Anything new, such as messaging people, merging, deleting, spending money, or unrelated work, waits for the user's yes.

## Repair or change a package

- **Package details change** (Project name, repo, or owner): run `bridge.mjs update`, then `bridge.mjs grokbot-setup`, and replace your memory note with what it prints. The reply routine prompt only changes when this skill changes it. For changes that reach the Claude side, run `bridge.mjs handoff` and ask the main thread to replace its "ONYO messages" section with the PROJECT INSTRUCTIONS part.
- **The helper moved** (for example, a reinstall in another folder): run `grokbot-setup` from the new copy and replace the memory note, because it holds the helper's path.
- **New webhook URL** (the webhook routine was recreated): run `update --webhook-url`, then `handoff`, and update the "ONYO messages" section. The new routine also needs its new key in the Project's environment. The relay prompt doesn't change.
- **The main thread restarts:** nothing to do. It keeps its session id, and the relay finds it by itself.

## Other triggers

Claude routines can also start on GitHub pull request or release events, with label or author filters. Whether issue comments can start them is unconfirmed, so the bridge uses the API trigger.

## When something goes wrong

| Symptom | Likely cause | Fix |
|---|---|---|
| The relay run says it couldn't forward the message | The Project's main conversation was deleted or archived, or the routine lost its way to reach it | Ask the user to check the Project's main conversation and ask it to fix the routine, then send the message again |
| The relay acted on the message itself | The routine runs an older or longer prompt | Replace it with the relay prompt from this skill, which starts "You are a relay." |
| The main thread treats the message as information | The message lost its `# ONYO MESSAGE` first line, or the Project instructions have no "ONYO messages" section | Check the relay run, put the relay prompt from this skill back, and ask the main thread to add the "ONYO messages" section again (run `handoff` for the text) |
| No reply arrives, and the main thread says its POST failed | See the next rows for the HTTP status it reports | Fix the environment, then send a test message |
| POST fails with `403` and `x-deny-reason: host_not_allowed` | The session's environment has no Onyo Key secret for `api2.cursor.sh`, or the session isn't running in the Project's environment at all | Select the package's environment in Project settings > Environment, and check that it has the "Onyo Key" Bearer secret with allowed website `api2.cursor.sh`. With the variable alternative, add `api2.cursor.sh` to the environment's allowlist |
| `401` from `api2.cursor.sh` | The webhook key is missing or stale: no network secret (or variable) in the session's environment, the wrong host on the secret, or a regenerated Grok Bot key | Delete the "Onyo Key" secret and add it again with the current key, as Bearer for host `api2.cursor.sh` |
| `CLAUDE_BRIDGE_WEBHOOK_KEY` is empty (variable alternative) | The session runs in a different environment, or started before the variable was added | Check that the Project uses the package's environment, then send the message again so a new session starts |
| Claude says the webhook URL is empty, or curl reports a malformed URL | The URL was passed in an environment variable | Write the URL inline in the instructions or prompt (`handoff` does) |
| A work thread asks which repository to use | No repository on the Project | Ask the main thread to add it |
| The user can't find the relay routine to add the API trigger | The main thread didn't give its direct link, or the link didn't open | Ask the main thread for the routine's link. As a fallback, open the routine list in the left sidebar at claude.ai/code and select the relay routine, then add the API trigger and generate the token there |
| The relay run can't reach the main thread, or runs in the wrong environment | The routine was created without the Project's environment or without what it needs to reach the main thread | Ask the main thread to fix the routine, or delete it and create it again (that needs a new API trigger and token) |
| Sending can't find the helper | The helper moved since setup | Run `grokbot-setup` from the current copy and replace the memory note |
| The user's webhook link opens the Routines tab instead of the URL or key field | The link was a generic Routines tab link, sent because the routine status with the field links wasn't in context yet right after the routine was created | Build the links from the folder id UpdateRoutine returned: `grokbot://app/v1/sidebar?target=webhook-url&automation=<folder id>` and `...target=webhook-key&automation=<folder id>`. Without the folder id, send the link from the routine status on your next turn |
| You don't know a Project is connected, or how to send it a message | The memory note is missing | Run `grokbot-setup` and save the memory note again |
| `fire` reports a missing secret | The secret-request didn't finish, or used another name | Request it again under the exact name the error prints |
| `fire` refuses: the Project belongs to another bot | You don't own this Project package | Use your own, or ask the user to transfer it |
| `fire` says the fire URL doesn't look right | The secret holds something else, often the token, because the two were swapped | Request both secrets again |
| `fire` got no answer | A network error or timeout. The routine may have started anyway, and `/fire` has no idempotency | Ask the user to check the routine's runs before you send the same message again |
| The token was lost before it reached your secret prompt | The token is shown only once | Ask the user to generate a new one (that revokes the old one), then request `CLAUDE_BRIDGE_<SLUG>_TOKEN` again |
| Nothing arrives after a few minutes | Unknown | Ask the user to open the Project's main thread (or the routine run) and tell you what it says |
