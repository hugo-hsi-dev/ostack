# ostack audit and migration

This revision removes the mode layer and adapts the remaining guidance to native Claude Code, Desktop, and Projects workflows. Earlier deletions remain except for arena and swarm, which return under the requested brainstorming-only model policy.

## Audit findings

- **Routing duplicated skill discovery.** onyo-mode required playbook selection, copied todo steps, principle reads, and further skill loads before ordinary work. Several of those dependencies had already been deleted.
- **Rigor became an unconditional execution cost.** Crossing a function boundary triggered architecture exploration. Feature work required delegates or competing implementations. Reviews required multiple models. Optimization campaigns imposed iteration floors and logs even after useful evidence existed.
- **Automatic discovery was disabled.** Most surviving task skills had `disable-model-invocation: true`. Descriptions could not make them self-invoking while that flag remained set.
- **The port retained platform assumptions.** Custom agent types, model-role files, local transcript paths, explicit session orchestration, and mandatory PR playbooks survived terminology changes from Cursor to Claude Code.
- **The documentation described a different repo.** README links and the porting checklist referenced deleted setup, memory, review, and orchestration components.

## Decisions

| Previous component | Decision and destination |
| --- | --- |
| onyo-mode, its plan checker and worktree audit scripts | Removed. Claude discovers direct task skills; native session tools own coordination. |
| Feature playbook | Removed as generic process. Design and experiments remain available through architect and prototype when needed. |
| Bug fix | Direct bug-fix skill; incorporates root-cause tracing and testing a repeatedly failed premise. |
| Investigation, runtime forensics, trace forensics | Consolidated in investigate. Performance-specific artifact analysis also fits performance. No forced database conversion or parallel readers. |
| Perf issue, hillclimb, benchmark checklist | Consolidated in performance, with a conditional measurement reference. One change per measurement; no iteration floor or self-waking loop. |
| Refactoring, prototype, visual parity, eval | Direct refactor, prototype, visual-parity, and evaluate skills, with bounded task-specific checks. |
| Orchestrate, autonomous run, autopilot variants, multi-phase plan | Removed. Use native Projects, planning, threads, and scheduling when requested. |
| Session pickup, pause safely | Removed. Use native session and memory mechanisms; no transcript scraping. |
| Opening a PR and worktree cleanup | Removed. Use native PR creation and worktree lifecycle; retain project-specific requirements in the project. |
| Shipping | Retained as a small, explicitly requested stack-landing skill. Dependency order and verified integration state remain; per-PR verifier agents, patch-id shortcuts, and automatic watchers are removed. |
| Authoring a skill | Removed as a pass-through. Use the target platform's skill authoring tools. |
| Twenty-four standalone principle skills | Retained as independently discoverable skills, with concrete applicability descriptions and automatic invocation enabled. The umbrella principle index was removed. |
| Design principles | Individual skills preserve the rules, including proactive redesign for new requirements. Architect names relevant skills; native discovery exposes each principle independently. |
| Simplicity and migration principles | Canonical principle skills remain reusable across tasks. Refactor names subtraction, reader load, migration, and redesign as appropriate. External compatibility remains an explicit constraint. |
| Test and measurement principles | Independently discoverable skills expose their own applicability. Tdd and performance also name relevant principles. |
| Experience and alternative-design principles | Experience and design-space skills remain available across domains; prototype names them when those decisions arise. |
| Encode lessons in structure | Preserved as an individual skill and named by correct. The correct workflow remains focused on demonstrated repo failures; native preference memory remains native. |
| Create/maintain app verification skills | Launch-framework generation removed in favor of available native/project tooling. The distinctive feature-map reconciliation survives in verify-feature-map. |
| Create/maintain formal verification skills | Consolidated in formal-verification with maintenance loaded separately. No compulsory generated skill or repo-wide target search. |
| Statechart implementation and fixtures | Retained. Moved detailed instructions behind a short entrypoint; rendering is optional. |
| Architect, interrogate, blast-radius | Retained without deleted skill dependencies, model configuration, or required panels. |
| TypeScript guidance | Retained without a prerequisite skill. Corrected misleading claims about assertions and nonnegative durations. |
| Technical writing, unslop | Retained as independent writing and editing tasks. Removed the requirement to apply both to every reply. |
| Arena and swarm | Restored with three Haiku idea-only proposals and one Opus synthesis. Enforced read-only role agents and turn caps replace unrestricted candidates, model-role files, and recursive fan-out. |
| Other previously deleted skills, old agents, and guide | Left deleted. New idea-scout and idea-judge agents are narrow native roles, not replacements for the old mode wrappers. |

