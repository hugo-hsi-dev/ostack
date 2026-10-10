---
name: setup-onyo-project
description: Set up a project for ostack in one pass. Runs setup-ostack (budget, models, role mapping), then turns onyo-mode on for every new session or thread. Use for /setup-onyo-project, "set up ostack for this project", or "set up onyo for this project". In a Claude Projects project chat, run it there yourself instead of starting a thread.
---

# Setup onyo project

Two parts, in order: pick ostack's models with setup-ostack, then turn onyo-mode on where it lasts for this project. Running this skill is the request to turn onyo-mode on, so part 2 asks nothing.

## Where it runs

Use setup-ostack's "Where it runs" cases. In a Claude Projects project chat, run both parts yourself and never start a thread for them. In a Projects thread, ask nothing and write nothing: hand the run to the project chat as that section says, naming `/setup-onyo-project`, and stop.

## 1. Pick the models

Load setup-ostack with the Skill tool (`ostack:setup-ostack` in a plugin install). If the Skill tool doesn't list it, read `${CLAUDE_SKILL_DIR}/../setup-ostack/SKILL.md` in full. If `${CLAUDE_SKILL_DIR}` appears literally, it is the directory that holds this file. Follow it through its step 6, including all three of its questions, and wait for each answer as it says. Hold its step 7 until part 2 is done.

## 2. Turn onyo-mode on

The line is `use onyo-mode`. Claude loads the onyo-mode skill on its own when its instructions say so.

- **Project chat.** Read the project instructions again, after setup-ostack's write. If a line outside the ostack block already asks for onyo-mode, leave the instructions as they are. Otherwise put `use onyo-mode` on the first line, then one blank line, then the instructions as they were. Write them with `update_project_settings`. Keep every other line exactly as it was. New threads follow it, running ones don't.
- **Local or another cloud session.** Use `CLAUDE.local.md` at the repository root (the current directory outside a repository). Claude Code loads it into every session in this project, and it stays out of the shared `CLAUDE.md`. If it already has a line asking for onyo-mode, leave it. Otherwise add `use onyo-mode` as its first line, creating the file if it's missing. In a git repository, run `git check-ignore -q CLAUDE.local.md`, and when that fails, append `CLAUDE.local.md` to `.git/info/exclude` so it is never committed. In a cloud session outside Projects, say the file ends with the container.

## 3. Confirm

Then do setup-ostack's step 7. Close with one message: where the model rule went, where the onyo-mode line went, and that both apply to new sessions, or to new threads in a Claude project. Re-running this skill is safe. It asks the three questions again and leaves an existing onyo-mode line alone.
