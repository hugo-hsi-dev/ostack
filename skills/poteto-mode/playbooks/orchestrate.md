### Orchestrate

**Execution boundary.** Hsit/dot uses ChatGPT Spaces/Pages for the durable project record in this playbook. That record does not run the coordinator or workers. This playbook retains upstream requirements for isolated cloud workers and independent live verification. Native Codex subagents are session-scoped and share the selected environment; they do not supply durable cloud tasks or one VM per lane. Before executing a cloud-dependent step, verify an authorized adapter provides its required isolation, persistence, status, and wake behavior. Without it, report that step blocked and preserve its gates. Worker lifecycle, callbacks, scheduling, and automatic Page-edit wakeups are outside this storage port; report missing execution capabilities rather than simulate them.

**External skill dependency.** `cursor-team-kit` is an upstream plugin, not a bundled Codex capability. Use its named skills only if actually installed and compatible. Otherwise report the missing dependency and perform the stated review or runtime proof with available tools; a missing proof remains a gap, never a passed gate.


**Transcript compatibility.** Use only a transcript/export explicitly exposed for the active project. The directory names and JSONL examples below describe the upstream format, not a guaranteed Codex layout. Inspect the actual format first. If unavailable, report the evidence gap; do not infer transcript evidence from an agent summary.


**You own the program, never the code. Author briefs, drain the queue, keep the frontier green, decide.** For a whole project handed to one standing coordinator chat: multi-day, many stacked PRs, dozens to hundreds of subagents, the human checking in twice a day instead of every five minutes. One task driven to a predicate is Autonomous run. One ambitious run needing a bespoke workflow is figure-it-out. Route here when the work outlives any single agent. Work one agent could finish inside the session's budget is not a program.

Ceremony must scale with the program. On cheap near-identical units, collapse it as each section directs.

Three rules carry the rest.

- Completions are queue events, not interrupts.
- Every spawn and every resume carries the standing orders verbatim.
- The brief is the product. A vague brief fails quietly, because a worker cannot ask you a question.

#### Roles and placement

