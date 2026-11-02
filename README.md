# ostack

Focused engineering skills for Claude Code, adapted from [Lauren Tan's pstack](https://github.com/cursor/plugins/tree/main/pstack).

ostack keeps the useful parts: reproduce bugs, measure performance, model ownership, simplify code, and verify real behavior. Each skill handles a specific task. Ask for the work in ordinary language; Claude can select the relevant skill from its description.

## Install

For account-wide availability, install or enable the skills through **Chat**. They can then be used in local, cloud, and Project work threads.

For a machine-local installation through **Code**, run:

```text
/plugin marketplace add hugo-hsi-dev/ostack
/plugin install ostack@ostack
```

For a local source preview:

```sh
claude --plugin-dir /absolute/path/to/ostack
```

All bundled skills allow automatic invocation. You can also invoke one directly with its plugin-qualified name, such as `/ostack:bug-fix`. Automatic selection depends on Claude's judgment and the skills available in that session; this package does not force a skill load on every task. See [Claude's skill documentation](https://code.claude.com/docs/en/skills).

## Desktop and Projects

Use Projects' normal coordination. The project conversation routes work into threads; those work threads use the skills available to them. No coordinator prompt, routing skill, custom agent, or mode activation is needed.

Installing skills through **Chat** makes them available through your Claude account, including local, cloud, and Project work threads. Installing only on your machine through **Code** is local to that environment. For Projects, you can also add the plugin under **Project settings > Plugins** for new threads. Repository `.claude/skills/` folders and plugins declared in repository `.claude/settings.json` do not load into Project cloud threads. Follow the [Projects setup documentation](https://code.claude.com/docs/en/claude-projects#get-skills-plugins-connectors-and-tools-into-threads) for the current availability and installation options.

Leave preferences, memory, session history, planning, PR creation, and PR monitoring to Claude's native features. Where automatic PR creation is enabled, use the session's existing PR. These skills finish at the requested engineering result; they do not open, ready, merge, or babysit a PR as a mandatory final step.

## Skills

| Skill | Use it for |
| --- | --- |
| [arena](skills/arena/SKILL.md) | Three distinct Haiku idea proposals, then Opus selection and synthesis. |
| [swarm](skills/swarm/SKILL.md) | Haiku brainstorming across separate slices, synthesized by Opus. |
| [shipping](skills/shipping/SKILL.md) | Land an explicitly requested PR stack with dependency and current-head checks. |
| [bug-fix](skills/bug-fix/SKILL.md) | Reproduce a bug, isolate its cause, fix it, and rerun the reproduction. |
| [investigate](skills/investigate/SKILL.md) | Explain how code works or why it is shaped that way, using focused source and history evidence. |
| [performance](skills/performance/SKILL.md) | Diagnose bottlenecks, validate benchmark claims, or run a bounded optimization campaign. |
| [architect](skills/architect/SKILL.md) | Choose data models, ownership, and interfaces for a substantial design change. |
| [prototype](skills/prototype/SKILL.md) | Resolve a concrete uncertainty with a small disposable experiment. |
| [refactor](skills/refactor/SKILL.md) | Reduce structural complexity while preserving the behavior contract. |
| [interrogate](skills/interrogate/SKILL.md) | Challenge a change or design for concrete correctness failures. |
| [blast-radius](skills/blast-radius/SKILL.md) | Check contracts and consequences outside a change's diff. |
| [correct](skills/correct/SKILL.md) | Prevent a demonstrated recurring repo mistake with structural enforcement. |
| [tdd](skills/tdd/SKILL.md) | Capture a cheap failing regression test before fixing a bug. |
| [typescript-best-practices](skills/typescript-best-practices/SKILL.md) | Model domain variants and validate external data in TypeScript. |
| [technical-writing](skills/technical-writing/SKILL.md) | Structure and write substantial developer documentation. |
| [unslop](skills/unslop/SKILL.md) | Edit existing prose for clarity while preserving voice and meaning. |
| [verify-feature-map](skills/verify-feature-map/SKILL.md) | Reconcile an existing verification map with source and live user journeys. |
| [formal-verification](skills/formal-verification/SKILL.md) | Establish or maintain a formal check for a named high-risk invariant. |
| [statechart](skills/statechart/SKILL.md) | Check a bounded TLA+ model and explain counterexamples with statecharts. |
| [evaluate](skills/evaluate/SKILL.md) | Compare prompts, skills, or workflows with controlled trials. |

Examples of ordinary requests:

- "Fix the scroll drift. Reproduce it first and verify the fix."
- "Why does this worker keep its own copy of the cache?"
- "Measure export latency on this dataset and improve the bottleneck."
- "Simplify this internal API and migrate its callers."
- "Check whether this retry protocol can charge twice."

## Principles and native discovery

The 24 principles remain individual skills. Each description exposes a concrete applicability condition to native discovery, so principles can be selected independently of task workflows. A loaded task skill can also name a relevant principle. No umbrella principle skill or mode activation is required.

Principles keep one source in their own `SKILL.md`. Cross-skill handoffs use registered skill names rather than assuming neighboring installation folders. The full principle text loads only when selected. There are 45 skill entries in total: 21 task skills and 24 principles.

Domain-specific routing remains an option for closely related procedures. The current task skills are directly discoverable; none requires a repo-wide playbook router.

| Principle | Applicability |
| --- | --- |
| [attack-the-premise](skills/principle-attack-the-premise/SKILL.md) | Apply when two or more fixes that share one premise have failed the same gate. Write the premise down and test it directly before you write another fix that assumes it. |
| [boundary-discipline](skills/principle-boundary-discipline/SKILL.md) | Apply when wiring validation, error handling, or framework adapters. Concentrate guards at system boundaries (CLI, config, network, external APIs); trust internal types and keep business logic in pure functions. |
| [build-the-lever](skills/principle-build-the-lever/SKILL.md) | Apply to any non-trivial work, not just bulk work: edits, migrations, analyses, checks. Build the tool that does it or proves it (codemod, script, generator, or a skill your subagents follow) instead of working by hand. The tool is the artifact a reviewer can rerun. |
| [encode-lessons-in-structure](skills/principle-encode-lessons-in-structure/SKILL.md) | Apply when you catch yourself writing the same instruction a second time, or notice a recurring correction. Encode the rule as a lint, metadata flag, runtime check, or script instead of more text. |
| [exhaust-the-design-space](skills/principle-exhaust-the-design-space/SKILL.md) | Apply when facing a novel UI interaction or architectural decision with no precedent in the codebase. Build 2-3 competing prototypes and compare side by side before committing. |
| [experience-first](skills/principle-experience-first/SKILL.md) | Apply when product, UX, or feature-scope tradeoffs come up. Choose user delight over implementation convenience; ship fewer polished features over more rough ones. |
| [explain-the-number](skills/principle-explain-the-number/SKILL.md) | Apply before you measure, and before you trust, report, or act on a number you measured: a speedup, a regression, a throughput, a latency, or an eval result. Find what limits it, and rule out that it measured something other than the work you think. |
| [fix-root-causes](skills/principle-fix-root-causes/SKILL.md) | Apply when debugging. Trace each symptom back to the first place the system went wrong and fix it there. A guard is a fix only when the state it handles is legitimate. |
| [foundational-thinking](skills/principle-foundational-thinking/SKILL.md) | Apply before writing logic: choosing core types and data structures, sequencing scaffold-vs-feature work, asking what concurrent actors share. Get the data structures right so downstream code becomes obvious. |
| [guard-the-context-window](skills/principle-guard-the-context-window/SKILL.md) | Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads. |
| [laziness-protocol](skills/principle-laziness-protocol/SKILL.md) | Apply when refactoring, evaluating diff size, or tempted to add abstractions, layers, or signal threading. Bias toward deletion and the smallest change that solves the problem. |
| [make-operations-idempotent](skills/principle-make-operations-idempotent/SKILL.md) | Apply when designing commands, lifecycle steps, or processing loops that run amid crashes, restarts, and retries. Converge to the same end state regardless of partial prior runs. |
| [migrate-callers-then-delete-legacy-apis](skills/principle-migrate-callers-then-delete-legacy-apis/SKILL.md) | Apply when introducing a new internal API while old callers still exist. Migrate callers and delete the old API in the same wave instead of preserving compatibility layers. |
| [minimize-reader-load](skills/principle-minimize-reader-load/SKILL.md) | Apply when reviewing or shaping code that's hard to trace. Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope. |
| [model-the-domain](skills/principle-model-the-domain/SKILL.md) | Apply when writing stateful logic, or when code branches a lot or repeats a shape assumption across files. |
| [never-block-on-the-human](skills/principle-never-block-on-the-human/SKILL.md) | Apply when tempted to ask 'should I do X?' on reversible work. |
| [outcome-oriented-execution](skills/principle-outcome-oriented-execution/SKILL.md) | Apply during planned rewrites and migrations with explicit phase boundaries. Converge on the target architecture; don't preserve smooth intermediate states with throwaway compatibility code. |
| [prove-it-works](skills/principle-prove-it-works/SKILL.md) | Apply after completing a task, before declaring done. Verify against the real artifact (run the feature, read the actual value, inspect the diff), not a proxy, self-report, or 'it compiles.' |
| [redesign-from-first-principles](skills/principle-redesign-from-first-principles/SKILL.md) | Apply when integrating a new requirement into an existing design. |
| [separate-before-serializing-shared-state](skills/principle-separate-before-serializing-shared-state/SKILL.md) | Apply when concurrent actors might write to the same file, branch, key, or state object. Eliminate the sharing first; serialize structurally only when one shared writer is a real invariant. |
| [sequence-verifiable-units](skills/principle-sequence-verifiable-units/SKILL.md) | Apply to multi-step work (sweeps, migrations, runs of similar edits) and to how you stack commits and PRs. Break work into small units that each end in a verifiable state, check each before the next, and order delivery so the sequence proves itself to a reviewer. |
| [subtract-before-you-add](skills/principle-subtract-before-you-add/SKILL.md) | Apply when sequencing an addition, refactor, or rewrite. Remove dead code, redundant validators, and stub references first, then build on the simpler base. |
| [test-behavior-not-implementation](skills/principle-test-behavior-not-implementation/SKILL.md) | Apply when you write, change, or keep a test. Assert what the code's users can observe, so that the test fails when that behavior breaks and keeps passing when only the internals change. |
| [type-system-discipline](skills/principle-type-system-discipline/SKILL.md) | Apply when designing types, reviewing a function signature, or writing code in any statically-typed language. Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, exhaust variants, derive from authoritative schemas. |


## Brainstorm panels

Arena explores competing approaches to one question. Swarm partitions a question into different areas. Both default to three Haiku idea proposals and one Opus judgment pass. The Opus owner can judge directly; otherwise one Opus judge returns the synthesis. Opus owns any requested implementation and verification.

The plugin bundles two native role agents. `idea-scout` uses Haiku with only Read, Grep, and Glob, a four-turn cap, and proposals capped at 250 words. It cannot write code, run commands, install tools, or spawn agents. `idea-judge` uses Opus with the same read-only tools and a six-turn cap. Both omit automatically loaded instruction files; the owner supplies relevant project constraints and small source excerpts in the brief.

There are no automatic second rounds, nested panels, or retries until an idea works. Check the effective model when the host exposes it; native policies can override a requested alias. Report an unavailable role or a partial result rather than silently using another model or resuming past the cap.

These workflows use the role definitions bundled with the plugin. Installing an individual skill through Chat alone does not establish that the role agents and enforced tool limits are available. Use the plugin or a supported equivalent native configuration; report unsupported execution rather than assuming the roles exist. Actual token or plan-usage savings have not been measured.

## Cost and scope

Work stays in the current session by default. There are no mandatory model panels, implementation delegates, repeated style passes, minimum optimization iterations, or overnight loops. Compare alternatives when uncertainty justifies it, and stop when the evidence answers the task. Detailed references load only when needed.

Existing generated verification skills, including pstack output, retain their shared names, structure, and verification meaning during maintenance. Routine upkeep does not migrate or replace them.

Formal checks and evaluations remain specialized workflows. They should match an explicit request or a named invariant, rather than run on routine changes. The statechart tool needs a supported JavaScript runtime; first use also provisions Java and TLC through mise and requires network access.

For ordinary launch instructions, prefer Claude's available app-running tools or the project's existing harness. The feature-map skill adds coverage reconciliation; it does not replace launch tooling.

The [audit and migration notes](PORTING.md) explain what was removed, what was consolidated, and how to retire old ostack instructions.

## Credit

Derived from pstack by Lauren Tan. The retained workflows and tooling build on that work. See [LICENSE](LICENSE) for the MIT license and copyright notice.
