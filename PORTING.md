# ostack audit and migration

## Current architecture

Version 0.3.1 replaces the previous 45 independently discoverable skills with ten outcome-based Entries and six specialized callable skills. Entries route conditionally to ordinary Markdown inside the same plugin. No onyo-mode or repo-wide prerequisite returns.

```text
ostack/
├── .claude-plugin/       manifests
├── skills/              10 Entries + 6 specialized skills
├── principles/          24 original rules + preserve-contracts; TypeScript applications
├── playbooks/           design, prototype, compare-artifacts, measure, arena, swarm
└── agents/              bounded Haiku idea scout and Opus judge
```

Only `skills/<name>/SKILL.md` registers a skill. Entries use `${CLAUDE_PLUGIN_ROOT}` for direct reads. Shared documents use relative links from the document's directory; those links are navigation for a read tool, not automatic context inclusion. Keep every dependency inside the plugin root. Installing an individual Entry ZIP does not include its sibling shared folders.

## Migration from the old standalone methods

| Previous skill or group | Destination |
| --- | --- |
| 24 principle-* skills | principles/<name>.md; exact applicability descriptions retained. |
| playbook-arena, playbook-swarm, playbook-prototype | playbooks/arena.md, swarm.md, prototype.md; shared procedures, no slash commands. |
| architect | Direct principle selection in each applicable Entry, plus playbooks/design.md for an unresolved design question. The intermediate architect router is removed. |
| interrogate, blast-radius | Review owns scope, contract tracing, adversarial checks, and findings. The shared preserve-contracts principle serves feature, review, maintenance, and refactor. |
| correct | Maintenance owns the enforcement workflow. Encode-lessons-in-structure supplies the reusable rule, also selected by bug-fix for requested prevention. |
| tdd | Bug-fix owns the failing-before/passing-after regression procedure and the conditions for skipping impractical new tests. |
| typescript-best-practices | principles/type-system-discipline/typescript.md applies the owning principle to TypeScript; no intermediate best-practices router. |
| unslop | Technical-writing owns the editing procedure and scope/voice constraints. |
| verify-feature-map, visual-parity | Verify owns coverage, real driving, triage, and evidence. Shared comparison mechanics live in playbooks/compare-artifacts.md, also selected by feature and refactor. |
| formal-verification | Removed the combined creation/maintenance replacement; restored the original four separate workflows below. |
| bug-fix, refactor, investigate, performance, technical-writing, evaluate | Rewritten as outcome owners with their own procedure, evidence standard, stopping condition, and direct selection of principles/playbooks. |
| shipping, statechart | Retained as specialized callable skills; statechart tools and fixtures unchanged. |
| feature, review, maintenance, verify | Rewritten around the complete outcome, rather than forwarding to renamed old skills. |

The old principle and playbook slash commands intentionally disappear; no aliases keep their descriptions in the catalog. Ask through the appropriate Entry. Shared documents may also be read directly when their file path is already known.

## Original verification workflows restored

The following directories, including all supporting feature-map examples, are restored byte-for-byte from ostack commit `798dcee`:

- skills/create-verification-skill/
- skills/maintain-verification-skill/
- skills/create-formal-verification-skill/
- skills/maintain-formal-verification-skill/

Their original names and manual-only invocation flags remain. App creation produces and executes a project-local driving skill and seeds its map. App maintenance has full-map source and live passes, limits edits to verification, and ships at most one corrections PR. Formal creation chooses a tool, proves a meaningful property can fail, and generates its reusable verification skill. Formal maintenance reviews code changes since the sync commit and updates the check without concealing product bugs. Creation is not maintenance.

This explicitly restores the original workflow and execution cost, rather than imposing the cheaper Entry defaults on them. No Entry silently invokes those manual-only workflows or reads their bodies to bypass invocation policy. The verify Entry uses the project's existing verification setup and points users to the appropriate explicit workflow when creation or full upkeep is needed.

Existing generated project verification files are untouched by this migration. The verify Entry preserves existing names, locations, structure, commands, and coverage meaning. No new ostack-only output contract is introduced. Restoring source does not establish end-to-end interoperability with a colleague's pstack installation. Project-local generated skill discovery can differ in cloud/Project threads; report unsupported discovery rather than silently rewriting the artifact.

## Principle preservation and routing

All 24 applicability descriptions matched upstream pstack when checked on November 2, 2026 and remain unchanged in the new Markdown bodies. Bodies preserve the rules; old skill-name references are now relative file links. Type-system guidance points to its TypeScript application document. This migration changes packaging and navigation, not the substantive principle wording.

