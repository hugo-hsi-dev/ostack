---
name: create-formal-verification-skill
description: "Formally verify a high-risk property of this codebase (TLA+, model checker, prover, or SMT verifier) and generate a project-local skill that reruns it. Run only when asked to create formal verification."
disable-model-invocation: true
---

# Create a formal verification skill

## Workflow

1. **Choose the target.**

    Answer from the codebase, and ask the user only what you cannot observe. If the user named an area or a bug, start there.

    A good target is a promise the code makes, where a break harms users and tests rarely reach the case that breaks it. Choose the strongest such target in the repo, not the one that is easiest to verify.

2. **Choose the verifier.**

    Pick the tool that answers the question at the lowest cost: a model checker, a proof assistant, an SMT-backed verifier, or another tool. Whether events can happen in a bad order usually suits a model checker over a small model of the design, and TLA+ is the default for that in any language. Whether the code itself behaves for every input, as with memory safety, overflow, or a data-structure invariant, usually suits a verifier that runs on the code. If no verifier runs on this language, say so, and test the real code with generated inputs, not a hand model of the function. A property that must hold at every size, where a bound is not enough, can need a proof. Prefer a tool that the repo's developers can install and run, and tell the user why you chose it.

3. **Establish the check.**

    - **True to the code.** Every part of the model or proof points to code that a reviewer can open. What the verification treats as one indivisible step is one indivisible step in the code. Names come from this repo.
    - **Able to fail.** A check that you have never seen fail proves nothing. Show each property failing on a broken variant of the code it guards, such as a removed check or a reordered step.
    - **Findings stay findings.** When the current code breaks the property, report it with the counterexample in the code's terms. Do not weaken the property or the model until it passes, and do not change product code unless the user asks.
    - **Honest about scope.** Say what is verified, under which bounds and assumptions, and what is left out. A pass covers the model or the bound, not the whole system.
    - **Readable without the tool.** State the property and the harm in one plain sentence each. Tell a counterexample as a short sequence of steps in the code's words.
    - **Cheap to rerun.** One command, a reproducible tool version, and a run short enough that the next agent will use it on every relevant change.
    - **Kept in step with the code.** Record which files and functions each check covers, and the commit at which you last confirmed that the verification describes them. When the covered code changes after that commit, the next agent can see that the verification needs another look.

4. **Generate the verification skill.**

    Write a project-local skill with frontmatter that names the area and says when to use it. Without frontmatter, the skill never registers. From the skill alone, the next agent must be able to tell whether a change touches the verified code, run the check, tell a real bug from a modeling error, and update the verification when a change is intended. Put the coverage record and the sync commit in the skill, and tell the next agent to move the sync commit forward only after it confirms that the verification describes the code at the new commit. Use this repo's real commands, paths, and nouns, and leave no placeholders.

    If the check is a TLA+ model, read the bundled [statechart guide](references/statechart/STATECHART.md) for checking it and interpreting shortest counterexample paths and state diagrams. Prefer the project's existing checker and reporting commands. If the generated verification needs this toolkit to rerun, include one project-owned copy of the necessary runtime scripts and operating documentation with that generated artifact, record its source revision and prerequisites, and prove its project-relative command. Do not make a generated skill depend on an installed ostack path or cache directory. Existing generated artifacts retain their names, locations, and verification meaning; report an unavailable tool rather than silently migrating them.

5. **Prove the generated workflow.**

    Follow the generated skill once, as the next agent would, on a scratch change that breaks the property in the real code. It must catch the break. Then drop the scratch change and confirm that the check is back where it started: passing, or failing only on the findings you will report. A verify skill that was never run is a draft. If the skill misses the break or a step does not run, fix the skill or the verification, not the scratch change.

6. **Hand off.**

    Tell the user what you verified, which tool you used and why, the bounds, what the check found in plain words, how to run it, and what it does not cover. Suggest a second target only if you found a close one. Point the user at `/maintain-formal-verification-skill` for bringing the verification back in line after changes that did not recheck it.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| A proposed property or negative control needs judging | [Test behavior](${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md) |
| The proof evidence or claimed scope is uncertain | [Prove it works](${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md) |
