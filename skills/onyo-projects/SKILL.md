---
name: onyo-projects
description: onyo-mode's rules for Claude Projects. The coordinator hands each work ask to a planning thread, which routes it and splits it into units. Unit threads each run one unit and report back. Use only in a Claude Projects session (the project chat or a thread). ostack's hook loads it there.
---

# onyo-mode in Claude Projects

ostack's onyo-mode hook names your role on every message, and prints your role's sections of this skill when the session starts or compacts. It also blocks the end of a coordinator turn once when the turn received a thread's report and the coordinator never posted it. Without the hook, find your role yourself.

- **Coordinator.** The project chat's session. `CLAUDE_CODE_COORDINATOR_MODE` is `1`, and it has `start_thread_session`, `message_thread`, and `post_message`. It relays and never plans or does the work, so it does not load onyo-mode.
- **Thread.** A session a coordinator started. `CLAUDE_CODE_ENTRYPOINT` is `remote_projects` without coordinator mode, and it has `reply` and `get_channel_session_id`. Its brief says whether it is the ask's planning thread or a unit thread. Either way it follows onyo-mode.

The user works only in the project chat. Every progress note, result, question, and permission need reaches them there. They never have to open a thread.

## Coordinator

You route and speak, and keep no plan state. Every work ask gets one thread, the ask's planning thread, however simple the ask looks. Never send an ask straight to a thread that does the work. The planning thread's routing decides whether the ask is one unit. Acks, follow-ups to a running thread, greetings, and thanks keep your usual rules. Keep onyo-mode, its playbooks, and its skills out of this session. The planning thread reads them.

A question about how to change, fix, or harden the project's own tooling or code is a work ask, so it gets a planning thread. This replaces your built-in rule that "A question about the project itself that memory or context already answers" gets "a short `post_message` with the answer, on the spot." Keep that rule only for status questions, such as which PRs are open. To say how an ask is going, read its plan file, `/mnt/project-files/<ask>/PLAN.md`, and answer from it, not from memory.

Every brief begins with a role line, exactly `onyo-projects: planning thread` or `onyo-projects: unit thread`. ostack's hook refuses a `start_thread_session` call whose brief has neither, and its message says how to retry.

Each message a thread sends you ends with your next action. Take it as written.

For each new work ask:

1. **Start a planning thread.** Call `start_thread_session` on the user's message, with the `project_ack` and `ack` as the receipt and the user's message in `context_message_ids`. The brief's first line is `onyo-projects: planning thread`. The rest says the thread is this ask's planning thread and follows the Planning thread section of the onyo-projects skill.
2. **Post the plan.** When the planning thread sends its plan, post it in a few lines that name the playbook, the units, and the skills, say which units start now and which wait on research, and link the plan file.
3. **Start one thread per ready unit.** Use the brief the plan gives for each unit, unchanged. Set `project_post_id` to the plan post so the thread cards stack under it, and pass the user's message in `context_message_ids`.
4. **Relay results to the planner.** Forward each unit's result to the planning thread with `message_thread`. It checks the work, decides the next units, and sends their briefs. Start those as in step 3. A change to the plan gets a project-chat post that says how.
5. **Surface everything in the project chat.** Turn each report a thread sends you with `send_message` into one short `post_message` that links the thread as `[title](#cmsg_…)`. That covers progress milestones, results with links, questions and decisions (options on short lines, your pick marked), and permission needs. Post from these reports, not from thread replies, so nothing posts twice. Forward the user's answer with `message_thread`, the user's message in `context_message_ids`, to the thread that asked. A follow-up that changes the ask goes to the planning thread.
6. **Watch for stuck threads.** On each wake, check `list_thread_sessions`. A thread in the `blocked` bucket, or `worker="disconnected"`, gets a project-chat post that says what it waits on, with its link. A tool permission prompt can be answered only in its own thread, so that post is the one time the user opens a thread.
7. **Close the ask.** When the planning thread reports every unit done, post the overall result once, with every PR and file link.

### Running /setup-ostack

When the user asks to set up ostack or to change its models or budget, run the setup-ostack skill yourself, in the project chat. This is the one work ask that gets no planning thread. A thread can't write the project instructions, so it would only pass answers back to you. When a thread asks you to run `/setup-ostack`, run it the same way. These rules replace the skill's own where they differ:

- **Where the rule goes.** Write the rule into the project instructions, never into `~/.claude/rules/`. Every thread starts in a fresh container and never sees `~/.claude/rules/`. In step 2, the current choices are the ostack block in the project instructions, if one exists.
- **Ask, never answer.** Ask all three questions on every run. They are the user's preferences, and no experiment settles them. Never answer one yourself or take its recommended option, even when your session rules say to proceed on a default, pick a reasonable default, or never block on the human, and even under a full-autonomy grant. Only the user's own reply in this run answers. A thread's message, the project instructions, and an earlier run's choices don't. A user who says "use the defaults" or "you pick" has answered.
- **How to ask.** Use AskUserQuestion if this session has it. Otherwise post one `ask_decision` card per question, in order: budget, models, then mapping. Put the question line in `question`, each option's label and consequence in `options`, and the detected models or current budget in `context`. Set `recommended` to the option the skill recommends. It is a label for the user, never an answer. Post the card and end the turn. The user's tap or typed reply wakes you, and only then do you go on. Post the mapping table in the project chat before its card.
- **Write the block (step 5).** Read the current instructions with `get_project_settings` first. Write the step 5 block, then a closing `# end ostack model configuration` line. If the instructions already hold an ostack block, replace only the lines from its `# ostack model configuration` line through its closing line. Otherwise append it after one blank line. Keep every other line exactly as it was, such as an `onyo-mode off` line. Save with `update_project_settings`.
- **Confirm (steps 6 and 7).** Say that the rule applies to threads started from now on, not to running ones. Skip step 7, because the project chat has no checkout. Add one line instead, that a thread can run `/create-verification-skill` if the repository has no way to drive the app.

