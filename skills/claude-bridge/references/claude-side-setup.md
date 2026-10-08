# Claude-side paste prompt

A Project package is one Claude Project, its own cloud environment, and the bridge into it. Setup runs on the Grok Bot side. When the bot finishes its half, it gives the user one self-contained prompt to paste into the Claude Project's main thread. That prompt asks the main thread to write the "ONYO messages" section of the Project instructions and create the relay routine itself. The user is left with the environment clicks and one routine click: adding the API trigger and generating its token. Claude has no separate setup command.

Build the prompt with `bridge.mjs handoff --slug <slug> --as <agent id>`, which fills in this template from the registry. If you have to build it by hand, replace `{{PROJECT_INSTRUCTIONS}}` with the section from [`claude-project-instructions.md`](claude-project-instructions.md), replace `{{ROUTINE_PROMPT}}` with the relay prompt from [`claude-routine-relay-prompt.md`](claude-routine-relay-prompt.md), and fill in every `<PLACEHOLDER>`.

Send the result as one code block. Nothing in it is secret.

```text
Set up this Project so another system I use (an external assistant) can send it messages and get replies. My assistant prepared everything below. Nothing here is secret. Never ask me to paste the webhook key, the fire URL, or the routine token into this chat.

=== CLAUDE PROJECT PACKAGE HANDOFF v3 ===
project: <PROJECT_NAME>
project_slug: <SLUG>
environment: <ENVIRONMENT>
relay_routine: <RELAY_ROUTINE>
repo: <REPO>
webhook_url: <WEBHOOK_URL>
webhook_auth: a Bearer network secret for host api2.cursor.sh in the environment. I paste the key into Claude myself.
=== END HANDOFF ===

A relay routine will forward each message to this Project's main thread, and you handle it as the PROJECT INSTRUCTIONS below say. Do everything you can yourself, and give me only the clicks you can't do:

1. Add the PROJECT INSTRUCTIONS section below to this Project's instructions, replacing any older "ONYO messages", "Onyo Tasks", or "Claude bridge" section and keeping everything else. Add the handoff's repo to this Project.

2. Give me the environment clicks, each with its exact value and a direct link wherever you have one. Start with a link to this Project's page (https://claude.ai/code/project/<its id>) if you know it. This Project runs in whatever environment is selected in Project settings > Environment, which is Default unless I picked another. It doesn't get its own, and you can't create or edit environments or secrets, so these are my clicks. The environment holds the secret that reaches my assistant's webhook, so it must be a dedicated one, named after the handoff's environment. Never use Default or an environment other Projects share.
   a. Open Project settings > Environment, then the Cloud environment menu, then the gear beside the selected environment, and create the dedicated environment there. Set Network access to Limited (Custom in older apps), add api2.cursor.sh to Allowed domains, and keep package managers allowed. An organization-owned environment opens read-only, and only an organization admin can change it.
   b. In the same place, under Network secrets, choose Add secret, credential type Bearer. Name it "Webhook <SLUG>", set Allowed websites to api2.cursor.sh, keep the Authorization header with prefix Bearer, and paste the webhook key from my assistant's link as the value. Select Connect. If Network secrets isn't offered, tell me, and my assistant gives me the alternative.
   c. In Project settings > Environment, select the dedicated environment.
   Wait until I say they're done.

3. Create the relay routine yourself, as this Project's own routine: name it after the handoff's relay_routine, give it the ROUTINE PROMPT below unchanged, and run it in the environment selected in step 2 (pass that environment's id from your environment list, even if your own session runs in another one). Start a new session on each fire, give it no schedule (it only runs when fired), and give it what it needs to reach this Project's main thread. Then give me the routine's direct link: the URL your tool returns for it, or one built from its id if you know the page's URL shape. Only if you have neither, give me its id and say it's in the routine list in the left sidebar at claude.ai/code.

4. Don't add the API trigger or generate the token yourself. That click is mine: I open the relay routine from the link you gave me, click Add another trigger and choose API, tell my assistant I'm ready before I click Generate token (it's shown only once), and copy the fire URL and token straight into my assistant's masked secret prompts, never into a chat.
   Then stop. My assistant sends a test message once the token is stored.

Keep your messages short.

=== PROJECT INSTRUCTIONS ===
{{PROJECT_INSTRUCTIONS}}
=== END PROJECT INSTRUCTIONS ===

=== ROUTINE PROMPT ===
{{ROUTINE_PROMPT}}
=== END ROUTINE PROMPT ===
```

## What the main thread can and can't do

- **It can:** change the Project instructions and add a repository.
- **It creates the relay routine.** Routines the Project's main thread creates are attached to the Project automatically (verified by the user). Unverified: which connector the relay needs to reach the main thread. Earlier tests used claude-code-remote.
- **The user adds the API trigger and generates the token** on the routine's page. They open it from the direct link the main thread gives after creating it, or from the routine list in the left sidebar at claude.ai/code as the fallback (verified by the user). The Project never generates or shows the token, so it reaches only the bot's masked secret prompts.
- **Links (URL shapes).** Confirmed: a Project page is `https://claude.ai/code/project/<project id>`, and a routine's fire URL is `https://api.anthropic.com/v1/claude_code/routines/<routine id>/fire`. Unverified: the URL of a routine's page (possibly `https://claude.ai/code/routines/<routine id>`), the Project settings and environment-editor pages, and whether the routine tool returns a link. So the prompt asks the main thread for the link its tool returns, and falls back to the sidebar path.
- **It can't:** create or edit cloud environments, set network access, add network secrets, or pick the Project's environment (verified: no tool for any of them). Those stay as clicks for the user. Unverified: whether creating a new environment from the Project settings menu works the same as Add cloud environment from the cloud icon.
- **Team and Enterprise plans** have no Network secrets section. The bot tells the user about the variable alternative outside this paste (see the walkthrough), so the prompt stays one path.
- **Changing the rules later.** Ask the main thread to replace its "ONYO messages" section with the new one. The relay prompt never changes.
