# ostack

Task skills, principles, and playbooks for Claude Code, adapted from [Lauren Tan's pstack](https://github.com/cursor/plugins/tree/main/pstack). Ask for the outcome in plain language; Claude picks the matching skill on its own. There is no mode to turn on and no router to call.

## Install

```text
/plugin marketplace add hugo-hsi-dev/ostack
/plugin install ostack@ostack
```

In Claude Projects, add the plugin in **Project settings > Plugins** so its sessions load it. For a source preview, run `claude --plugin-dir /absolute/path/to/ostack`.

## Layout

Three kinds of content, each with one job:

- **Skills** (`skills/<name>/SKILL.md`) are the only entry points. A skill is a task workflow: numbered steps that call playbooks where a procedure is needed, then a routing table of principles to read as decisions arise.
- **Principles** (`principles/<name>/PRINCIPLE.md`) each hold one decision. The text gives the trigger, the rule, and the reasoning, enough for an agent to remake that decision on a new case. A principle never prescribes a procedure or names a skill.
- **Playbooks** (`playbooks/<name>/PLAYBOOK.md`) are ordered procedures that are not tied to one task type. They may cite a principle for a judgment inside a step, but never call another playbook or a skill.

Optional supporting files live in a `references/` folder next to the document that owns them. Skills link shared files through `${CLAUDE_PLUGIN_ROOT}`; principles and playbooks link each other with relative paths. Keep the plugin together: one skill folder alone is missing its dependencies.

To add a skill, write the workflow from existing playbooks and a principle table. If a step would restate a decision, it belongs in a principle; if two skills would share a procedure, it belongs in a playbook.

## Skills

Model-invoked:

| Skill | Use |
| --- | --- |
| [bug-fix](skills/bug-fix/SKILL.md) | Diagnose and fix a bug, crash, error, failing test, flaky behavior, or regression: reproduce it, find the root cause, add a regression check, and prove the fix. |
| [feature](skills/feature/SKILL.md) | Design and build a new feature, integration, endpoint, command, or UI, or extend existing behavior. |
| [investigate](skills/investigate/SKILL.md) | Explain how code works, why it was built that way, or what happened at runtime, without changing it. |
| [maintenance](skills/maintenance/SKILL.md) | Update dependencies, change configuration, build or CI tooling, clean up the repository, or add a lint or check that stops a recurring mistake. |
| [performance](skills/performance/SKILL.md) | Measure, diagnose, and improve speed, latency, throughput, memory, or other resource use, and check benchmark claims. |
| [technical-writing](skills/technical-writing/SKILL.md) | Write, restructure, or edit technical documentation such as READMEs, guides, API references, design docs, changelogs, and PR descriptions. |
| [verify](skills/verify/SKILL.md) | Prove that a feature or fix actually works by driving the real app through its user journeys, capturing evidence, and comparing UI or output against a reference. |

Run only when called by name (`disable-model-invocation: true`). Their generated `verify-<app>` skills, feature maps, and formal verification skills keep the stock pstack shapes, so colleagues on pstack can use and maintain the same artifacts.

| Skill | Use |
| --- | --- |
| [create-verification-skill](skills/create-verification-skill/SKILL.md) | Create a project-local verify-<app> skill and feature map that launch, drive, and capture evidence from this app. |
| [maintain-verification-skill](skills/maintain-verification-skill/SKILL.md) | Audit and update an existing verify-<app> skill and its feature map against the current app, fixing drift and harness gaps. |
| [create-formal-verification-skill](skills/create-formal-verification-skill/SKILL.md) | Formally verify a high-risk property of this codebase (TLA+, model checker, prover, or SMT verifier) and generate a project-local skill that reruns it. |
| [maintain-formal-verification-skill](skills/maintain-formal-verification-skill/SKILL.md) | Bring existing formal verification back in sync with changed code, separating model drift from real bugs. |

For code review, security review, and refactoring cleanups, use Claude Code's built-in `/code-review`, `/security-review`, and `/simplify`.

## Principles

| Principle | Applies |
| --- | --- |
| [attack-the-premise](principles/attack-the-premise/PRINCIPLE.md) | when two or more fixes that share one premise have failed the same gate. |
| [boundary-discipline](principles/boundary-discipline/PRINCIPLE.md) | when wiring validation, error handling, or framework adapters. |
| [build-the-lever](principles/build-the-lever/PRINCIPLE.md) | to any non-trivial work, not just bulk work: edits, migrations, analyses, checks. |
| [design-from-usage](principles/design-from-usage/PRINCIPLE.md) | when choosing or reviewing representations, ownership, or interfaces whose caller usage is not yet clear. |
| [encode-lessons-in-structure](principles/encode-lessons-in-structure/PRINCIPLE.md) | when you catch yourself writing the same instruction a second time, or notice a recurring correction. Encode the rule as a lint, metadata flag, runtime check, or script instead of more text. |
| [experience-first](principles/experience-first/PRINCIPLE.md) | when product, UX, or feature-scope tradeoffs come up. |
| [explain-the-number](principles/explain-the-number/PRINCIPLE.md) | before you measure, and before you trust, report, or act on a number you measured: a speedup, a regression, a throughput, a latency, or an eval result. Find what limits it, and rule out that it measured something other than the work you think. |
| [fix-root-causes](principles/fix-root-causes/PRINCIPLE.md) | when debugging. |
| [make-operations-idempotent](principles/make-operations-idempotent/PRINCIPLE.md) | when designing commands, lifecycle steps, or processing loops that run amid crashes, restarts, and retries. |
| [minimize-reader-load](principles/minimize-reader-load/PRINCIPLE.md) | when reviewing or shaping code that's hard to trace. Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope. |
| [model-the-domain](principles/model-the-domain/PRINCIPLE.md) | when writing stateful logic, or when code branches a lot or repeats a shape assumption across files. |
| [outcome-oriented-execution](principles/outcome-oriented-execution/PRINCIPLE.md) | during planned rewrites and migrations with explicit phase boundaries. |
| [preserve-contracts](principles/preserve-contracts/PRINCIPLE.md) | when changing behavior consumed outside the edited code: public APIs, persisted data, wire formats, CLI output, configuration, or independently deployed clients. |
| [prove-it-works](principles/prove-it-works/PRINCIPLE.md) | after completing a task, before declaring done. |
| [redesign-from-first-principles](principles/redesign-from-first-principles/PRINCIPLE.md) | when integrating a new requirement into an existing design. |
| [separate-before-serializing-shared-state](principles/separate-before-serializing-shared-state/PRINCIPLE.md) | when concurrent actors might write to the same file, branch, key, or state object. |
| [sequence-verifiable-units](principles/sequence-verifiable-units/PRINCIPLE.md) | to multi-step work (sweeps, migrations, runs of similar edits) and to how you stack commits and PRs. |
| [subtract-before-you-add](principles/subtract-before-you-add/PRINCIPLE.md) | when sequencing an addition, refactor, or rewrite, judging diff size, or tempted to add an abstraction, layer, or threaded flag. |
| [test-behavior-not-implementation](principles/test-behavior-not-implementation/PRINCIPLE.md) | when you write, change, or keep a test. Assert what the code's users can observe, so that the test fails when that behavior breaks and keeps passing when only the internals change. |
| [type-system-discipline](principles/type-system-discipline/PRINCIPLE.md) | when designing types, reviewing a function signature, or writing code in any statically-typed language. |

## Playbooks

| Playbook | Use |
| --- | --- |
| [compare-artifacts](playbooks/compare-artifacts/PLAYBOOK.md) | Use to establish whether a candidate preserves or intentionally changes an observable reference: screenshots, generated files, command output, or structured results. Inputs are the reference, candidate, relevant states, and agreed comparison rule. |
| [measure](playbooks/measure/PLAYBOOK.md) | Use when a decision needs a trustworthy latency, throughput, resource-use, accuracy, or other quantitative result. Inputs are the workload or trial, metric, intended conclusion, and available budget. A requested ballpark may use one labeled run; a comparison needs enough samples to resolve the effect. |
| [prototype](playbooks/prototype/PLAYBOOK.md) | State the decision and the observation that would change it. If inspection can settle the question, use that evidence first. |

## License

MIT