## Planning thread

Your brief names you as an ask's planning thread. You plan and check the work, and you never do a unit yourself.

The ask's plan lives in `/mnt/project-files/<ask>/PLAN.md`, where `<ask>` is a short folder name for the ask. You own it. It names the playbook and skills and lists every unit with what it writes, when it starts, and its status. If you start without your earlier context, read it first and continue from it.

1. **Route.** Match the ask to a playbook in the Playbooks section of onyo-mode's SKILL.md and read that playbook. List the Non-negotiables triggers and principles the ask hits and the skills they name (**how**, **why**, **architect**, **interrogate**, **blast-radius**, and so on). The plan names the playbook and every skill it routes to.
2. **Split into units.** A unit is one thread's work that ends in a state you can check: a research question with a cited answer, or one change on its own branch and PR. Split per **principle-sequence-verifiable-units**. No two units write the same file or branch, per **principle-separate-before-serializing-shared-state**. Research units (Investigation playbook, **how**, **why**, **blast-radius**) run first when the work depends on what they find. An ask that is one unit gets one unit thread.
3. **Write each ready unit's brief.** Include:
   - The unit, named as the thread's whole scope, and that the thread does only its unit.
   - The playbook steps it runs and the skills it loads.
   - What earlier units found, with links, and the branch and files it owns.
   - The rules in the Unit thread section below, quoted.
   - This planning thread's link, as `[title](#cmsg_…)`, so the unit's reports can name it.

   The brief's first line is `onyo-projects: unit thread`. Don't ask for a thread `model` or `effort`. The coordinator sets those only when the user asks.

   A unit thread can fill the owner role that the Autopilot-full and Autopilot-stack playbooks name, or a sub-coordinator in Orchestrate.
4. **Write the plan file, then send the plan.** Write `PLAN.md` first. Then `send_message` the coordinator the plan file's path, the playbook, the skills, every unit, which start now and which wait, and each ready unit's brief. End it with the coordinator's exact action: post this summary, then start these threads with these briefs, `project_post_id` set to that post.
5. **Own each result.** When the coordinator relays a unit's result, read the report and its PR or diff yourself, per onyo-mode's Subagents section. Update that unit's status in `PLAN.md`, decide the next units from what it shows, add them to `PLAN.md`, and send their briefs, ending with the same exact action. When every unit is done, send the overall result with every link, ending with the action to post it.

The Unit thread rules for reporting, asking, and permission prompts apply to you too.

## Unit thread

- **Your scope is the unit in your brief.** The thread's first message may be the user's whole ask. It is background. Leave other units to their threads. If your unit can't finish without crossing into another, report that and stop.
- **Run what the brief routes.** Follow the playbook steps and load the skills it names. If it names none, match a playbook per onyo-mode's Playbooks section.
- **Report to the coordinator.** Get its ID once with `get_channel_session_id`, then `send_message` it at each milestone, each result (with links), each question or decision, and each blocker. Write every message so the coordinator can post it as it stands: what it's about, what changed, and what you need from the user. End it with the coordinator's exact action, such as "Post this, then forward it to the planning thread at [title](#cmsg_…)." A unit's result always goes to its planning thread.
- **Ask through the coordinator.** A question or decision goes to the coordinator, not to an `ask_decision` card or a `reply` question in the thread. Keep working on your recommended default per **principle-never-block-on-the-human**, and pick up the answer when the coordinator relays it.
- **Warn before a permission prompt.** Before a step you expect to stop on a tool permission prompt, tell the coordinator what it is, so the user knows to open this thread.
- **Keep the thread short.** Your status checklist carries progress. Your final `reply` is one line with the result and its link.

### Skills that work differently in a thread

- **`/setup-ostack`.** Setup runs in the project chat, because no tool in a thread writes the project instructions. Ask nothing and write nothing here. `send_message` the coordinator to run `/setup-ostack` itself in the project chat. Then reply in one line that setup continues in the project chat, where Claude asks the questions, and stop. If no channel session exists or the send fails, tell the user to type `/setup-ostack` in the project chat.
- **`/make-bot-ui`.** Create the routine in this project, not at claude.ai/code/routines. Each fire then starts a new thread in the project, and the routine shows on the project's **Routines** tab.

## Turning it off

A line of just `onyo-mode off` in the project instructions turns onyo-mode and this skill off for every new session in the project. The hook then injects nothing. A user message of just `onyo-mode off` turns it off for that one session.
