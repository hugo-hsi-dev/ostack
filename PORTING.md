# ostack audit and migration

## Current architecture

Version 0.3.3 has nine outcome-based Entries and four user-invoked verification skills. Entries route conditionally to ordinary Markdown inside the same plugin. No onyo-mode or repo-wide prerequisite returns.

```text
ostack/
├── .claude-plugin/       manifests
├── skills/              9 Entries + 4 user-invoked workflows
├── principles/
│   └── <name>/
│       ├── PRINCIPLE.md
│       └── references/  optional documentation owned by the principle
├── playbooks/
│   └── <name>/
│       ├── PLAYBOOK.md
│       └── references/  optional documentation owned by the procedure
└── agents/              bounded Haiku idea scout and Opus judge
```

Only `skills/<name>/SKILL.md` registers a skill. Entries use `${CLAUDE_PLUGIN_ROOT}` for direct reads. Shared documents use relative links from the document's directory; those links are navigation for a read tool, not automatic context inclusion. Keep every dependency inside the plugin root. Installing an individual Entry ZIP does not include its sibling shared folders.

## Migration from the old standalone methods

| Previous skill or group | Destination |
| --- | --- |
| 24 principle-* skills | principles/<name>/PRINCIPLE.md; exact applicability descriptions retained. |
| playbook-arena, playbook-swarm, playbook-prototype | playbooks/<name>/PLAYBOOK.md; shared procedures, no slash commands. |
| architect | Entries select principles/design-from-usage/PRINCIPLE.md and other applicable principles. The design playbook is removed; no shared design text is copied into Entries. |
| interrogate, blast-radius | Review owns scope, contract tracing, adversarial checks, and findings. The shared preserve-contracts principle serves feature, review, maintenance, and refactor. |
| correct | Maintenance owns the enforcement workflow. Encode-lessons-in-structure supplies the reusable rule, also selected by bug-fix for requested prevention. |
| tdd | Bug-fix owns the failing-before/passing-after regression procedure and the conditions for skipping impractical new tests. |
| typescript-best-practices | principles/type-system-discipline/references/typescript.md applies the owning principle to TypeScript; no intermediate best-practices router. |
| unslop | Technical-writing owns the editing procedure and scope/voice constraints. |
| verify-feature-map, visual-parity | Verify owns coverage, real driving, triage, and evidence. Shared comparison mechanics live in playbooks/compare-artifacts/PLAYBOOK.md, also selected by feature and refactor. |
| formal-verification | Removed the combined creation/maintenance replacement; restored the original four separate workflows below. |
| bug-fix, refactor, investigate, performance, technical-writing | Rewritten as outcome owners with their own procedure, evidence standard, stopping condition, and direct selection of principles/playbooks. |
| shipping, statechart | Shipping removed. Statechart preserved once under formal creation’s references and read from both formal workflows; neither remains a registered skill. |
| feature, review, maintenance, verify | Rewritten around the complete outcome, rather than forwarding to renamed old skills. |

The old principle and playbook slash commands intentionally disappear; no aliases keep their descriptions in the catalog. Ask through the appropriate Entry. Shared documents may also be read directly when their file path is already known.

## Original verification workflows restored

The four workflows were restored from ostack commit `798dcee`. The four skills now use numbered workflows followed by conditional principle routing. Their names, manual-only settings, distinct procedures, generated-artifact contracts, and original app examples remain. The formal workflows share the statechart supporting toolkit:

- skills/create-verification-skill/
- skills/maintain-verification-skill/
- skills/create-formal-verification-skill/
- skills/maintain-formal-verification-skill/

Their original names and manual-only invocation flags remain. App creation produces and executes a project-local driving skill and seeds its map. App maintenance has full-map source and live passes, limits edits to verification, and ships at most one corrections PR. Formal creation chooses a tool, proves a meaningful property can fail, and generates its reusable verification skill. Formal maintenance reviews code changes since the sync commit and updates the check without concealing product bugs. Creation is not maintenance.

