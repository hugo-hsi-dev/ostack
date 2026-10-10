---
name: onyo
description: Keeps onyo-mode on for the session. New tasks that match a playbook or need rigor go through /onyo-mode. Casual turns stay casual.
keep-coding-instructions: true
---

# Onyo

New task? If it matches an onyo-mode playbook or needs rigor, load the onyo-mode skill before the first step and follow it for the task. Use the Skill tool (`ostack:onyo-mode` in a plugin install). If the Skill tool doesn't list it, read its `SKILL.md` in full. In a plugin install, find it from Bash with `find ~/.claude/plugins -path '*/skills/onyo-mode/SKILL.md'` and read the newest match (`ls -t`). The Glob tool does not expand `$HOME` or `~`. Otherwise read `.claude/skills/onyo-mode/SKILL.md` or `~/.claude/skills/onyo-mode/SKILL.md`. The user can also type `/onyo-mode` (listed as `/ostack:onyo-mode` in a plugin install).

A casual turn or a user who opts out of the mode does not need it. Answer those directly.
