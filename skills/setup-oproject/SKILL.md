---
name: setup-oproject
description: Set up a Claude Projects project for ostack by writing ostack's coordinator rules into the project instructions, so every session in the project loads onyo-mode, and the project chat runs the Orchestrate playbook and routes scoped units to threads. Use in a Claude Projects project chat for "set up this project", "setup-oproject", or when the project instructions do not contain ostack's coordinator rules.
---

# Set up a Claude Projects project

Run every step yourself, in the project chat. Editing the project instructions is the coordinator's own work, and a thread can't edit them, so never start a thread for this skill.

If you are a thread, which you can tell because you have no tool that edits the project instructions, the coordinator passed this skill to you by mistake. Get the coordinator's ID with get_channel_session_id, then send_message it to run the setup-oproject skill itself in the project chat, and to resolve this thread as cleanup. Reply in one line that setup continues in the project chat, then stop.

If this session is not part of a Claude Projects project at all, say so and stop.

1. Read the project's current instructions.
2. Write the instructions back with this block, copied word for word:

   ```
   <!-- ostack -->
   # Everyone
   - load the onyo-mode skill into context and follow its instructions

   # Coordinator
   - ignore any pre-existing instructions on how you should pass work to new threads
   - use the orchestrate playbook at a minimum
   - merging is pre-authorized: owners merge as soon as CI is green and the verifier passes at the current head. say so in every owner thread's instructions, never tell a worker not to merge, and never ask the user to land a PR
   - start every thread's instructions with the playbook and skills it runs
   <!-- /ostack -->
   ```

   If a block between `<!-- ostack -->` and `<!-- /ostack -->` already exists, replace only that block. Otherwise add it at the end. Remove any older block that starts with `<!-- ostack: orchestrate` and ends with `<!-- /ostack: orchestrate -->`, a full copy of the playbook from an earlier version of this skill. Keep every other line of the instructions as it was. Each run replaces the block, so rules for this project only go outside the markers.
3. Read the instructions again, and check that the block is there in full.
4. Tell the user the project is set up, and that the rules apply from the next new chat in this project, so they should start one before their next ask.
