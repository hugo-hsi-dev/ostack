# Maintain a formal check

1. Locate the check and record its property, covered code, bounds, assumptions, command, and last verified commit. If no sync commit exists, use the last verification change as a starting point and disclose that assumption.
2. Run the current check once. A pass may reflect a stale model; a failure alone does not distinguish drift from a bug.
3. Diff the covered code from the recorded commit, including current working changes. Follow moved symbols and new writers to guarded state. Inspect relevant commit rationale when deciding whether a promise intentionally changed.
4. Update the model from the code before rerunning. Check action boundaries, value ranges, branches, and new access paths. Change a property only when evidence establishes an intentional contract change; record that evidence. Disclose any reduced bounds.
5. Rerun. For a pass, use a faithful broken variant to confirm the check still detects the failure it guards. For a failure, replay the counterexample against the implementation: an impossible step means model drift; a realizable violation is a bug.
6. Update coverage records and commands. Advance the sync commit only for code actually checked. If working changes affect the result, record the base commit plus that fact; do not claim the base commit alone describes the checked tree. Leave blocked coverage visibly pending.

Report each check as in sync, updated, bug, or blocked; updated checks may also reveal bugs. Include changed assumptions, excluded code, and any stale pass that became a failure after reconciliation. Keep product fixes separate from verification changes unless both are requested.
