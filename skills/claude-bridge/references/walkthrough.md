# Setup walkthrough: a Project package

You set up a **Project package**: one Claude Project, the Claude cloud environment it runs in, and the bridge into it (a relay routine on the Claude side, a webhook routine on yours). Everything is named from the Project's slug.

Setup runs on the Grok Bot side. When the user asks to connect a Claude Project, do your half here. Then give the user one self-contained prompt to paste into the Project's main thread. That prompt asks the main thread to write the "ONYO messages" section of the Project instructions and to spawn a work thread that creates the relay routine, because the main thread's session has no routine-creation tool. The user does the environment clicks and one routine click: adding the API trigger and generating its token. When the user comes back, store the routine secrets and send a test message.

After setup, daily use never needs this skill:

- **Claude side:** the "ONYO messages" section of the Project instructions, which every thread in the Project reads, and the relay routine the main thread created.
- **Your side:** your webhook routine's saved prompt, which handles Claude's replies, and one memory note, which covers sending messages in normal chats. Step 3 sets up both.

Lead one step at a time, and wait for the user before you move on. Do every step you can yourself. Never ask for a secret in chat.

Throughout, `bridge.mjs` means `node <this skill>/scripts/bridge.mjs`, and `<agent id>` is your own Grok Bot agent id.

## 1. Agree on the Project

Ask two things in one message:

1. The Claude Project's name, for example "Docs Site".
2. The repository the work happens in, as `owner/repo`.

Don't ask which Claude subscription they have. Where the webhook key goes depends on what the user sees when they edit the environment (see step 5).

Derive the Project slug following [`registry-format.md`](registry-format.md). Run `bridge.mjs show`. If the Project already has a package owned by another bot, tell the user who owns it and stop.

The package's names come from the slug: the environment `<slug>-env`, the relay routine `<slug>-relay`, and your webhook routine `Claude replies <slug>`. The environment must be dedicated to this Project, because it holds the secret that reaches your webhook. Never use Default or an environment other Projects share. A Project runs in whatever environment is selected in Project settings > Environment (Default unless changed) and doesn't get its own, and Claude can't create or edit environments or secrets, so the user creates it. Pass `--environment` only if the dedicated environment already exists under another name. Read "The Project's cloud environment" in SKILL.md before you go on, because most setup failures happen there.

## 2. Claim the Project

```bash
bridge.mjs claim --slug <slug> --project "<Project name>" --owner-name "<your name>" --owner-id <agent id> \
  --repo <owner/repo>
```

Add `--environment <name>` or `--relay-routine <name>` only to override the defaults.

## 3. Set up your side: the reply routine prompt and the memory note

Print both texts, filled in from the registry:

```bash
bridge.mjs grokbot-setup --slug <slug> --as <agent id>
```

Then:

1. **Write the reply routine prompt.** Create a routine with a webhook trigger named `Claude replies <slug>`, with the printed REPLY ROUTINE PROMPT as its saved prompt, unchanged. Keep the folder id that UpdateRoutine returns, and record it with `bridge.mjs update --slug <slug> --as <agent id> --webhook-routine <folder id>`. Steps 4 and 5 build the webhook links from it.
2. **Save the memory note.** Save the printed MEMORY NOTE with your memory tool's write, scope `agent`, unchanged.

The routine prompt runs on every reply, often with nobody in the chat. It's short and names no Project: it summarizes Claude's reply, carries on with next steps that are part of what the user asked for, and takes anything new to the user first. The memory note tells you the Project is connected and how to send it a message, including the answers to Claude's questions. Neither needs a skill loaded. onyo-mode is for coding and stays out of the bridge.

If the helper moves, or the Project's name, repo, or owner changes, run `grokbot-setup` again and replace the memory note.

## 4. Get the webhook URL

Send the user the **Webhook URL** link, built from the folder id UpdateRoutine returned in step 3:

```
grokbot://app/v1/sidebar?target=webhook-url&automation=<folder id>
```

Right after you create the routine, the routine status with its ready-made field links isn't in your context yet. It only arrives on your next turn, so build the link yourself. If you don't have the folder id, end your turn after creating the routine and send the link from the routine status on your next turn. Never fall back to a generic Routines tab link (`grokbot://app/v1/sidebar?tab=routines`), because it doesn't open the field.

Ask the user to paste the URL into chat. It isn't secret, but it belongs only in the registry and the Claude-side texts, never in a repository. Record it:

```bash
bridge.mjs update --slug <slug> --as <agent id> --webhook-url <url>
```

## 5. Hand over the paste prompt

Print the complete prompt:

```bash
bridge.mjs handoff --slug <slug> --as <agent id>
```

