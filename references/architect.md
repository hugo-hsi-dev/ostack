# Architect

Start from realistic caller usage and the constraints in the existing code. Sketch the types and signatures that make that usage work before filling in the implementation. Keep a small change's sketch in the conversation; create a design artifact only when it helps implementation or review.

## Choose the shape

Read the affected callers, current types, and tests. Start the sketch from realistic usage and separate observed constraints from assumptions.

Load only the principle documents relevant to the decision:

- Integrating a new requirement: [redesign-from-first-principles](../principles/redesign-from-first-principles.md), before settling on an extension to the existing flow.
- Choosing the representation: [model-the-domain](../principles/model-the-domain.md) and, for foundational sequencing, [foundational-thinking](../principles/foundational-thinking.md).
- Placing validation or framework adapters: [boundary-discipline](../principles/boundary-discipline.md).
- Concurrent writers: [separate-before-serializing-shared-state](../principles/separate-before-serializing-shared-state.md).
- Retried commands or partial lifecycle runs: [make-operations-idempotent](../principles/make-operations-idempotent.md).
- Judging interface depth and hidden state: [minimize-reader-load](../principles/minimize-reader-load.md).

Compare alternatives only when a material uncertainty could change the decision. Start with a written comparison or one small probe. Build competing prototypes when observation is needed; additional models and design panels require an explicit request.

For a broad redesign, read [design red flags](architect/design-red-flags.md) to check ownership, information leakage, and duplicate sources of truth.

## Implement or hand off

Follow the user's scope: a design request produces a recommendation; an implementation request continues into code unless a checkpoint was requested. Explain the chosen shape, the consequential tradeoff, and how it will be checked.

If implementation repeatedly requires casts, caller coordination, or the same workaround, revisit the shape using the new evidence. Remove obsolete paths as the replacement becomes usable. Preserve external compatibility when it is part of the contract.