This explicitly restores the original workflow and execution cost, rather than imposing the cheaper Entry defaults on them. No Entry silently invokes those manual-only workflows or reads their bodies to bypass invocation policy. The verify Entry uses the project's existing verification setup and points users to the appropriate explicit workflow when creation or full upkeep is needed.

Existing generated project verification files are untouched by this migration. The verify Entry preserves existing names, locations, structure, commands, and coverage meaning. No new ostack-only output contract is introduced. Restoring source does not establish end-to-end interoperability with a colleague's pstack installation. Project-local generated skill discovery can differ in cloud/Project threads; report unsupported discovery rather than silently rewriting the artifact.

## Principle preservation and routing

All 24 applicability descriptions matched upstream pstack when checked on November 2, 2026 and remain unchanged in the new Markdown bodies. Bodies preserve the rules; old skill-name references are now relative file links. Type-system guidance points to its TypeScript application document. The two ownership adjustments for the current skill format remove workflow steps from fix-root-causes and place the enforcement-choice method in encode-lessons-in-structure. All original applicability descriptions remain unchanged; broader principle redesign is separate work.

Entries carry concrete selection conditions. Feature and refactor can both select redesign-from-first-principles; bug-fix selects root causes and TDD; review selects correctness and downstream-contract methods. Entries select the relevant principles directly. Playbooks carry reusable procedures without an additional principle-routing layer. Read only the applicable documents, not all files linked from them. Available tools, authorization, requested scope, and project constraints still govern execution. A context-budget principle does not grant permission to launch delegates, and a sequencing principle does not authorize rewriting a shared branch.

## Rewriting the intermediate references layer

The first Entry migration moved old methods into shared references but left a second routing/workflow layer. This rewrite removes that layer. Entries own their task procedure and select principles and playbooks directly. The former shared references directory is removed; original app-verification examples remain unchanged, and the statechart toolkit has one owner under formal creation’s references.

Shared content earns its place through reuse. Design judgments help feature work, refactors, design-related bug fixes, performance representation changes, integration migrations, and requested design critique. All six Entries point to one design-from-usage principle. Entries select any independent arena, prototype, or other procedure themselves. The removed design playbook is not replaced by duplicated design text in each Entry.

Comparison and measurement are reusable procedures across task domains, so they are playbooks. Preserve-contracts is a new decision rule, selected where supported consumers or stored data constrain a change. TypeScript examples apply type-system discipline and live with that principle. No broad third shared category or hidden set of renamed task skills is introduced.

## Mock routing stress checks

These are source-level walkthroughs, not live model-selection results. No skills or agents were invoked.

| Scenario | Entry-owned work and relevant shared content | Stop or exclusion |
| --- | --- | --- |
| Add export to an existing results flow | Feature defines acceptance conditions, selects redesign and experience principles, and designs only if the shape is unresolved. | Implement and drive affected paths; no automatic panel or generator. |
| Fix a typo in a label | Feature makes the bounded edit and checks the visible result. | No extra design procedure, prototype, or model. |
| Race caused by two state owners | Bug-fix reproduces first; shared-state/model and design-from-usage principles can resolve ownership; regression fails before and passes after. | No broad architecture campaign for an isolated defect. |
| Straightforward arithmetic regression | Bug-fix owns the cheap failing regression check and minimal fix. | No TDD wrapper or extra design procedure is needed. |
| Refactor phase-based modules | Refactor selects domain-modeling and reader-load rules, and design-from-usage for the new boundary; checks equivalence. | No new user-visible behavior. |
| Review a split-ownership proposal | Review traces the consequential failure; model/shared-state/reader-load principles support judgment. | Select design-from-usage when the interface or representation needs judgment; no product edits. |
| Replace a quadratic lookup in a hot path | Performance establishes a baseline and limiter; model and design-from-usage principles guide representation if necessary. | Measure one selected intervention; no default brainstorming panel. |
| Upgrade an SDK with a changed integration boundary | Maintenance checks actual versions and consumers; preserve-contracts/boundary/design-from-usage principles apply to the unresolved interface. | Routine updates with a known migration skip design. |
| Prevent a recurring invalid repo state | Maintenance selects encode-lessons-in-structure and chooses an existing structural guard; checks broken and valid cases. | No transcript mining or repo-wide hardening. |
| Edit an existing README | Technical-writing owns editing, voice, examples, and link checks. | No unslop wrapper, design stage, or mandatory second pass. |
| Verify a UI migration against screenshots | Verify owns mapped states and live behavior; compare-artifacts controls the reference and captures. | Pixel parity does not prove interactions or accessibility. |
| Brainstorm approaches to a design question | The relevant Entry selects arena or swarm according to one question versus separate areas. | Haiku proposes ideas only; Opus owns any requested implementation and verification. |
| Generate versus maintain verification | The appropriate original create/maintain skill is directly user-invoked. | Entries never bypass the manual-only setting. |

