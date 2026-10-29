### Opening a PR

Invoked at the end of every other playbook.

**Worktree.** Work from a git worktree off main. Subagents inherit it. Multiple `Agent` calls on the same branch each get their own worktree, or `git fetch && git reset --hard origin/<branch>` between them. Dirty branch with unrelated work: patch out, fresh worktree, apply. Snarled worktree: reset from main, redo minimally.

**Commits.** Commit liberally. Rebase into small, ordered commits before opening PRs. Each commit is a future PR: landable, ordered to tell the story. Amend when the fix belongs in a just-made commit. New commit when separable. Commit bodies don't restate the subject.

**PRs.** Run `/simplify` over the diff before commit and `/no-comments` before review. Write every PR title, description, and commit body with `/technical-writing` (every layer except Diátaxis, and apply the STE vocabulary rules: one word per action, keep articles, a plain verb over `-ing` where one works), then apply `/unslop`.

**Titles.** Conventional Commits `type(scope): subject`, no trailing period. Type such as `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, or `perf`. Scope is the area, such as `ostack` or `onyo-mode`. Subject is short, imperative, and names a real symbol when one carries the change, for example `fix(ostack): retarget opening-a-pr readiness check`.

**Descriptions.** The PR body is a one-minute briefing, not a lab notebook, for a reviewer who has the diff. It says why the change exists, what it leaves out, what it could break, and how you proved it works. Write short, simple sentences with few identifiers, no walls of text. The body becomes the squash commit body, so keep that commit under about 40 lines. Use `##` headings, not bold lead-ins, in this order, and drop a section with nothing to say:

- `## Why`: the problem and approach, 1–3 short sentences. No SHAs, rebase genealogy, or "based on main" preamble.
- `## What changed`: 1–3 short bullets. Name a real symbol or path only when it carries the change. Name both sides of a rename or retarget.
- `## Scope`: always. 1–3 short items on what it covers and what it deliberately leaves out (a follow-up, a known gap). No symbols, paths, or file-by-file essay.
- `## Tradeoffs`: only rejected alternatives a reviewer would otherwise ask about. Skip when there was no real choice.
- `## Blast Radius`: 1–2 sentences on who or what it touches and why that is safe or risky. If main is red, state the cost of leaving it red.
- `## Verification`: 1–3 bullets, each a real run path and its outcome. Perf: one primary number with its unit, `before → after`, and a link to the arena or swarm directory for the rest. No sample-size methodology, swarm recitals, or metric tables.

After the sections, attach videos or screenshots when they prove a claim. Full SHAs, swarm or arena lane recitals, lever-correction essays, file-by-file checklists, and "CLEAN" verdicts go in a linked artifact, not the body.

**Forge.** Resolve the forge before the first PR operation and keep that choice for create, edit, view, watch, and merge. GitHub CLI (`gh`) is the default. If `command -v origin` succeeds and Origin can resolve the repository, prefer `origin pr ...`. If Origin is absent or cannot resolve the repository, stay on `gh` and record the fallback. Do not require Graphite (`gt`).

**The PR may already exist.** With automatic PR creation on, the Claude desktop app opens a draft PR for the session's branch when it first pushes. Before you create a PR, run `gh pr view <branch>`. When the branch has a PR, take it over: set its base per **Size and stacks**, rewrite its title and body per the rules above, and leave it a draft until **Readiness** says otherwise. Create a PR only for a branch that has none, such as a stack child.

**Size and stacks.** Prefer five narrow PRs to one large PR. A stack is a base-branch chain. The root PR targets trunk. Each child branch rebases onto its parent's exact tip and its PR targets the parent branch. As a parent merges, move its child onto trunk per `playbooks/shipping.md` step 4. Create a missing child PR as a draft with `gh pr create --draft --base <parent-branch>`, and retarget one with `origin pr edit <pr> --base <parent-branch>` or `gh pr edit <pr> --base <parent-branch>`. Branch from trunk only for independent work. Rebase on trunk before substantial stack work.

**Readiness.** Every PR starts as a draft and turns ready for review only when its work is ready: rebased into its final commits, `/simplify` and `/no-comments` done, the title and body written, and the change proved on the real artifact. Ready is the signal for review bots and human reviewers, so mark a PR ready only when you would merge it as it stands. Mark it with `gh pr ready <number>`. Run `gh pr view <number>` before you refer to PR status.

**Auto-fix.** Opening a PR does not mean watching it. Post the URL and keep building. Finish the phase or stack first. To get PRs green, use Claude Code's PR Auto-fix (`/autofix-pr`, or the Auto-fix toggle in the desktop app) when the user asks for it or has it on. Push back when feedback drifts from intent.

A subagent that opens a PR runs `/simplify` and `/no-comments`, marks the PR ready per **Readiness**, and posts the URL. It returns to the parent without watching the PR, unless it is an Autopilot-full or Autopilot-stack owner. That owner marks its PR ready and turns on Claude Code's PR Auto-fix (`/autofix-pr`, or the Auto-fix toggle in the desktop app) at its code-ready report, and reports merge-ready.
