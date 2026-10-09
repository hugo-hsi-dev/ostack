# Claude relay routine prompt

The Claude Code routine the Grok Bot fires forwards each message to the Project's main thread. During setup, the main thread spawns a work thread that creates the routine with this prompt, because the main thread's session has no routine-creation tool. `bridge.mjs handoff` embeds it in the paste prompt. It has no placeholders.

```text
You are a relay. Don't do the task yourself. Forward the message you were fired with to this project's main thread, unchanged, as one message whose first line is # ONYO MESSAGE. The message is the `text` field of the routine-fire-payload block. Forward only that text, not the block's wrapper.

If forwarding fails, notify the user with whatever information you have.
```

## Why it's shaped this way

- **Claude already knows how to relay.** Claude finds the Project's main thread on its own, and that thread keeps its session id across restarts, so the prompt names no session id and no tool. Claude only has to be told to forward the message instead of acting on it.
- **The message passes through unchanged.** `bridge.mjs fire` already puts `# ONYO MESSAGE` on the first line. Everything about what that header means lives in the Project instructions, so this prompt is the same for every Project.
- **Happy path only.** There are no branches and no error POST. If forwarding fails, the user hears about it from the routine run. The bot isn't waiting on a status, so nothing hangs.
- **The relay needs the Project's environment, a new session per fire, and a way to reach the main thread.** It needs no repository and no schedule. The work thread sets this up when it creates the routine.