## Earlier audit findings

- **Routing duplicated skill discovery.** onyo-mode required playbook selection, copied todo steps, principle reads, and further skill loads before ordinary work. Several of those dependencies had already been deleted.
- **Rigor became an unconditional execution cost.** Crossing a function boundary triggered architecture exploration. Feature work required delegates or competing implementations. Reviews required multiple models. Optimization campaigns imposed iteration floors and logs even after useful evidence existed.
- **Automatic discovery was disabled.** Most surviving task skills had `disable-model-invocation: true`. Descriptions could not make them self-invoking while that flag remained set.
- **The port retained platform assumptions.** Custom agent types, model-role files, local transcript paths, explicit session orchestration, and mandatory PR playbooks survived terminology changes from Cursor to Claude Code.
- **The documentation described a different repo.** README links and the porting checklist referenced deleted setup, memory, review, and orchestration components.

These findings explain retiring the global mode, transcript scraping, native-memory duplicates, and forced execution chains. The original explicit verification workflows are now a deliberate exception to earlier consolidation decisions.

## Arena and swarm bounds

All five playbooks are independent plain Markdown procedures, each in its own folder with PLAYBOOK.md. They do not invoke one another. Arena compares distinct proposals for one question; swarm partitions brainstorming across areas; prototype tests a concrete uncertainty in a disposable experiment. Arena and swarm keep Haiku at idea generation: no writes, commands, tests, implementation, or make-it-work loops. Three candidates and one Opus synthesis are the default. Opus owns requested implementation and verification.

The existing idea-scout and idea-judge agent definitions retain read-only tool allowlists, four/six-turn caps, and omission of automatically loaded project instruction files. The owner supplies relevant constraints. No nested fan-out, automatic second round, fallback model, or automatic resumption after a cap. Native agent availability and effective model controls must be checked in the target host. These are execution bounds, not measured savings.

## Review of the 22 original onyo-mode playbooks

