### Session pickup

**You own the resume point. Read the prior trail, don't redo it.**

1. Locate the prior trail through authorized, project-scoped history tools exposed in this host, an explicitly supplied transcript/export, a cloud-task reference readable here, or a pushed branch. Use a known thread reference directly; otherwise narrow supported listings to the project. Inspect supplied formats, without assuming private session paths or JSONL fields. See [history access](../../../docs/harness/codex.md#history-access-for-recall-and-session-pickup) for listing/read limits. If history is unavailable or incomplete, state the gap and use the supplied capsule and branch/artifact state without inventing missing decisions. A sufficient capsule skips unnecessary history mining. Read the metadata overview and last messages first, then scan back for the decision points. Parse a long transcript in a subagent and keep the reduced timeline in the main thread (the **principle-guard-the-context-window** skill). Pick each subagent's reasoning level and fast or standard speed for the job, per the Subagents section.
2. Reconstruct operational state. The branch and worktree, what already landed (`git log`, `git diff` against the base), the open todos, the decisions made. The prior trail is authoritative input. Resist the bias to re-derive it.
3. Diff done vs pending. Compare what shipped against what was planned, name the resume point, do not re-run the prior repro or redo completed work. A "let me verify from scratch" pass means you're treating the trail as untrustworthy when it's authoritative.
4. Route the remaining work to the matching playbook and pick the verdict: continue the execution, ship a finished recommendation, ratify or override a prior conclusion, or postmortem a failed run. The pickup playbook ends here. The routed playbook owns the rest.
5. Verify the inherited claims against the original goal on the real artifact (the **principle-prove-it-works** skill). A passing prior self-report is not the proof.

**Reply:** where the prior agent stopped, what you inherited vs redid (ideally nothing redone), the resume point, and the outcome.
