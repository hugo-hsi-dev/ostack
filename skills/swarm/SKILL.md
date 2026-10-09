---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
disable-model-invocation: true
---

# Swarm

Fan out N parallel cloud workers. They may cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report.

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Set N from the user or derive it from the shape. N is total workers, not the cloud concurrency limit.
4. Pick the worker model and effort from the `swarm workers` line in `~/.claude/rules/ostack-models.md`. If the rule or that line is missing, use `sonnet xhigh`. For `inherit`, omit `model` and `effort` so the workers run on the parent model. If the Agent tool rejects a model, use the default and say so. For a model race, name each arm's model up front.
5. Give each worker its own writable output when it writes. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Spawn all N workers in one message with `subagent_type: "general-purpose"`, `isolation: "remote"`, `run_in_background: true`, and the step 4 model and effort, left unset for `inherit`. Each remote worker is a Claude Code cloud session with its own machine. Where the Agent tool does not offer `isolation: "remote"`, start each worker with `claude --cloud "<brief>"` from Bash. That command takes no model, so the worker runs on the cloud session's default model. Record the model it ran on in the report. Each such brief names the branch the worker pushes to and tells it to commit its report as a file on that branch and push it. Drop `isolation: "remote"` only when the worker needs access to something on the user's computer, and use `isolation: "worktree"` when it writes.

When a worker must start from a non-default pushed branch, name the branch in its brief and have it check that branch out first.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. A subagent worker returns its result to you. A `claude --cloud` worker pushes its report file to the branch its brief names. Poll for that branch with a Bash loop that runs `git fetch origin <branch>` until it succeeds, started with `run_in_background: true` so its exit wakes you. Then read the report with `git show origin/<branch>:<path>`. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

Keep a compact result table, one-line evidenced issues, and explicit gaps or dropouts.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.
