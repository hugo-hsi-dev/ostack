# Claude-side paste prompt

A Project package is one Claude Project, its own cloud environment, and the bridge into it. Setup has one command, and it runs on the Grok Bot side. When the bot finishes its half, it gives the user one self-contained prompt to paste into the Claude Project's main thread. That prompt carries the handoff block, asks the main thread to write the "Onyo Tasks" section of the Project instructions itself, and lists the clicks that are left. Claude has no separate setup command.

Build the prompt with `bridge.mjs handoff --slug <slug> --as <agent id>`, which fills in this template from the registry. If you have to build it by hand:

- Replace `{{PROJECT_INSTRUCTIONS}}` with the section from [`claude-project-instructions.md`](claude-project-instructions.md), or with "(Not needed in direct mode.)".
- Replace `{{ROUTINE_PROMPT}}` with the relay prompt from [`claude-routine-relay-prompt.md`](claude-routine-relay-prompt.md), or with its direct-mode prompt in direct mode.
- Fill in every `<PLACEHOLDER>`.

Send the result as one code block. Nothing in it is secret.

```text
Set up this Project as a Claude bridge package: this Project, its own cloud environment, and a relay routine that my Grok Bot "<BOT_NAME>" fires. My bot prepared everything below. Nothing here is secret, and you must never ask me to paste the webhook key or the routine token into this chat.

=== CLAUDE PROJECT PACKAGE HANDOFF v2 ===
project: <PROJECT_NAME>
project_slug: <SLUG>
environment: <ENVIRONMENT>
relay_routine: <RELAY_ROUTINE>
repo: <REPO>
mode: <MODE>
grok_bot: <BOT_NAME>
approver: <USER_NAME>
webhook_url: <WEBHOOK_URL>
webhook_auth: a Bearer network secret for host api2.cursor.sh in the environment (or the CLAUDE_BRIDGE_WEBHOOK_KEY variable on plans without network secrets). I paste the key into Claude myself.
=== END HANDOFF ===

In relay mode, the relay routine forwards each task to this Project's main thread as an Onyo Task, and you hand it to a work thread. In direct mode, this thread only helps with setup, and the routine does the work itself. Do everything you can yourself, then give me only the clicks you couldn't do. Work in this order:

1. Relay mode only: add the PROJECT INSTRUCTIONS section below to this Project's instructions yourself. If they already have an "Onyo Tasks" section, or an older "Claude bridge" section, replace it with this one. Keep everything else as it is. Then tell me in one line that it's saved. If you can't change the instructions yourself, the checklist in step 3 includes pasting them.

2. Make sure this Project has the handoff's repo. In relay mode, add it to the Project yourself if you can. In direct mode, the routine needs it instead.

3. Give me a numbered checklist of only the clicks left, each with its exact value, and put anything I have to paste in its own code block. Explain step a in one sentence: this Project's environment holds the reply settings, and giving the Project its own keeps the webhook key and allowlist away from my other Projects, sessions, and routines.
   a. Create this Project's cloud environment, named after the handoff's environment. Don't edit Default or reuse an environment other Projects use. At claude.ai/code, click the cloud icon above the message box, choose Cloud, then Add cloud environment. Set Network access to Custom, add api2.cursor.sh to Allowed domains, keep "Also include default list of common package managers" checked, and create it.
   b. Add the webhook key to that environment. Open it again for editing (hover, then the settings icon).
      - If a "Network secrets" section appears (Pro and Max plans): choose Add secret, credential type Bearer. Name it "Grok Bot webhook <SLUG>", set Allowed websites to api2.cursor.sh, keep the Authorization header with prefix Bearer, and paste the webhook key from my Grok Bot's link as the value. Select Connect.
      - If there's no Network secrets section (Team and Enterprise plans): add the line CLAUDE_BRIDGE_WEBHOOK_KEY=<key> under Environment variables instead, and save. Warn me that anyone who uses this environment can read that value, so the environment must stay personal and must never be shared with the organization.
   c. In Project settings > Environment, choose the handoff's environment as this Project's cloud environment. Changes reach new threads, not threads already running.
   d. Relay mode, and only if step 1 or 2 couldn't do it: paste the PROJECT INSTRUCTIONS section into Project settings > Memory > Project instructions, or add the repo in Project settings > Environment.
   e. Create the relay routine, named after the handoff's relay_routine. Its prompt is the ROUTINE PROMPT below. Below the Instructions box, select the Project's environment with the cloud icon. Routines use their own environment setting, not the Project's. In relay mode, keep the routine's claude-code-remote connector turned on, because that's how it reaches this Project's main thread, and give it no repositories (if the form requires one, add the handoff's repo; the prompt tells the routine not to do the task). In direct mode, attach the handoff's repo.
   f. On that routine, click Add another trigger and choose API. Before you click Generate token, tell my Grok Bot you're ready, because the token is shown only once. Keep the window open, and copy the fire URL and the token straight into my Grok Bot's secret prompts, not into this chat.
   Then stop and wait for me. My Grok Bot will send a test task through the relay once the token is stored. That test proves the whole return path.

4. In relay mode, handle every Onyo Task from then on under the "Onyo Tasks" section of the Project instructions.

Keep your messages short.

=== PROJECT INSTRUCTIONS ===
{{PROJECT_INSTRUCTIONS}}
=== END PROJECT INSTRUCTIONS ===

=== ROUTINE PROMPT ===
{{ROUTINE_PROMPT}}
=== END ROUTINE PROMPT ===
```

## What the main thread can and can't do

- **It can:** change the Project instructions and add a repository. Claude's docs say you can ask Claude in the Project's main conversation to do both, and the user confirmed that Claude edits the Project instructions on request, so the prompt asks it to write the "Onyo Tasks" section itself. Pasting by hand is only the fallback click.
- **It can't:** create or edit cloud environments, add network secrets, pick the Project's environment, create routines, or generate tokens. Those stay as clicks for the user, listed with exact values.
- **The bot's first fire tests the return path.** The paste asks the main thread for no POST of its own. Claude's docs don't say which environment the Project's main conversation runs in, so a POST from it could fail even when everything is set up right. The bot's setup test instead expects `received` and then `done`: `received` shows the task reached the main thread (or its work thread) and that a reply got out, and `done` shows a work thread in the Project's environment can reply.
- **Changing the rules later.** To update the Claude side, ask the main thread to replace its "Onyo Tasks" section with a new one. The relay prompt only changes when the webhook URL does.
