---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your available models and writes user-level role configuration that the workflow reads explicitly. Use for $setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

Read [Codex compatibility](../../docs/harness/codex.md) before using this workflow.

# Setup pstack

Write `$CODEX_HOME/pstack-models.md` in the user’s Codex home. This is pstack role configuration, not native Codex configuration or an automatically loaded rule. Read it explicitly when entering a routed workflow. See [the Codex mapping](../../docs/harness/codex.md).

Resolve `CODEX_HOME` from the host environment; when unset, use `~/.codex`, so the default file is `~/.codex/pstack-models.md`. This is one user-level preference file across projects, with no repository override layer. The filename is pstack-owned data, not a native Codex configuration key. See the [documented Codex home convention](https://learn.chatgpt.com/docs/config-file/config-advanced#config-and-state-locations).

## Steps

### 1. Detect available models

Enumerate the model IDs and reasoning efforts accepted by the session's native subagent tool. That exposed schema is the dependable source. A documented model is not evidence that the current account can use it. If an entitled-model listing is available, consult it too. If you cannot detect any, ask the user for available IDs. Never write a model or effort you have not confirmed is available. `inherit-parent` and `auto` are pstack aliases that omit model and effort overrides; never pass those strings as model IDs.

The observed Codex `collaboration.spawn_agent` accepts separate `model` and `reasoning_effort` fields only with `fork_turns: "none"`. A full-history fork inherits the parent model and effort. Other clients may expose a different schema; inspect it before calling.

### 2. Load current state

The default role-to-model mapping is the configuration shape shown in step 5 below. If `$CODEX_HOME/pstack-models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer `request_user_input` when it is exposed and allowed in the current mode; otherwise ask in plain text. Offer these four options with these exact labels, and name the current budget when the configuration records one. With no configuration, offer `large` as the upstream starting budget. Inherited models keep the parent effort until a supported explicit choice is confirmed.

- `unlimited — max reasoning`
- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Build the working table from the defaults below, and on a re-run keep any role changed by model family, list, or alias. The budget labels `unlimited`, `large`, `medium`, and `small` target `max`, `xhigh`, `high`, and `medium` respectively. Model ID and reasoning effort are separate values, written as `<model-id> <effort>` for each real model. Use the selected model's highest confirmed effort at or below the target; if none is confirmed, mark that role as needing a choice. Do not edit model-name suffixes or invent a `-fast` model. `inherit-parent` and `auto` do not change.

The baseline uses inheritance rather than pretending Cursor's Grok and Claude defaults have exact Codex equivalents. Preserve every role and panel slot. Offer distinct available models for diverse panels, but explicitly report when cross-family diversity cannot be met. Two inherited slots remain two independent agents; they are not evidence of model diversity.

**(c) Show the roles and confirm.** Show every role with its model, marking any model/effort choice not in the detected set as needing a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected model/effort choices plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model, without overriding the session selection) as the options. Prefer `request_user_input` when it is exposed and allowed in the current mode; otherwise ask in plain text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model family differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every model/effort choice written must be in the detected set. `inherit-parent` and `auto` always pass. If a chosen model/effort choice is not available, stop and ask again.

### 5. Write the configuration

Write `$CODEX_HOME/pstack-models.md` in the user’s Codex home with a `# budget` line and one line per role using the labels below. Overwrite only this dedicated file so re-runs stay idempotent. Keep unrelated files in Codex home unchanged. Shape:

```text
# pstack model configuration. Read explicitly; this is not native Codex config.
# Delete a line to use inherit-parent. A real choice is <model-id> <effort>.
# inherit-parent and auto omit native model and effort overrides.
# Alias entries in a panel list still count toward its fan-out.
# budget: large (xhigh target for explicitly configured models)
feature, refactoring: inherit-parent
bug-fix: inherit-parent
perf-issue: inherit-parent
hillclimb: inherit-parent
judgment and prose: inherit-parent
hardest tasks: inherit-parent
how explorer: inherit-parent
how explainer: inherit-parent
why investigators: inherit-parent
why synthesizer: inherit-parent
arena runners: inherit-parent, inherit-parent
arena cross-judge pool: inherit-parent, inherit-parent
swarm workers: inherit-parent
architect runners: inherit-parent, inherit-parent
interrogate reviewers: inherit-parent, inherit-parent
```

### 6. Confirm

Tell the user the configuration path, model choices, and any unmet diversity or effort constraints. The workflows explicitly read this file at entry; Codex does not automatically load it as a rule. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with $create-verification-skill." On yes, invoke `$create-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.

### 8. Offer a formal verification skill (optional)

Check whether the project already has a formal verification skill (a project skill that runs a model checker, a proof, or another verifier against the code). If not, offer once: "want a formal verification skill, so agents can prove a key property of your code holds in every case in scope, not only the cases tests reach? I can generate one with $create-formal-verification-skill." On yes, invoke `$create-formal-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.