Entries carry concrete selection conditions. Feature and refactor can both select redesign-from-first-principles; bug-fix selects root causes and TDD; review selects correctness and downstream-contract methods. Entries select the relevant principles directly. Playbooks carry reusable procedures without an additional principle-routing layer. Read only the applicable documents, not all files linked from them. Available tools, authorization, requested scope, and project constraints still govern execution. A context-budget principle does not grant permission to launch delegates, and a sequencing principle does not authorize rewriting a shared branch.

## Rewriting the intermediate references layer

The first Entry migration moved old methods into shared references but left a second routing/workflow layer. This rewrite removes that layer. Entries own their task procedure and select principles and playbooks directly. The former shared references directory is removed; original verification examples and statechart operating files remain local resources of their untouched skill packages.

Shared content earns its place through reuse. Design is not exclusive to feature work: its procedure helps refactors, design-related bug fixes, performance representation changes, integration migrations, and requested design critique. Each Entry selects the applicable domain, boundary, ownership, type, or reader-load principles before choosing the design playbook. A straightforward edit does not trigger a design exercise.

Comparison and measurement are reusable procedures across task domains, so they are playbooks. Preserve-contracts is a new decision rule, selected where supported consumers or stored data constrain a change. TypeScript examples apply type-system discipline and live with that principle. No broad third shared category or hidden set of renamed task skills is introduced.

## Mock routing stress checks

These are source-level walkthroughs, not live model-selection results. No skills or agents were invoked.

| Scenario | Entry-owned work and relevant shared content | Stop or exclusion |
| --- | --- | --- |
| Add export to an existing results flow | Feature defines acceptance conditions, selects redesign and experience principles, and designs only if the shape is unresolved. | Implement and drive affected paths; no automatic panel or generator. |
| Fix a typo in a label | Feature makes the bounded edit and checks the visible result. | No design playbook, prototype, or extra model. |
| Race caused by two state owners | Bug-fix reproduces first; shared-state/model principles and design can resolve ownership; regression fails before and passes after. | No broad architecture campaign for an isolated defect. |
| Straightforward arithmetic regression | Bug-fix owns the cheap failing regression check and minimal fix. | No TDD wrapper or design playbook is needed. |
| Refactor phase-based modules | Refactor selects domain-modeling and reader-load rules, then design for the new boundary; checks equivalence. | No new user-visible behavior. |
| Review a split-ownership proposal | Review traces the consequential failure; model/shared-state/reader-load principles support judgment. | Design playbook only if replacement-design work is requested; no product edits. |
| Replace a quadratic lookup in a hot path | Performance establishes a baseline and limiter; model principle and design resolve representation if necessary. | Measure one selected intervention; no default brainstorming panel. |
| Upgrade an SDK with a changed integration boundary | Maintenance checks actual versions and consumers; preserve-contracts/boundary principles and design apply to the unresolved interface. | Routine updates with a known migration skip design. |
| Prevent a recurring invalid repo state | Maintenance selects encode-lessons-in-structure and chooses an existing structural guard; checks broken and valid cases. | No transcript mining or repo-wide hardening. |
| Edit an existing README | Technical-writing owns editing, voice, examples, and link checks. | No unslop wrapper, design stage, or mandatory second pass. |
| Verify a UI migration against screenshots | Verify owns mapped states and live behavior; compare-artifacts controls the reference and captures. | Pixel parity does not prove interactions or accessibility. |
| Compare two agent prompts | Evaluate owns fair trials and anonymous assessment; explain-the-number/measure apply to quantitative conclusions. | No minimum trials or unapproved paid model panel. |
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

All six playbooks are plain Markdown. Arena compares distinct proposals for one question; swarm partitions brainstorming across areas; prototype tests a concrete uncertainty in a disposable experiment. Arena and swarm keep Haiku at idea generation: no writes, commands, tests, implementation, or make-it-work loops. Three candidates and one Opus synthesis are the default. Opus owns requested implementation and verification.

The existing idea-scout and idea-judge agent definitions retain read-only tool allowlists, four/six-turn caps, and omission of automatically loaded project instruction files. The owner supplies relevant constraints. No nested fan-out, automatic second round, fallback model, or automatic resumption after a cap. Native agent availability and effective model controls must be checked in the target host. These are execution bounds, not measured savings.

## Review of the 22 original onyo-mode playbooks

