# ostack's shipped defaults, printed by ostack's hook into every session. This is not the user's ostack-models.md rule.
# These lines replace the skill defaults. Wherever ostack skill text gives a default model, effort, or budget, use the line here instead. That covers a value to use "if the rule or that line is missing", onyo-mode's defaults for every Agent call, and /setup-ostack's step 5 table and recommended budget.
# Per role, the user's own rule wins: ~/.claude/rules/ostack-models.md, or the `# ostack model configuration` block in the project instructions. A role that rule leaves out takes its line here.
# A label that names several roles, such as `feature, refactoring`, sets each of them. A value is `<model> <effort>`. Pass them as the Agent tool's `model` and `effort`.
# budget: medium (high)
feature: sonnet high
refactoring: opus high
bug-fix: opus high
perf-issue: opus high
hillclimb: opus high
judgment and prose: opus high
hardest tasks: opus high
how explorer: haiku high
how explainer: opus high
why investigators: haiku high
why synthesizer: opus high
reflect tooling: haiku high
reflect judgment, divergent, synthesizer: opus high
arena runners: opus high, sonnet high
arena cross-judge pool: opus high, sonnet high
swarm workers: haiku high
architect runners: opus high, sonnet high
interrogate reviewers: opus high, sonnet high
