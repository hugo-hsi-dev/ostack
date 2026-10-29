---
name: setup-oproject
description: Set up a Claude Projects project for ostack by copying onyo-mode's Orchestrate playbook into the project instructions, so the project chat plans each ask and routes scoped units to threads. Use in a Claude Projects project chat for "set up this project", "setup-oproject", or when the project instructions do not contain the Orchestrate playbook.
---

# Set up a Claude Projects project

Run every step yourself, in the project chat. Editing the project instructions is the coordinator's own work, and a thread can't edit them, so never start a thread for this skill. If this session is not a Claude Projects project chat, say so and stop.

1. Read `../onyo-mode/playbooks/orchestrate.md`, relative to this skill's directory.
2. Read the project's current instructions.
3. Write the instructions back with the playbook between these two marker lines, copied word for word:

   ```
   <!-- ostack: orchestrate -->
   <the full contents of orchestrate.md>
   <!-- /ostack: orchestrate -->
   ```

   If the markers already exist, replace only what is between them. Otherwise add the block at the end. Keep every other line of the instructions as it was.
4. Read the instructions again, and check that the block holds the whole file.
5. Tell the user the project is set up, and that the playbook applies from the next new chat in this project, so they should start one before their next ask.
