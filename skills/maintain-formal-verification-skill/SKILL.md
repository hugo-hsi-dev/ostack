---
name: maintain-formal-verification-skill
description: "Bring existing formal verification back in sync with changed code, separating model drift from real bugs. Run only when asked to maintain formal verification."
disable-model-invocation: true
---

# Maintain a formal verification skill

## Workflow

1. **Find the checks.**

    A verify skill has no fixed name, so find it by what it does: a project skill that runs a model checker, a prover, or another verifier against named code. Read each one you find, or the one the user named. For each check, collect the property, the code it covers, the bounds and assumptions, the command that runs it, and the commit where it was last confirmed to describe the code. If no verify skill exists, stop and point at `/ostack:create-formal-verification-skill`. If the skill does not record a sync commit, use the last commit that changed the verification files, and say that you did.

    Edit only the verification: models, harnesses, property files, and the verify skill itself. Never edit product code during a run, unless the user asks you to.

2. **Run it as it is.**

    Run each check once before you change anything, and record the result. A pass here does not tell you that the code is correct. It tells you that the old description still holds. A failure here can be drift or a bug. Do not decide which until step 5.

    For a TLA+ check, use the checker and operating guide that the verify skill records in the project. If it records none, read the checker's own output directly. Prefer the project's existing reproducible commands and preserve its verification artifact contract; report unavailable tooling rather than silently replacing it.

3. **Read every change to covered code.**

    Diff the covered files from the sync commit to the current commit, and read each commit message. Also look for code that moved: a covered function that is renamed, split, or moved to another file is still covered code. Also look for new code that touches the state that a check guards, such as a new function that writes the same fields. For each change, decide which of these it is:
    - **No effect.** The change does not alter anything the verification describes, such as formatting, comments, or code paths that the verification does not cover. Check this against the model or harness, not against the commit message.
    - **The verification no longer describes the code.** A step that was one indivisible action is now two, a branch was added or removed, a check moved, a new path reaches the guarded state, or a value now has a different range. The model or harness must change.
    - **The promise changed on purpose.** The change alters what the code promises, and evidence in the change says that this is intended: the doc comment, the tests, the changelog, or the commit message. The property must change, and you must cite that evidence.
    - **The promise may be broken.** The code changed, and no evidence says that the promise changed. Treat a failure that follows as a bug candidate.

4. **Update from the code, not from the result.**

    Change the model or harness so that each changed part again points to code that a reviewer can open, and keep one indivisible step in the code as one step in the verification. Write the update from the code before you rerun, and do not shape it by what makes the check pass. Change a property only for a promise that changed on purpose. Write down the old wording, the new wording, and the evidence. Keep the bounds unless the change makes them wrong. If you must reduce a bound, say so in the report.

5. **Rerun and judge each result.**

    - **Pass:** the check can now pass on a description that has lost the ability to fail. Run [negative control](<${CLAUDE_PLUGIN_ROOT}/playbooks/negative-control/PLAYBOOK.md>) against the new code.
    - **Fail:** replay the counterexample against the real code, step by step. If a step cannot happen in the code, the verification is wrong. Fix the verification, and say what was wrong. If every step can happen, it is a bug. Name the commit that introduced it, tell the counterexample as a sequence of steps in the code's own words, and state the harm in one sentence. If a cheap test or reproduction against the real code shows the bug, add it to the report as evidence. Do not commit it to the product code.

6. **Update the verify skill.**

    Update the code that each check covers, the commands, the bounds, the assumptions, and the sync commit. Set the sync commit to the commit that you checked. Do not move the sync commit for a blocked check, and say so in the report. Then follow the verify skill once as the next agent would, so that you know its steps still run.

7. **Report each check.**

    Give each check one outcome, and say which:

    - **in sync**: no change since the last sync alters what the check describes, and the check passes.
    - **updated**: the code changed, the verification now describes the new code, and the check passes.
    - **bug**: the verification describes the current code, and the code breaks the property. This is a finding about the code. It is not drift.
    - **blocked**: the check could not be brought back in line or could not run. Say exactly why.

    A check can be both updated and bug: the update makes the verification describe the code again, and then the property fails on it.

    For each check, report the outcome, the commits read, each verification change with its reason or evidence, the break that shows the updated check can still fail, each bug as code-step counterexample plus harm plus introducing commit, and code the verification should cover but does not.

    For a check that passed before you updated it and fails after, say that the old pass was on a stale description.

    Put the verification updates in a change of their own, separate from any product fix.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| A changed property or negative control needs judging | [Test behavior](<${CLAUDE_PLUGIN_ROOT}/principles/test-behavior-not-implementation/PRINCIPLE.md>) |
| It is unclear what a pass or counterexample establishes | [Prove it works](<${CLAUDE_PLUGIN_ROOT}/principles/prove-it-works/PRINCIPLE.md>) |
