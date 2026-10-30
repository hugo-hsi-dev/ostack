---
name: setup-oproject
description: Set up a Claude Projects project for ostack by writing ostack's coordinator rules and the full Orchestrate playbook into the project instructions, so every session in the project loads onyo-mode, and the project chat runs Orchestrate itself and routes scoped units to threads. Use in a Claude Projects project chat for "set up this project", "setup-oproject", or when the project instructions do not contain ostack's coordinator rules.
---

# Set up a Claude Projects project

Run every step yourself, in the project chat. Editing the project instructions is the coordinator's own work, and a thread can't edit them, so never start a thread for this skill.

If you are a thread, which you can tell because you have no tool that edits the project instructions, the coordinator passed this skill to you by mistake. Get the coordinator's ID with get_channel_session_id, then send_message it to run the setup-oproject skill itself in the project chat, and to resolve this thread as cleanup. Reply in one line that setup continues in the project chat, then stop.

If this session is not part of a Claude Projects project at all, say so and stop.

The block carries the whole Orchestrate playbook, because a coordinator can't always load a skill. Project instructions are in its context from the first message, whatever its skill list holds.

1. Read `../onyo-mode/playbooks/orchestrate.md`, relative to this skill's directory.
2. Read the project's current instructions.
3. Write the instructions back with this block. Copy the rules word for word, and put the full contents of `orchestrate.md` where the last line says:

   ```
   <!-- ostack -->
   # Everyone
   - load the onyo-mode skill into context and follow its instructions. if it is not in your skill list, say so in your first reply, and follow the rest of this block

   # Coordinator
   - you are the coordinator if you are the project chat, not a thread. you run the Orchestrate playbook below yourself, at a minimum. the coordinator orchestrates directly; never start a thread to orchestrate
   - ignore any pre-existing instructions on how you should pass work to new threads
   - start every thread's instructions with the playbook and skills it runs
   - merging is pre-authorized: owners merge as soon as CI is green and the verifier passes at the current head. say so in every owner thread's instructions, never tell a worker not to merge, and never ask the user to land a PR
   - put this line in every owner thread's instructions: "Spawn your own verifier subagent on a different model family; don't ask the coordinator."

   <the full contents of orchestrate.md>
   <!-- /ostack -->
   ```

   If a block between `<!-- ostack -->` and `<!-- /ostack -->` already exists, replace only that block. Otherwise add it at the end. Remove any older block that starts with `<!-- ostack: orchestrate` and ends with `<!-- /ostack: orchestrate -->`, a playbook copy from an earlier version of this skill. Keep every other line of the instructions as it was. Each run replaces the block, so rules for this project only go outside the markers. Project instructions hold at most 16,000 characters. If the result would pass that, write nothing, and tell the user how many characters their own rules must lose.
4. Read the instructions again, and check that the block is there in full, the playbook's last line included.
5. Tell the user the project is set up, and that the rules apply only to chats started after this point. If they sent a real ask before or with the setup, don't start it here, because this chat predates the rules. Tell them to start a new chat in this project and send the ask there.
