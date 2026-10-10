# Set up ostack

In this page you install the plugin, see what it turns on, and run your first task. Setup is two commands. Picking other models is optional.

## Install the plugin

ostack installs from its own plugin marketplace. In Claude Code, run:

```text
/plugin marketplace add hugo-hsi-dev/ostack
/plugin install ostack@ostack
```

Run `/plugin` to confirm the plugin loaded. Plugin skills are namespaced, so `/onyo-mode` is also `/ostack:onyo-mode`. The bare name works when no other skill shares it. This guide uses bare names. The [README](../../README.md#install) also covers local checkouts, Cursor, and skills.sh.

## onyo-mode is on by default

The plugin ships a `UserPromptSubmit` hook, [`hooks/onyo-mode.sh`](../../hooks/onyo-mode.sh). On every message it tells Claude to follow `/onyo-mode`, so you never have to type it. In a Claude project it also tells the session whether it is the project chat's coordinator or a thread, and adds the [`onyo-projects`](../../skills/onyo-projects/SKILL.md) skill. The project chat then routes each ask into research and work threads, and the threads report back to it. No project setup is needed.

To opt out, write a line of just `onyo-mode off`:

- In a project's `CLAUDE.md` or `CLAUDE.local.md`, or a Claude project's instructions, it turns onyo-mode off for that project.
- As a message, it turns onyo-mode off for the rest of the session. A message of just `onyo-mode on` turns it back on.

`"disableAllHooks": true` in your settings turns off every hook, this one included.

## Pick other models, if you want

The defaults need no setup. To change them, run:

```text
/setup-ostack
```

[`/setup-ostack`](../../skills/setup-ostack/SKILL.md) detects the models you have access to and asks three questions: an effort budget, which models to use, and whether to keep the resulting role mapping (code delegates, judgment, the review panels) or change some roles. It asks every time, with multiple-choice questions, and writes nothing until you answer. It writes `~/.claude/rules/ostack-models.md`, a small rule file Claude Code loads into every session and every ostack skill reads. In a Claude project it writes the same rule into the project instructions instead, since cloud threads never see `~/.claude/rules/`. Run it in the project chat, which can edit the project instructions. Run in a thread, it hands the setup back to the project chat.

The defaults run at `high` reasoning, the same as the `medium` budget. `unlimited` and `large` lift the reasoning to `max` and `xhigh`. `small` lowers it to `medium` and spends fewer tokens.

You only override what you care about. A role with no line in the rule keeps the skill's default. To restore a default, delete that role's line. A rerun of `/setup-ostack` keeps any role whose model differs from the default. When a default changes, a rule written before the change still pins the old default, so delete those role lines, or delete the file, then run `/setup-ostack` again.

You might be wondering how to run a role on your main session's model. Set it to `inherit` and ostack omits the subagent's `model` and `effort`, so the subagent inherits them from your session. `inherit` isn't a model alias. For a panel role the value is a list, and one subagent runs per entry, so the list length sets the panel size. Setup also configures `swarm workers`, the default model for every `/swarm` worker unless a race names a model for each arm.

## Accept the verification offer, or don't

At the end of setup, `/setup-ostack` looks for a way to prove app behavior in your project, either a `verify-*` skill or an existing harness. If it finds neither, it offers once to generate one with [`/create-verification-skill`](../../skills/create-verification-skill/SKILL.md).

Say yes and it writes `.claude/skills/verify-<app>/`, a project-local skill that teaches agents to drive your app the way a user does. It proves the skill works once before handing it over. Say no and setup moves on. You can run `/create-verification-skill` yourself any time. [Verify and ship](./06-verify-and-ship.md#create-a-project-verification-skill) covers it in depth.

If you're new to ostack, say yes. An agent that can check its own work keeps going until the check passes. An agent that can't hands every result back to you to check by hand. Of everything in this guide, the verification skill pays off the most.

After setup, start a new session. The model rule applies to new sessions.

## Keep the cost in check

ostack spends extra tokens on subagents and review panels. That's the price of the rigor. To spend fewer:

- Rerun `/setup-ostack` and pick a smaller effort budget or cheaper models. A strong model in the main chat with cheaper, faster models in the code roles is a good split.
- Set a role to `inherit` so it runs on the session's own model.
- Shorten a panel list. Each entry runs one subagent.
- Send `onyo-mode off` in a session that doesn't need the rigor. A small, obvious edit doesn't.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
add a --json flag to this command. text output stays byte-identical. verify both.
```

The hook runs it through `/onyo-mode`. Watch the todo list. Its first items are the matched playbook's steps copied in, the Feature playbook for this prompt. If `/onyo-mode` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. onyo-mode stays on for each of them.

Next: [Route work through `/onyo-mode`](./02-onyo-mode.md).
