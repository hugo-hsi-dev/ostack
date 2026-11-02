---
name: formal-verification
description: Model-check or prove a named high-risk invariant, or maintain an existing formal check after code changes. Use for explicit formal verification, concurrency proofs, and model drift.
---

# Formal verification

Apply formal methods to the promise the user names or the failure under investigation. Do not expand ordinary bug fixing into a repository-wide proof effort.

## Establish a check

1. State the property, the harm if it fails, and the code that implements it. Identify bounds, assumptions, and atomic steps from actual code.
2. Choose the lowest-cost suitable tool. A small TLA+ model suits event ordering; a code-level verifier suits memory safety or arithmetic properties. Prefer existing repository tooling. If no practical verifier exists, offer a property-based test while making clear it is not a proof.
3. Keep every modeled action traceable to code. A model's indivisible step must correspond to an indivisible operation in the implementation. Use small bounds first and report their limits.
4. Run the check. For a failure, replay the counterexample against real code where possible. If a step cannot occur, correct the model. If it can, report the bug; do not weaken the property to obtain a pass.
5. Demonstrate that the check can fail on a faithful broken variant. Restore the variant and confirm the original result, preserving the user's changes.

For TLA+ reports and state diagrams, the bundled [statechart skill](../statechart/SKILL.md) provides a checker and shortest counterexample paths. Read it only when using that tooling.

## Keep an existing check in sync

Record the covered files and symbols, reproducible command and tool version, bounds, assumptions, and last verified commit with a maintained check. Generate a project-local skill only when requested; existing verification docs or scripts may suffice.

When maintenance is needed, read [the maintenance procedure](references/maintenance.md). Edit verification artifacts within scope; product fixes need to be part of the user's request.

Report the property, result, evidence, tool choice, and scope. Distinguish code bugs, modeling errors, and blocked checks. Explain counterexamples in the system's terms. A bounded model pass is not a proof of the whole implementation.

## Shared verification artifacts

Treat existing generated verification skills, including pstack output, as a shared project contract. Preserve names, locations, section structure, property or journey meaning, and coverage records during routine maintenance. Correct proven drift in place; retain usable commands and dependencies for the project's supported environments. Rename, relocate, replace the framework, or change the contract only when requested. Do not introduce a dependency on ostack merely to maintain an existing artifact. Report an unsupported tool or discovery path rather than silently migrating it.
