# Claude-side setup prompt

The Grok Bot puts this prompt at the top of the handoff paste (see [`walkthrough.md`](walkthrough.md), step A4). The user pastes the whole thing into the Claude Project's main thread, the one that will act as coordinator. Send the text between the markers as written. It has no placeholders, because the handoff block that follows carries the values.

```text
Set up the Claude side of a Claude bridge in this Project. This thread will be the coordinator. If the handoff says mode: direct, this thread only helps with setup, and the routine does the work. Below this message are four parts: this setup prompt, a CLAUDE BRIDGE HANDOFF block from my Grok Bot, a PROJECT INSTRUCTIONS block, and a RELAY PROMPT block. None of them contain secrets. Never ask me to paste the webhook key or the routine token into this chat.

Do everything you can yourself, and give me only the clicks I have to make. Work in this order:

1. Run get_channel_session_id and tell me this thread's session id.

2. Fill in the RELAY PROMPT: replace <DEFAULT_COORDINATOR_SESSION_ID> with that id. If the handoff says mode: direct, skip the relay prompt, because the routine will do the work itself.

3. Project instructions: if you can edit this Project's instructions yourself, add the PROJECT INSTRUCTIONS block as its own section and keep what's already there. If you can't, give me the block as one copyable code block and tell me exactly where to paste it.

4. Check whether this Project has the handoff's repo set in its settings. Tell me if it doesn't.

5. Give me a numbered checklist of only the clicks you couldn't do, with the exact values. It should cover:
   a. In the environment this Project and the routine will use (a dedicated one is best): set network access to Custom, add the handoff's webhook host (api2.cursor.sh), and keep the default list checked.
   b. In that environment, add a network secret for host api2.cursor.sh, type Bearer. The value is the webhook key from my Grok Bot's link, without the word "Bearer". I paste it into Claude only.
   c. If step 4 found no repo: set the Project's repository to the handoff's repo.
   d. Create a routine named "Claude bridge <slug>". Its prompt is the filled-in RELAY PROMPT, as one copyable code block. Its environment is the one from step a. No repositories in coordinator mode (attach the handoff's repo in direct mode). Keep the connector that provides send_message turned on.
   e. On that routine, click Add another trigger, choose API, and click Generate token. Copy the fire URL and the token straight into my Grok Bot's secret prompts, not into this chat.

6. When I tell you steps a and b are done, POST this to the handoff's webhook_url with the single header Content-Type: application/json. Don't set Authorization yourself, because the network secret adds it:
   {"thread_id": "none", "status": "coordinator_online", "coordinator_session_id": "<your session id>", "message": "Coordinator set up for bridge <slug>."}
   Tell me whether it worked. If it failed, show me the error and your session id again, so I can give the id to my Grok Bot. This session may have started before the environment changed, and a restarted coordinator will send the same message under the Project instructions.

7. From then on, handle bridge requests under the Project instructions' "Claude bridge" section.

Keep your messages short. After the checklist, wait for me.
```

## What the coordinator can and can't do

- **It can:** read its own session id, fill in the relay prompt, check the Project's settings, POST to the webhook once the network secret exists, and possibly edit the Project instructions (this depends on its tools, so the prompt asks it to try).
- **It can't:** change environment network settings or secrets, create routines, or generate tokens. Those stay as clicks for the user, listed with exact values.
- **The coordinator_online POST does two jobs.** It tests the return path, and it delivers the coordinator id to the Grok Bot without a copy-and-paste. If it fails, the user pastes the id into the Grok Bot chat instead.
