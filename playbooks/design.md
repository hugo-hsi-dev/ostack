# Design a change

Use when an outcome depends on an unresolved representation, ownership, or interface choice. Inputs are the decision, current constraints, and the principles selected by the Entry. This playbook settles the design question; the Entry owns implementation and completion.

1. **Start at the callers.** Read affected usage, types, and tests. Separate observed constraints from assumptions. Write a realistic usage sketch before designing internal machinery.
2. **Sketch the smallest coherent shape.** Show the data representation, ownership, and signatures needed for that usage. Keep a small sketch in the conversation; write a separate artifact only when it helps the work or review.
3. **Inspect the boundaries.** Check what callers must coordinate and what complexity the interface hides. Look for internal representations leaking across modules, execution stages repeating domain rules, pass-through layers, split state ownership, importable internals, and hand-synchronized lists. These are questions to investigate, not automatic rewrite requirements.
4. **Resolve material uncertainty.** Compare alternatives only where a different answer could change the decision. Start with a written comparison or a small probe. Use observations from any experiment selected by the Entry; do not launch a panel or manufacture competing implementations as a default.
5. **Return the decision.** Explain the chosen shape, consequential tradeoff, affected callers, compatibility constraints, and the observation that will validate it. During implementation, repeated casts, caller coordination, or duplicated workarounds are evidence to revisit the sketch.

A reviewer can use the same steps to evaluate a proposed shape without editing it. A design-only task ends at the recommendation. This procedure contains no further principle or playbook routing.
