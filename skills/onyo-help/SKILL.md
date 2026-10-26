---
name: onyo-help
description: Guides users through ostack setup, $onyo-mode, and picking the skill, playbook, or principle for a task. Type $onyo-help with a question.
---

Read [Codex compatibility](../../docs/harness/codex.md) before using this workflow.

# Onyo help

Answer the user's question about ostack, hand them a prompt they can send, and link the file the answer came from. For a help question, don't start the work. The user asked how, and a ostack run spends real tokens, so let them send the prompt.

A message that asks for work, such as "use ostack to fix this bug", is not a help question. Read [`onyo-mode`](../onyo-mode/SKILL.md), do the work under it, and keep its active playbook through the task. Invoke it explicitly for new tasks.

This file maps questions to the skills and guide pages that hold the answers. Read the destination before quoting it. Link the local port file, or a verified URL for this branch, rather than an upstream page whose harness instructions differ.

## Find out what they need

Infer the need from the message and the conversation. A named situation, such as "which skill reviews a PR?", goes straight to its section. If the need is still unclear, ask one multiple-choice question with these options, then answer only the section they pick:

- Get set up
- Start a task with `$onyo-mode`
- Pick a skill for a situation
- Fix a run that went wrong
- Make ostack my own

Check the state that changes the answer, and mention it only when it does:

- Without `$CODEX_HOME/pstack-models.md`, use the selected Sol/Terra role defaults from `$setup-ostack`, with the medium budget’s high starting effort and current-host availability checks. A saved `inherit-parent` or `auto` role value remains an explicit override.
- No `verify-*` skill or other app harness in the project means agents have no scripted way to drive the app. Mention `$create-verification-skill` when the question is about proving a change works.
- No formal verification skill in the project means no property is checked past what tests reach. Mention `$create-formal-verification-skill` when the question is about a race, an invariant, or another case tests rarely hit. When one exists and the code it covers changed after the commit it records as last in sync, mention `$maintain-formal-verification-skill` if the question touches that code.

When the model rule is missing and it matters, ask whether the user wants to pick a model for each role and a reasoning budget now. It matters when the user is new, the question is about setup or cost, or the answer depends on which models run. Ask at most once per chat. If the need is also unclear, ask both questions together. Offer two choices:

- Now: give them `$setup-ostack` to type, and answer their question too.
- Later: answer their question, and add one line saying the selected Sol/Terra role defaults and medium/high starting budget apply, subject to current-host support, until they choose other models or a budget.

## Get set up