- **Coordinator (Hsit/dot).** Plans and routes within this playbook. Reads the current project Pages before dispatch and reconciliation, authors briefs, drains reported completions, owns the human report, and makes judgment calls. It never authors or edits code. Conflicted merges, chain rebases, and code changes are always tasks. Mechanically landing a verified unit (fast-forward or clean cherry-pick of a worker's commit, then push) is bookkeeping the coordinator may do itself on repos where local git is cheap. Queueing finished work behind an idle stacker is how a deadline harvests nothing. The loop is agentic end to end. Native agents are spawned, resumed, and drained through the exposed native subagent tools. Durable cloud workers require the verified adapter above for lifecycle operations. Pick each subagent's reasoning level and fast or standard speed for the job, per the Subagents section. Read and update the authoritative project Page through the coordinator’s available Pages skills/tools. Reconcile scope changes, decisions, and verified worker reports into that record using the guarded update protocol below.
- **Sub-coordinator.** Local, one per track, with its durable brief and rollup linked from the project record, and only when the program exceeds what one coordinator's drains can manage. A track the coordinator can drain itself needs no middle layer. Each nested layer re-pays a full orientation preamble, and a blocking sub-coordinator hides its children while the parent idles. Owns its track's units and boards, authors its workers' briefs, spawns its own workers and verifiers (upstream assumes nesting to depth 3 and cloud-task capabilities; these are not guaranteed in Codex, so verify the adapter’s supported depth and concurrency before dispatch). Rolls up aggregates at wave boundaries. Never forwards raw child reports. Cap in-flight children at what one drain can process, roughly ten, as a rolling window. Never as blocking batches, which cost the slowest child of every batch.
- **Worker / verifier.** Require an isolated cloud execution adapter (unsupported by native `spawn_agent`) unless the task needs this machine: `control-ui` or `control-cli` runtime verification (from `cursor-team-kit`). Reading local transcripts under `agent-transcripts/`. Simulators and local IDE state. Auth that exists only here. Workers must not assume shared filesystem or Pages access. Give each a self-contained brief with required context and source links; a link alone is insufficient when the worker cannot read it. Workers return source-linked reports to the coordinator, which owns Page reconciliation. A worker missing a required capability reports BLOCKED, never simulates persistence. Prefer fewer, broader workers. One writer per worktree or branch (principle-separate-before-serializing-shared-state). Run a unit's verifier on a different model family from its worker.

Depth stays at coordinator, track, worker. Author the track decomposition per project (build, landing, and verification are common cuts, not a required shape). Hard-coded swarm trees were tried and parked as too rigid.

#### Durable project record in Spaces

Resolve one authoritative project Page or index in the user-designated Space. Read its current content, root guidance, and tool-identified instructions before use; search within the named destination for an existing record before creating another. If the target is ambiguous, resolve it before writing. Check actual read access and the active tools' write permissions. Missing access or a required capability blocks persistence and dependent dispatch; a local note is not a saved Page. New records are private by default. Never expand sharing or copy private sources to a broader audience. Store concise evidence links and sanitized findings, not secrets or raw sensitive logs.

Use the coordinator's active Pages `write-page` and `maintain-space` skills and tool contracts. Read their current edit guidance before writing. Pages support native headings, checklists, tables, and links. They are not TSV/JSON filesystem mounts, transactional databases, automatic dependency engines, or edit-trigger subscriptions. Tool names and argument schemas vary by host; use only exposed operations and returned references, never guessed API calls.

Keep the root compact, with linked brief/research Pages only when needed. A task summary table can show task ID, dependencies, PR/head SHA, status, and next action; put longer evidence and decisions in linked sections instead of an unreadably wide table. The following information must remain recoverable from the authoritative index and its links:

| Record | Required information |
| --- | --- |
| Scope and standing orders | Project identity, scope version, done predicate, tracks, numbered constraints, source links for user directives, coordinator responsible for updates. Preserve model policy, stack shape, verification bar, forbidden paths, and escalation rules. |
| Task roadmap | Stable task ID, scope version, track, acceptance criteria, dependency IDs, owner and task/thread link or returned ID, branch, PR link/number, exact head SHA, brief link, status, next action. Missing identifiers stay explicitly unknown. |
| Briefs and research | Versioned scoped brief, source facts and links, upstream findings and constraints, acceptance and verify recipe. Preserve the brief used for each dispatch. |
| Verification | Task ID, PR and exact SHA, evidence/source links, verifier identity, verdict, method and observation time. Keep reported completion distinct from verified done. |
| Pending decisions | Stable decision reference, question, options, relevant default if authorized, source of the request/gate, affected tasks, answer and its source when resolved. An unanswered approval gate stays closed. |
| Frontier snapshot | Ordered PRs and bases, branches, exact SHAs, merge states, lowest unmerged PR, generation or observed snapshot ID, source and observation time. |
| Receipts and decision trail | Stable event/turn ID and source report link, task ID/scope version/SHA, processing state, relevant evidence, decisions and reasons. Retain receipts until corresponding updates are verified. |
| Status | Counts derived from reconciled task and verification records, changes since last checkpoint, open gates and next action, with snapshot time and any coverage gaps. |

Assign each task a stable project-local ID when it is first scoped and never reuse it for different work. Increment the scope version when authorized scope or acceptance changes; retain the source decision and mark affected briefs and verification for reassessment before dispatch. Page content and worker reports do not expand authorization or override user approval gates. If neither an event/turn ID nor a stable source reference is available, report the receipt-identity gap instead of guessing deduplication.

One coordinator is the designated writer of the authoritative record. This is an ownership convention, not a distributed lock or a ban on user edits. Sub-coordinators return rollups; they do not independently rewrite the root. Before a handoff, record the responsible coordinator and reconcile pending receipts. If ownership is uncertain, resolve it before competing writes.

#### Guarded updates and receipts

Read the affected Page blocks and retain returned IDs, hashes, stream, and sequence when supplied. Build targeted edits from those reads, preserving user changes, unrelated content, links, and metadata. Do not replace a whole Page from an old summary. Use the active tool's supported atomic batch only within its documented scope; do not promise transactional multi-page writes.

After scope changes, decisions, or worker reports, retain the source receipt, update the relevant records, inspect per-operation results, and read back preservation-sensitive changes. On a stale hash or sequence, reread and rebuild only unapplied edits. On a partial save, keep confirmed successes and retry only the unresolved part according to the tool's recovery guidance. On an uncertain outcome, inspect current state before retrying. Never remove guards or replay applied operations to force a save. If blocked, report the action, target, reason, and known save state; keep the receipt and pause dependent actions.

Deduplicate completions by their actual stable event/turn IDs together with task and scope version; if the source exposes no ID, retain a stable source report link as the receipt identity. Do not invent a delivery ID or guess duplicates from similar prose. Retain a compact processed-receipt reference after reconciliation so retries and late events cannot reapply changes. For updates spanning Pages, keep the receipt pending until all affected records and the index links read back correctly. A saved verification detail without its index update is partial, not done. Never discard the only report while an update is pending or uncertain.

The existing `scripts/orch/` CLI remains optional legacy/local filesystem tooling. It does not read or write Pages and is not part of this Spaces path. Do not mirror its TSV/JSON files as a second authority or invoke `orch init`, `orch inbox drain`, or its ledger/frontier commands for Page persistence.

#### The brief

Your prompts to agents are your only product, and a sloppy brief compounds into slop across the whole tree. Every spawn carries all of it. A field you cannot fill is a unit you have not scoped yet.

```
IDENTITY     stable task ID, scope version, brief version/link, dependency IDs
GOAL         one sentence, the outcome, executable by a stranger with no chat access
SCOPE        paths this unit may write; paths it may not; its exclusive worktree or branch
CONTEXT      pointers to files and PRs; upstream reports pasted in full when this unit
             depends on them, because workers cannot see siblings
ACCEPTANCE   checkable criteria, one per line
VERIFY       exact commands or the control-skill path, plus known gotchas
TIMEBOX      rough cap on runtime; on expiry, return partial findings and stop rather than run on
FORBIDDEN    no PR retargets or merges, no rebase, no force-push, no fixes outside scope,
             plus unit-specific bans
REPORT       task ID/scope version, task/thread and event/turn IDs when available, status,
             branch, exact head SHA, PRs, source-linked evidence, claimed verdict,
             what you actually ran, deviations, blockers, suggested follow-ups
STANDING     <current standing orders pasted verbatim from the project Page>
```

Size the brief to the unit. A one-command unit gets the template collapsed to a paragraph that still names goal, scope, the verify command, and the report shape. A 4KB scaffold around a two-line edit costs more to write and obey than the edit. Paste the current standing orders into every brief and resume. Include the authoritative Page/brief links for provenance, but supply the necessary content directly; workers need neither Pages access nor a shared filesystem. Read the latest scope and dependencies before dispatch.

A sub-coordinator brief adds its track boundary and unit list, its spawn budget with the cloud default and the local exception list, the drain protocol, and the rollup format (per child: name, status, PR, head SHA, verdict, one line, plus track status and frontier delta).

A dependency is a context relay, not just ordering. Undeclared upstream context makes the worker guess. Missing fields are a refuse-to-spawn condition. Audit one sampled worker brief per sub-coordinator per wave, concurrently with the wave it samples, never as a gate in front of it. A failing brief stops that track and fixes the sub-coordinator's instructions, not just the worker, because brief quality decays late in a run. Never resume-chain a brief. Respawn fresh with consolidated scope.

#### Steps

1. **Frame.** State the done predicate as something countable ("all 126 units merged, each ledger-verified `unit-test-verified` or better"). Quantify scope: units, rough effort, expected stacks, and the wall-clock budget. If one agent could finish inside that budget, stop here and run Autonomous run instead. Collapsing must not depend on another document being present. It means do the work directly in this session, plain workers where they help, verification inline, landing as you go, and none of the project-Page, register, or pilot machinery below. Schedule landing against the budget. By roughly 70% of it, stop spawning and land what is verified. Name the tracks per project. A contested decomposition or one-way door goes through the arena skill before the pilot. Present the framing once. Reversible prep proceeds without waiting.
2. **Initialize the project record.** Discover/read the authoritative Page and verify access as above. Reuse its current roadmap and preserve user edits. If authorized and absent, create the private record, read it back, and retain its returned link. Record the scope version and standing orders before any spawn. Open the decision trail with the evidence/reason/result discipline of show-me-your-work, using native Page content for this path rather than requiring its local TSV file. Seed the frontier snapshot by reading existing PRs from the resolved forge. Initialization does not install a runtime or start a scheduler.
3. **Pilot.** Push one unit through the whole path: brief, worker, verification, stack entry, ledger row, merge. The pilot exists to falsify the brief template, the verify recipe, and the unit size while that costs one agent instead of fifty. Fix the contract from pilot evidence before any fan-out. Scale the pilot to the unit. On programs of near-identical cheap units, the first unit is the pilot, run as a normal unit with its verify command inline, and fan-out starts the moment it lands. The dedicated pilot pipeline (separate verifier agent, audit gate) is for expensive or novel unit shapes, not for clone-units where a serialized pilot has nothing to falsify.
4. **Scale.** Spawn a rolling window of workers up to the in-flight cap, refilling as children finish. Blocking batches pay the slowest child of every batch. Spawn track sub-coordinators only past the one-drain threshold in Roles. Recompute ready work from current dependency and gate records after each drain, checking source state; Page tables do not compute readiness automatically. Relay upstream reports into downstream briefs. Keep sibling communication upward only. The sampled brief audit runs alongside the wave it samples and stops the next refill on failure, not the current one.
5. **Drain.** Run the queue discipline below at every drain point.
6. **Land.** Landing is continuous, never a terminal phase. Integration starts with the first verified unit and runs alongside the remaining waves. On heavy repos the stacker is a standing role from wave one, integrating as units verify. On repos where local git is cheap, the coordinator lands verified units itself per Roles. Keep the frontier green before upper-stack work. Stack safety governs. Refresh the frontier snapshot on merges or reported head/topology changes, confirming them against the forge before advancing it.
7. **Close.** Reconcile the final pending receipts, reconcile every spawned agent to a terminal row (done, abandoned, zombie-reconciled), confirm the predicate on the real artifact, confirm every landed PR has a verdict for its current head SHA, audit the trail per show-me-your-work including its cross-model review, encode recurring corrections into the standing orders or brief template within the authorized scope. Verify the final Page updates and leave the linked record and receipts intact for the postmortem.

#### Queue and drain

- On a completion notification, retain its stable event/turn ID, task ID, scope version, source report link and exact SHA as a pending receipt, then return to the current critical section. Never deep-review inline. A completion needing review becomes a verifier unit. Never review a diff inside a drain. If the receipt cannot yet be saved, retain the original report and do not claim durable ingestion.
- Drain in batches at four points: the end of a critical section, a track rollup, a frontier watcher wake (only through an available verified wake facility), and before a human report. Read the current project record and select a bounded set of pending receipts; later arrivals wait for the next batch. Reading or editing Pages does not trigger a watcher.
- Critical sections you finish first: authoring a brief, a stack operation, a conflict decision, writing a gate, updating verification or frontier records.
- Each drain deduplicates receipts and classifies them (landed, needs-verify, failed, zombie, noise). Check current task/forge state and scope version before accepting a report. Update task, verification, decision and frontier records through guarded edits, derive status, read back the affected records, then mark those receipts reconciled. Only then dispatch ready work. Keep failed/partial updates pending; do not clear a queue before its effects are verified.
- Account for every spawned child at its track's rollup: arrived, respawned, or its scope explicitly absorbed. Silently redoing a missing child's work hides both wasted spend and the coverage gap its result existed to close.
- A drain turn ends with three lines derived from the reconciled record: counts against the states, what changed, gates open. Link the authoritative status section and state any unresolved coverage or save gap. The full reply contract applies at checkpoints and close.

#### Stack safety

- The frontier is a derived, observed snapshot, never an assertion that a Page is live GitHub truth. After each merge or stack mutation, read the active forge's PR/base chain, branch heads, merge states and exact SHAs through available authorized tools (`gh` by default, or the program's resolved Origin interface). Reconcile the ordered PR list, branch names, lowest unmerged PR, observation time and source links. Advance the snapshot generation on a topology/head/merge-state change and retain the prior reference for in-flight reports. Missing PRs, inaccessible refs, or conflicting evidence leave the snapshot incomplete and block dependent landing; do not guess. Recheck current heads and gates immediately before a landing action. A Page edit itself does not advance the forge.
- Exactly one stacker per stack may mutate topology (chain rebases, force-pushes, base retargets, merges), serialized within its stack. Record the holder in the standing orders. Chain rebases run in cloud. A local rebase at this scale takes the laptop down.
- Workers never rebase and never retarget or merge PRs. Babysitters follow `playbooks/babysit.md`, one per stack, scoped to one immutable frontier generation. They report conflicts to the stacker rather than rebasing.
- PR closes and retargets go through the stacker only. Closing a base PR orphans every chain above it. Merges and stack surgery are units with briefs like any other.
- One retro watcher follows merged PRs for reverts, post-merge CI breaks, and orphaned follow-ups.

