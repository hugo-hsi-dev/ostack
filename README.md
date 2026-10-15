# ostack

ostack is a fork of [pstack](https://github.com/cursor/plugins/tree/main/pstack), the skill pack by
[poteto](https://x.com/poteto) (Lauren Tan), with every `poteto` swapped for `onyo`. `poteto-mode`
is `onyo-mode`, `poteto-help` is `onyo-help`, `poteto-agent` is `onyo-agent`, and `setup-pstack` is
`setup-ostack`.

All credit for the original skills, playbooks, principles, guide, and automations goes to poteto.
ostack keeps pstack's MIT license and copyright notice. See [LICENSE](./LICENSE) and
[NOTICE](./NOTICE). ostack isn't affiliated with or endorsed by poteto or Cursor.

## install

ostack targets Claude Code. pstack was built for Cursor, and ostack ports its Cursor-specific parts
(subagent tools, model slugs, Custom Modes, Bugbot, `cursor-team-kit`, cloud agents, Automations) to
their Claude Code equivalents. [Claude Code port](#claude-code-port) lists each mapping.

### Claude Code

```text
/plugin marketplace add hugo-hsi-dev/ostack
/plugin install ostack@ostack
```

Claude Code prefixes plugin skills with the plugin name, so `/onyo-mode` becomes
`/ostack:onyo-mode`. The bare name works when no other skill shares it. For a local checkout, run
`/plugin marketplace add .` from the repository root. Nothing else needs setting up.
[ostack's defaults](#ostacks-defaults) say what the plugin turns on.

### Cursor

The skills still use the Agent Skills format, so Cursor can load them. Clone the repository into
Cursor's local plugin folder, then restart Cursor or run **Developer: Reload Window**:

```bash
git clone https://github.com/hugo-hsi-dev/ostack ~/.cursor/plugins/local/ostack
```

Cursor reads the plugin from [`.cursor-plugin/plugin.json`](./.cursor-plugin/plugin.json). The skills
now name Claude Code tools, models, and features, so the subagent and model parts may behave
differently there.

### skills.sh

```bash
npx skills add hugo-hsi-dev/ostack --list
npx skills add hugo-hsi-dev/ostack --skill onyo-mode
```

skills.sh copies skills only. The `onyo-agent`, `onyo-reader`, and Comment Sicko subagents and the
onyo-mode hook ship with the Claude Code plugin install.

### which parts work where

The skills use the Agent Skills format, so every harness above can read them. The workflow skills,
including `onyo-mode`, `how`, `why`, and `teach`, spawn Claude Code subagents through the Agent tool
with a model and effort per role. The onyo-mode hook, `/loop`, `/simplify`, `/run`, and cloud
sessions are Claude Code features, so those parts may behave differently in other harnesses.
`make-bot-ui` assumes a Claude Code routine with an API trigger.

## Claude Code port

pstack's creator runs it inside Cursor. Her public posts describe three layers: Cursor cloud agents
doing the coding in threads on their own machines, Cursor Projects grouping those agents into one
conversation, and a Grok Bot in Slack acting as a manager that takes in work and hands tasks down to
the Projects. Cursor Automations and Grok Bot routines run work on a schedule or on events, such as
the benny bug-report pack. ostack keeps the first two layers on Claude, as threads and Claude
Projects, and drops the bot. What the bot did, taking in work, comes from project routines on a
schedule or trigger, or from you typing in a Project's threads:

| pstack in Cursor | ostack in Claude Code |
| --- | --- |
| `Task` tool, `subagent_type: generalPurpose`, `readonly: true` | Agent tool, `general-purpose`, and ostack's read-only `onyo-reader` agent |
| Model slugs such as `claude-opus-5-5-xhigh` and `grok-4.7-xhigh-fast` | A model and an effort per role, such as `opus xhigh` and `sonnet xhigh`. [ostack's defaults](#ostacks-defaults) replace these values |
| `~/.cursor/rules/ostack-models.mdc` | `~/.claude/rules/ostack-models.md`, written by `/setup-ostack` |
| Custom Mode for `/onyo-mode` | A `UserPromptSubmit` hook that keeps onyo-mode on unless `onyo-mode off` opts out |
| `AskQuestion` | `AskUserQuestion` |
| Cursor cloud agents and Cursor Projects | Claude Code cloud sessions (`claude --cloud`) and Claude Projects |
| Cursor Automations | Claude Code routines (schedule, API, and GitHub triggers) |
| Grok Bot in Slack, taking in work for Projects | No bot. Project routines (schedule, API, and GitHub triggers) take in work, or you type in a Project's threads |
| Bugbot | Claude Code Review, and `/code-review` locally |
| `cursor-team-kit` `/deslop`, `control-ui`, `control-cli` | Claude Code's `/simplify` and `/run` |
| Cursor's `create-skill` | Anthropic's `skill-creator` plugin |
| Cursor's built-in babysit | Claude Code's PR Auto-fix. The Babysit playbook still owns PR-status requests under `/onyo-mode` |
| Origin forge CLI | `gh`, or the GitHub MCP tools in cloud sessions |

## ostack's defaults

ostack sets its own defaults on top of pstack. pstack's text below and the skills keep pstack's
defaults, mapped to Claude Code. These replace them:

- onyo-mode is on for every task. ostack's hook tells Claude to follow `/onyo-mode` on every
  message, so you don't type it. A line of just `onyo-mode off` in a project's `CLAUDE.md` or
  `CLAUDE.local.md`, or in a Claude project's instructions, turns it off for that project. The same
  line as a message turns it off for the rest of the session, and `onyo-mode on` turns it back on.
- Models and effort come from [`hooks/ostack-defaults.md`](./hooks/ostack-defaults.md), which the
  hook prints into every session. Feature code runs on `sonnet`. Refactoring, bug fixes, perf,
  hillclimb, the hardest changes, prose, and judgment run on `opus`. The `how`, `why`, and `reflect`
  explorers and the swarm workers run on `haiku`. Every role runs at `high` effort, the `medium`
  budget.
- Setup is optional. Run `/setup-ostack` only to change the models or the budget. Its rule wins over
  the shipped defaults for every role it sets.
- Skills load on their own when your request matches their description. Only `/arena`,
  `/correct`, `/ketchup`, `/recall`, `/swarm`, and `/unslop` wait for you to type them. Where
  pstack's text says another skill runs only when you type it, that doesn't hold here.

[ostack's defaults](./docs/guide/ostack-defaults.md) in the guide explains each one and how to
change it.

## ostack in Claude Projects

In a Claude project, ostack's hook adds the [`onyo-projects`](./skills/onyo-projects/SKILL.md)
skill. The project chat hands each ask to a planning thread, which splits it into units that other
threads run, and every thread reports back to the project chat. Run `/setup-ostack` in the project
chat, not in a thread, so it writes the model rule into the project instructions.

The guide's [overnight page](./docs/guide/07-overnight.md#run-many-projects-in-parallel) comes from
pstack and says to start prompts to a project's coordinator with `/onyo-mode`. In a Claude project,
don't. The project chat doesn't load onyo-mode, and every thread follows it already.
[ostack in a Claude project](./docs/guide/ostack-projects.md) in the guide explains the layer and
its hooks.

Every file that comes from pstack is generated from upstream plus a port patch. [sync/README.md](./sync/README.md)
explains how to change one and how to sync to a new pstack version.

---

*Everything below comes from pstack's README with the names swapped. "i" is poteto.*

there's a growing sense that ai writes too much slop code. i agree. i don't want to ship like a team of twenty slop artists. throughput without quality is not a goal i aspire to. if you want to go fast, go deep first. 

**ostack is my answer.** these are the same skills i use everyday to ship high quality code at Cursor. this turns claude code into a real engineering team. the goal is not to maximize loc, in fact it's the opposite. ostack helps you write less, but higher quality code.

**ostack gives you fearless parallelism.** when you can go deep on one agent and trust it to write good, verifiable code, you can truly parallelize with confidence. start multiple agents up with `onyo-mode` and trust that they'll apply rigorous engineering principles to their work.

fork it. improve it. make it yours. PRs are welcome! 

## get started

two steps:

1. run [`/setup-ostack`](./skills/setup-ostack/SKILL.md), pick a reasoning budget, and choose which models you want.
2. use [`/onyo-mode`](./skills/onyo-mode/SKILL.md) whenever you're doing anything that requires rigor.

new here? the [ostack guide](./docs/guide/README.md) walks you through a first real task, from setup and prompting through verification and overnight runs. stuck, or unsure which skill fits? ask [`/onyo-help`](./skills/onyo-help/SKILL.md).

that's it. the other skills are situational; the mode skill uses them for you as needed. out of the box the mode splits work by model strength: code delegates (feature, refactoring, bug fix, perf, hillclimb) go to sonnet, while the hardest changes, prose, and judgment go to opus. the default panel is opus / sonnet. [`/setup-ostack`](./skills/setup-ostack/SKILL.md) changes any of it.

## usage

use [`/onyo-mode`](./skills/onyo-mode/SKILL.md) at the start of a task. it reads your request, picks from a set of playbooks, and runs the other skills as the steps need them.

pick `/onyo-mode` from the `/` menu before you type your task, so cursor attaches the skill to the message.

### just use [`/onyo-mode`](./skills/onyo-mode/SKILL.md)

this skill is the main shortcut. i use it whenever i need the agent to do rigorous engineering work. it comes with twenty-three playbooks:

```
/onyo-mode this pr has a subtle bug where the scroll drifts every 750ms even when idle. repro
first, then fix and verify.
```

```
/onyo-mode i'm going to bed. land the stack even if ci flakes. i want everything merged by
morning.
```

<details>
<summary>the twenty-three playbooks</summary>

| playbook | for |
|---|---|
| [investigation](./skills/onyo-mode/playbooks/investigation.md) | a read-only question. how does x work, why was y built this way, are we sure. |
| [bug fix](./skills/onyo-mode/playbooks/bug-fix.md) | reproduce a defect, root-cause it, and fix with runtime evidence. |
| [perf](./skills/onyo-mode/playbooks/perf-issue.md) | trace a measured slowness and improve it against a baseline. |
| [hillclimb](./skills/onyo-mode/playbooks/hillclimb.md) | sustained, scientific improvement of one metric against a target, looping hypotheses with before/after measurement and one commit per accepted win. |
| [runtime forensics](./skills/onyo-mode/playbooks/runtime-forensics.md) | diagnose a live symptom (leak, idle-cpu spin, glitch) from instrumentation. |
| [trace forensics](./skills/onyo-mode/playbooks/trace-forensics.md) | diagnose a captured profiling artifact (cpuprofile, trace, spindump, heap snapshot). |
| [feature](./skills/onyo-mode/playbooks/feature.md) | new or changed behavior, built from a named data shape. |
| [refactoring](./skills/onyo-mode/playbooks/refactoring.md) | a behavior-preserving change to structure or shape. |
| [prototype](./skills/onyo-mode/playbooks/prototype.md) | a throwaway sketch to make a design or behavioral decision cheaply, or to settle an empirical fork by observing it. |
| [visual parity](./skills/onyo-mode/playbooks/visual-parity.md) | pixel-exact ui equivalence between two implementations. |
| [authoring a skill](./skills/onyo-mode/playbooks/authoring-a-skill.md) | writing or editing a SKILL.md. |
| [eval](./skills/onyo-mode/playbooks/eval.md) | test how a skill or prompt change affects agent behavior, blinded. |
| [babysit](./skills/onyo-mode/playbooks/babysit.md) | drive a pr or a stack to merge-ready: conflicts, review threads, ci. |
| [shipping](./skills/onyo-mode/playbooks/shipping.md) | independently verify a green stack, then land the contiguous verified run bottom-up through github (`gh`, or the GitHub MCP tools in cloud sessions). |
| [autonomous run](./skills/onyo-mode/playbooks/autonomous-run.md) | drive a long task to completion without stopping. |
| [orchestrate](./skills/onyo-mode/playbooks/orchestrate.md) | a standing project handed to one coordinator chat: multi-day, many stacked prs, fleets of subagents. |
| [autopilot-full](./skills/onyo-mode/playbooks/autopilot-full.md) | run independent prs to merged with one owner per pr and a root swarm verdict on each round, from the code-ready head on. |
| [autopilot-stack](./skills/onyo-mode/playbooks/autopilot-stack.md) | build and verify one linear base-branch stack for the operator to review and land. |
| [session pickup](./skills/onyo-mode/playbooks/session-pickup.md) | resume or take over a prior agent's in-flight work. |
| [pause safely](./skills/onyo-mode/playbooks/pause-safely.md) | suspend in-flight work cleanly so it can be resumed later. |
| [multi-phase plan](./skills/onyo-mode/playbooks/multi-phase-plan.md) | work that spans phases or stacked PRs. |
| [worktree cleanup](./skills/onyo-mode/playbooks/worktree-cleanup.md) | reclaim disk by pruning merged or abandoned worktrees and stale ios simulators, safety-gated. |
| [opening a pr](./skills/onyo-mode/playbooks/opening-a-pr.md) | open a ready pr from small ordered commits with a conventional commits title and a briefing-style body. invoked at the end of every other playbook. |

</details>



when invoked it:

1. matches your task to a [playbook](./skills/onyo-mode/playbooks/) and opens a todo list whose first items are its steps, copied in verbatim.
2. routes to the other skills as the steps fire.
3. writes unslopped replies framed for the consumer and the maintainer.

the full rules and playbooks live in [`skills/onyo-mode/SKILL.md`](./skills/onyo-mode/SKILL.md).

ostack's [hook](./hooks/onyo-mode.sh) keeps [`/onyo-mode`](./skills/onyo-mode/SKILL.md) on. on every message it tells claude to follow the skill, unless a line of just `onyo-mode off` in a message, a `CLAUDE.md`, or a `CLAUDE.local.md` opts out. `"disableAllHooks": true` in your settings turns off every hook, this one included.

[`/onyo-mode`](./skills/onyo-mode/SKILL.md) works extremely well with claude code's `/loop` command. you can make claude work for many hours without sacrificing rigor.

## skills

[`/onyo-mode`](./skills/onyo-mode/SKILL.md) runs most of these for you when a step needs them (`how`, `why`, `architect`, `arena`, `swarm`, `interrogate`, `unslop`, `no-comments`, `technical-writing`, `tdd`, and the principles). the table below is for when you want one directly:

```
/how do we cancel runs? do we have an n+1 when we look up every run to cancel?
```

```
/interrogate review this pr.
```

<details>
<summary>all skills</summary>

| skill | use it when |
|---|---|
| [`/onyo-mode`](./skills/onyo-mode/SKILL.md) | default entry point for any non-trivial task. |
| [`/onyo-help`](./skills/onyo-help/SKILL.md) | you're new to ostack, or unsure which skill, playbook, or principle fits. finds out what you're trying to do, answers that part, and hands you a prompt to type. runs only when you type `/onyo-help`. |
| [`/in-your-own-words`](./skills/in-your-own-words/SKILL.md) | you want the agent to play back your goal and the problem before it starts. runs only when you type `/in-your-own-words`. |
| [`/sharpen`](./skills/sharpen/SKILL.md) | you want a task approached the way a top expert would, aimed at what you're really after, without overspecifying it or deciding your choices for you. |
| [`/how`](./skills/how/SKILL.md) | you want a walkthrough of how a subsystem works. |
| [`/why`](./skills/why/SKILL.md) | you want to know why something was built this way. discovers available MCPs at run time and queries each evidence category in parallel (source control, issue tracker, long-form docs, real-time chat, infra observability, error tracking, analytics warehouse). |
| [`/recall`](./skills/recall/SKILL.md) | you're starting or resuming work and want your recent context on a topic rebuilt from your own chat history and the shared record, handed back as a tight current-state brief. |
| [`/ketchup`](./skills/ketchup/SKILL.md) | you want what changed in this chat since your last message, in a few plain sentences and small visuals, with just enough context on each action item to make the call. |
| [`/blast-radius`](./skills/blast-radius/SKILL.md) | you have a small-looking change and want to know what else it could break, with the one fact it's safe because of proven by running code, not asserted. |
| [`/architect`](./skills/architect/SKILL.md) | you're about to write code that crosses a function boundary and want the caller's usage, types, and module shape settled first. |
| [`/arena`](./skills/arena/SKILL.md) | you want N parallel attempts at the same thing, then to grab the best parts of each. |
| [`/swarm`](./skills/swarm/SKILL.md) | you want N parallel workers across different slices or races, then one aggregated report. |
| [`/interrogate`](./skills/interrogate/SKILL.md) | you have a diff and want different models to try to break it, including a strict code-quality lens. |
| [`/automate-me`](./skills/automate-me/SKILL.md) | you want your own `-mode` skill, drafted from how you've actually worked. |
| [`/make-bot-ui`](./skills/make-bot-ui/SKILL.md) | you want a page or dashboard whose buttons wake a Claude Code routine over its API trigger, including the token handoff and Tailscale. |
| [`/setup-ostack`](./skills/setup-ostack/SKILL.md) | you want to pick which models ostack uses per role. detects your models and writes a config rule. |
| [`/reflect`](./skills/reflect/SKILL.md) | a long task landed and you want the recipe captured as a skill edit. |
| [`/correct`](./skills/correct/SKILL.md) | you keep correcting agents for the same mistakes. mines history for mistake classes, fixes each at the highest level that works (architecture, then types, lint, and ci, then tests, with docs last), and keeps a table pairing each rule with what enforces it. |
| [`/teach`](./skills/teach/SKILL.md) | you want to actually understand a change or subsystem, not just have it summarized. runs how + why and weaves one plain explanation, built up diagram by diagram. |
| [`/tdd`](./skills/tdd/SKILL.md) | you're fixing a bug and there's a cheap local test path. write the failing test first, then the fix. |
| [`/benchmark-checklist`](./skills/benchmark-checklist/SKILL.md) | you ran a benchmark or measured a speedup or regression. vets the number (limiter, tuning, errors, repeat runs, end-to-end relevance) before you report or act on it. |
| [`/no-comments`](./skills/no-comments/SKILL.md) | strip comments before review; spawns Comment Sicko, fixes accepted findings, offers encodings for claimed constraints. |
| [`/typescript-best-practices`](./skills/typescript-best-practices/SKILL.md) | you're reading or editing typescript. grounds the type-system-discipline principle in syntax. |
| [`/figure-it-out`](./skills/figure-it-out/SKILL.md) | no bundled playbook fits. designs a rigorous, auditable playbook for the task. |
| [`/show-me-your-work`](./skills/show-me-your-work/SKILL.md) | you want a reviewable decision trail. logs decisions to a tsv you can commit. |
| [`/create-verification-skill`](./skills/create-verification-skill/SKILL.md) | your project has no scripted way to prove app behavior. generates a project-local verify skill with a feature map, for any language or platform. |
| [`/maintain-verification-skill`](./skills/maintain-verification-skill/SKILL.md) | your verify skill's feature map has drifted from the app. source wave + one live pass, at most one PR of proven corrections. |
| [`/unslop`](./skills/unslop/SKILL.md) | you're cleaning up writing. removes AI tells. |
| [`/bro`](./skills/bro/SKILL.md) | you want the last message restated in plain human language, no jargon. |
| [`/technical-writing`](./skills/technical-writing/SKILL.md) | layered doc standard (Diátaxis + Google developer style + STE + Global English) for docs, RFCs, readmes, PR descriptions, commit messages. |

</details>



### examples

mostly i type [`/onyo-mode`](./skills/onyo-mode/SKILL.md) at the start of a task and let it route to a playbook. the other skills fire as the steps need them. a few i reach for directly.


<details>
<summary>all the examples</summary>

```
bug fix:           /onyo-mode this pr has a subtle bug where the scroll drifts every 750ms even
                   when idle. repro first, then fix and verify.
perf:              /onyo-mode a big list takes a second or two to load even though we virtualize.
                   run a cpu trace and tell me why.
feature:           /onyo-mode build a small feature behind a feature flag. verify it really works.
prototype:         /onyo-mode build two prototypes of the markdown renderer so we can compare.
                   spawn an agent for each.
multi-phase:       /onyo-mode open source these skills as a plugin. nothing internal leaks, work
                   in a temp dir, show me the dependency graph first.
overnight run:     /onyo-mode i'm going to bed. land the stack even if ci flakes. i want
                   everything merged by morning.
babysit:           /onyo-mode check on pr 123. anything outstanding?
visual parity:     /onyo-mode the row spacing is too tall when this flag is on. the second image
                   is correct. repro and fix until it matches.
figure it out:     /onyo-mode i'm stepping away. migrate every caller from the synchronous store
                   to the new async one, keeping behavior identical. i want to trust it was done
                   right when i'm back.
how:               /how do we cancel runs? do we have an n+1 when we look up every run to cancel?
why:               /why is this feature flag not on yet?
architect:         design this instrumentation to be high signal with no false positives. /architect
                   this first.
arena:             /arena take my prompt to the arena verbatim. i want to compare their proposals
                   with yours.
swarm:             /swarm check every package under packages/ against its check.sh. one worker per
                   package. one report.
interrogate:       /interrogate review this pr.
tdd:               /tdd implement
unslop:            can we unslop and tighten the new changes?
reflect:           /reflect that took too long. capture what we learned so the next run doesn't
                   repeat it.
correct:           /correct
show-me-your-work: /show-me-your-work keep a decision trail i can review when i'm back.
automate-me:       /automate-me
help:              /onyo-help which skill should i use to review this branch?
```

</details>

## the `onyo-agent` and Comment Sicko subagents

[`/onyo-mode`](./skills/onyo-mode/SKILL.md) runs in the chat that receives it. that chat owns the playbook, the todo list, and every subagent spawn.

ostack also ships [`subagent_type: "onyo-agent"`](./agents/onyo-agent.md) (`ostack:onyo-agent` in a plugin install) as the wrapper for delegates spawned during a run. it reads `onyo-mode` in full, including its inline principles index, before doing any work. substituting `general-purpose` skips that read and drifts. do not spawn `onyo-agent` to run the playbook itself.

[`/onyo-mode`](./skills/onyo-mode/SKILL.md) and [`subagent_type: "onyo-agent"`](./agents/onyo-agent.md) route through the same wrapper.

ostack also ships [Comment Sicko](./agents/comment-sicko.md), a read-only comment reviewer available as `subagent_type: "comment-sicko"` (`ostack:comment-sicko` in a plugin install). usually invoke it through [`/no-comments`](./skills/no-comments/SKILL.md), not directly.

## principles

twenty-four short skills, one principle each. `onyo-mode` indexes them inline and reads that index at task start. the standalone files are there so other skills can reference a principle by name, and so the index can point at the full rule for each.

<details>
<summary>all twenty-four principles</summary>

| principle | group | rule |
|---|---|---|
| [laziness-protocol](./skills/principle-laziness-protocol/SKILL.md) | core | Bias toward deletion and the smallest change that solves the problem. |
| [foundational-thinking](./skills/principle-foundational-thinking/SKILL.md) | core | Apply before writing logic: choosing core types and data structures, sequencing scaffold-vs-feature work, asking what concurrent actors share. Get the data structures right so downstream code becomes obvious. |
| [redesign-from-first-principles](./skills/principle-redesign-from-first-principles/SKILL.md) | core | Redesign as if the requirement had been a foundational assumption from day one, instead of bolting it on. |
| [attack-the-premise](./skills/principle-attack-the-premise/SKILL.md) | core | Apply when two or more fixes that share one premise have failed the same gate. Write the premise down and test it directly before you write another fix that assumes it. |
| [subtract-before-you-add](./skills/principle-subtract-before-you-add/SKILL.md) | core | Remove dead weight, redundant validators, and stub references first, then build on the simpler base. |
| [minimize-reader-load](./skills/principle-minimize-reader-load/SKILL.md) | core | Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope. |
| [outcome-oriented-execution](./skills/principle-outcome-oriented-execution/SKILL.md) | core | Apply during planned rewrites and migrations with explicit phase boundaries. Converge on the target architecture; don't preserve smooth intermediate states with throwaway compatibility code. |
| [experience-first](./skills/principle-experience-first/SKILL.md) | core | Choose user delight over implementation convenience; ship fewer polished features over more rough ones. |
| [exhaust-the-design-space](./skills/principle-exhaust-the-design-space/SKILL.md) | core | Build 2-3 competing prototypes and compare side by side before committing. |
| [build-the-lever](./skills/principle-build-the-lever/SKILL.md) | core | Apply to any non-trivial work, not just bulk work: edits, migrations, analyses, checks. Build the tool that does it or proves it (codemod, script, generator, or a skill your subagents follow) instead of working by hand. The tool is the artifact a reviewer can rerun. |
| [model-the-domain](./skills/principle-model-the-domain/SKILL.md) | architecture | Encode the domain in a structure instead of scattered conditionals. |
| [boundary-discipline](./skills/principle-boundary-discipline/SKILL.md) | architecture | Concentrate guards at system boundaries (CLI, config, network, external APIs); trust internal types and keep business logic in pure functions. |
| [type-system-discipline](./skills/principle-type-system-discipline/SKILL.md) | architecture | Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, refuse to lie to the compiler, exhaust variants, derive from authoritative schemas. |
| [make-operations-idempotent](./skills/principle-make-operations-idempotent/SKILL.md) | architecture | Converge to the same end state regardless of partial prior runs. |
| [migrate-callers-then-delete-legacy-apis](./skills/principle-migrate-callers-then-delete-legacy-apis/SKILL.md) | architecture | Migrate callers and delete the old API in the same wave instead of preserving compatibility layers. |
| [separate-before-serializing-shared-state](./skills/principle-separate-before-serializing-shared-state/SKILL.md) | architecture | Eliminate the sharing first; serialize structurally only when one shared writer is a real invariant. |
| [prove-it-works](./skills/principle-prove-it-works/SKILL.md) | verification | Apply after completing a task, before declaring done. Verify against the real artifact (run the feature, read the actual value, inspect the diff), not a proxy, self-report, or 'it compiles.'. |
| [fix-root-causes](./skills/principle-fix-root-causes/SKILL.md) | verification | Trace each symptom back to the first place the system went wrong and fix it there. A guard is a fix only when the state it handles is legitimate. |
| [sequence-verifiable-units](./skills/principle-sequence-verifiable-units/SKILL.md) | verification | Apply to multi-step work (sweeps, migrations, runs of similar edits) and to how you stack commits and PRs. Break work into small units that each end in a verifiable state, check each before the next, and order delivery so the sequence proves itself to a reviewer. |
| [test-behavior-not-implementation](./skills/principle-test-behavior-not-implementation/SKILL.md) | verification | Apply when you write, change, or keep a test. Assert what the code's users can observe, so the test fails when that behavior breaks and keeps passing when only the internals change. |
| [explain-the-number](./skills/principle-explain-the-number/SKILL.md) | verification | Apply before you trust, report, or act on a number you measured: a speedup, a regression, a throughput, a latency, or an eval result. Find what limits it, and rule out that it measured something other than the work you think. |
| [guard-the-context-window](./skills/principle-guard-the-context-window/SKILL.md) | delegation | Route bulk to subagents; keep summaries in the main thread, not raw payloads. |
| [never-block-on-the-human](./skills/principle-never-block-on-the-human/SKILL.md) | delegation | Proceed, present the result, let the human course-correct after the fact; reserve confirmation for irreversible actions. |
| [encode-lessons-in-structure](./skills/principle-encode-lessons-in-structure/SKILL.md) | meta | Encode the rule as a lint, metadata flag, runtime check, or script instead of more text. |

</details>

## not shipped here

a few things `onyo-mode` references but doesn't bundle:

- `/simplify` (cleanup before commit) and `/run` (drive the app, CLI, or TUI) are claude code built-ins.
- `skill-creator` is anthropic's skill-authoring plugin. install it with `/plugin install skill-creator@claude-plugins-official`.
- claude code also ships pr auto-fix (`/autofix-pr`). inside `onyo-mode`, the [babysit playbook](./skills/onyo-mode/playbooks/babysit.md) supersedes it for pr-status requests.

## why are there no planning skills?

claude code already has a great plan mode which works great with ostack. but personally, i don't believe in planning. the best spec is code. if you do want to make a plan, [`/onyo-mode`](./skills/onyo-mode/SKILL.md) covers it, but it's not a default. 

## make it yours

`onyo-mode` is my style. you may not want exactly that.

type [`/automate-me`](./skills/automate-me/SKILL.md). it mines your recent transcripts, drafts a `<your-name>-mode` skill from how you've actually worked, and routes through ostack underneath. you keep ostack as the base and end up with your own routing skill alongside `onyo-mode`.

models are configurable too. type [`/setup-ostack`](./skills/setup-ostack/SKILL.md). it detects the models you have access to and writes a small always-loaded rule at `~/.claude/rules/ostack-models.md` mapping each role (code, judgment, the review panels) to a model and an effort. every skill reads it and falls back to sensible defaults when the rule is absent, so you override only what you want.

when a default changes, a rule written before the change still pins the old default. delete those role lines, or delete the file, then run `/setup-ostack` again. a rerun keeps any role whose model differs from the default.

## routines

ostack also ships a dormant [benny routine pack](./automations/benny/). benny triages slack issue reports, then reproduces and fixes confirmed bugs with real ui evidence. its files are not registered as slash skills.

to set it up, point claude code at [`FOR_AGENTS.md`](./automations/benny/FOR_AGENTS.md). setup copies the pack into the target repository at `.claude/automations/benny/`, enables ostack there for shared skills, keeps user configuration outside the copied pack, and helps you create the two claude code routines.

## license

MIT. pstack is Copyright (c) 2026 Lauren Tan. ostack's changes are Copyright (c) 2026 Hugo Hsi. See [LICENSE](./LICENSE) and [NOTICE](./NOTICE).