1. Install the desktop plugin following the [Codex instructions](../../README.md#install-in-the-codex-desktop-app).
2. Run [`$setup-ostack`](../setup-ostack/SKILL.md). It asks for a reasoning budget, maps a model to each role, and writes `$CODEX_HOME/pstack-models.md`, which skills explicitly read. This is not automatic Codex configuration. Then it offers once each to generate a verification skill and a formal verification skill for the project, unless the project already has one.
3. Start a real task with `$onyo-mode`, a goal, and a check that can pass or fail.

Installing changes nothing until the user invokes a skill. Only `$setup-ostack` loads from the user's words. The [README](../../README.md) and [guide page 1](../../docs/guide/01-setup.md) have the details. Offer to word their first prompt with them, per [`references/prompting.md`](references/prompting.md).

If cost is the worry, say where the tokens go and how to spend fewer. ostack spends extra tokens on subagents and review panels. Rerun `$setup-ostack` and pick a smaller budget or cheaper models. A role set to `auto` or `inherit-parent` runs on the chat's model, which saves tokens when the chat runs on a cheaper model. A shorter panel list runs fewer subagents, one for each entry. Save `$onyo-mode` for work that needs rigor.

This branch adapts ostack to Codex. Read [the compatibility map](../../docs/harness/codex.md) before promising model diversity, custom agent registration, cloud persistence, or automations. Report missing capabilities without weakening the workflow’s gates.

## Start a task with `$onyo-mode`

`$onyo-mode` matches the task to a playbook, copies the playbook's steps into the todo list, and runs the other skills as the steps need them. A step it skips stays in the list as `skip: <reason>`. A good prompt states the goal and how to tell it's done. It doesn't list skills, because a hand-written sequence tends to drop or reorder steps the playbook would keep. Read [`references/prompting.md`](references/prompting.md) before you help word one. [Guide page 2](../../docs/guide/02-onyo-mode.md) has examples.

Invoke `$onyo-mode` for each new task and preserve the active playbook during follow-ups. Cursor’s Custom Mode keybindings have no verified Codex equivalent. Mid-chat, "new task" asks the mode to match a fresh playbook. Delegates must read the [`onyo-agent` prompt](../../agents/onyo-agent.md) and the mode skill; a custom name alone does not load them.

## Pick a skill

The default answer is `$onyo-mode`, which runs most of the others when its steps need them. Name a skill directly when the user wants more or less of something than the playbook gives. Read the skill before you recommend it, and give one example prompt.

| The user wants to | Skill |
|---|---|
| Do any non-trivial task with rigor | [`$onyo-mode`](../onyo-mode/SKILL.md) |
| Know how code works now, or where new code should live | [`$how`](../how/SKILL.md) |
| Know why code is shaped this way, or where a number came from | [`$why`](../why/SKILL.md) |
| Understand a change or subsystem, explained plainly | [`$teach`](../teach/SKILL.md) |
| Know what a small diff could break outside itself | [`$blast-radius`](../blast-radius/SKILL.md) |
| Settle types and module shape before code that crosses a function boundary | [`$architect`](../architect/SKILL.md) |
| Get several attempts at one brief, merged into the best one | [`$arena`](../arena/SKILL.md) |
| Run parallel checks over slices, or race workers, as cloud agents | [`$swarm`](../swarm/SKILL.md) |
| Have different models review a diff and try to break it | [`$interrogate`](../interrogate/SKILL.md) |
| Fix a bug test-first when a cheap local test exists | [`$tdd`](../tdd/SKILL.md) |
| Apply TypeScript rules to `.ts` or `.tsx` work | [`$typescript-best-practices`](../typescript-best-practices/SKILL.md) |
| Strip comments before review, using a reviewer that didn't write them | [`$no-comments`](../no-comments/SKILL.md) |
| Clean AI tells out of prose | [`$unslop`](../unslop/SKILL.md) |
| Write docs, an RFC, a README, a PR description, or a commit message to a standard | [`$technical-writing`](../technical-writing/SKILL.md) |
| Give agents a scripted way to drive the app and prove behavior | [`$create-verification-skill`](../create-verification-skill/SKILL.md) |
| Bring a verification skill and its feature map back in line with the app | [`$maintain-verification-skill`](../maintain-verification-skill/SKILL.md) |
| Formally verify a race, invariant, or other property that tests rarely reach | [`$create-formal-verification-skill`](../create-formal-verification-skill/SKILL.md) |
| Bring a formal verification back in line after the code it covers changed, and learn whether a failure is drift or a bug | [`$maintain-formal-verification-skill`](../maintain-formal-verification-skill/SKILL.md) |
| Show a PM or designer what the user sees as a chart checked by a model, with each bug drawn as a numbered path, turn an agreed chart into a TLA+ skeleton, or audit the code against its TLA+ spec | [`$statechart`](../statechart/SKILL.md) |
| Vet a performance number before reporting or acting on it | [`$benchmark-checklist`](../benchmark-checklist/SKILL.md) |
| Run a large or cross-cutting change, or one to review after stepping away | [`$figure-it-out`](../figure-it-out/SKILL.md) |
| Keep a decision log during a run, and review it afterward | [`$show-me-your-work`](../show-me-your-work/SKILL.md) |
| Pick a model for each role and a reasoning budget | [`$setup-ostack`](../setup-ostack/SKILL.md) |
| Stop agents from repeating the same mistakes in this repo | [`$correct`](../correct/SKILL.md) |
| Find their way around ostack | `$onyo-help` |

If a skill directory next to this one is missing from the table, read its frontmatter and route by its description. The `principle-*` directories are covered under principles below.

Close calls:

- `$how` explains what the code does. `$why` explains the reasons. `$teach` runs one or both and explains the result plainly.
- `$arena` gives every worker the same brief and merges the best parts. `$swarm` splits work into slices or a race and returns one report.
- `$architect` implements right after it settles the design. Add "with checkpoint" to review the design before it writes code.
- `$interrogate` reviews the diff. `$blast-radius` looks for breakage outside the diff and proves the one fact that makes the change safe.
- Resuming one specific chat or branch is the Session pickup playbook.
- `$figure-it-out` designs one rigorous run. The Orchestrate playbook runs a program that spans days and many PRs. The Autonomous run playbook drives one task to a finish condition.

Not in ostack:

- `/deslop`, `control-cli`, and `control-ui` ship in the `cursor-team-kit` plugin.
- Cursor’s `/loop` and `create-skill` are not Codex commands. Verify a wake mechanism or skill-creation skill before relying on them.
- ostack has no `/orchestrate` skill. Orchestrate is a `$onyo-mode` playbook. If the slash menu shows `/orchestrate`, another plugin provides it.

## Playbooks and principles

Playbooks are step lists inside `$onyo-mode`, not skills, so they have no slash command. Inside `$onyo-mode`, describing the task picks one, and these phrases name one directly:

- "babysit this pr" or "check on pr 123" runs Babysit. It drives the PR to merge-ready and stops there. It doesn't merge unless the user asks to merge, land, or ship.
- "land the stack" runs Shipping.
- "take over this branch" runs Session pickup.
- "pause safely" runs Pause safely.
- "full autopilot on this queue" runs Autopilot-full. "stack them, don't ship" runs Autopilot-stack.
- "run the eval playbook" runs Eval.

The Playbooks section of [`onyo-mode`](../onyo-mode/SKILL.md) lists every playbook and when it applies. [Guide page 6](../../docs/guide/06-verify-and-ship.md) covers opening, babysitting, and landing a PR. Route explicitly to the bundled playbook instead of a host skill with a similar name.

ostack has no planning skill. Codex Plan Mode can work alongside it when the host provides it. For work that spans phases or stacked PRs, asking `$onyo-mode` for a plan runs the [Multi-phase plan playbook](../onyo-mode/playbooks/multi-phase-plan.md), which writes the plan and doesn't implement it. For a design question, the Prototype playbook or `$architect` settles it in code first.

Principles are one-rule skills that `$onyo-mode` reads and cites in its replies. The user rarely invokes one. They steer with the names instead, as in "apply prove it works. show me the real output." Typing `/principle-<name>` still loads one on demand. [Guide page 8](../../docs/guide/08-principles.md) lists them.

## Fix a run that went wrong

| Symptom | Fix |
|---|---|
| The mode stopped applying after a few turns | Invoke `$onyo-mode` for each task; persistent Custom Mode UI is not mapped in this port. |
| A question got treated as the next step of the last task | Say "new task", or say the turn doesn't need the mode. |
| A new model choice had no effect | Have the skill reread `$CODEX_HOME/pstack-models.md` and verify the chosen model is supported by the current host. |
| Runs cost more than expected | See the cost paragraph under Get set up. |
| A skill didn't load on its own | Only `$setup-ostack` loads from the user's words. The others load when the user types them or when `$onyo-mode` runs them, and it doesn't run every skill. |
| Parallel agents overwrote each other | Give each agent its own worktree, and distinct ports; native Codex subagents do not guarantee separate machines. |
| An overnight run moved but finished nothing | An autonomous run needs a check that can pass or fail, not a duration. See [guide page 7](../../docs/guide/07-overnight.md). |
| The reply claims success from a green build | Ask for the real command, flow, stored value, or profile. That's the prove-it-works principle. |

For a run that drifts, [`references/prompting.md`](references/prompting.md) has one-line steers. [Guide page 10](../../docs/guide/10-recipes-and-pitfalls.md) has more pitfalls and the recipes worth copying.

## Make ostack my own

- `$onyo-mode write a skill for <workflow>` runs the authoring playbook. The eval playbook tests a skill change blind.
- Fix a misbehaving skill in its own PR, not inside the feature work where it went wrong.

[Guide page 9](../../docs/guide/09-make-it-yours.md) covers each of these.

## Reply

Lead with the answer. Give at most one example prompt in a code block, adapted from [`references/recipes.md`](references/recipes.md) when one fits, then the link to that file. Keep it short unless the user asked for the whole map.
