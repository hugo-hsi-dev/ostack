# Set up ostack

In this page you install the plugin, pick which models ostack uses, and run your first task. Setup is two commands plus a short conversation.

## Install the plugin

In Claude Code, run:

```text
/plugin marketplace add hugo-hsi-dev/ostack
/plugin install ostack@ostack
```

Claude Code prefixes plugin commands, so each command in this guide takes an `ostack:` prefix, such as `/ostack:setup-ostack`.

## Pick your models

Run:

```text
/setup-ostack
```

[`/setup-ostack`](../../skills/setup-ostack/SKILL.md) detects the models you have access to, shows you each role's default model and effort (code delegates, judgment, the review panels), and asks what you want. Answer the questions. It writes `~/.claude/rules/ostack-models.md`, a small rule every ostack skill reads.

Every role ships with a default model and effort. Opus at `high` writes code and handles prose and judgment, and Opus at `xhigh` takes the hardest tasks. Haiku explores, investigates, and runs swarm workers. The review panels pair Opus at `high` with Sonnet at `xhigh`, so each panel gets a second model's view.

You only override what you care about. A role with no line in the rule keeps the skill's default. To restore a default, delete that role's line. A rerun of `/setup-ostack` keeps any role whose model differs from the default. When a default changes, a rule written before the change still pins the old default, so delete those role lines, or delete the file, then run `/setup-ostack` again.

To run a role on your chat's own model, set it to `inherit`. ostack then omits the subagent's `model` and `effort`, so the subagent inherits your parent chat model. For a panel role the value is a list, and one subagent runs per entry, so the list length sets the panel size. Setup also configures `swarm workers`, the default model for every `/swarm` worker unless a race names a model for each arm.

## Accept the verification offers, or don't

At the end of setup, `/setup-ostack` looks for a way to prove app behavior in your project, either a `verify-*` skill or an existing harness. If it finds neither, it offers once to generate one with [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.claude/skills/verify-<app>/`, a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. You can run `/create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers it in depth.

If you're new to ostack, say yes. An agent that can check its own work keeps going until the check passes. An agent that can't hands every result back to you to check by hand. Of everything in this guide, the verification skill pays off the most.

Then setup offers once to generate a formal verification skill with [`/create-formal-verification-skill`](../../skills/create-formal-verification-skill/SKILL.md), unless the project already has one. Tests check the cases someone thought to write. A formal verification skill checks one key property of your code, such as "a job never runs twice at once", in every case within a stated scope. Say yes when your code has concurrency, retries, a state machine, or a parser, where a bug is costly and tests rarely reach the case that breaks. Otherwise say no, and run it later if that changes. [Verify and ship](./06-verify-and-ship.md#prove-a-property-with-a-formal-verification-skill) covers it.

After setup, start a new chat. The model rule applies to new sessions.

## Keep the cost in check

ostack spends extra tokens on subagents and review panels. That's the price of the rigor. To spend fewer:

- Rerun `/setup-ostack` and move roles to cheaper models or lower efforts. A strong model in the main chat with cheaper, faster models in the code roles is a good split.
- Set a role to `inherit` so it runs on the chat's own model.
- Shorten a panel list. Each entry runs one subagent.
- Save `/onyo-mode` for work that needs rigor. A small, obvious edit doesn't.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
/onyo-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

Watch the todo list. Its first items are the matched playbook's steps copied in, the Feature playbook for this prompt. If `/onyo-mode` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. ostack's hook turns onyo-mode on in every session, so you don't need to type `/onyo-mode` again. A line of just `onyo-mode off` in a project's `CLAUDE.md` turns it off there.

Next: [Route work through `/onyo-mode`](./02-onyo-mode.md).
