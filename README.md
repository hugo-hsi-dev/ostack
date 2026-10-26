# ostack

This first-stage Codex port starts from Lauren Tan’s pstack at upstream commit `99b609a72323b70204eab407c622f436e858e112` (version `0.15.32`). See [NOTICE](./NOTICE) and [the Codex compatibility map](./docs/harness/codex.md). The retained workflows remain pstack’s; [the versioned product selection](./sync/omissions.json) records the approved omitted skills and automation pack. Model diversity, durable cloud orchestration, and external integrations require verified host support; this is not a runtime-complete port.

ostack adapts the workflows developed by Lauren Tan ([poteto](https://x.com/poteto)) in pstack. The goal is to write less, higher-quality code, with deliberate parallel work and evidence that the result works.

Start work with `onyo-mode`. It routes the task, delegates where useful, and keeps verification and approval gates visible.

**Model diversity remains part of the inherited workflow.** Codex model availability differs by host and account. Use only verified model choices. When a different model family is unavailable, report the missing diversity rather than treating two inherited-model agents as equivalent evidence.

fork it. improve it. make it yours. PRs are welcome!

## install in the Codex desktop app

Use this repository’s `codex` branch as the **ostack** marketplace source; `main` is the Claude version. Once the marketplace is available in your desktop app:

1. Open **Plugins Directory** in the desktop app and choose the **ostack** marketplace source.
2. Open **ostack** and select **Install**.
3. Start a chat with the installed plugin selected, then run `$setup-ostack` or `$onyo-mode`.

The repository-root catalog is `.agents/plugins/marketplace.json`. Its `ostack` entry points to `./`, where `.codex-plugin/plugin.json` declares the skills. The app manages the installed copy, keeping the skills, references, scripts, docs, and agent prompts together. See the [official marketplace documentation](https://developers.openai.com/plugins/build/plugins#marketplace-metadata).

Read [the Codex compatibility map](./docs/harness/codex.md) before running workflows. The package keeps sibling files together so skill links and scripts resolve. The agent Markdown prompts are supporting resources; plugin installation is not evidence that the host registered custom-agent definitions. Where role selection is unavailable, the coordinator includes the supplied prompt in the delegate's brief. The files in `docs/upstream/` are historical metadata, not installation manifests. This plugin installs no Claude hooks. Orchestrate's Spaces records and cloud execution remain separately verified capabilities.

## get started

two steps:

1. run [`$setup-ostack`](./skills/setup-ostack/SKILL.md), pick a reasoning budget, and choose which models you want.
2. use [`$onyo-mode`](./skills/onyo-mode/SKILL.md) whenever you're doing anything that requires rigor.

new here? the [ostack guide](./docs/guide/README.md) walks you through a first real task, from setup and prompting through verification and overnight runs. stuck, or unsure which skill fits? ask [`$onyo-help`](./skills/onyo-help/SKILL.md).

that's it. the other skills are situational, and the mode skill uses them as needed. Defaults map upstream Opus 5.5 roles to `gpt-6.1-sol` and Grok 4.7 roles to `gpt-6.1-terra`, preserving the original role split and panel sizes. [`$setup-ostack`](./skills/setup-ostack/SKILL.md) checks current-host availability and uses your budget to select reasoning effort. `inherit-parent` and `auto` remain opt-in choices; distinct Sol/Terra variants alone do not establish cross-family diversity.

## usage

use [`$onyo-mode`](./skills/onyo-mode/SKILL.md) at the start of a task. it reads your request, picks from a set of playbooks, and runs the other skills as the steps need them.

Type `$onyo-mode` before the task, or select it with `/skills`, so Codex loads the skill.

### just use [`$onyo-mode`](./skills/onyo-mode/SKILL.md)

this skill is the main shortcut. i use it whenever i need the agent to do rigorous engineering work. it comes with twenty-three playbooks:

```
$onyo-mode this pr has a subtle bug where the scroll drifts every 750ms even when idle. repro
first, then fix and verify.
```

```
$onyo-mode i'm going to bed. land the stack even if ci flakes. i want everything merged by
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
| [shipping](./skills/onyo-mode/playbooks/shipping.md) | independently verify a green stack, then land the contiguous verified run bottom-up through github by default or origin when available. |
| [autonomous run](./skills/onyo-mode/playbooks/autonomous-run.md) | drive a long task to completion without stopping. |
| [orchestrate](./skills/onyo-mode/playbooks/orchestrate.md) | a standing project handed to one coordinator chat: multi-day, many stacked prs, fleets of subagents. |
| [autopilot-full](./skills/onyo-mode/playbooks/autopilot-full.md) | run independent prs to merged with one owner per pr. a swarm verifies each code-ready head, and every later change to the patch gets a fresh check. |
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

Invoke `$onyo-mode` for each new task and carry the active playbook into follow-up turns. There is no verified Codex equivalent of Cursor’s Option+Enter Custom Mode persistence in this port.

Long runs retain the [Autonomous run playbook](./skills/onyo-mode/playbooks/autonomous-run.md), its finish predicate, gates, and decision trail. Cursor’s `/loop` has no verified drop-in mapping here. Native subagents do not promise wake-ups or survival after the session ends; record the gap before promising unattended execution.

## skills

[`$onyo-mode`](./skills/onyo-mode/SKILL.md) runs most of these for you when a step needs them (`how`, `why`, `architect`, `arena`, `swarm`, `interrogate`, `unslop`, `no-comments`, `technical-writing`, `tdd`, and the principles). the table below is for when you want one directly:

```
$how do we cancel runs? do we have an n+1 when we look up every run to cancel?
```

```
$interrogate review this pr.
```

<details>
<summary>all skills</summary>

| skill | use it when |
|---|---|
| [`$onyo-mode`](./skills/onyo-mode/SKILL.md) | default entry point for any non-trivial task. |
| [`$onyo-help`](./skills/onyo-help/SKILL.md) | you're new to ostack, or unsure which skill, playbook, or principle fits. finds out what you're trying to do, answers that part, and hands you a prompt to type. runs only when you type `$onyo-help`. |
| [`$how`](./skills/how/SKILL.md) | you want a walkthrough of how a subsystem works. |
| [`$why`](./skills/why/SKILL.md) | you want to know why something was built this way. discovers available MCPs at run time and queries each evidence category in parallel (source control, issue tracker, long-form docs, real-time chat, infra observability, error tracking, analytics warehouse). |
| [`$blast-radius`](./skills/blast-radius/SKILL.md) | you have a small-looking change and want to know what else it could break, with the one fact it's safe because of proven by running code, not asserted. |
| [`$architect`](./skills/architect/SKILL.md) | you're about to write code that crosses a function boundary and want the caller's usage, types, and module shape settled first. |
| [`$arena`](./skills/arena/SKILL.md) | you want N parallel attempts at the same thing, then to grab the best parts of each. |
| [`$swarm`](./skills/swarm/SKILL.md) | you want N parallel workers across different slices or races, then one aggregated report. |
| [`$interrogate`](./skills/interrogate/SKILL.md) | you have a diff and want different models to try to break it, including a strict code-quality lens. |
| [`$setup-ostack`](./skills/setup-ostack/SKILL.md) | you want to pick which models ostack uses per role. detects your models and writes a config rule. |
| [`$correct`](./skills/correct/SKILL.md) | you keep correcting agents for the same mistakes. mines history for mistake classes, fixes each at the highest level that works (architecture, then types, lint, and ci, then tests, with docs last), and keeps a table pairing each rule with what enforces it. |
| [`$teach`](./skills/teach/SKILL.md) | you want to actually understand a change or subsystem, not just have it summarized. runs how + why and weaves one plain explanation, built up diagram by diagram. |
| [`$tdd`](./skills/tdd/SKILL.md) | you're fixing a bug and there's a cheap local test path. write the failing test first, then the fix. |
| [`$benchmark-checklist`](./skills/benchmark-checklist/SKILL.md) | you ran a benchmark or measured a speedup or regression. vets the number (limiter, tuning, errors, repeat runs, end-to-end relevance) before you report or act on it. |
| [`$no-comments`](./skills/no-comments/SKILL.md) | strip comments before review; spawns Comment Sicko, fixes accepted findings, offers encodings for claimed constraints. |
| [`$typescript-best-practices`](./skills/typescript-best-practices/SKILL.md) | you're reading or editing typescript. grounds the type-system-discipline principle in syntax. |
| [`$figure-it-out`](./skills/figure-it-out/SKILL.md) | no bundled playbook fits. designs a rigorous, auditable playbook for the task. |
| [`$show-me-your-work`](./skills/show-me-your-work/SKILL.md) | you want a reviewable decision trail. logs decisions to a tsv you can commit. |
| [`$create-verification-skill`](./skills/create-verification-skill/SKILL.md) | your project has no scripted way to prove app behavior. generates a project-local verify skill with a feature map, for any language or platform. |
| [`$maintain-verification-skill`](./skills/maintain-verification-skill/SKILL.md) | your verify skill's feature map has drifted from the app. source wave + one live pass, at most one PR of proven corrections. |
| [`$create-formal-verification-skill`](./skills/create-formal-verification-skill/SKILL.md) | tests can't reach the case that breaks a race, retry, state machine, parser, or unsafe code. verifies one property with the tool that fits and generates a project-local skill to recheck it on every change. |
| [`$maintain-formal-verification-skill`](./skills/maintain-formal-verification-skill/SKILL.md) | code your formal verification covers has changed since it was last checked. updates the model, harness, or properties to match the code, reruns, and says whether each failure is drift in the verification or a bug in the code. |
| [`$statechart`](./skills/statechart/SKILL.md) | someone who owns the behavior needs to see it, not read a spec. draws what the user sees as a mermaid statechart generated from a tla+ model, marks each state works, still wrong, or fixed by your open pr, and draws each bug tlc finds as a numbered path. also turns an agreed chart into a tla+ skeleton, or audits the code against an existing spec. |
| [`$unslop`](./skills/unslop/SKILL.md) | you're cleaning up writing. removes AI tells. |
| [`$technical-writing`](./skills/technical-writing/SKILL.md) | layered doc standard (Diátaxis + Google developer style + STE + Global English) for docs, RFCs, readmes, PR descriptions, commit messages. |

</details>



### examples

mostly i type [`$onyo-mode`](./skills/onyo-mode/SKILL.md) at the start of a task and let it route to a playbook. the other skills fire as the steps need them. a few i reach for directly.


<details>
<summary>all the examples</summary>

```
bug fix:           $onyo-mode this pr has a subtle bug where the scroll drifts every 750ms even
                   when idle. repro first, then fix and verify.
perf:              $onyo-mode a big list takes a second or two to load even though we virtualize.
                   run a cpu trace and tell me why.
feature:           $onyo-mode build a small feature behind a feature flag. verify it really works.
prototype:         $onyo-mode build two prototypes of the markdown renderer so we can compare.
                   spawn an agent for each.
multi-phase:       $onyo-mode open source these skills as a plugin. nothing internal leaks, work
                   in a temp dir, show me the dependency graph first.
overnight run:     $onyo-mode i'm going to bed. land the stack even if ci flakes. i want
                   everything merged by morning.
babysit:           $onyo-mode check on pr 123. anything outstanding?
visual parity:     $onyo-mode the row spacing is too tall when this flag is on. the second image
                   is correct. repro and fix until it matches.
figure it out:     $onyo-mode i'm stepping away. migrate every caller from the synchronous store
                   to the new async one, keeping behavior identical. i want to trust it was done
                   right when i'm back.
how:               $how do we cancel runs? do we have an n+1 when we look up every run to cancel?
why:               $why is this feature flag not on yet?
architect:         design this instrumentation to be high signal with no false positives. $architect
                   this first.
arena:             $arena take my prompt to the arena verbatim. i want to compare their proposals
                   with yours.
swarm:             $swarm check every package under packages/ against its check.sh. one worker per
                   package. one report.
interrogate:       $interrogate review this pr.
tdd:               $tdd implement
unslop:            can we unslop and tighten the new changes?
correct:           $correct
show-me-your-work: $show-me-your-work keep a decision trail i can review when i'm back.
help:              $onyo-help which skill should i use to review this branch?
```

</details>

## the `onyo-agent` and Comment Sicko subagents

[`$onyo-mode`](./skills/onyo-mode/SKILL.md) runs in the chat that receives it. that chat owns the playbook, the todo list, and every subagent spawn.

ostack also ships [`onyo-agent` prompt](./agents/onyo-agent.md) as the wrapper for delegates spawned during a run. it reads `onyo-mode` in full, including its inline principles index, before doing any work. a generic delegate must also receive and read that prompt; a name alone does not register a custom agent. do not spawn `onyo-agent` to run the playbook itself.

[`$onyo-mode`](./skills/onyo-mode/SKILL.md) and [`onyo-agent` prompt](./agents/onyo-agent.md) route through the same wrapper.

ostack also ships [Comment Sicko](./agents/comment-sicko.md), a comment reviewer whose prompt must be loaded by the delegate, with a no-file-edits constraint. usually invoke it through [`$no-comments`](./skills/no-comments/SKILL.md), not directly.

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
| [type-system-discipline](./skills/principle-type-system-discipline/SKILL.md) | architecture | Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, exhaust variants, derive from authoritative schemas. |
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

- `/deslop` and the `deslop` skill ship in the `cursor-team-kit` plugin.
- `control-cli` (for CLIs and TUIs) and `control-ui` (for browser, Electron, web) ship in `cursor-team-kit` too.
- Cursor’s `create-skill` and `autopilot` are not Codex tool names. Use a skill-creation skill only if the current catalog provides it. Inside `onyo-mode`, PR-status requests still go to the [babysit playbook](./skills/onyo-mode/playbooks/babysit.md).

The `cursor-team-kit` skills are external dependencies, not installed Codex capabilities. Use a verified equivalent driver or perform the documented cleanup directly when possible. If the required live proof cannot run, report the missing dependency and keep the verification gate open.

## why are there no planning skills?

Codex Plan Mode can work alongside ostack where the host provides it. This port adds no planner. If you want a plan, [`$onyo-mode`](./skills/onyo-mode/SKILL.md) retains the upstream planning playbook and approval gates.

## make it yours

`onyo-mode` is my style. you may not want exactly that.

models are configurable too. [`$setup-ostack`](./skills/setup-ostack/SKILL.md) checks supported choices and writes `$CODEX_HOME/pstack-models.md`, a user-level role map that skills explicitly read. The legacy filename is retained for backward compatibility. It is not an always-loaded Codex configuration file.

when a default changes, a rule written before the change still pins the old default. delete those role lines, or delete the file, then run `$setup-ostack` again. a rerun keeps any role whose model differs from the default.

## license

MIT
