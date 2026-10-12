# ostack in a Claude project

The other guide pages and the skills come from pstack, which has no Claude Projects. ostack adds a Projects layer on top of them: the [`onyo-projects`](../../skills/onyo-projects/SKILL.md) skill and the hook that loads it. This page explains that layer. Where this page and the pstack text disagree, this page describes what the plugin does in a project.

## The project chat plans, and threads do the work

A Claude project has one project chat and many threads. ostack gives each session one of three roles:

- **Coordinator.** The project chat's session. It relays asks and results and never does the work, so it doesn't load onyo-mode. It hands each work ask to a planning thread and posts every thread's progress, results, and questions in the project chat, so you never have to open a thread.
- **Planning thread.** One per ask. It follows onyo-mode, picks the playbook, splits the ask into units, writes each unit's brief, and checks each result.
- **Unit thread.** One per unit. It follows onyo-mode, does its one unit, and reports to the coordinator.

The rules for each role are in [`onyo-projects`](../../skills/onyo-projects/SKILL.md).

## The hook holds each role to its rules

ostack's hook, [`hooks/onyo-mode.sh`](../../hooks/onyo-mode.sh), knows a project session from its environment, so a project needs no setup. In a project it does four things:

- On every message, it names the session's role. A thread is told to follow onyo-mode and `onyo-projects`. The coordinator is told to follow `onyo-projects` only.
- When a session starts, resumes, or compacts, it prints that role's sections of `onyo-projects` in full, so a fresh or compacted coordinator still has its rules.
- Before the coordinator starts a thread, it checks that the brief opens with `onyo-projects: planning thread` or `onyo-projects: unit thread`. If not, it refuses the start and tells the coordinator how to retry.
- At the end of a coordinator turn that received a thread's report, it checks that the coordinator posted the report in the project chat. If not, it blocks the end of the turn once.

## Set up ostack in the project chat

Threads start in fresh cloud containers, so they never see `~/.claude/rules/ostack-models.md`. In a project, the model rule goes in the project instructions instead.

To change the models or the budget for a project, type `/setup-ostack` in the project chat. The coordinator runs the setup itself and doesn't start a thread for it. It asks the same three questions and waits for your answer to each. It then writes the rule into the project instructions, between a `# ostack model configuration` line and a `# end ostack model configuration` line, and leaves every other line there as it was. Threads started after that use the rule. Running threads don't.

If you type `/setup-ostack` in a thread, the thread asks the coordinator to run it in the project chat, and the questions appear there.

## Start prompts without `/onyo-mode`

[Run work while you sleep](./07-overnight.md#run-many-projects-in-parallel) says to start your prompts to a project's coordinator with `/onyo-mode`. In a Claude project with ostack, don't. The coordinator doesn't load onyo-mode, and every thread follows it already.

The Autopilot-full and Autopilot-stack playbooks start one owner session per PR, and Orchestrate can start sub-coordinators. In a project, a unit thread can fill either role.

## Turn it off for a project

A line of just `onyo-mode off` in the project instructions turns off onyo-mode and `onyo-projects` for every new session in the project. A message of just `onyo-mode off` turns them off for that one session.
