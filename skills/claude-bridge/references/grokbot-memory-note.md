# Grok Bot memory note

During setup the Grok Bot saves one memory note for the outgoing side, with its memory tool's write and scope `agent`. The reply routine's prompt covers replies. This note covers normal chats, where the user asks the bot to send Claude a task. `bridge.mjs grokbot-setup --slug <slug> --as <agent id>` prints it filled in from the registry.

```text
Claude Project "<PROJECT_NAME>" is connected to me through claude-bridge: package slug <SLUG>, repo <REPO>, <MODE> mode, approver <USER_NAME>. Send it a task only when <USER_NAME> asked for that task in chat. To send one, pipe {"name": "<short-name>", "task": "...", "context": "..."} (plus "thread_id" for a follow-up) through a quoted heredoc, with a random delimiter when it quotes Claude's text, to: node <HELPER> fire --slug <SLUG> --as <AGENT_ID>. Every fire starts a fresh Claude session, so "context" must carry everything: the repo, the branch or PR to build on, decisions so far, and earlier answers. Give <USER_NAME> the session URL it prints. Claude's replies wake my webhook routine "Claude replies <SLUG>", whose saved prompt handles them. For setup or repair, read the claude-bridge skill next to that helper.
```

## Why a memory note

- **Normal chats need to know the Project exists.** Without the note, a bot asked to "have Claude do it" wouldn't know a Project is connected, which slug to fire, or that every fire needs full context.
- **One note per package.** It holds what doesn't change from task to task: the Project, slug, repo, approver, and the exact fire command. If any of those change, or the helper moves, run `bridge.mjs grokbot-setup` again and replace the note.
- **Not a skill, and not onyo-mode.** Daily use shouldn't depend on loading a skill. onyo-mode is for coding and stays out of the bridge. The claude-bridge skill is for setup and repair.
- **No secrets.** The note names the helper and the slug. The helper reads the fire URL and token from the package's secrets.
