# ostack

Task entry skills, shared principles and playbooks, and specialized workflows for Claude, adapted from [Lauren Tan's pstack](https://github.com/cursor/plugins/tree/main/pstack).

Ask for the outcome in ordinary language. Claude can select a focused Entry, which handles the task and reads relevant shared Markdown as decisions arise. There is no repo-wide mode to activate and no mandatory skill chain.

## Install the whole plugin

For account availability, install or enable the **whole plugin through Chat**, or add it in **Project settings > Plugins** for new Project work threads. Account installation and a machine-local Code installation have different scopes. Use the host's supported plugin installation flow; enabling a machine-local copy does not provision a cloud session.

For a machine-local installation through Code:

```text
/plugin marketplace add hugo-hsi-dev/ostack
/plugin install ostack@ostack
```

For a source preview:

```sh
claude --plugin-dir /absolute/path/to/ostack
```

Keep the plugin together. Entries reference shared files through `${CLAUDE_PLUGIN_ROOT}`, which Claude Code substitutes with the installed plugin path. Marketplace installation copies files inside the plugin root; nothing depends on having the ostack source checkout next to your project. Shared Markdown uses document-relative links for further reads. This is a plugin package, not a collection of self-contained Entry ZIPs: uploading one Entry folder alone omits its shared dependencies.

The layout follows the documented [plugin paths](https://code.claude.com/docs/en/plugins-reference#environment-variables) and [installation copying rules](https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins). Shared-file reads in a Chat-installed cloud/Project plugin still need a live compatibility check; source validation does not prove that behavior on every Claude surface.

## Entries

These ten skills match recognizable task outcomes and allow automatic selection. You can also call them directly, for example `/ostack:feature`. Selection depends on the host and model; no hook forces invocation.

| Entry | Outcome |
| --- | --- |
| [feature](skills/feature/SKILL.md) | Build or extend a capability through implementation and verification. |
| [bug-fix](skills/bug-fix/SKILL.md) | Reproduce, diagnose, fix, and verify a bug or regression. |
| [refactor](skills/refactor/SKILL.md) | Simplify structure or migrate an internal API while preserving behavior. |
| [investigate](skills/investigate/SKILL.md) | Explain a subsystem or runtime observation from source and history. |
| [review](skills/review/SKILL.md) | Assess correctness and consequences of a change or design. |
| [maintenance](skills/maintenance/SKILL.md) | Update dependencies, configuration, tooling, or repo housekeeping; prevent demonstrated recurring mistakes. |
| [performance](skills/performance/SKILL.md) | Diagnose or improve a measured bottleneck; check benchmark claims. |
| [technical-writing](skills/technical-writing/SKILL.md) | Write, restructure, or edit substantial developer documentation. |
| [verify](skills/verify/SKILL.md) | Check implemented behavior, mapped user journeys, or visual parity using existing tooling. |
| [evaluate](skills/evaluate/SKILL.md) | Compare prompts, skills, models, or workflows with controlled trials. |

Examples:

- “Add CSV export to the existing results flow.” → feature; redesign guidance if the flow changes, then affected-path verification.
- “Fix the retry that creates duplicate jobs.” → bug-fix; root causes and a focused failing-before/passing-after check.
- “Upgrade this library and adjust CI.” → maintenance; compatibility assessment and the affected checks.
- “Review this branch for regressions.” → review; correctness and downstream contracts as needed.
- “Verify the new export journey.” → verify; the existing project harness and relevant feature-map paths.

Entries read only the supporting documents whose conditions apply. A reference is not independently discoverable or a skill invocation. Its relative links resolve from its own directory. One principle can serve feature, bug-fix, refactor, and other Entries without copying its text.

## Specialized callable skills

Specific user workflows remain skills rather than disappearing into Entry references.

| Skill | Distinct job | Invocation |
| --- | --- | --- |
| [create-verification-skill](skills/create-verification-skill/SKILL.md) | Generate and prove a project-local app-driving skill; seed a feature map. | User-invoked only. |
| [maintain-verification-skill](skills/maintain-verification-skill/SKILL.md) | Audit source and live coverage; repair an existing app-driving skill and map. | User-invoked only. |
| [create-formal-verification-skill](skills/create-formal-verification-skill/SKILL.md) | Establish a code-grounded formal check and generate its reusable project skill. | User-invoked only. |
| [maintain-formal-verification-skill](skills/maintain-formal-verification-skill/SKILL.md) | Reconcile formal checks with code changes; distinguish model drift from bugs. | User-invoked only. |
| [statechart](skills/statechart/SKILL.md) | Run TLC and explain checked states and counterexamples. | Specific task discovery or direct invocation. |
| [shipping](skills/shipping/SKILL.md) | Land an explicitly authorized existing PR stack in dependency order. | Explicit landing request or direct invocation. |

The four create/maintain skills are restored from the original ostack revision `798dcee`, with their original names, bodies, supporting files, and `disable-model-invocation: true`. Creation and maintenance are different jobs. The `verify` Entry does not automatically invoke them or turn normal verification into a generator or maintenance campaign.

Their original workflows include generating project-local skills, proving those generated instructions, and, for app maintenance, parallel source readers plus full live coverage and a corrections PR when changed. Those costs are confined to explicit use; they are not the default feature or bug-fix path. Existing project verification artifacts are not migrated by this plugin refactor. Project-local skill availability in a cloud thread still follows that host's discovery rules.

## Shared playbooks and domain references

Playbooks are domain-independent procedures stored as ordinary Markdown:

| Playbook | Read when |
| --- | --- |
| [arena](playbooks/arena.md) | A requested idea panel compares approaches to one question. |
| [swarm](playbooks/swarm.md) | Requested brainstorming partitions a question into independent areas. |
| [prototype](playbooks/prototype.md) | A concrete assumption needs a disposable experiment. |

Arena and swarm retain three Haiku idea-only proposals by default and one Opus judgment/synthesis pass. Haiku never owns code, commands, prototypes, tests, or “make it work” loops. Opus owns requested implementation and verification. The bundled [idea-scout](agents/idea-scout.md) and [idea-judge](agents/idea-judge.md) enforce read-only tools and four/six-turn limits. Briefs must supply relevant project constraints because the roles omit automatically loaded instruction files. No nested panels, automatic second rounds, silent model fallback, or cap-resume loops. Report unavailable roles rather than claiming the split ran. Actual usage savings are unmeasured.

Domain-specific methods are also shared Markdown, rather than additional catalog entries:

| Reference | Main callers |
| --- | --- |
| [architect](references/architect.md) | feature: ownership, data models, APIs. |
| [interrogate](references/interrogate.md), [blast-radius](references/blast-radius.md) | review; blast radius also supports maintenance and refactor. |
| [correct](references/correct.md) | maintenance or bug-fix: prevent a demonstrated recurring mistake. |
| [tdd](references/tdd.md) | bug-fix: cheap failing-before/passing-after regression path. |
| [typescript-best-practices](references/typescript-best-practices.md) | feature, review, and the type-system principle. |
| [unslop](references/unslop.md) | technical-writing: edit existing prose. |
| [verify-feature-map](references/verify-feature-map.md) | verify, feature, and bug-fix: targeted journey coverage. |
| [visual-parity](references/visual-parity.md) | verify, feature, and refactor: controlled UI comparison. |

## Shared principles

All 24 principles now have one Markdown source under `principles/`. Their original applicability descriptions are unchanged and remain in the documents. The table below preserves those descriptions exactly. Cross-references point to files rather than removed skill names. Entries expose the relevant conditions in their own routing instructions; there is no umbrella principle skill to discover first.

| Principle | Applicability |
| --- | --- |
| [attack-the-premise](principles/attack-the-premise.md) | Apply when two or more fixes that share one premise have failed the same gate. Write the premise down and test it directly before you write another fix that assumes it. |
| [boundary-discipline](principles/boundary-discipline.md) | Apply when wiring validation, error handling, or framework adapters. Concentrate guards at system boundaries (CLI, config, network, external APIs); trust internal types and keep business logic in pure functions. |
| [build-the-lever](principles/build-the-lever.md) | Apply to any non-trivial work, not just bulk work: edits, migrations, analyses, checks. Build the tool that does it or proves it (codemod, script, generator, or a skill your subagents follow) instead of working by hand. The tool is the artifact a reviewer can rerun. |
| [encode-lessons-in-structure](principles/encode-lessons-in-structure.md) | Apply when you catch yourself writing the same instruction a second time, or notice a recurring correction. Encode the rule as a lint, metadata flag, runtime check, or script instead of more text. |
| [exhaust-the-design-space](principles/exhaust-the-design-space.md) | Apply when facing a novel UI interaction or architectural decision with no precedent in the codebase. Build 2-3 competing prototypes and compare side by side before committing. |
| [experience-first](principles/experience-first.md) | Apply when product, UX, or feature-scope tradeoffs come up. Choose user delight over implementation convenience; ship fewer polished features over more rough ones. |
| [explain-the-number](principles/explain-the-number.md) | Apply before you measure, and before you trust, report, or act on a number you measured: a speedup, a regression, a throughput, a latency, or an eval result. Find what limits it, and rule out that it measured something other than the work you think. |
| [fix-root-causes](principles/fix-root-causes.md) | Apply when debugging. Trace each symptom back to the first place the system went wrong and fix it there. A guard is a fix only when the state it handles is legitimate. |
| [foundational-thinking](principles/foundational-thinking.md) | Apply before writing logic: choosing core types and data structures, sequencing scaffold-vs-feature work, asking what concurrent actors share. Get the data structures right so downstream code becomes obvious. |
| [guard-the-context-window](principles/guard-the-context-window.md) | Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads. |
| [laziness-protocol](principles/laziness-protocol.md) | Apply when refactoring, evaluating diff size, or tempted to add abstractions, layers, or signal threading. Bias toward deletion and the smallest change that solves the problem. |
| [make-operations-idempotent](principles/make-operations-idempotent.md) | Apply when designing commands, lifecycle steps, or processing loops that run amid crashes, restarts, and retries. Converge to the same end state regardless of partial prior runs. |
| [migrate-callers-then-delete-legacy-apis](principles/migrate-callers-then-delete-legacy-apis.md) | Apply when introducing a new internal API while old callers still exist. Migrate callers and delete the old API in the same wave instead of preserving compatibility layers. |
| [minimize-reader-load](principles/minimize-reader-load.md) | Apply when reviewing or shaping code that's hard to trace. Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope. |
| [model-the-domain](principles/model-the-domain.md) | Apply when writing stateful logic, or when code branches a lot or repeats a shape assumption across files. |
| [never-block-on-the-human](principles/never-block-on-the-human.md) | Apply when tempted to ask 'should I do X?' on reversible work. |
| [outcome-oriented-execution](principles/outcome-oriented-execution.md) | Apply during planned rewrites and migrations with explicit phase boundaries. Converge on the target architecture; don't preserve smooth intermediate states with throwaway compatibility code. |
| [prove-it-works](principles/prove-it-works.md) | Apply after completing a task, before declaring done. Verify against the real artifact (run the feature, read the actual value, inspect the diff), not a proxy, self-report, or 'it compiles.' |
| [redesign-from-first-principles](principles/redesign-from-first-principles.md) | Apply when integrating a new requirement into an existing design. |
| [separate-before-serializing-shared-state](principles/separate-before-serializing-shared-state.md) | Apply when concurrent actors might write to the same file, branch, key, or state object. Eliminate the sharing first; serialize structurally only when one shared writer is a real invariant. |
| [sequence-verifiable-units](principles/sequence-verifiable-units.md) | Apply to multi-step work (sweeps, migrations, runs of similar edits) and to how you stack commits and PRs. Break work into small units that each end in a verifiable state, check each before the next, and order delivery so the sequence proves itself to a reviewer. |
| [subtract-before-you-add](principles/subtract-before-you-add.md) | Apply when sequencing an addition, refactor, or rewrite. Remove dead code, redundant validators, and stub references first, then build on the simpler base. |
| [test-behavior-not-implementation](principles/test-behavior-not-implementation.md) | Apply when you write, change, or keep a test. Assert what the code's users can observe, so that the test fails when that behavior breaks and keeps passing when only the internals change. |
| [type-system-discipline](principles/type-system-discipline.md) | Apply when designing types, reviewing a function signature, or writing code in any statically-typed language. Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, exhaust variants, derive from authoritative schemas. |

## Native workflows and limits

Use Projects' normal coordination and the skills available in the work thread. Leave preferences, memory, session history, planning, automatic PR creation, and monitoring to Claude's native features. Ordinary Entries finish at the requested result; they do not merge or publish as an automatic final step.

There are **16 native skills**: ten Entries, four original manual-only verification workflows, statechart, and shipping. Principles, playbooks, and domain references add no skill catalog entries. The plugin keeps one canonical copy of each shared document.

Strict static validation, reference reachability, and original-content comparisons are separate from live automatic-selection, cloud installation, and model-cost testing. See [PORTING.md](PORTING.md) for the old-to-new map and validation details.

## Credit

Derived from pstack by Lauren Tan. See [LICENSE](LICENSE) for the MIT license and copyright notice.