| Original playbook | Current disposition |
| --- | --- |
| authoring-a-skill | Native skill-authoring tools; no extra routing playbook. |
| autonomous-run | Native scheduling or loops when requested, with explicit scope and a stop condition; no automatic wake machinery. |
| autopilot-full | Native Projects and user-authorized delivery; no per-PR owner/verifier swarms or standing audit heartbeat. |
| autopilot-stack | Native Projects and PR handoff; landing uses the native forge workflow when requested. |
| bug-fix | Preserved in the direct bug-fix skill. |
| eval | The user-deleted evaluate skill remains removed; this format change does not restore it. |
| feature | The feature Entry plus directly selected principles and independent procedures; no compulsory delegate or competing implementations. |
| hillclimb | Preserved as the bounded optimization-campaign mode in performance. |
| investigation | Preserved in investigate. |
| multi-phase-plan | Native planning plus verifiable-unit principles; remove the rigid template, ten live lanes, and checker tied to old orchestration. |
| opening-a-pr | Native PR creation and existing session PR; technical-writing covers requested prose. |
| orchestrate | Native Projects coordination. No coordinator skill-loading requirements. |
| pause-safely | Native session lifecycle; no compulsory WIP commit or separate handoff archive. |
| perf-issue | Preserved in performance with the shared measure playbook. |
| prototype | Preserved in the shared playbooks/prototype/PLAYBOOK.md, selected from Entries. |
| refactoring | Preserved in refactor. |
| runtime-forensics | Preserved in investigate and performance; collect only the relevant signal. |
| session-pickup | Native session/history tools; no local transcript crawling. |
| shipping | Removed at the user’s request; use native forge tools for an authorized landing task. |
| trace-forensics | Preserved in investigate and performance; no mandatory SQLite conversion or delegate. |
| visual-parity | Verify owns the outcome; compare-artifacts supplies reusable comparison mechanics for verify, feature, and refactor. |
| worktree-cleanup | Native worktree lifecycle; remove transcript/pinned-chat assumptions and automatic simulator/cache deletion. |

## Folder organization and statechart ownership

Every principle lives in `principles/<name>/PRINCIPLE.md` and every playbook in `playbooks/<name>/PLAYBOOK.md`. Optional documentation belongs in that owner’s `references/` directory. Type-system discipline now has `references/typescript.md`; the new design-from-usage principle owns the former design-red-flags detail. All relative links are recalculated from the document’s new location. Original principle applicability descriptions remain unchanged.

The design playbook is retired. Its reusable judgments are written as one design-from-usage principle, selected by feature, bug-fix, refactor, performance, maintenance, and relevant design review. Entries contain selection conditions, not repeated copies of the guidance. Independent procedures such as arena and prototype are still chosen by the Entry; no playbook chains another playbook.

Statechart is not deleted or duplicated. Its documentation, runtime, and fixtures have one home at `skills/create-formal-verification-skill/references/statechart/`. `STATECHART.md` is supporting documentation rather than SKILL.md. Formal maintenance links to this same directory. The original `/statechart` registration is removed, and the formal generator no longer tells new project skills to invoke it. New generated checks prefer existing project tooling; when they need the bundled runtime, they receive project-owned runtime files and documented prerequisites so they do not depend on a plugin cache path. This affects future generation instructions only; no existing project artifact is migrated here.

Shipping is removed. The remaining catalog is exactly nine Entries plus four manual-only create/maintain workflows. This task changes no account installation or external project files.

## Workflow and principle-routing format

All thirteen remaining skills use `## Workflow` followed by `## Select principles`. Descriptions start with a direct use trigger. Workflow steps own task sequencing, outputs, and completion; the lower table owns selection cues for applicable principles. Read a selected principle when the corresponding decision arises, rather than after completing the workflow. Playbooks appear only in the relevant workflow step. No playbook chain or repo-wide routing mode is added.

The approved bug-fix draft is applied. Reproduction and the task-scoped check for sibling faults are removed from fix-root-causes because the Entry owns those phases. Maintenance no longer repeats the enforcement-choice method; that method now sits with encode-lessons-in-structure, including its justification and a broken/valid-case check. Original principle applicability descriptions are preserved. Other principle policy changes remain outside this formatting pass.

The four create/maintain workflows receive the same layout and trigger-first descriptions while retaining their separate methods. App creation still emits Launch, Doctor, Drive, Evidence, Cleanup, Helpers, and the original feature-map sections. App maintenance still performs source and live coverage, restricts edits, retries a doctor fix once, preserves evidence, and limits changed output to one corrections PR. Formal creation retains tool selection, code fidelity, negative controls, coverage/sync records, and a proven generated skill; formal maintenance retains sync history, drift-versus-bug classification, property-change evidence, negative controls, and per-check outcomes. Their owned resources and the shared statechart toolkit are unchanged.

