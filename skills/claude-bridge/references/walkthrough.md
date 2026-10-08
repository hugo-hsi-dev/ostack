# Setup walkthrough

Setup is one command, and it runs on the Grok Bot side. When the user asks to set up a Claude bridge, do your half here. Then give the user one self-contained prompt to paste into the Claude Project's main thread. That prompt carries the handoff block, tells the coordinator what to set up itself, and lists the clicks that are left. Claude has no separate setup command. When the user comes back, store the routine secrets and run a round-trip test.

Lead one step at a time, and wait for the user before you move on. Do every step you can yourself. Never ask for a secret in chat.

Throughout, `bridge.mjs` means `node <this skill>/scripts/bridge.mjs`, and `<agent id>` is your own Grok Bot agent id.

## 1. Agree on the bridge

Ask three things in one message:

1. The Claude Project's name, for example "Docs Site".
2. The repository the work happens in, as `owner/repo`.
3. Coordinator mode (recommended when the user keeps a main thread open in the Project) or direct mode (the fewest moving parts; see "Direct mode" in SKILL.md).

The claim names the Claude cloud environment `claude-bridge-<slug>` unless you pass `--environment`. Read "The Claude cloud environment" in SKILL.md before you go on, because most setup failures happen there.

Derive the slug following [`registry-format.md`](registry-format.md). Run `bridge.mjs show`. If the slug or the Project already belongs to another bot, tell the user who owns it and stop.

## 2. Create the webhook routine and claim the slug

1. Create a routine with a webhook trigger named `Claude bridge <slug>`, with [`grokbot-reply-routine-prompt.md`](grokbot-reply-routine-prompt.md) filled in as its prompt. Wait for the save result, then read its folder id from your routine list.
2. Claim the slug:

   ```bash
   bridge.mjs claim --slug <slug> --owner-name "<your name>" --owner-id <agent id> --approver "<user's name>" \
     --project "<Project name>" --repo <owner/repo> --webhook-routine <folder id> --mode <coordinator|direct>
   ```

## 3. Get the webhook URL

Send the ready-made **Webhook URL** link from the routine's line in your routine status, and ask the user to paste the URL into chat. It isn't secret. It looks like `https://api2.cursor.sh/automations/webhook/<id>`. Record it:

```bash
bridge.mjs update --slug <slug> --as <agent id> --webhook-url <url>
```

## 4. Hand over the paste prompt

Print the complete prompt:

```bash
bridge.mjs handoff --slug <slug> --as <agent id>
```

It fills in [`claude-side-setup.md`](claude-side-setup.md) from the registry, and embeds the Project instructions and the routine prompt for the bridge's mode. It refuses to print if a placeholder is still empty. Send the user one message with:

1. The output, as one code block, to paste into the Claude Project's main thread. In direct mode, any Claude Code session in the Project works.
2. The ready-made **Webhook key** link from your routine status, outside the code block. Say that the key is for one Claude-side click and goes straight into Claude, never into either chat.
3. A short note on the Claude cloud environment: the paste asks the user to create a dedicated environment named `claude-bridge-<slug>`, put the webhook key in it, and select it on both the Project and the routine. On Team and Enterprise plans the key goes in an environment variable instead of a network secret, and anyone who uses that environment can read it.
4. One line on what happens next: the Claude thread sets up what it can and lists the remaining clicks. When the user reaches the token step, they come back here.

## 5. Record the coordinator id

When the Claude thread POSTs `coordinator_online`, your reply routine records the id. If that POST failed, ask the user to paste the id the thread showed them (it isn't secret), and record it with `bridge.mjs update --slug <slug> --as <agent id> --coordinator <id>`. Skip this step in direct mode.

## 6. Store the fire URL and token

When the user has the routine's token window open, send two secret-requests, one per turn:

- Secret `CLAUDE_BRIDGE_<SLUG>_FIRE_URL`, labeled "Claude routine fire URL for <slug>".
- Secret `CLAUDE_BRIDGE_<SLUG>_TOKEN`, labeled "Claude routine token for <slug>".

Confirm both names exist with `env | cut -d= -f1 | grep '^CLAUDE_BRIDGE_<SLUG>_'`, without printing the values. If they don't show up in your shell yet, go on to the test anyway, because `fire` names any missing secret.

## 7. Round-trip test

```bash
bridge.mjs fire --slug <slug> --as <agent id> <<'EOF'
{"name": "setup-test", "task": "Connectivity test. Reply with status received, then status done, echoing the thread_id. Make no repository changes.", "context": "First run on this bridge."}
EOF
```

Send the user the session URL it prints. Expect `received` and then `done` with the same thread id within a few minutes (only `done` in direct mode).

- **Both arrive:** tell the user the bridge is ready and how to send it tasks.
- **`error` from the relay:** the coordinator id is wrong or the coordinator is closed. Repeat step 5 with a fresh id.
- **Nothing arrives:** ask the user to open the session URL and tell you how the run ended, then use the troubleshooting table in SKILL.md.

After any later change on the Claude side, fire one test. A fire sent before the change is saved can run on the old settings.

## Optional: the bot drives claude.ai

Manual setup is the default. Only offer this if the user finds the clicks tedious, and only do it after they agree. Make the offer in these words, or close to them:

> I can do the Claude-side clicks in my computer's browser after you sign in to claude.ai there yourself. Before you decide: that computer is shared by all your Grok Bots, so your Claude login would be reachable by every one of them until you sign out. Your webhook key and routine token still have to go from your own screen into Claude and into my secret prompts. I won't handle either one in the browser.

If the user agrees:

- The user signs in themselves, on your desktop. Never type their Claude credentials.
- Paste the step 4 prompt into the Project's main thread, then do the clicks it lists: the dedicated environment and its allowlist, selecting it on the Project, the Project repository and instructions if needed, and the routine with its prompt and environment. Stop before every secret field.
- The user enters the webhook key in the Bearer secret field, or in the environment variable on Team and Enterprise.
- Leave the routine's API trigger to the user. Never click **Add another trigger** or **Generate token** in your browser, because the token would appear on your screen. The user adds the API trigger and generates the token on their own computer, then copies the fire URL and token straight into your secret-requests.
- When you're done, suggest the user sign out of claude.ai in your browser, unless they want other bots to use it.
