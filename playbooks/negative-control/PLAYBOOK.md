# Negative control

Use to show that a check (test, guard, lint, model property, or verification skill) can fail on the fault it claims to catch. A check never seen failing proves nothing.

1. **Record the baseline.** Run the check on the current code and note the result.
2. **Break the guarded behavior.** Make the smallest faithful fault in the real code: remove a check, reorder a step, return a wrong value, or skip an effect. For a regression test, the unfixed code is the break.
3. **Confirm it fails for the right reason.** The check must fail and point at the injected fault. If it passes or fails elsewhere, fix the check, not the break.
4. **Check valid use.** Where the check guards a rule, confirm valid behavior still passes; a check that fails everything has not captured the rule.
5. **Restore.** Drop the break and confirm the check returns to the baseline: passing, or failing only on known findings.

Report the break used, the failing output, and the restored result.