The user-deleted evaluate skill is not restored. Inventory and installation documentation describe nine Entries plus four manual-only workflows. No account settings, generated project verification artifacts, or role agents are changed.

## Update an installation

1. Update or reload the whole plugin through the host's normal flow. A version change invalidates cached copies; do not edit an installed cache manually.
2. Remove old instructions requiring onyo-mode, separate principle activation, or playbook-* slash commands. Preserve project-owned requirements.
3. Keep the whole shared plugin directory. Entry-only ZIPs are not a supported distribution of this layout. Account/Chat installation and machine-local/Code installation are different scopes.
4. Use the four original create/maintain commands for their specific jobs. Do not replace existing project verification files just to adopt the new Entry catalog.
5. Keep memory, history, PR settings, and scheduling native. This migration changes no account settings or files outside the repo.

The supported path substitution is documented for Claude Code plugins. Account-synced plugin loading is documented, but shared file access in the user's specific Chat-installed cloud/Project environment remains untested. A live smoke check should confirm an Entry reads a shared principle outside its own directory after marketplace/account installation, including a nested relative reference. Static validation cannot establish this or guarantee automatic skill selection.

## Validation

Run `claude plugin validate --strict .` and validate the marketplace, skills, and agents with the native CLI. Also validate skill frontmatter, every document-relative and plugin-root Markdown link, reachability of retained shared guidance from Entries, exact principle applicability text, and preservation of the four distinct workflow protocols and their owned resources. Check the installed-copy layout without relying on the source checkout. `git diff --check` must pass.

Completed checks cover native plugin, marketplace, skill, and agent validation; metadata and invocation policies for all 13 skills; all internal Markdown links; reachability of shared principles/playbooks from Entries; exact applicability text for the 24 original principles; preservation of the four specialized workflow protocols and byte-for-byte preservation of their examples, statechart runtime, fixtures, and operating documentation; and a copied-package path check outside the source tree. Statechart runtime source, fixtures, and both role-agent definitions are unchanged; statechart operating-document path labels reflect the new resource location. The generic skill-creator validator checks common metadata in scratch copies without Claude's invocation flag; the native CLI and explicit metadata checks validate that supported flag without altering source.

The relocated statechart toolkit also passed all 67 existing pipeline, chart, and message tests. These exercise local imports, captured model data, diagrams, and reports; they do not install or run Java/TLC or establish live formal-verification coverage. Those folder-migration checks covered 158 internal links and all 33 shared documents. Current checks additionally validate the common skill structure, trigger descriptions, routing placement, manual invocation flags, original principle descriptions, and the preserved specialized procedures and resources. All 26 principles and five independent playbooks follow the requested folder structure.

For the 0.3.3 format pass, all thirteen skills pass the structure and metadata checks, every original specialized workflow section or pass item is retained, and all 168 internal links resolve. All 33 shared documents remain reachable from the nine Entries, including in a copied package outside the source checkout. The verification examples, statechart toolkit, and role agents are unchanged. No live skill-selection evaluation or new statechart execution was performed for this instruction-only change.

No live models, paid eval trials, real app-driving sessions, account installation, or cloud execution are needed for the source migration. Those remain separate empirical checks, rather than claims implied by a validator pass.

## Platform sources

Checked against official documentation on November 2, 2026:

- [Skill discovery, invocation control, and supporting files](https://code.claude.com/docs/en/skills).
- [Plugin-root path substitution](https://code.claude.com/docs/en/plugins-reference#environment-variables).
- [Plugin copying and account sync](https://code.claude.com/docs/en/plugins/loading).
- [Agent Skills format](https://agentskills.io/specification).
- [Claude account skill packaging](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills).
- [Native subagent models, allowlists, and turn limits](https://code.claude.com/docs/en/sub-agents).
