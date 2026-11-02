---
name: bug-fix
description: Diagnose and fix a reproducible software bug or regression using runtime evidence and a focused before-and-after check.
---

# Bug fix

Find the first incorrect decision, rather than hiding its downstream symptom.

For causal diagnosis, use `principle-fix-root-causes`. When fixes repeatedly share a failed assumption, use `principle-attack-the-premise`. Load only the principle skill relevant to the current uncertainty.

1. Reproduce on the affected interface or the closest faithful local path. Record expected and actual behavior. If the necessary environment is inaccessible, name the missing prerequisite and distinguish a suspected fix from a verified one.
2. Read the relevant code and regression history. Choose observations that distinguish the leading hypotheses. Instrument only what is unclear; keep large logs in files and inspect a reduced result.
3. If two fixes fail while assuming the same premise, write that premise down and test it directly before trying a third. Remove rejected experimental edits without disturbing the user's work.
4. Fix the cause with the smallest justified change. A guard is appropriate when the triggering state is legitimate; otherwise find what produced the invalid state. Check nearby instances of the same fault within scope.
5. Rerun the original reproduction and relevant existing checks. When a cheap regression test fits the repo's harness, demonstrate its failure before the fix and its pass afterward. Do not build unrelated test infrastructure for a small fix.

Work directly by default. No required design panel, delegation, loop command, commit sequence, or PR ceremony. Stop when the evidence supports the fix; report blockers when additional attempts cannot resolve them.

Report the symptom, root cause, change, and before-and-after evidence. Include limitations that affect confidence.
