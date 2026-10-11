---
name: onyo-projects
description: onyo-mode's rules for Claude Projects. The coordinator hands each work ask to a planning thread, which routes it and splits it into units. Unit threads each run one unit and report back. Use only in a Claude Projects session (the project chat or a thread). ostack's hook loads it there.
---

# onyo-mode in Claude Projects

ostack's onyo-mode hook names your role on every message. Without the hook, find it yourself.

- **Coordinator.** The project chat's session. `CLAUDE_CODE_COORDINATOR_MODE` is `1`, and it has `start_thread_session`, `message_thread`, and `post_message`. It relays and never plans or does the work, so it does not load onyo-mode.
- **Thread.** A session a coordinator started. `CLAUDE_CODE_ENTRYPOINT` is `remote_projects` without coordinator mode, and it has `reply` and `get_channel_session_id`. Its brief says whether it is the ask's planning thread or a unit thread. Either way it follows onyo-mode.

The user works only in the project chat. Every progress note, result, question, and permission need reaches them there. They never have to open a thread.

## Coordinator

Your default for a work ask is one thread per ask. Here that one thread is the ask's planning thread, never a thread that does the work. Acks, follow-ups to a running thread, greetings, and thanks keep your usual rules. Keep onyo-mode, its playbooks, and its skills out of this session. The planning thread reads them.

Every brief begins with a role line, exactly `onyo-projects: planning thread` or `onyo-projects: unit thread`. ostack's hook refuses a `start_thread_session` call whose brief has neither, and its message says how to retry.

Each message a thread sends you ends with your next action. Take it as written.

For each new work ask:

1. **Start a planning thread.** Call `start_thread_session` on the user's message, with the `project_ack` and `ack` as the receipt and the user's message in `context_message_ids`. The brief's first line is `onyo-projects: planning thread`. The rest says the thread is this ask's planning thread and follows the Planning thread section of the onyo-projects skill.
2. **Post the plan.** When the planning thread sends its plan, post it in a few lines that name the playbook, the units, and the skills, and say which units start now and which wait on research.
3. **Start one thread per ready unit.** Use the brief the plan gives for each unit, unchanged. Set `project_post_id` to the plan post so the thread cards stack under it, and pass the user's message in `context_message_ids`.
4. **Relay results to the planner.** Forward each unit's result to the planning thread with `message_thread`. It checks the work, decides the next units, and sends their briefs. Start those as in step 3. A change to the plan gets a project-chat post that says how.
5. **Surface everything in the project chat.** Turn each report a thread sends you with `send_message` into one short `post_message` that links the thread as `[title](#cmsg_…)`. That covers progress milestones, results with links, questions and decisions (options on short lines, your pick marked), and permission needs. Post from these reports, not from thread replies, so nothing posts twice. Forward the user's answer with `message_thread`, the user's message in `context_message_ids`, to the thread that asked. A follow-up that changes the ask goes to the planning thread.
6. **Watch for stuck threads.** On each wake, check `list_thread_sessions`. A thread in the `blocked` bucket, or `worker="disconnected"`, gets a project-chat post that says what it waits on, with its link. A tool permission prompt can be answered only in its own thread, so that post is the one time the user opens a thread.
7. **Close the ask.** When the planning thread reports every unit done, post the overall result once, with every PR and file link.

## Planning thread

Your brief names you as an ask's planning thread. You plan and check the work, and you never do a unit yourself.

1. **Route.** Match the ask to a playbook in the Playbooks section of onyo-mode's SKILL.md and read that playbook. List the Non-negotiables triggers and principles the ask hits and the skills they name (**how**, **why**, **architect**, **interrogate**, **blast-radius**, and so on). The plan names the playbook and every skill it routes to.
2. **Split into units.** A unit is one thread's work that ends in a state you can check: a research question with a cited answer, or one change on its own branch and PR. Split per **principle-sequence-verifiable-units**. No two units write the same file or branch, per **principle-separate-before-serializing-shared-state**. Research units (Investigation playbook, **how**, **why**, **blast-radius**) run first when the work depends on what they find. An ask that is one unit gets one unit thread.
3. **Write each ready unit's brief.** Include:
   - The unit, named as the thread's whole scope, and that the thread does only its unit.
   - The playbook steps it runs and the skills it loads.
   - What earlier units found, with links, and the branch and files it owns.
   - The rules in the Unit thread section below, quoted.
   - This planning thread's link, as `[title](#cmsg_…)`, so the unit's reports can name it.

   The brief's first line is `onyo-projects: unit thread`. Don't ask for a thread `model` or `effort`. The coordinator sets those only when the user asks.
4. **Send the plan.** `send_message` the coordinator the playbook, the skills, every unit, which start now and which wait, and each ready unit's brief. End it with the coordinator's exact action: post this summary, then start these threads with these briefs, `project_post_id` set to that post.
5. **Own each result.** When the coordinator relays a unit's result, read the report and its PR or diff yourself, per onyo-mode's Subagents section. Decide the next units from what it shows and send their briefs, ending with the same exact action. When every unit is done, send the overall result with every link, ending with the action to post it.

The Unit thread rules for reporting, asking, and permission prompts apply to you too.

## Unit thread

- **Your scope is the unit in your brief.** The thread's first message may be the user's whole ask. It is background. Leave other units to their threads. If your unit can't finish without crossing into another, report that and stop.
- **Run what the brief routes.** Follow the playbook steps and load the skills it names. If it names none, match a playbook per onyo-mode's Playbooks section.
- **Report to the coordinator.** Get its ID once with `get_channel_session_id`, then `send_message` it at each milestone, each result (with links), each question or decision, and each blocker. Write every message so the coordinator can post it as it stands: what it's about, what changed, and what you need from the user. End it with the coordinator's exact action, such as "Post this, then forward it to the planning thread at [title](#cmsg_…)." A unit's result always goes to its planning thread.
- **Ask through the coordinator.** A question or decision goes to the coordinator, not to an `ask_decision` card or a `reply` question in the thread. Keep working on your recommended default per **principle-never-block-on-the-human**, and pick up the answer when the coordinator relays it.
- **Warn before a permission prompt.** Before a step you expect to stop on a tool permission prompt, tell the coordinator what it is, so the user knows to open this thread.
- **Keep the thread short.** Your status checklist carries progress. Your final `reply` is one line with the result and its link.

## Turning it off

A line of just `onyo-mode off` in the project instructions turns onyo-mode and this skill off for every new session in the project. The hook then injects nothing. A user message of just `onyo-mode off` turns it off for that one session.
