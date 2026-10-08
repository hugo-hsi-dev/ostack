# Setup walkthrough

Lead the user through these steps one at a time. Send one step, wait until the user says it's done, check what you can, then send the next one. Do every step marked **Bot** yourself. For every **User** step, send the exact text to paste and say where it goes. Fill in all placeholders before you send anything.

Throughout, `bridge.mjs` means `node <this skill>/scripts/bridge.mjs`, and `<agent id>` is your own Grok Bot agent id.

## Step 1. Agree on the bridge (Bot)

Ask the user three things in one message:

1. The Claude Project's name, for example "Docs Site".
2. The repository the work happens in, as `owner/repo`.
3. Coordinator mode or direct mode. Recommend coordinator mode when the Project already has a main thread the user keeps open. Recommend direct mode when the user wants the fewest moving parts (see "Direct mode" in SKILL.md).

Derive the slug from the Project name, following [`registry-format.md`](registry-format.md). Run `bridge.mjs show`. If the slug or the Project already belongs to another bot, tell the user who owns it and stop.

## Step 2. Create the webhook routine and claim the slug (Bot)

1. Create a routine with a webhook trigger named `Claude bridge <slug>`. Use [`grokbot-reply-routine-prompt.md`](grokbot-reply-routine-prompt.md) as its prompt, filled in. Wait for the save result, then read the routine's folder id from your routine list.
2. Claim the slug:

   ```bash
   bridge.mjs claim --slug <slug> --owner-name "<your name>" --owner-id <agent id> \
     --project "<Project name>" --repo <owner/repo> --webhook-routine <folder id> --mode <coordinator|direct>
   ```

## Step 3. Get the webhook URL (User, then Bot)

Send the user the ready-made **Webhook URL** link from the routine's line in your routine status, and ask them to paste the URL into chat. The URL isn't secret. It looks like `https://api2.cursor.sh/automations/webhook/<id>`. You need it to fill in the Claude prompts.

## Step 4. Set up the Claude environment (User)

Send the ready-made **Webhook key** link and this message:

> In Claude Code, open the environment this Project and its routine use. Give the bridge its own environment, because everyone who uses an environment can see its secrets.
> 1. **Network access:** choose **Custom**, add `api2.cursor.sh` to the allowed domains, and keep the default list checked.
> 2. **Network secret:** add a secret for host `api2.cursor.sh` with type **Bearer**. Copy the key from the link above and paste only the key, without the word "Bearer". Paste it into Claude only, never into this chat.
> 3. Make sure the Project's threads and the routine both use this environment.

## Step 5. Set the Project repository (User, coordinator mode)

> In the Claude Project's settings, set the repository to `<owner/repo>`.

Skip this step in direct mode. Step 8 attaches the repo to the routine instead.

## Step 6. Paste the Project instructions (User, coordinator mode)

Fill in [`claude-project-instructions.md`](claude-project-instructions.md) and send the block:

> Add this block to the Claude Project's instructions. Keep anything that's already there.
> ```text
> <filled-in block>
> ```

## Step 7. Get the coordinator session id (User, then Bot; coordinator mode)

> Open the Project's main thread, the one that should receive tasks, and send it: `Run get_channel_session_id and show me the id.` Paste the id here. It isn't secret.

Record it with `bridge.mjs update --slug <slug> --as <agent id> --coordinator <id>`.

## Step 8. Create the routine (User)

Fill in [`claude-routine-relay-prompt.md`](claude-routine-relay-prompt.md), using the id from step 7 as the default, and send:

> In Claude Code, create a new routine:
> 1. **Name:** `Claude bridge <slug>`.
> 2. **Prompt:** paste this block.
>    ```text
>    <filled-in relay prompt>
>    ```
> 3. **Environment:** the one from step 4.
> 4. **Repositories:** none. The relay doesn't need one.
> 5. **Connectors:** keep the one that provides `send_message` (claude-code-remote) turned on.
> 6. Under **Select a trigger**, click **Add another trigger**, choose **API**, and click **Generate token**. Leave that window open. The token shows only once.

In direct mode, attach `<owner/repo>` in item 4 and use the direct-mode prompt from SKILL.md in item 2.

## Step 9. Store the fire URL and token (Bot)

Send two secret-requests, one per turn, naming each secret after the registry's env names:

- Secret `CLAUDE_BRIDGE_<SLUG>_FIRE_URL`, labeled "Claude routine fire URL for <slug>".
- Secret `CLAUDE_BRIDGE_<SLUG>_TOKEN`, labeled "Claude routine token for <slug>".

Tell the user to copy both from the token window in Claude. Then confirm both names exist with `env | cut -d= -f1 | grep '^CLAUDE_BRIDGE_<SLUG>_'`, without printing the values. If the names don't show up in your shell yet, run the next step anyway, because `fire` reports a missing secret by name.

## Step 10. Round-trip test (Bot)

```bash
bridge.mjs fire --slug <slug> --as <agent id> <<'EOF'
{"name": "setup-test", "task": "Connectivity test. Reply with status received, then status done, echoing the thread_id. Make no repository changes.", "context": "First run on this bridge."}
EOF
```

Send the user the session URL it prints. Expect `received` and then `done` with the same thread id, within a few minutes. (In direct mode, expect only `done`.)

- **Both arrive:** the bridge works. Tell the user it's ready and how to send it tasks.
- **`error` from the relay:** the coordinator id is wrong or the coordinator is closed. Redo step 7.
- **Nothing arrives:** ask the user to open the session URL and tell you how the run ended, then use the troubleshooting table in SKILL.md.

Fire one test after every later change on the Claude side. A fire sent before the user saves a change can still run on the old settings.
