# Set up pstack

In this page you install the skills, pick supported models, and run your first task.

## Install the skills

Follow the [Codex installation steps](../../README.md#install-for-codex) to link this checkout’s skills into `.agents/skills` or `~/.agents/skills`. Keep the complete checkout so relative references remain available. Restart Codex if skills do not appear, then use `/skills` or type `$poteto-mode`.

Read [the Codex compatibility map](../harness/codex.md) for model, subagent, cloud, and integration limits.

## Pick your models

Run:

```text
$setup-pstack
```

[`$setup-pstack`](../../skills/setup-pstack/SKILL.md) detects the models you have access to, asks for a reasoning budget, shows you each role (code delegates, judgment, the review panels), and asks what you want. Answer the questions. It writes `.agents/pstack-models.md`, a project-owned role map that skills explicitly read, not an automatically loaded Codex rule.

The Codex baseline inherits the parent model. Setup preserves the budget choices, but applies reasoning effort only when the host and selected model expose a supported value. It does not convert Cursor’s combined model-and-effort slugs into guessed Codex models.

You only override what you care about. A role with no line in the rule keeps the skill's default. To restore a default, delete that role's line. A rerun of `$setup-pstack` keeps any role whose model differs from the default. When a default changes, a rule written before the change still pins the old default, so delete those role lines, or delete the file, then run `$setup-pstack` again.

Set a role to `inherit-parent` or `auto` to omit a model override. Both are pstack aliases, not Codex model IDs. A panel list still runs one agent per entry. When all entries inherit one model, report that different-model-family review is unavailable. Setup also configures `swarm workers` unless a race names a verified model per arm.

## Accept the verification offers, or don't

At the end of setup, `$setup-pstack` looks for a way to prove app behavior in your project, either a `verify-*` skill or an existing harness. If it finds neither, it offers once to generate one with [`$create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.agents/skills/verify-<app>/`, a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. You can run `$create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers it in depth.

If you're new to pstack, say yes. An agent that can check its own work keeps going until the check passes. An agent that can't hands every result back to you to check by hand. Of everything in this guide, the verification skill pays off the most.

Then setup offers once to generate a formal verification skill with [`$create-formal-verification-skill`](../../skills/create-formal-verification-skill/SKILL.md), unless the project already has one. Tests check the cases someone thought to write. A formal verification skill checks one key property of your code, such as "a job never runs twice at once", in every case within a stated scope. Say yes when your code has concurrency, retries, a state machine, or a parser, where a bug is costly and tests rarely reach the case that breaks. Otherwise say no, and run it later if that changes. [Verify and ship](./06-verify-and-ship.md#prove-a-property-with-a-formal-verification-skill) covers it.

After setup, have the next workflow read `.agents/pstack-models.md`. This file is explicitly loaded by the skills; writing it does not change Codex’s global model configuration.

## Keep the cost in check

pstack spends extra tokens on subagents and review panels. That's the price of the rigor. To spend fewer:

- Rerun `$setup-pstack` and pick a smaller reasoning budget or cheaper models. A strong model in the main chat with cheaper, faster models in the code roles is a good split.
- Set a role to `auto` or `inherit-parent` so it runs on the chat's own model.
- Shorten a panel list. Each entry runs one subagent.
- Save `$poteto-mode` for work that needs rigor. A small, obvious edit doesn't.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
$poteto-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

Watch the todo list. Its first items are the matched playbook's steps copied in, the Feature playbook for this prompt. If `$poteto-mode` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. Invoke `$poteto-mode` for each new task. Cursor’s persistent Custom Mode UI has no verified equivalent in this port; do not assume a skill remains loaded after a new chat or compaction.

Next: [Route work through `$poteto-mode`](./02-poteto-mode.md).
