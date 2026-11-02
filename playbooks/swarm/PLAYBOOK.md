# Swarm playbook

Partition brainstorming across different slices. Arena explores competing answers to one question; swarm explores different parts of a question. Haiku generates ideas only. It does not own implementation, exhaustive audits, or proof of correctness.

## Partition and bound

Name the question, required slices, and what a useful proposal contains. Default to three Haiku workers in one round. Group related slices into those three briefs instead of spawning one worker per file or feature. Honor a user-specified bound. When there are fewer independent slices, use fewer workers; when one direct read or deterministic command settles the question, do that instead.

Give each worker a different scope and a small relevant context package, including the project constraints needed for that slice. Prefer supplied excerpts and exact source locations over a full conversation or repeated repo-wide discovery. State the input revision and relevant working changes when they affect the ideas.

## Generate ideas

Use the available `idea-scout` agent on Haiku, with read-only tools and a four-turn cap. Each returns at most 250 words: useful possibilities for its slice, supporting source observations, tradeoffs, uncertain assumptions, and the next check for the owner.

No code changes, commands, tests, prototypes, nested agents, or retries until something works. No automatic replacement for a failed worker. Record a missing slice as a gap. A brainstorm report does not establish exhaustive coverage or verify a suspected defect.

## Synthesize

Opus combines the returned proposals in one pass, resolves conflicts between slices, and prioritizes the useful ideas. The Opus owner can do this directly; otherwise use one available `idea-judge` agent on Opus. Inspect source only to resolve a decision that matters. Keep raw proposals out of the final report.

Opus owns any requested implementation and the real checks needed to validate it. Do not hand selected work back to Haiku to make it function. Stop after the synthesis for an ideas-only request.

If native agents or model selection are unavailable, report the limitation. An alternative runtime must enforce equivalent read-only, turn, worker, and model bounds before this policy can run there. Do not silently inherit the parent model or expand worker counts.

Return prioritized ideas, the slices they came from, evidence versus assumptions, gaps, and roles actually used. Actual usage may be reported when the host provides it. There is no automatic second round, background watcher, or ongoing swarm.

Check the effective model and capability metadata when the host exposes it, because host policy can override a requested role. Do not count a partial response as completed work or automatically resume it past the turn cap. The role agents omit automatically loaded project instruction files to keep context small, so the owner must supply relevant constraints in the brief.
