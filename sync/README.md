# Sync ostack with pstack

ostack's pstack-origin files are generated. Each one is the upstream pstack file at the commit in [`PIN`](./PIN), with the harness map applied, plus its port patch in `patches/<path>.patch`. CI runs `python3 sync/sync.py check` and fails when a committed file differs from that result.

The harness map renames `poteto` to `onyo`, `Poteto` to `Onyo`, and `pstack` to `ostack` at the start of a word, so `upstack` stays as it is. It renames four paths, listed in `RENAMES` in [`sync.py`](./sync.py). It also removes `disable-model-invocation: true` from the frontmatter of every skill except the ones in `KEEP_FLAG`, so most skills can load on their own.

Files that pstack doesn't have, such as `hooks/`, `skills/onyo-projects/`, `NOTICE`, and `agents/onyo-reader.md`, are ostack's own. The tool never touches them.

## Hunk markers

The patches have no context lines, so each change is its own hunk. Each hunk header ends with the audit code of the change:

| Marker | Meaning |
| --- | --- |
| `[A]` | Harness port: a Cursor word, tool, or path mapped to its Claude Code equivalent. |
| `[C]` | Claude Projects workflow written into pstack text. |
| `[D]` | ostack's own change that is neither a port nor a default. |

A hunk that mixes codes carries all of them, for example `[CD]`. To find the hunks for one code, run `grep -rn '^@@ .*\[[A-Z]*C' sync/patches`. The README's fork section, above the line that starts pstack's README, is part of the port and carries `[A]`.

ostack's own defaults, such as its models and efforts, onyo-mode being on for every task, and setup being optional, never go in a patch. They live in [`hooks/ostack-defaults.md`](../hooks/ostack-defaults.md), the hook, and the README's fork section, so pstack's text keeps pstack's defaults. `check` rejects a `[B]` marker, the code these hunks used to carry.

## Change a generated file

1. Edit the file in the tree, for example `skills/why/SKILL.md`.
2. Run `python3 sync/sync.py refresh skills/why/SKILL.md`. This rewrites the file's patch from the tree. Hunks your edit didn't touch keep their markers. New or changed hunks get `[?]`.
3. Replace each `[?]` in the patch with the right code. If every new hunk has the same code, run `refresh --code A <path>` instead.
4. Run `python3 sync/sync.py check`, then commit the file and its patch together.

`write` regenerates every file from `PIN` and the patches. It refuses to overwrite uncommitted edits unless you pass `--force`.

## Sync to a new pstack version

1. Start from a clean tree where `check` passes.
2. Find the new commit on `cursor/plugins` main that bumps pstack's version.
3. Run `python3 sync/sync.py bump <commit>`. For each file upstream changed, the tool merges ostack's version with the change between the old and the new pin, writes the result, and updates `PIN`.
4. Resolve every file it lists as `conflict`, then run `refresh <path>` on it.
5. Read each file it lists as new upstream. Port any Cursor-specific text and mark those hunks `[A]`. If a new skill must keep `disable-model-invocation: true`, add it to `KEEP_FLAG`.
6. Mark every `[?]` hunk, run `check`, and update the commit and version in `NOTICE`.

The merge carries ostack's changes forward as changes. Text outside a patch hunk is always the new upstream text, so an old pstack sentence can't stay behind unless a person keeps it while resolving a conflict, and that leaves a `[?]` hunk that `check` rejects.

The tool fetches upstream into `~/.cache/ostack-pstack.git`. Set `PSTACK_CACHE` to use another git directory, such as a local clone of `cursor/plugins`.
