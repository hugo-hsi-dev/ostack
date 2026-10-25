# benny

benny preserves pstack's two automation workflows for slack issue reports. one triages each report. the other reproduces confirmed bugs and may prepare a small draft fix.

this Codex port contains dormant setup and automation sources, not active automations or registered skills. the upstream Cursor `/automate` editor handoff and event runtime have no verified drop-in adapter in this port. a native subagent is not a durable automation. do not create, enable, or claim either workflow is running until a supported adapter satisfies the setup gates.

## prepare it

1. point Codex at [`FOR_AGENTS.md`](./FOR_AGENTS.md) and name the target repository.
2. let setup merge this whole directory into the target at `automations/benny/`. this is a repository-owned path, not a Codex discovery directory. preserve destination-only files and review conflicts instead of overwriting local edits.
3. make the shared pstack skills available through the target repository's `.agents/skills/`. preserve existing skills and verify discovery from a fresh session in the target repository.
4. keep user-owned configuration outside the copied pack, for example in `.benny/`. adapt [`configuration.example.yaml`](./templates/configuration.example.yaml) and [`feature-map.example.md`](./skills/reproduce-and-fix-issues/references/feature-map.example.md).
5. commit the shared skills, `automations/benny/`, and any secret-free configuration before enabling either automation.
6. prepare each automation draft for review. activation remains blocked on a verified event/runtime adapter, the original approval and readiness gates, and a harmless thread-safety test.

See [Codex skill discovery](https://developers.openai.com/codex/skills) and [automations](https://developers.openai.com/codex/app/automations). Those facilities do not establish compatibility with Cursor's editor, webhook contract, or worker isolation.
