# Design from caller usage

Apply when choosing or reviewing representations, ownership, or interfaces whose caller usage is not yet clear.

Judge a design by how directly realistic callers can express their intent and how much implementation knowledge they must carry. A small usage sketch grounded in actual callers is stronger evidence than an architecture that only looks orderly internally.

- Ground the shape in affected callers, existing types, tests, and observed constraints. Keep assumptions distinguishable from evidence.
- Sketch types and signatures together with caller usage before filling in internal machinery. Keep small sketches in the conversation; a separate design artifact earns its place when it helps implementation or review.
- Prefer boundaries that hide consequential decisions. Repeated caller coordination, leaked representations, split ownership, and hand-synchronized lists are evidence that responsibility may sit in the wrong place. The [boundary symptoms](references/design-red-flags.md) give concrete examples.
- Compare alternatives when an unresolved assumption could change the choice. Inspection or a written comparison may settle it; an untested assumption remains an assumption. This principle does not prescribe a panel, prototype count, or another procedure.
- Repeated casts, duplicated workarounds, or the same coordination spreading through callers are evidence to reconsider the shape rather than repeat the patch.

A useful design explains its consequential tradeoff and how the chosen shape can be checked. The Entry decides whether the task ends at a recommendation or continues into implementation, and selects any independent procedure needed to resolve uncertainty.
