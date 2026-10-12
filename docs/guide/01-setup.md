# Set up ostack

In this page you install the plugin, pick which models ostack uses, and run your first task. Setup is one command plus a short conversation.

## Install the plugin

ostack installs from its own plugin marketplace. In Claude Code, run:

```text
/plugin marketplace add hugo-hsi-dev/ostack
/plugin install ostack@ostack
```

Run `/plugin` to confirm the plugin loaded. Plugin skills are namespaced, so `/onyo-mode` is also `/ostack:onyo-mode`. The bare name works when no other skill shares it. This guide uses bare names. The [README](../../README.md#install) also covers local checkouts, Cursor, and skills.sh.

## In a Claude project

In a Claude project, ostack's hook, [`hooks/onyo-mode.sh`](../../hooks/onyo-mode.sh), adds the [`onyo-projects`](../../skills/onyo-projects/SKILL.md) skill, and the project chat's coordinator gets only that skill, not onyo-mode. The coordinator hands each ask to a planning thread, which routes it into research and work threads, and the threads report back to the project chat. A second hook, on `PreToolUse`, holds the coordinator to that. It refuses to start a thread whose brief doesn't open with `onyo-projects: planning thread` or `onyo-projects: unit thread`, and tells the coordinator how to retry. A third hook, on `SessionStart`, prints the session's part of `onyo-projects` in full when a project session starts, resumes, or compacts, so a fresh or compacted coordinator still has its rules. A fourth, on `Stop`, blocks the end of a coordinator turn once when that turn received a thread's report and the coordinator never posted it in the project chat. No project setup is needed.

## Pick your models

Run:

```text
/setup-ostack
```

[`/setup-ostack`](../../skills/setup-ostack/SKILL.md) detects the models you have access to and asks three questions: an effort budget, which models to use, and whether to keep the resulting role mapping (code delegates, judgment, the review panels) or change some roles. It asks every time, with multiple-choice questions, and writes nothing until you answer. It writes `~/.claude/rules/ostack-models.md`, a small rule file Claude Code loads into every session and every ostack skill reads. In a Claude project it writes the same rule into the project instructions instead, since cloud threads never see `~/.claude/rules/`. Run it in the project chat, which can edit the project instructions. Run in a thread, it hands the setup back to the project chat.

The defaults run at `xhigh` reasoning, the same as the `large` budget. `unlimited` lifts each model to its highest tier, up to `max`. `medium` and `small` lower the reasoning and spend fewer tokens.

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
- Save `/onyo-mode` for work that needs rigor. A small, obvious edit doesn't.

## Run your first task

Pick something real but small, and describe it the way you'd describe it to a colleague:

```text
/onyo-mode add a --json flag to this command. text output stays byte-identical. verify both.
```

Watch the todo list. Its first items are the matched playbook's steps copied in, the Feature playbook for this prompt. If `/onyo-mode` skips a step, the step stays in the list with `skip: <reason>`, so you can see what it chose not to do.

From here you can type normal follow-ups. `/onyo-mode` attaches the skill to one message, and it fades as the chat moves on.

Next: [Route work through `/onyo-mode`](./02-onyo-mode.md).
