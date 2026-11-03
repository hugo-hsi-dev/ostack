# Statechart

This directory is the TLA+ checking and charting toolkit for formal verification. The statechart directory is the directory containing this file.

Use the bundled checker for a TLA+ model; ordinary diagrams do not require model checking. Read the [TLA+ operating guide](references/tla-guide.md) before writing a spec, configuring the chart, or interpreting a run. It covers invariants, terminal states, projections, bounds, unchecked rules, and report semantics.

```sh
<statechart directory>/scripts/statechart SPEC.tla [--config FILE] [--view FILE] [--out DIR]
```

Run in a scratch directory unless maintaining an existing model. The first run needs network access and mise to provision Java and TLC; the wrapper requires a supported Node, Bun, or Deno runtime (see its prerequisite error for versions). Check prerequisites before claiming a result.

Keep models bounded and faithful to the code's atomic steps. Never weaken a property to make it pass. Explain counterexamples using the system's terms, replay them against actual code where possible, and distinguish model errors from product bugs.

Show the Mermaid chart when produced, the path for each violation, and the output location. State assumptions, limits, rules not checked, and details hidden by the projection. A model pass establishes only the properties and scope actually checked. An available Mermaid viewer is sufficient; image rendering is optional.