| Original playbook | Current disposition |
| --- | --- |
| authoring-a-skill | Native skill-authoring tools; no extra routing playbook. |
| autonomous-run | Native scheduling or loops when requested, with explicit scope and a stop condition; no automatic wake machinery. |
| autopilot-full | Native Projects and user-authorized delivery; no per-PR owner/verifier swarms or standing audit heartbeat. |
| autopilot-stack | Native Projects and PR handoff; dependency-sensitive landing is covered by shipping when requested. |
| bug-fix | Preserved in the direct bug-fix skill. |
| eval | Preserved in evaluate, with small controlled trials rather than a mandatory model panel. |
| feature | The feature Entry plus directly selected principles and the shared design playbook; no compulsory delegate or competing implementations. |
| hillclimb | Preserved as the bounded optimization-campaign mode in performance. |
| investigation | Preserved in investigate. |
| multi-phase-plan | Native planning plus verifiable-unit principles; remove the rigid template, ten live lanes, and checker tied to old orchestration. |
| opening-a-pr | Native PR creation and existing session PR; technical-writing covers requested prose. |
| orchestrate | Native Projects coordination. No coordinator skill-loading requirements. |
| pause-safely | Native session lifecycle; no compulsory WIP commit or separate handoff archive. |
| perf-issue | Preserved in performance with the shared measure playbook. |
| prototype | Preserved in the shared playbooks/prototype.md, selected from Entries. |
| refactoring | Preserved in refactor. |
| runtime-forensics | Preserved in investigate and performance; collect only the relevant signal. |
| session-pickup | Native session/history tools; no local transcript crawling. |
| shipping | Retained as a focused shipping skill for explicitly authorized stack landing. |
| trace-forensics | Preserved in investigate and performance; no mandatory SQLite conversion or delegate. |
| visual-parity | Verify owns the outcome; compare-artifacts supplies reusable comparison mechanics for verify, feature, and refactor. |
| worktree-cleanup | Native worktree lifecycle; remove transcript/pinned-chat assumptions and automatic simulator/cache deletion. |

## Update an installation

1. Update or reload the whole plugin through the host's normal flow. A version change invalidates cached copies; do not edit an installed cache manually.
2. Remove old instructions requiring onyo-mode, separate principle activation, or playbook-* slash commands. Preserve project-owned requirements.
3. Keep the whole shared plugin directory. Entry-only ZIPs are not a supported distribution of this layout. Account/Chat installation and machine-local/Code installation are different scopes.
4. Use the four original create/maintain commands for their specific jobs. Do not replace existing project verification files just to adopt the new Entry catalog.
5. Keep memory, history, PR settings, and scheduling native. This migration changes no account settings or files outside the repo.

The supported path substitution is documented for Claude Code plugins. Account-synced plugin loading is documented, but shared file access in the user's specific Chat-installed cloud/Project environment remains untested. A live smoke check should confirm an Entry reads a shared principle outside its own directory after marketplace/account installation, including a nested relative reference. Static validation cannot establish this or guarantee automatic skill selection.

## Validation

Run `claude plugin validate --strict .` and validate the marketplace, skills, and agents with the native CLI. Also validate skill frontmatter, every document-relative and plugin-root Markdown link, reachability of retained shared guidance from Entries, exact principle applicability text, and byte-for-byte restoration of the four original workflows. Check the installed-copy layout without relying on the source checkout. `git diff --check` must pass.

Completed checks cover native plugin, marketplace, skill, and agent validation; metadata and invocation policies for all 16 skills; all internal Markdown links; reachability of shared principles/playbooks from Entries; exact applicability text for the 24 original principles; byte-for-byte preservation of the four restored verification directories; and a copied-package path check outside the source tree. Statechart source, fixtures, and both role-agent definitions are unchanged. The generic skill-creator validator checks common metadata in scratch copies without Claude's invocation flag; the native CLI and explicit metadata checks validate that supported flag without altering source.

No live models, paid eval trials, real app-driving sessions, account installation, or cloud execution are needed for the source migration. Those remain separate empirical checks, rather than claims implied by a validator pass.

## Platform sources

Checked against official documentation on November 2, 2026:

- [Skill discovery, invocation control, and supporting files](https://code.claude.com/docs/en/skills).
- [Plugin-root path substitution](https://code.claude.com/docs/en/plugins-reference#environment-variables).
- [Plugin copying and account sync](https://code.claude.com/docs/en/plugins/loading).
- [Agent Skills format](https://agentskills.io/specification).
- [Claude account skill packaging](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills).
- [Native subagent models, allowlists, and turn limits](https://code.claude.com/docs/en/sub-agents).
