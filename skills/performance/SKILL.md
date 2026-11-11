---
name: performance
description: "Load before working on anything slow, backed up, or heavy (latency, throughput, queues, CI run time, memory, cost) or before trusting a speedup number, even mid-task and alongside project skills. Needs a baseline and a same-metric before and after."
---

# Performance

## Workflow

1. **Establish the workload.** Identify the user-visible metric, representative input and state, requested target, and available measurement command or capture.

2. **Measure the baseline.** Use [measure](<${CLAUDE_PLUGIN_ROOT}/playbooks/measure/PLAYBOOK.md>) and retain its workload, commands, and raw results for comparison.

3. **Locate the bottleneck.** Inspect the profile or supplied runtime artifact and map the observations to code. For diagnosis-only work, finish with the supported cause and recommendation.

4. **Choose and test an intervention.** Use [prototype](<${CLAUDE_PLUGIN_ROOT}/playbooks/prototype/PLAYBOOK.md>) if a runtime assumption needs an experiment. Apply one selected intervention, rerun the workload using [measure](<${CLAUDE_PLUGIN_ROOT}/playbooks/measure/PLAYBOOK.md>), run correctness checks, and remove rejected experimental edits.

5. **Finish or continue within scope.** For a requested campaign, keep a hypothesis/result/keep-or-revert record. Continue until the requested target, supplied budget, or a lack of viable remaining interventions ends the campaign.

## Select principles

Read only the documents whose conditions apply. Resolve their relative links from the document's directory.

| Situation | Read |
| --- | --- |
| A measured result or its interpretation needs judging | [Explain the number](<${CLAUDE_PLUGIN_ROOT}/principles/explain-the-number/PRINCIPLE.md>) |
| The intervention changes data representation | [Model the domain](<${CLAUDE_PLUGIN_ROOT}/principles/model-the-domain/PRINCIPLE.md>) |
| The intervention changes concurrent ownership | [Separate shared state](<${CLAUDE_PLUGIN_ROOT}/principles/separate-before-serializing-shared-state/PRINCIPLE.md>) |
| Caller interfaces or responsibilities remain unresolved | [Design from caller usage](<${CLAUDE_PLUGIN_ROOT}/principles/design-from-usage/PRINCIPLE.md>) |

Lead with the outcome in plain words, then baseline and final values with units, delta, and variation, the bottleneck, correctness checks, and artifact locations. State what the runs could not establish. End with `Method: ostack:performance`.
