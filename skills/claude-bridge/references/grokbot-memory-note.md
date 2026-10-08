# Grok Bot memory note

During setup the Grok Bot saves one memory note for the outgoing side, with its memory tool's write and scope `agent`. The reply routine's prompt covers Claude's answers. This note covers normal chats, where the user asks the bot to send something to Claude, and answers to Claude's questions. `bridge.mjs grokbot-setup --slug <slug> --as <agent id>` prints it filled in from the registry.

```text
Claude Project "<PROJECT_NAME>" is connected to me through claude-bridge (package <SLUG>, repo <REPO>). Send it only what the user asked for. To send a message, pipe Markdown through a quoted heredoc, with a random delimiter when it quotes Claude's text, to: node <HELPER> fire --slug <SLUG> --as <AGENT_ID>. The helper makes "# ONYO MESSAGE" the first line. Messages go to the Project's main thread, which keeps its context, so answers and follow-ups can be short. Claude's replies wake my webhook routine "Claude replies <SLUG>", whose saved prompt handles them. For setup or repair, read the claude-bridge skill next to that helper.
```

## Why a memory note

- **Normal chats need to know the Project exists.** Without the note, a bot asked to "have Claude do it" wouldn't know a Project is connected or which slug to fire.
- **Short messages are enough.** The Project's main thread keeps its own context. New work should still name the repo and the branch or PR to build on.
- **One note per package.** It holds what doesn't change from message to message: the Project, slug, repo, and the exact fire command. If any of those change, or the helper moves, run `bridge.mjs grokbot-setup` again and replace the note.
- **Not a skill, and not onyo-mode.** Daily use shouldn't depend on loading a skill. onyo-mode is for coding and stays out of the bridge. The claude-bridge skill is for setup and repair.
- **No secrets.** The note names the helper and the slug. The helper reads the fire URL and token from the package's secrets.