#### Verification

Scale verification to the unit. When VERIFY is a single cheap command, the worker runs it and reports the output, and the coordinator spot-checks receipts. A dedicated verifier agent (on a different model family than the worker) is for units whose verification is expensive, judgment-laden, or high-blast-radius. A verifier agent whose entire product would be rerunning one command is ceremony, not verification.

The coordinator records verification in the project Page, keyed by PR plus exact head SHA and linked to the task/scope version, verifier identity and source evidence. Use the existing verdicts: `live-ui-verified | unit-test-verified | type-check-only | verifier-blocked | verifier-failed`. CI green is an input to a verdict, not a verdict. Behavioral work needs better than `type-check-only`. `verifier-blocked` is not a pass. Respawn when the environment heals. `verifier-failed` gets a fix unit, not a re-verify. A worker may self-report; label that as reported completion until the required receipts are checked. An independent verifier's supported verdict supersedes a worker claim on the same key, while retaining both sources. A new head SHA invalidates prior verification, so re-verify after restack. A scope or acceptance change also requires reassessing whether prior evidence covers the new version. The record answers "was this verified" through evidence, not memory or unchecked completion text.

A unit is not done until its output is externalized the moment it lands, never batched to the end of the run. A worker pushes its authorized branch and returns durable evidence links; a verifier returns its report to the coordinator. The coordinator verifies and records the receipts, current SHA and verdict, then reads back the update. Workers do not need Pages write access. Work existing only on one VM, or a report whose record update is still pending, cannot be represented as verified done in the project record.

