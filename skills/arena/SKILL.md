---
name: arena
description: Compare several ideas for the same design or problem, then select and combine their strongest parts. Use for a requested brainstorm panel, competing approaches, or an arena comparison.
---

# Arena

Use a small Haiku idea panel and one Opus judgment pass. Candidates propose possibilities; implementation and verification belong to Opus after selection, within the user's requested scope.

## Frame once

State the question, constraints, and a few concrete selection criteria. Default to three candidates and one round unless the user specifies another bound. Assign each candidate a distinct exploration angle, such as adapting the existing structure, changing the representation, or removing the need for the work. These are directions to explore, not required conclusions.

Give every candidate the same essential facts and relevant project constraints plus its angle. Supply small source excerpts or pointers to the exact relevant files. Include uncommitted state when it affects the question. Do not copy the whole conversation, run a fresh repo investigation per candidate, or preload the skill collection.

## Brainstorm cheaply

Use the available plugin `idea-scout` agent, explicitly on Haiku. Its tool allowlist permits only reading and searching, with a four-turn cap. Each candidate returns at most 250 words covering idea, mechanism, tradeoff, assumption, and the next useful check.

Candidates do not write code, run tests or commands, build prototypes, spawn agents, or try until an idea works. Missing evidence stays a hypothesis for the owner to test. Do not send candidates one another's proposals.

## Judge and synthesize once

Opus compares the proposals against the criteria, picks a base, and combines only compatible improvements. If the current owner is Opus, it judges directly. Otherwise use one `idea-judge` agent on Opus and consume its decision once. Keep the losing proposals outside the main discussion unless a specific tradeoff needs them.

Opus implements the selected direction only when implementation is part of the request, and verifies it against actual code or behavior. For an ideas-only request, deliver the synthesis and unresolved assumptions. Similar proposals indicate convergence, not independent proof. Never call a brainstormed solution verified.

## Bound the cost

No nested fan-out, automatic judge panel, repeated brainstorming rounds, or model escalation. Enlarge the panel only when requested. Report dropouts rather than silently replacing candidates. If no idea is viable, return that result with the blocking constraint.

Use the host's registered agent names and native model controls. If these agents are unavailable, use equivalent Haiku/Opus roles only when the runtime can enforce read-only candidate access and bounded execution. Otherwise explain the unavailable role; do not silently inherit an expensive model or promise this model split ran.

Report the chosen direction, useful contributions, open assumptions, roles actually used, and any implementation checks. Record actual usage when available; a smaller model and bounded reports are cost controls, not measured billing savings.

Check the effective model and capability metadata when the host exposes it, because host policy can override a requested role. Do not count a partial response as completed work or automatically resume it past the turn cap. The role agents omit automatically loaded project instruction files to keep context small, so the owner must supply relevant constraints in the brief.
