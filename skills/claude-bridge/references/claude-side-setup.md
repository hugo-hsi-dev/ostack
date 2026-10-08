# Claude-side paste prompt

Setup has one command, and it runs on the Grok Bot side. When the bot finishes its half, it gives the user one self-contained prompt to paste into the Claude Project's main thread. That prompt carries the handoff block, tells the coordinator what to set up itself, and lists the clicks that are left. Claude has no separate setup command.

Build the prompt with `bridge.mjs handoff --slug <slug>`, which fills in this template from the registry. If you have to build it by hand:

- Replace `{{PROJECT_INSTRUCTIONS}}` with the block from [`claude-project-instructions.md`](claude-project-instructions.md).
- Replace `{{ROUTINE_PROMPT}}` with the relay prompt from [`claude-routine-relay-prompt.md`](claude-routine-relay-prompt.md), or with its direct-mode prompt in direct mode.
- Fill in every `<PLACEHOLDER>` except `<DEFAULT_COORDINATOR_SESSION_ID>`, which the coordinator fills in itself.

Send the result as one code block. Nothing in it is secret.

```text
Set up the Claude side of a Claude bridge in this Project. My Grok Bot "<BOT_NAME>" prepared everything below. Nothing here is secret, and you must never ask me to paste the webhook key or the routine token into this chat.

=== CLAUDE BRIDGE HANDOFF v1 ===
slug: <SLUG>
grok_bot: <BOT_NAME>
approver: <USER_NAME>
claude_project: <PROJECT_NAME>
repo: <REPO>
mode: <MODE>
claude_environment: <ENVIRONMENT>
webhook_url: <WEBHOOK_URL>
webhook_auth: a Bearer network secret for host api2.cursor.sh in the claude_environment. I paste the key into Claude myself.
reply_schema: {"thread_id": "<from the payload>", "status": "received | question | progress | done | error | coordinator_online", "message": "<plain text, under 4,000 characters>", "pr_url": "<optional>", "session_url": "<optional>", "coordinator_session_id": "<optional>"}
=== END HANDOFF ===

In coordinator mode, this thread becomes the coordinator. In direct mode, this thread only helps with setup, and the routine does the work itself. Do everything you can yourself, then give me only the clicks you couldn't do. Work in this order:

1. Run get_channel_session_id and tell me this thread's session id. In coordinator mode, replace <DEFAULT_COORDINATOR_SESSION_ID> in the ROUTINE PROMPT below with it.

2. Coordinator mode only: add the PROJECT INSTRUCTIONS block below to this Project's instructions as its own section, keeping what's already there. If you can't change the instructions yourself, the checklist in step 4 includes pasting them.

3. Make sure this Project has the handoff's repo. In coordinator mode, add it to the Project yourself if you can. In direct mode, the routine needs it instead.

4. Give me a numbered checklist of only the clicks left, each with its exact value, and put anything I have to paste in its own code block. Explain step a in one sentence: the cloud environment holds the reply settings, and a dedicated one keeps the webhook key and allowlist away from my other sessions and routines.
   a. Create a cloud environment named after the handoff's claude_environment. Don't edit Default. At claude.ai/code, click the cloud icon above the message box, choose Cloud, then Add cloud environment. Set Network access to Custom, add api2.cursor.sh to Allowed domains, keep "Also include default list of common package managers" checked, and create it.
   b. Add the webhook key to that environment. Open it again for editing (hover, then the settings icon).
      - If a "Network secrets" section appears (Pro and Max plans): choose Add secret, credential type Bearer. Name it "Grok Bot webhook <SLUG>", set Allowed websites to api2.cursor.sh, keep the Authorization header with prefix Bearer, and paste the webhook key from my Grok Bot's link as the value. Select Connect.
      - If there's no Network secrets section (Team and Enterprise plans): add the line CLAUDE_BRIDGE_WEBHOOK_KEY=<key> under Environment variables instead, and save. Warn me that anyone who uses this environment can read that value, so the environment must stay personal and must never be shared with the organization.
   c. Coordinator mode: in Project settings > Environment, choose the claude_environment as this Project's cloud environment. Changes reach new threads, not threads already running.
   d. Coordinator mode, and only if step 2 or 3 couldn't do it: paste the PROJECT INSTRUCTIONS block into Project settings > Memory > Project instructions, or add the repo in Project settings > Environment.
   e. Create a routine named "Claude bridge <SLUG>". Its prompt is the filled-in ROUTINE PROMPT. Below the Instructions box, select the claude_environment with the cloud icon. Routines use their own environment setting, not the Project's. In coordinator mode, give it no repositories, and keep the connector that provides send_message turned on. In direct mode, attach the handoff's repo.
   f. On that routine, click Add another trigger, choose API, and click Generate token. Copy the fire URL and the token straight into my Grok Bot's secret prompts, not into this chat.
   Then stop and wait for me.

5. When I tell you a to c are done, POST this JSON to the handoff's webhook_url with the header Content-Type: application/json:
   {"thread_id": "none", "status": "coordinator_online", "coordinator_session_id": "<your session id>", "message": "Claude side set up for bridge <SLUG>."}
   With a network secret, don't set Authorization, because the secret adds it. If the CLAUDE_BRIDGE_WEBHOOK_KEY variable is set instead, add Authorization: Bearer $CLAUDE_BRIDGE_WEBHOOK_KEY, reading the variable inside the command so the key never shows up in a message.
   Tell me the result. If it failed, show me the HTTP status, any x-deny-reason header, and your session id, so I can give the id to my Grok Bot myself. This conversation may not run in the new environment, because environment changes reach new threads, and that's fine: the work threads will.

6. In coordinator mode, handle bridge requests from then on under the "Claude bridge" section of the Project instructions.

Keep your messages short.

=== PROJECT INSTRUCTIONS ===
{{PROJECT_INSTRUCTIONS}}
=== END PROJECT INSTRUCTIONS ===

=== ROUTINE PROMPT ===
{{ROUTINE_PROMPT}}
=== END ROUTINE PROMPT ===
```

## What the coordinator can and can't do

- **It can:** read its own session id and fill in the routine prompt. Claude's docs say you can ask Claude in the Project conversation to change the Project instructions or add a repository, so the prompt asks it to do both. It can also POST to the webhook if its session can reach the network.
- **It can't:** create or edit cloud environments, add network secrets, pick the Project's environment, create routines, or generate tokens. Those stay as clicks for the user, listed with exact values.
- **The coordinator_online POST does two jobs.** It tests the return path, and it delivers the coordinator id to the Grok Bot without a copy-and-paste. Claude's docs don't say which environment the Project conversation itself runs in, so the POST may fail even when everything is set up right. If it does, the user pastes the id into the Grok Bot chat, and the round-trip test proves the work threads can reply.
