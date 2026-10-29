---
name: setup-oproject
description: Set up a Claude Projects project for ostack by copying onyo-mode's Orchestrate playbook into the project instructions, so the project chat plans each ask and routes scoped units to threads. Use in a Claude Projects project chat for "set up this project", "setup-oproject", or when the project instructions do not contain the Orchestrate playbook.
---

# Set up a Claude Projects project

Run every step yourself, in the project chat. Editing the project instructions is the coordinator's own work, and a thread can't edit them, so never start a thread for this skill.

If you are a thread, which you can tell because you have no tool that edits the project instructions, the coordinator passed this skill to you by mistake. Get the coordinator's ID with get_channel_session_id, then send_message it to run the setup-oproject skill itself in the project chat, and to resolve this thread as cleanup. Reply in one line that setup continues in the project chat, then stop.

If this session is not part of a Claude Projects project at all, say so and stop.

1. Read `../onyo-mode/playbooks/orchestrate.md`, relative to this skill's directory.
2. Read the project's current instructions.
3. Write the instructions back with the playbook between these two marker lines, copied word for word:

   ```
   <!-- ostack: orchestrate <checksum> -->
   <the full contents of orchestrate.md>
   <!-- /ostack: orchestrate -->
   ```

   `<checksum>` is the one your ostack hook note names. Without that note, run `cksum < ../onyo-mode/playbooks/orchestrate.md` and use its first number. If a block that starts with `<!-- ostack: orchestrate` already exists, replace the whole block, whatever checksum it carries. Otherwise add the block at the end. Keep every other line of the instructions as it was.

   This block is a copy of ostack's playbook, and each run replaces it. Put rules for this project only outside the markers, and send a lesson that would help every project to ostack's `orchestrate.md`.
4. Read the instructions again, and check that the block holds the whole file.
5. Tell the user the project is set up, and that the playbook applies from the next new chat in this project, so they should start one before their next ask.
