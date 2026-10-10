# onyo-mode in Claude Projects

A Claude project has two roles. Find yours first.

- **Coordinator.** The project chat's session. It has `start_thread_session`, `message_thread`, and `post_message`. It routes and never does the work.
- **Thread.** A session a coordinator started for one unit. `CLAUDE_CODE_ENTRYPOINT` is `remote_projects`, and it has `reply` and `get_channel_session_id`. It runs its unit and reports to the coordinator.

The user works only in the project chat. Every progress note, result, question, and permission need reaches them there. They never have to open a thread.

## Coordinator

The project instructions replace your default for a work ask, which is one thread per ask with the user's message passed straight through. Acks, follow-ups to a running thread, greetings, and thanks keep your usual rules.

For each new work ask:

1. **Route.** Match the ask to a playbook in the Playbooks section of onyo-mode's SKILL.md and read that playbook. List the Non-negotiables triggers and principles the ask hits and the skills they name (**how**, **why**, **architect**, **interrogate**, **blast-radius**, and so on). Your plan names the playbook and every skill it routes to.
2. **Split into units.** A unit is one thread's work that ends in a state you can check: a research question with a cited answer, or one change on its own branch and PR. Split per **principle-sequence-verifiable-units**. No two units write the same file or branch, per **principle-separate-before-serializing-shared-state**. Research units (Investigation playbook, **how**, **why**, **blast-radius**) run first when the work depends on what they find. Start the work units after you read their results. An ask that is one unit gets one thread, decided after routing.
3. **Post the plan.** One `project_ack` (or `post_message`) is the receipt. In a few lines it names the playbook, the units, and the skills, and says which units start now and which wait on research.
4. **Start one thread per ready unit.** Set `project_post_id` to the plan post so the thread cards stack under it. Write each brief in `instructions` with:
   - The unit, named as the thread's whole scope. Pass the user's message in `context_message_ids` as background, and say the thread does only its unit.
   - The playbook steps it runs and the skills it loads.
   - What earlier units found, with links, and the branch and files it owns.
   - The reporting rules in the Thread section below, quoted.
   - Where `start_thread_session` takes `model` and `effort`, the role's line from the ostack model configuration (`feature`, `bug-fix`, `how explorer`, and so on).
5. **Own each result.** Read each thread's report and its PR or diff yourself before you act on it, per onyo-mode's Subagents section. Decide the next units from what it shows, then start them. A finding that changes the plan gets a project-chat post that says how.
6. **Surface everything in the project chat.** Turn each report a thread sends you with `send_message` into one short `post_message` that links the thread as `[title](#cmsg_…)`. That covers progress milestones, results with links, questions and decisions (options on short lines, your pick marked), and permission needs. Post from these reports, not from thread replies, so nothing posts twice. Forward the user's answer with `message_thread`, the user's message in `context_message_ids`.
7. **Watch for stuck threads.** On each wake, check `list_thread_sessions`. A thread in the `blocked` bucket, or `worker="disconnected"`, gets a project-chat post that says what it waits on, with its link. A tool permission prompt can be answered only in its own thread, so that post is the one time the user opens a thread.
8. **Close the ask.** When every unit is done, post the overall result once, with every PR and file link.

A follow-up that changes the plan goes back through steps 1 to 4.

## Thread

- **Your scope is the unit in your brief.** The thread's first message may be the user's whole ask. It is background. Leave other units to their threads. If your unit can't finish without crossing into another, report that and stop.
- **Run what the brief routes.** Follow the playbook steps and load the skills it names. If it names none, match a playbook per onyo-mode's Playbooks section.
- **Report to the coordinator.** Get its ID once with `get_channel_session_id`, then `send_message` it at each milestone, each result (with links), each question or decision, and each blocker. Write every message so the coordinator can post it as it stands: what it's about, what changed, and what you need from the user.
- **Ask through the coordinator.** A question or decision goes to the coordinator, not to an `ask_decision` card or a `reply` question in the thread. Keep working on your recommended default per **principle-never-block-on-the-human**, and pick up the answer when the coordinator relays it.
- **Warn before a permission prompt.** Before a step you expect to stop on a tool permission prompt, tell the coordinator what it is, so the user knows to open this thread.
- **Keep the thread short.** Your status checklist carries progress. Your final `reply` is one line with the result and its link.

## Project instructions

The coordinator reads the project instructions every session but loads a skill only when told. `/setup-onyo-project` puts this block at the top of the project instructions, so both roles get the routing rules before any skill loads:

```text
## onyo-mode in this project

Use onyo-mode for every task.

Project chat (coordinator): for every new work ask, load the onyo-mode skill (ostack:onyo-mode) and follow the Coordinator section of its references/claude-projects.md before you start any thread. This replaces your default of one thread per ask with my message passed straight through. Route first: name the playbook and the skills the ask needs, split it into research and work units, and post that plan. Then start one thread per ready unit, with a brief that names its unit, playbook, skills, and inputs. Read each thread's results before you start the work that depends on them. Post every thread's progress, results, questions, and permission needs in the project chat, and forward my answers to the thread. I should never have to open a thread except to answer a tool permission prompt.

Threads: do only the unit your brief names, even when the thread's first message is my whole ask. Send progress, results, questions, and permission needs to the coordinator with send_message (its ID from get_channel_session_id). Ask through the coordinator, not in the thread.
```
