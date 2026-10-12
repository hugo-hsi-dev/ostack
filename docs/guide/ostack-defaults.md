# ostack's defaults

ostack keeps pstack's text and sets its own defaults on top of it. The other guide pages and the skills come from pstack, so they describe pstack's defaults mapped to Claude Code: `sonnet xhigh` for code, `opus xhigh` for prose and judgment, the `large` budget, and `/onyo-mode` typed at the start of a task. This page lists what ostack changes. Where this page and the pstack text disagree, this page describes what the plugin does.

## onyo-mode is on for every task

ostack's hook, [`hooks/onyo-mode.sh`](../../hooks/onyo-mode.sh), runs on every message and tells Claude to follow `/onyo-mode`. You don't type `/onyo-mode`, and it doesn't fade as the chat moves on.

A line of just `onyo-mode off` turns it off:

- In a project's `CLAUDE.md` or `CLAUDE.local.md`, or in a Claude project's instructions, it turns onyo-mode off for that project.
- As a message, it turns onyo-mode off for the rest of the session. A message of just `onyo-mode on` turns it back on.

`"disableAllHooks": true` in your settings turns off every hook, this one included. Without the hook, ostack falls back to pstack's behavior, so type `/onyo-mode` at the start of each task.

## The models and efforts come from one file

[`hooks/ostack-defaults.md`](../../hooks/ostack-defaults.md) holds one line per role, in the same shape as the rule `/setup-ostack` writes. The hook prints it into every session when the session starts, resumes, clears, or compacts. If no session start printed it, the session's first message prints it.

| Roles | Model and effort |
| --- | --- |
| `feature` | `sonnet high` |
| `refactoring`, `bug-fix`, `perf-issue`, `hillclimb`, `hardest tasks`, `judgment and prose` | `opus high` |
| `how explorer`, `why investigators`, `reflect tooling`, `swarm workers` | `haiku high` |
| `how explainer`, `why synthesizer`, `reflect judgment, divergent, synthesizer` | `opus high` |
| `arena runners`, `arena cross-judge pool`, `architect runners`, `interrogate reviewers` | `opus high`, `sonnet high` |

Every role runs at `high` effort, which is the `medium` budget. The `haiku` roles need a Haiku that takes an effort level. Claude Haiku 5.5 does. An older Haiku runs at its own default effort.

For each role, Claude uses the first of these that sets it:

1. Your own rule from `/setup-ostack`, in `~/.claude/rules/ostack-models.md` or in a Claude project's instructions.
2. The line in `hooks/ostack-defaults.md`.
3. The default written in the skill.

The defaults reach every role, whether onyo-mode is on or off, because skills such as `/how` and `/swarm` pick their models with onyo-mode off too.

## Setup is optional

You don't need to run `/setup-ostack`. Run it only to change the models or the budget. Its rule wins over the shipped defaults for every role it sets, and a role it leaves out keeps its shipped default. [Set up ostack](./01-setup.md#pick-your-models) shows how it asks and where it writes the rule.

## Most skills load on their own

ostack removes `disable-model-invocation: true` from every skill except `/arena`, `/correct`, `/ketchup`, `/recall`, `/swarm`, and `/unslop`. Every other skill can load when your request, your instructions, or the files at hand match its description. Where the pstack text says a skill runs only when you type it, that holds only for those six.

## Change a default for everyone

To change a shipped default in ostack itself, edit `hooks/ostack-defaults.md` and run `sh hooks/onyo-mode.test.sh`. The test fails if the file and `/setup-ostack`'s rule shape name different roles. Don't change the defaults in the pstack text. [`sync/README.md`](../../sync/README.md) explains why. `python3 sync/sync.py check` keeps the pstack text equal to upstream plus the harness port.
