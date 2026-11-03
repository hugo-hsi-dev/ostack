# Build the Lever

Apply to any non-trivial work, not just bulk work: edits, migrations, analyses, checks.

Build the tool that does or proves the work (codemod, script, generator, or a skill your subagents follow) instead of working by hand. Hand-done changes can only be re-verified by redoing them.

- Do the first unit by hand to learn the recipe, then build the tool. Prove it by rerunning it on that unit and diffing against your hand-done version. Make the lever safe to rerun.
- Codemod or script for edits, generator for repetitive files, a dump-to-sqlite query for analysis, a rerunnable check for verification.
- A deterministic lever beats fan-out. If the tool can process every unit in one pass, run it yourself. Don't fan out delegates to hand-apply what a script can do.
- When you fan work out to subagents, write the lever as a skill they all read: the recipe, the verification contract, and the do-not-touch fences in one artifact. Keep it outside the delegates' write scope so they can't quietly edit the contract.
- Applying this principle produces a file. If you cited it and there is no codemod, script, generator, or delegate skill in the diff, you didn't apply it.
- Keep the lever in the repo when the work outlives the session.

The bar is triviality, not repetition: skip it only for a couple of obvious edits you can see at a glance. A one-off still earns a lever when the lever is what makes the work checkable. Build the smallest script that does or proves the job, never a framework.
