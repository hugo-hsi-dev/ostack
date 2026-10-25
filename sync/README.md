# Sync the Codex baseline with pstack

Every pstack-origin file is the exact upstream file at `PIN`, plus its reviewed `[A]` patch in `patches/<path>.patch`. `sync.py` retains ostack's patch/check/bump mechanism, but the baseline no longer renames pstack/poteto or strips invocation flags implicitly. No Claude fork patches are reused.

Three paths move for archival purposes: upstream `.cursor-plugin/plugin.json`, `plugin.json`, and `docs/harness/claude-code.md` live in `docs/upstream/`. These are provenance, not active installation instructions. `LICENSE` stays byte-identical. All other paths retain their upstream names.

## Change port content

1. Edit the generated file.
2. Run `python3 sync/sync.py refresh <path>`. New hunks get `[?]`.
3. Review each hunk against the harness-only scope. Mark accepted hunks `[A]`, or use `refresh --code A <path>` after review. No workflow redesign belongs in a port patch.
4. Run `python3 sync/sync.py check` and `python3 sync/validate_codex.py`.
5. Commit generated files, patches, and any derived metadata together.

`write` reconstructs upstream plus patches and refuses uncommitted generated edits unless `--force` is explicit. Use a disposable checkout for regeneration checks. `bump <sha>` first checks the current tree, then three-way merges upstream changes. Resolve conflicts, refresh and classify each changed patch, inspect new files, regenerate metadata for invocation flags and agent bodies, rerun validation, and update NOTICE.

Codex `agents/openai.yaml` files derive from upstream invocation flags; custom agent TOML bodies derive from `agents/*.md`. `validate_codex.py` checks these relationships. Codex mapping documentation, NOTICE, CI, and validation are port-owned. They are not overwritten by `sync.py`.

The cache defaults to `~/.cache/ostack-pstack.git`; set `PSTACK_CACHE` to an existing upstream bare clone when appropriate. No scheduled publication, automatic merge, or release policy is configured by this branch.
