# Setup walkthrough: a Project package

You set up a **Project package**: one Claude Project, its own Claude cloud environment, and the bridge into it (a relay routine on the Claude side, a webhook routine on yours). The environment and the bridge belong to the Project, and everything is named from the Project's slug.

Setup is one command, and it runs on the Grok Bot side. When the user asks to connect a Claude Project, do your half here. Then give the user one self-contained prompt to paste into the Project's main thread. That prompt carries the handoff block, tells the coordinator what to set up itself (including the Project's environment), and lists the clicks that are left. Claude has no separate setup command. When the user comes back, store the routine secrets and run a round-trip test.

Lead one step at a time, and wait for the user before you move on. Do every step you can yourself. Never ask for a secret in chat.

Throughout, `bridge.mjs` means `node <this skill>/scripts/bridge.mjs`, and `<agent id>` is your own Grok Bot agent id.

## 1. Agree on the Project

Ask four things in one message:

1. The Claude Project's name, for example "Docs Site".
2. The repository the work happens in, as `owner/repo`.
3. Coordinator mode (recommended when the user keeps a main thread open in the Project) or direct mode (the fewest moving parts; see "Direct mode" in SKILL.md).
4. Their Claude plan. Pro and Max keep the webhook key in a network secret. Team and Enterprise have to use an environment variable, which anyone using the environment can read.

Derive the Project slug following [`registry-format.md`](registry-format.md). Run `bridge.mjs show`. If the Project already has a package owned by another bot, tell the user who owns it and stop.

The package's names come from the slug: the environment `<slug>-env`, the relay routine `<slug>-relay`, and your webhook routine `Claude replies <slug>`. If the Project already has a dedicated environment, use its name with `--environment`. Never use Default, and never use an environment that other Projects, or routines outside this package, share. Read "The Project's cloud environment" in SKILL.md before you go on, because most setup failures happen there.

## 2. Create the webhook routine and claim the Project

1. Create a routine with a webhook trigger named `Claude replies <slug>`, with [`grokbot-reply-routine-prompt.md`](grokbot-reply-routine-prompt.md) filled in as its prompt. Wait for the save result, then read its folder id from your routine list.
2. Claim the Project:

   ```bash
   bridge.mjs claim --slug <slug> --project "<Project name>" --owner-name "<your name>" --owner-id <agent id> \
     --approver "<user's name>" --repo <owner/repo> --webhook-routine <folder id> --mode <coordinator|direct>
   ```

   Add `--environment <name>` or `--relay-routine <name>` only to override the defaults.

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

It fills in [`claude-side-setup.md`](claude-side-setup.md) from the registry, and embeds the Project instructions and the routine prompt for the package's mode. It refuses to print if a placeholder is still empty. Send the user one message with:

1. The output, as one code block, to paste into the Claude Project's main thread. In direct mode, any Claude Code session in the Project works.
2. The ready-made **Webhook key** link from your routine status, outside the code block. Say that the key is for one Claude-side click and goes straight into the Project's environment, never into either chat.
3. Two sentences on the environment: the paste asks them to create `<slug>-env` for this Project, put the webhook key in it, and select it both on the Project and on the relay routine, because routines don't inherit the Project's environment. On Team and Enterprise plans the key goes in an environment variable, and anyone using that environment can read it.
4. One line on what happens next: the Claude thread sets up what it can and lists the remaining clicks. When the user reaches the token step, they come back here.

## 5. Record the coordinator id

When the Claude thread POSTs `coordinator_online`, your reply routine records the id. If that POST failed, ask the user to paste the id the thread showed them (it isn't secret), and record it with `bridge.mjs update --slug <slug> --as <agent id> --coordinator <id>`. If the thread also showed a `403` or `401`, check the troubleshooting table in SKILL.md before you go on. Skip this step in direct mode.

## 6. Store the fire URL and token

When the user has the relay routine's API trigger window open, send two secret-requests, one per turn. The token is shown only once, so ask the user to keep that window open until both are stored:

- Secret `CLAUDE_BRIDGE_<SLUG>_FIRE_URL`, labeled "Claude relay routine fire URL for <slug>".
- Secret `CLAUDE_BRIDGE_<SLUG>_TOKEN`, labeled "Claude relay routine token for <slug>".

Confirm both names exist with `compgen -e | grep '^CLAUDE_BRIDGE_<SLUG>_'`, which lists names only, never values. If they don't show up in your shell yet, go on to the test anyway, because `fire` names any missing secret.

## 7. Round-trip test

```bash
bridge.mjs fire --slug <slug> --as <agent id> <<'EOF'
{"name": "setup-test", "task": "Connectivity test. Make no repository changes and open no pull request. Reply with status done, echoing the thread_id, with a one-line message.", "context": "First run on this Project package."}
EOF
```

Send the user the session URL it prints. Expect `received` and then `done` with the same thread id within a few minutes (only `done` in direct mode).

- **Both arrive:** tell the user the Project is connected and how to send it tasks.
- **`error` from the relay:** the coordinator id is wrong or the coordinator is closed. Repeat step 5 with a fresh id.
- **Nothing arrives:** ask the user to open the session URL and tell you how the run ended. A `403` with `host_not_allowed`, a `401`, or an empty variable points at the environment. Use the troubleshooting table in SKILL.md.

After any later change on the Claude side, fire one test. A fire sent before the change is saved can run on the old settings, and environment changes reach only new threads.

## Optional: the bot drives claude.ai

Manual setup is the default. Only offer this if the user finds the clicks tedious, and only do it after they agree. Make the offer in these words, or close to them:

> I can do the Claude-side clicks in my computer's browser after you sign in to claude.ai there yourself. Before you decide: that computer is shared by all your Grok Bots, so your Claude login would be reachable by every one of them until you sign out. Your webhook key and routine token still have to go from your own screen into Claude and into my secret prompts. I won't handle either one in the browser.

If the user agrees:

- The user signs in themselves, on your desktop. Never type their Claude credentials.
- Paste the step 4 prompt into the Project's main thread, then do the clicks it lists: the Project's environment and its allowlist, selecting it on the Project, the Project repository and instructions if needed, and the relay routine with its prompt and environment. Stop before every secret field.
- The user enters the webhook key in the Bearer secret field, or in the environment variable on Team and Enterprise.
- Leave the routine's API trigger to the user. Never click **Add another trigger** or **Generate token** in your browser, because the token would appear on your screen. The user adds the API trigger and generates the token on their own computer, then copies the fire URL and token straight into your secret-requests.
- When you're done, suggest the user sign out of claude.ai in your browser, unless they want other bots to use it.
