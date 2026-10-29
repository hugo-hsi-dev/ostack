---
name: setup-ostack
description: Configure which model and effort ostack uses per role. Shows the defaults, detects your available models, and writes a rule that overrides the skill defaults. Use for /setup-ostack, "configure ostack models", or changing ostack's model choices.
---

# Setup ostack

Write `~/.claude/rules/ostack-models.md`, a rule that sets ostack's model and effort per role. Claude Code loads every `.md` file in `~/.claude/rules/` into each new session.

## Steps

### 1. Detect available models

The available models are the `model` values the `Agent` tool schema lists, such as `opus`, `sonnet`, and `haiku`. The efforts are its `effort` values on the ladder `xhigh` > `high` > `medium` > `low`. ostack never uses an effort above `xhigh`. Never write a model the schema does not list. `inherit` is always valid.

### 2. Load current state

The default role values are the rule shape shown in step 5 below. If `~/.claude/rules/ostack-models.md` already exists, read it and treat its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it, and drop any `# budget` line, which ostack no longer uses.

### 3. Show the roles and confirm

Show every role with its value, marking any model not in the detected set as needing a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit`, which runs the role on the parent chat model. Prefer AskUserQuestion over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, `inherit` entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena runs one judge. It tries only entries on a model other than the parent's, in list order, so order it by preference. An `inherit` entry never judges. `swarm workers` is the default for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every model written must be in the detected set, and every effort must be on the ladder. `inherit` always passes. If a chosen value is not available, stop and ask again.

### 5. Write the rule

Write `~/.claude/rules/ostack-models.md` with no frontmatter. Give it the comment lines and one line per role as `<model> <effort>`, using the same labels onyo-mode uses. Overwrite the whole file so re-runs stay idempotent. Never put the role lines in `CLAUDE.md`. Shape:

```
# ostack model configuration. One line per role, as `<model> <effort>`. Delete a line to fall back to the skill default.
# `inherit` as a value: the role runs on the parent chat model (omit Agent `model` and `effort`). An `inherit` entry in a panel list still counts toward its fan-out.
feature, refactoring: opus high
bug-fix: opus high
perf-issue: opus high
hillclimb: opus high
judgment and prose: opus high
hardest tasks: opus xhigh
how explorer: haiku high
how explainer: opus high
why investigators: haiku high
why synthesizer: opus high
reflect tooling: haiku high
reflect judgment, divergent, synthesizer: opus high
arena runners: opus high, sonnet xhigh
arena cross-judge pool: opus high, sonnet xhigh
swarm workers: haiku xhigh
architect runners: opus high, sonnet xhigh
interrogate reviewers: opus high, sonnet xhigh
```

### 6. Confirm

Tell the user the rule was written and that it applies to new sessions. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever ostack is installed: workspace, user, or plugin). On no, move on without pushing.

### 8. Offer a formal verification skill (optional)

Check whether the project already has a formal verification skill (a project skill that runs a model checker, a proof, or another verifier against the code). If not, offer once: "want a formal verification skill, so agents can prove a key property of your code holds in every case in scope, not only the cases tests reach? I can generate one with /create-formal-verification-skill." On yes, invoke `/create-formal-verification-skill` (resolves wherever ostack is installed: workspace, user, or plugin). On no, move on without pushing.
