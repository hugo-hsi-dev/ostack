---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
---

Read [Codex compatibility](../../docs/harness/codex.md) before using this workflow.

# Swarm

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Pick the worker model from `swarm workers` in the user-level `$CODEX_HOME/pstack-models.md`, defaulting to `inherit-parent`. Resolve models and effort through poteto-mode’s Subagents section. For a model race, name each supported model up front. Report missing model diversity instead of substituting fictional slugs.
4. Give each worker its own writable output when it writes. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Spawn all N workers in one message as asynchronous general workers using the step 3 model. Default to isolated cloud workers through a verified cloud execution adapter. Use local execution only when the worker needs access to something on the user's computer, as upstream specifies. If the required placement is unavailable, report it blocked. Native subagents and separate worktrees do not substitute for isolated cloud VMs.

When a worker must start from a non-default pushed branch, select that branch through the verified adapter's supported capability. Cursor's `environment` and `cloud_base_branch` fields are not accepted by the native Codex spawn schema; do not invent equivalent arguments.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

## Phase D: Report

Return one consolidated in-chat report with a result table, issue one-liners, gaps or dropouts, and the race rule when used.
