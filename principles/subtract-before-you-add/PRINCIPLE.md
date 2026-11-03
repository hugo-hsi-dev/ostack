# Subtract Before You Add

Apply when sequencing an addition, refactor, or rewrite, judging diff size, or tempted to add an abstraction, layer, or threaded flag.

When evolving a system, remove complexity first, then build. Default to subtraction.

Leave the design slightly simpler and more capable behind the same or smaller surface than you found it.

- Sequence removal before construction
- Cut before you polish (get to the minimum before investing in quality)
- No speculative validators, parsers, or guards beyond what the spec demands
- When a reference has no novel content, delete it rather than leaving a stub
- Make the smallest change that solves the problem; fewer lines beat elegant boilerplate
- Consolidate a repeated choice behind one source of truth and pass the result down
