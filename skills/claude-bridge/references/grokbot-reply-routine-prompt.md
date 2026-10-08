# Grok Bot reply routine prompt

This is the saved prompt for the Grok Bot's webhook routine, `Claude replies <slug>`, the routine Claude POSTs replies to. `bridge.mjs grokbot-setup --slug <slug> --as <agent id>` prints it. It's the same for every package.

```text
Each wake carries one Markdown message from Claude.

Summarize it for the user, keeping any links. Carry on with any next step that's part of what the user already asked for, such as reviewing a PR Claude opened or answering a question the user already settled. Anything new goes to the user first: relay Claude's open questions and send back their answers, and do nothing the user didn't ask for until they say yes.
```

## Why it's shaped this way

It runs every time Claude POSTs, often with nobody in the chat, so it says only what that wake needs:

- **No Project details.** Your memory note already says which Project is connected and how to send it a message, so the prompt doesn't repeat it.
- **Carry on with the asked-for work, and ask about anything new.** This works like an orchestrator reading an agent's report. Next steps inside what the user already asked for keep going without a round trip: reviewing the PR, answering a question the user already settled, or delivering the result. Anything the user didn't ask for, such as messaging people, merging, deleting, spending money, or starting unrelated work, waits for the user's yes.
- **Summarize.** Claude's replies are plain text written for a person. There's nothing to parse, log, or track.
- **Short answers are enough.** The answer goes to the Project's main thread, which keeps its context. Your memory note covers how to send it.

It holds no paths, names, or secrets, so it doesn't change when the helper moves or the package changes.
