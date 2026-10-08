# Setup walkthrough

Setup runs in two halves. First the user starts the bridge setup in the Grok Bot's chat. The bot does its half and produces one paste-ready handoff. Then the user pastes that handoff into the Claude Project's main thread, where the coordinator does its half and lists only the clicks the user has to make. Back in the Grok Bot chat, the bot stores the routine secrets and runs a round-trip test.

Lead one step at a time, and wait for the user before you move on. Do every step you can yourself. Never ask for a secret in chat.

Throughout, `bridge.mjs` means `node <this skill>/scripts/bridge.mjs`, and `<agent id>` is your own Grok Bot agent id.

## Part A. Grok Bot side

### A1. Agree on the bridge

Ask three things in one message:

1. The Claude Project's name, for example "Docs Site".
2. The repository the work happens in, as `owner/repo`.
3. Coordinator mode (recommended when the user keeps a main thread open in the Project) or direct mode (the fewest moving parts; see "Direct mode" in SKILL.md).

Derive the slug following [`registry-format.md`](registry-format.md). Run `bridge.mjs show`. If the slug or the Project already belongs to another bot, tell the user who owns it and stop.

### A2. Create the webhook routine and claim the slug

1. Create a routine with a webhook trigger named `Claude bridge <slug>`, with [`grokbot-reply-routine-prompt.md`](grokbot-reply-routine-prompt.md) filled in as its prompt. Wait for the save result, then read its folder id from your routine list.
2. Claim the slug:

   ```bash
   bridge.mjs claim --slug <slug> --owner-name "<your name>" --owner-id <agent id> \
     --project "<Project name>" --repo <owner/repo> --webhook-routine <folder id> --mode <coordinator|direct>
   ```

### A3. Get the webhook URL

Send the ready-made **Webhook URL** link from the routine's line in your routine status, and ask the user to paste the URL into chat. It isn't secret. It looks like `https://api2.cursor.sh/automations/webhook/<id>`.

### A4. Send the handoff

Send one copyable block for the user to paste into the Claude Project's main thread. It contains, in this order:

1. The setup prompt from [`claude-side-setup.md`](claude-side-setup.md).
2. The handoff block below, filled in.
3. The Project instructions from [`claude-project-instructions.md`](claude-project-instructions.md), between `=== PROJECT INSTRUCTIONS ===` and `=== END PROJECT INSTRUCTIONS ===`.
4. The relay prompt from [`claude-routine-relay-prompt.md`](claude-routine-relay-prompt.md), between `=== RELAY PROMPT ===` and `=== END RELAY PROMPT ===`.

Fill in every placeholder you know (`<SLUG>`, `<BOT_NAME>`, `<USER_NAME>`, `<REPO>`, `<WEBHOOK_URL>`). Leave `<DEFAULT_COORDINATOR_SESSION_ID>` for the coordinator. Nothing in the paste is secret.

```text
=== CLAUDE BRIDGE HANDOFF v1 ===
slug: <slug>
grok_bot: <BOT_NAME>
approver: <USER_NAME>
claude_project: <Project name>
repo: <owner/repo>
mode: <coordinator|direct>
webhook_url: <WEBHOOK_URL>
webhook_auth: a Bearer network secret for host api2.cursor.sh. The user pastes the key into Claude. It never appears in chat.
reply_schema: {"thread_id": "<from the payload>", "status": "received | question | progress | done | error | coordinator_online", "message": "<plain text, under 4,000 characters>", "pr_url": "<optional>", "session_url": "<optional>", "coordinator_session_id": "<optional>"}
=== END HANDOFF ===
```

In the same message, outside the block, send the ready-made **Webhook key** link. Tell the user they'll need the key for one Claude-side click, and that it goes straight into Claude, never into either chat.

In direct mode there's no coordinator to paste into. Send the handoff anyway, and have the user paste it into any Claude Code session in the Project, which then lists the clicks. The relay prompt gets replaced by the direct-mode prompt from SKILL.md.

## Part B. Claude side

The user pastes the handoff into the Project's main thread. The coordinator follows [`claude-side-setup.md`](claude-side-setup.md): it gets its own session id, fills in the relay prompt, writes or hands over the Project instructions, and lists the clicks. While this happens, stay available for questions. When the user comes back, they'll either say the token window is open, or the coordinator's `coordinator_online` reply will wake you first.

## Part C. Back on the Grok Bot side

### C1. Record the coordinator id

When the coordinator POSTs `coordinator_online`, the reply routine records the id. If that POST failed, ask the user to paste the id the coordinator showed them, and record it with `bridge.mjs update --slug <slug> --as <agent id> --coordinator <id>`. Skip this step in direct mode.

### C2. Store the fire URL and token

Once the user has generated the routine token in Claude, send two secret-requests, one per turn:

- Secret `CLAUDE_BRIDGE_<SLUG>_FIRE_URL`, labeled "Claude routine fire URL for <slug>".
- Secret `CLAUDE_BRIDGE_<SLUG>_TOKEN`, labeled "Claude routine token for <slug>".

Confirm both names exist with `env | cut -d= -f1 | grep '^CLAUDE_BRIDGE_<SLUG>_'`, without printing the values. If they don't show up in your shell yet, go on to the test anyway, because `fire` names any missing secret.

### C3. Round-trip test

```bash
bridge.mjs fire --slug <slug> --as <agent id> <<'EOF'
{"name": "setup-test", "task": "Connectivity test. Reply with status received, then status done, echoing the thread_id. Make no repository changes.", "context": "First run on this bridge."}
EOF
```

Send the user the session URL it prints. Expect `received` and then `done` with the same thread id within a few minutes (only `done` in direct mode).

- **Both arrive:** tell the user the bridge is ready and how to send it tasks.
- **`error` from the relay:** the coordinator id is wrong or the coordinator is closed. Repeat C1 with a fresh id.
- **Nothing arrives:** ask the user to open the session URL and tell you how the run ended, then use the troubleshooting table in SKILL.md.

After any later change on the Claude side, fire one test. A fire sent before the change is saved can run on the old settings.

## Optional: the bot drives claude.ai

Manual setup is the default. Only offer this if the user finds the clicks tedious, and only do it after they agree. Make the offer in these words, or close to them:

> I can do the Claude-side clicks in my computer's browser after you sign in to claude.ai there yourself. Before you decide: that computer is shared by all your Grok Bots, so your Claude login would be reachable by every one of them until you sign out. Your webhook key and routine token still have to go from your own screen into Claude and into my secret prompts. I won't handle either one in the browser.

If the user agrees:

- The user signs in themselves, on your desktop. Never type their Claude credentials.
- Do the network allowlist, the Project repository, the Project instructions, and the routine with its prompt and environment. Stop before every secret field.
- The user enters the webhook key in the Bearer secret field.
- Leave the routine's API trigger to the user. Never click **Add another trigger** or **Generate token** in your browser, because the token would appear on your screen. The user adds the API trigger and generates the token on their own computer, then copies the fire URL and token straight into your secret-requests.
- When you're done, suggest the user sign out of claude.ai in your browser, unless they want other bots to use it.