Principles are independently discoverable alongside the task workflows. Their applicability conditions are visible before activation, in their skill descriptions. A task skill can also name a relevant principle using native activation. No umbrella skill, startup index, or repo-wide task router is required.

The first audit pass over-consolidated principles and weakened proactive first-principles redesign. A shared-reference index then hid applicability behind another activation step. The final design retains all 24 principle skills, preserves their substantive descriptions and bodies, and keeps each original discovery description. All 24 were compared with upstream pstack and restored exactly; automatic invocation is enabled. Removed dependencies were repaired. Future substantive edits to a principle should be reviewed as changes to that rule.

This preserves cross-domain reuse at the cost of more short catalog descriptions. Reducing catalog entries alone is not the optimization goal; loaded text and actual execution cost matter too.

Existing generated verification artifacts are treated as shared contracts with original pstack users. Their names, locations, section structure, and verification meaning are preserved during routine maintenance. This is a source-level compatibility policy; end-to-end interoperability remains untested.

## Principle description provenance

All 24 original descriptions in the committed ostack baseline matched the corresponding upstream [pstack principle skills](https://github.com/cursor/plugins/tree/main/pstack/skills) when checked on November 2, 2026. The shortened descriptions from the first revision have been replaced with those exact originals. Required body guidance remains, with removed dependency names and cross-skill links adapted to native skill-name handoffs. Invocation is enabled rather than retaining the upstream explicit-only flag.

## Arena and swarm cost policy

Haiku is a brainstorming tool here. Candidates return ideas and assumptions, never working implementations or claimed test results. Arena gives three workers distinct angles on one problem; swarm assigns different areas to at most three workers by default. Each native idea-scout has read/search tools only, a four-turn cap, and a 250-word proposal limit. It omits auto-loaded instruction files, so briefs must include relevant constraints.

Opus judges and synthesizes once, then owns any requested implementation and verification. The existing Opus owner can judge without another delegate; otherwise one read-only idea-judge has a six-turn cap. No nested fan-out, automatic second round, model fallback, or automatic resumption after a turn cap. Effective model overrides must be surfaced when observable.

The model and tool restrictions are native plugin agent definitions, not an extra delivery system. Individually installed skill files need equivalent native role support before they can promise these controls. These are execution bounds; actual token or subscription-usage savings remain unmeasured.

## Review of the 22 original playbooks

| Original playbook | Current disposition |
| --- | --- |
| authoring-a-skill | Native skill-authoring tools; no extra routing playbook. |
| autonomous-run | Native scheduling or loops when requested, with explicit scope and a stop condition; no automatic wake machinery. |
| autopilot-full | Native Projects and user-authorized delivery; no per-PR owner/verifier swarms or standing audit heartbeat. |
| autopilot-stack | Native Projects and PR handoff; dependency-sensitive landing is covered by shipping when requested. |
| bug-fix | Preserved in the direct bug-fix skill. |
| eval | Preserved in evaluate, with small controlled trials rather than a mandatory model panel. |
| feature | Native implementation flow plus relevant architect and principle skills; no compulsory delegate or competing implementations. |
| hillclimb | Preserved as the bounded optimization-campaign mode in performance. |
| investigation | Preserved in investigate. |
| multi-phase-plan | Native planning plus verifiable-unit principles; remove the rigid template, ten live lanes, and checker tied to old orchestration. |
| opening-a-pr | Native PR creation and existing session PR; technical-writing covers requested prose. |
| orchestrate | Native Projects coordination. No coordinator skill-loading requirements. |
| pause-safely | Native session lifecycle; no compulsory WIP commit or separate handoff archive. |
| perf-issue | Preserved in performance with the measurement reference. |
| prototype | Preserved in the direct prototype skill. |
| refactoring | Preserved in refactor. |
| runtime-forensics | Preserved in investigate and performance; collect only the relevant signal. |
| session-pickup | Native session/history tools; no local transcript crawling. |
| shipping | Retained as a focused shipping skill for explicitly authorized stack landing. |
| trace-forensics | Preserved in investigate and performance; no mandatory SQLite conversion or delegate. |
| visual-parity | Preserved in the direct visual-parity skill. |
| worktree-cleanup | Native worktree lifecycle; remove transcript/pinned-chat assumptions and automatic simulator/cache deletion. |

## Size comparison

Counts use whitespace-separated words, including frontmatter. Instruction Markdown includes entrypoints, references, and old playbooks, but excludes statechart script fixtures. These are source-size measurements, not tokenizer counts or measured billing savings.

| Measure | At audit start, after existing deletions | Revised |
| --- | ---: | ---: |
| Skills | 40 | 45 |
| Words in skill entrypoints | 21,324 | 12,133 |
| Words in all skill instruction Markdown | 37,867 | 15,682 |

The committed baseline before the user's deletions had 58 skills and 35,229 entrypoint words. The working-tree comparison above separates this revision from those earlier removals.

Automatic discovery now exposes short descriptions that were previously hidden by invocation flags. That can increase description context relative to the partially deleted repo. The intended savings come from much shorter loaded guidance and removing forced execution chains; actual usage depends on which skills run and requires live measurement.

Reproduce the current counts from the repository root:

```sh
python3 - <<'PYCOUNT'
from pathlib import Path
entries = list(Path('skills').glob('*/SKILL.md'))
instructions = [p for p in Path('skills').rglob('*.md') if '/scripts/' not in str(p)]
print('skills:', len(entries))
print('entrypoint words:', sum(len(p.read_text().split()) for p in entries))
print('instruction words:', sum(len(p.read_text().split()) for p in instructions))
PYCOUNT
```

## Migrate an existing setup

1. Update or reload the plugin through the host's normal flow. Renamed and removed slash commands intentionally have no aliases.
2. In personal or project instructions, remove ostack-added requirements to load onyo-mode, run Orchestrate, use custom agents, or name playbooks and principles in every thread. Preserve your own project requirements.
3. Retire an old `ostack-models.md` role configuration if it exists solely for the removed workflows. This revision does not edit settings or files outside this repository.
4. Keep account-installed skills from Chat: those are available to local, cloud, and Project work threads. Machine-local Code installs are a different scope. For Projects, you can also add ostack under Project settings > Plugins for new threads; repository skill folders alone do not provision cloud skills.
5. Keep memory, history lookup, PR settings, and automation in the native host. Skills do not assume a local transcript archive, a particular model inventory, or access to tools absent from that session.

Source changes make implicit invocation eligible. They cannot guarantee that a model will select the right skill on every request, or provision skills into a remote account.

## Validation

Run the local manifest and component validator:

```sh
claude plugin validate --strict .
```

Completed for this revision: strict native plugin, marketplace, skill, and agent validation; all 45 skills passed the skill-creator validator; local Markdown links and `git diff --check` passed. No live model-selection evaluation or account installation was run.

Also validate skill frontmatter and local Markdown references. For a source preview, start a fresh local session with `claude --plugin-dir /absolute/path/to/ostack` and inspect available skills. Live automatic-selection checks and cloud installation checks require the corresponding Claude environment; they are separate from static validation.

## Platform sources

Checked against official documentation on November 2, 2026:

- [Skills: discovery, invocation control, and supporting files](https://code.claude.com/docs/en/skills).
- [Projects: coordination, cloud plugin setup, and memory](https://code.claude.com/docs/en/claude-projects).
- [Desktop: sessions and native integrations](https://code.claude.com/docs/en/desktop).
- [Native agent models, tool allowlists, and turn limits](https://code.claude.com/docs/en/sub-agents).
- [Claude model pricing](https://platform.claude.com/docs/en/about-claude/pricing).
- [Claude Code memory](https://code.claude.com/docs/en/memory).

Native feature availability varies by surface and account. The retained workflows use available tools rather than embedding a second implementation of those features.
