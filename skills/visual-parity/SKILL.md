---
name: visual-parity
description: Preserve or match a reference UI during a component migration using controlled screenshots and image comparison. Use for visual regression and parity work.
---

# Visual parity

Establish the reference before changing the implementation. Use an existing screenshot harness when available; otherwise capture the relevant states on the actual interface.

Hold viewport, scale, browser, fonts, fixtures, theme, and animation state consistent between captures. Include meaningful interaction states and responsive sizes within the requested scope.

Treat the reference and comparison settings as fixed during implementation. Use the project's agreed tolerance for rendering noise; exact parity requires zero unexplained differences. Do not update baselines, loosen thresholds, or hide changed regions to make a regression pass. If the requested design intentionally changes the reference, record that change separately.

Migrate one component or coherent dependency group at a time. Compare screenshots, inspect changed regions, and rerun affected states after the fix. A visual match alone does not establish interaction or accessibility equivalence; exercise behavior affected by the migration too.

If the environment cannot reproduce the reference, report the mismatch and its effect on confidence. Avoid an unbounded loop chasing nondeterministic pixels.

Report the states covered, comparison result, any accepted differences with their reason, artifact locations, and remaining gaps. Keep changes limited to the authorized migration.
