# Encode Lessons in Structure

Apply when you catch yourself writing the same instruction a second time, or notice a recurring correction. Encode the rule as a lint, metadata flag, runtime check, or script instead of more text.

If the lesson needs judgment and cannot be encoded, make the instruction more prominent and add an example of the failure mode.

**Corollary:** If the fix is structural, only use the structural fix. The instruction is the symptom.

An enforced constraint still applies when the next agent has not read the instruction. Choose the enforcement closest to the source of the mistake: remove the opportunity, encode the invariant in types, use an existing lint or runtime check, then use an observable-behavior test. Keep documentation for judgments that cannot be enforced, and prefer existing mechanisms over new infrastructure.

Check the choice against the original failure or a faithful broken variant, and against valid use. A guard that catches the failure by rejecting valid behavior has not encoded the intended rule.