It fills in [`claude-side-setup.md`](claude-side-setup.md) from the registry, and embeds the Project instructions section and the relay prompt. It refuses to print if a placeholder is still empty. Send the user one message with:

1. The output, as one code block, to paste into the Claude Project's main thread. If you know the Project's link (`https://claude.ai/code/project/<project id>`, or whatever the user pasted), put it right above the block.
2. The **Webhook key** link, outside the code block, built from the same folder id: `grokbot://app/v1/sidebar?target=webhook-key&automation=<folder id>`. If you don't have the folder id, use the link from your routine status, and never a generic Routines tab link. Say that the key goes straight into the Project's environment, never into either chat.
3. One line on what happens next: the main thread writes its own instructions, lists the environment clicks, and spawns a work thread to create the relay routine. The key goes under Network secrets as a Bearer secret named "Onyo Key". Then the main thread passes on the routine's direct link from that thread, where the user adds the API trigger. When the user reaches the Generate token click, they come back here first.

Network access stays at its default. The network secret's host is reachable without any allowlist change.

**If the environment has no Network secrets section,** the user tells you when they edit it. Only then, give them this alternative instead of the network-secret click:

- Allow the webhook host: in the environment's Network access, choose the level with an allowlist (Limited, or Custom in older apps), add `api2.cursor.sh` to Allowed domains, and keep package managers allowed. The variable sends the key from inside the session, so the host has to be on the allowlist.
- Add `CLAUDE_BRIDGE_WEBHOOK_KEY=<key>` under the environment's Environment variables. Anyone who uses the environment can read it, so the environment must stay personal and never be shared with the organization.
- Ask the main thread to change the reply paragraph of its "ONYO messages" section from "The environment adds the Authorization header, so don't set it yourself." to "Add the header Authorization: Bearer $CLAUDE_BRIDGE_WEBHOOK_KEY, reading the variable inside the command so the key never appears in a message or log."

## 6. Store the fire URL and token

The user opens the relay routine from the direct link the main thread gave (fallback: the routine list in the left sidebar at claude.ai/code), clicks **Add another trigger**, chooses **API**, and tells you they're ready before clicking **Generate token**. The Project never generates or shows the token. Then send two secret-requests, one per turn. The token is shown only once, so ask the user to keep that window open until both are stored, and to copy each value straight into your masked secret prompt, never into a chat:

- Secret `CLAUDE_BRIDGE_<SLUG>_FIRE_URL`, labeled "Claude relay routine fire URL for <slug>".
- Secret `CLAUDE_BRIDGE_<SLUG>_TOKEN`, labeled "Claude relay routine token for <slug>".

Confirm both names exist with `compgen -e | grep '^CLAUDE_BRIDGE_<SLUG>_'`, which lists names only, never values. If they don't show up in your shell yet, go on to the test anyway, because `fire` names any missing secret.

## 7. Test message

```bash
bridge.mjs fire --slug <slug> --as <agent id> <<'EOF'
Connectivity test for the claude-bridge setup. Make no repository changes. Reply with one line saying this test message arrived.
EOF
```

Expect one reply within a few minutes. Your reply routine handles it, so this also tests its prompt.

- **It arrives:** tell the user the Project is connected and that they can ask you to send Claude anything in any chat.
- **Nothing arrives:** ask the user to open the Project's main thread and the relay routine's latest run (from the routine link the main thread gave), and tell you what they say. Claude reports a failed POST there. A `403` with `host_not_allowed`, a `401`, or an empty variable points at the environment or its Onyo Key secret. Use the troubleshooting table in SKILL.md.

After any later change on the Claude side, send one test. Environment changes reach only new threads.

## Optional: the bot drives claude.ai

Manual setup is the default. Only offer this if the user finds the clicks tedious, and only do it after they agree. Make the offer in these words, or close to them:

> I can do the Claude-side clicks in my computer's browser after you sign in to claude.ai there yourself. Before you decide: that computer is shared by all your Grok Bots, so your Claude login would be reachable by every one of them until you sign out. Your webhook key and routine token still have to go from your own screen into Claude and into my secret prompts. I won't handle either one in the browser.

If the user agrees:

- The user signs in themselves, on your desktop. Never type their Claude credentials.
- Paste the step 5 prompt into the Project's main thread, then do the clicks it lists: creating the Project's environment and selecting it on the Project. Stop before every secret field. The main thread has a work thread create the relay routine.
- The user enters the webhook key in the "Onyo Key" Bearer secret field, or in the environment variable when there's no Network secrets section.
- Leave the routine's API trigger to the user. Never click **Add another trigger** or **Generate token** in your browser, because the token would appear on your screen. The user adds the API trigger and generates the token on their own computer, then copies the fire URL and token straight into your secret-requests.
- When you're done, suggest the user sign out of claude.ai in your browser, unless they want other bots to use it.
