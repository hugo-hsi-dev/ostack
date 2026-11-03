# Subtract Before You Add

Apply when sequencing an addition, refactor, or rewrite, judging diff size, or tempted to add an abstraction, layer, or threaded flag. Remove dead code, redundant validators, and stub references first, then build on the simpler base with the smallest change that works.

When evolving a system, remove complexity first, then build. Default to subtraction.

Make simplification a continual investment. Leave the design slightly simpler and more capable behind the same or smaller surface than you found it.

- Sequence removal before construction
- Cut before you polish (get to the minimum before investing in quality)
- Design for observed usage, not speculative edge cases
- No speculative validators, parsers, or guards beyond what the spec demands
- Simplify prompts (remove redundant instructions, excessive templates)
- When a reference has no novel content, delete it rather than leaving a stub
- Make the smallest change that solves the problem; fewer lines beat elegant boilerplate
- Consolidate a repeated choice behind one source of truth and pass the result down
