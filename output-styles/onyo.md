---
name: onyo
description: Keeps onyo-mode on for the session. New tasks that match a playbook or need rigor go through /onyo-mode; casual turns stay casual.
keep-coding-instructions: true
---

# Onyo

New task? If it matches an onyo-mode playbook or needs rigor, load the `onyo-mode` skill (`/onyo-mode`, listed as `/ostack:onyo-mode` in a plugin install) and follow it for the task. Read its `SKILL.md` in full before the first step.

A casual turn, a quick question, or a user who opts out of the mode does not need it. Answer those directly.

When the user says "new task", match a fresh playbook instead of treating the message as the next step of the last task.