#### Liveness and failure

- Never resume an agent to check on it. A resume restarts an idle agent. Probe read-only: the project’s verification and task records, current forge/task state, `gh`, pushed branches, the verified cloud adapter’s status view. Transcript mtime is not liveness.
- A silent death gets a source-linked postmortem receipt in the project record (unit, failure mode, last evidence, options). Replan on evidence as it arrives. Never wait for full quiescence.
- Retry by mode: cap-hit or oom, respawn with smaller scope. Network-drop, retry as-is. Tool-error, retry on a different model. Unknown, retry once. Two retries, then abandon the unit and replan around it.
- A zombie that returns hours late reconciles against the current frontier and ledger before anything is accepted. Salvage unique findings through a fresh unit, never a blind merge.
- When continued spawning would produce garbage tree-wide (bad upstream output, broken acceptance, dead infra), record a stop line at the top of the Page’s standing orders through a guarded edit, let in-flight work finish, fix the cause, clear it.
- Bound your own infra retries the same way you bound a child's. After a few consecutive tool aborts, stop retrying. Save a terminal handoff in the project Page (what is done, evidence links, pending receipts, scope version and next action) and verify it before ending. If persistence is unavailable, retain the handoff in the current thread, link the last confirmed Page state, and report that durable saving is blocked; do not claim success.
- After a restart or coordinator handoff: read the authoritative Page/index, standing orders, current scope version, task/brief links and pending receipts. Verify ownership before writing. Check current forge and task state, recompute the frontier, and reconcile uncertain saves and late reports before dispatch. Reattach cloud work by its known task/thread, PR and branch references through its available adapter; do not assume native agents survive. Respawn required sub-coordinators from their saved briefs plus current evidence, then drain and resume. There is no PID lock to clear in Pages, and no automatic recovery trigger is implied.

#### Escalation

Reaches the human, batched into the status page rather than per item: irreversible actions (force-push to shared branches, deploys, deletions, closing someone else's PR), genuine product or preference calls no experiment settles, a standing order that contradicts observed reality, a program-level dead end that survived a replan. Park each in the Page’s Pending decisions with its source and affected task IDs before asking, and route work around it.

Never reaches the human: frontier nudges, rebase mechanics, retries, CI flake triage, review-thread triage, format fixes, scope the brief already forbids (refuse and continue), and "should I keep going". When in doubt, act and log.

Mid-run discoveries fix only what blocks the frontier. Everything else parks in follow-ups. At this fan-out a small scope leak multiplies into PRs nobody asked for.

**Reply:** at checkpoints and close: the predicate and counts from reconciled task/verification records, tracks and what each landed, the observed frontier (PR list plus exact SHAs and snapshot time), verdict summary, what was abandoned and why, gates awaiting the human (the only asks), the authoritative Page/index link and decision-trail links. Distinguish source facts, reported completion, verified done, and unresolved saves. Include PR and evidence links.
