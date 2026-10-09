---
name: setup-ostack
description: Configure which models ostack uses per role and at what reasoning budget. Detects your available models and writes an always-loaded rule that overrides the skill defaults. Use for /setup-ostack, "configure ostack models", "ostack budget", or changing ostack's model choices.
---

# Setup ostack

Write `~/.claude/rules/ostack-models.md`, a user-level rule that sets ostack's model and effort per role. Claude Code loads every `~/.claude/rules/*.md` file without `paths` frontmatter into every session, in every project.

## Steps

### 1. Detect available models

Read the `model` parameter of the Agent tool in this session. Its allowed values (`opus`, `sonnet`, `haiku`, and `fable` when the account has it) are the dependable source. A full model ID such as `claude-opus-5-5` also works when the user names one. If you cannot read the parameter, ask the user which models they have access to. Never write a model you have not confirmed is available. The alias `inherit` is always valid even though it is not a detected model.

Every current model accepts the effort levels `low`, `medium`, `high`, `xhigh`, and `max`. The Agent tool takes them in its `effort` parameter.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below. If `~/.claude/rules/ostack-models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it. A value of `inherit-parent` or `auto` from an older rule means `inherit`. A Cursor-era slug such as `claude-opus-5-5-xhigh` or `grok-4.7-xhigh-fast` maps to `opus xhigh` or `sonnet xhigh`. Rewrite it in the new form and list the rewrite in step 3(c). If a Cursor rule exists at `~/.cursor/rules/ostack-models.mdc` and no Claude rule does, offer to carry its choices over the same way.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer AskUserQuestion over free text. Offer these four options with these exact labels, and name the current budget when the rule records one. With no rule, say that `large` matches the skill defaults.

- `unlimited — max effort`
- `large — xhigh effort`
- `medium — high effort`
- `small — medium effort`

**(b) Apply it.** Build the working table from the skill defaults, and on a re-run keep any role you changed by model, list, or alias (`inherit`). `unlimited`, `large`, `medium`, and `small` set the effort of every role value, panel entries included, to `max`, `xhigh`, `high`, or `medium`. The model stays the same. `inherit` does not change, because it takes the parent's model and effort. So `unlimited` turns `opus xhigh` into `opus max` and `sonnet xhigh` into `sonnet max`. `large` keeps both defaults. `small` turns them into `opus medium` and `sonnet medium`.

**(c) Show the roles and confirm.** Show every role with its value, marking any model not in the detected set as needing a choice. Also list each line step 2 dropped or rewrote. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit` (this role runs on the parent chat model and effort) as the options. Prefer AskUserQuestion over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, `inherit` entries included, so the list length sets the count. A panel gets its diversity from different models, so keep at least two models in it when the account has them. `fable` is a strong third entry under the `unlimited` budget. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every model written must be in the detected set, and every effort must be one of `low`, `medium`, `high`, `xhigh`, `max`. `inherit` always passes. If a chosen model is not available, stop and ask again.

### 5. Write the rule

Create `~/.claude/rules/` if it is missing. Write `~/.claude/rules/ostack-models.md` with no frontmatter, so Claude Code loads it in every session. Include a `# budget` line with the chosen label and its target effort, and one line per role, using the same labels onyo-mode uses. Each value is `<model> <effort>`, a comma-separated list of those for panels, or `inherit`. Overwrite the whole file so re-runs stay idempotent. Shape:

```
# ostack model configuration (overrides skill defaults)
# One line per role. Delete a line to fall back to the skill default.
# A value is `<model> <effort>`: pass the model as the Agent tool's `model` and the effort as its `effort`.
# `inherit`: the role runs on the parent chat model and effort (omit `model` and `effort`). Inherit entries in a panel list still count toward its fan-out.
# budget: large (xhigh)
feature, refactoring: sonnet xhigh
bug-fix: sonnet xhigh
perf-issue: sonnet xhigh
hillclimb: sonnet xhigh
judgment and prose: opus xhigh
hardest tasks: opus xhigh
how explorer: sonnet xhigh
how explainer: opus xhigh
why investigators: sonnet xhigh
why synthesizer: opus xhigh
reflect tooling: sonnet xhigh
reflect judgment, divergent, synthesizer: opus xhigh
arena runners: opus xhigh, sonnet xhigh
arena cross-judge pool: opus xhigh, sonnet xhigh
swarm workers: sonnet xhigh
architect runners: opus xhigh, sonnet xhigh
interrogate reviewers: opus xhigh, sonnet xhigh
```

### 6. Confirm

Tell the user the rule was written and that it applies to new sessions. Re-running this skill updates it. A rule in `~/.claude/rules/` lives on this machine. Cloud sessions and routines do not see it, so they run on the skill defaults unless the repository commits its own copy at `.claude/rules/ostack-models.md`. Offer that copy once when the user runs ostack in cloud sessions.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever ostack is installed: project, user, or plugin). On no, move on without pushing.
