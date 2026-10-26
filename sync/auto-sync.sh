#!/bin/sh
# Scheduled sync from pstack. Bumps the pin to the newest cursor/plugins main and,
# when the result is mechanical, opens a PR and merges it. It stops with exit 2
# when a person or an agent has to resolve something, and with exit 1 when a check fails.
# See sync/README.md, "Scheduled runs".
set -eu
cd "$(dirname "$0")/.."

UPSTREAM=https://github.com/cursor/plugins.git
if [ -n "$(git status --porcelain)" ]; then
	echo "tree is not clean; start from a clean checkout" >&2
	exit 1
fi

new=$(git ls-remote "$UPSTREAM" refs/heads/main | cut -f1)
if [ "$new" = "$(cat sync/PIN)" ]; then
	echo "pin is already the newest upstream commit"
	exit 0
fi

log=$(mktemp)
python3 sync/sync.py bump "$new" >"$log" 2>&1 || { cat "$log"; exit 1; }
cat "$log"

special=$(grep -E '^(conflict:|new upstream file)' "$log" || true)
if [ -n "$special" ]; then
	echo "needs review before it can merge:" >&2
	echo "$special" >&2
	exit 2
fi

git add -A
if git diff --cached --quiet -- . ':(exclude)sync/PIN'; then
	echo "pstack did not change since the pin; keeping the pin"
	git reset -q --hard
	exit 0
fi

python3 sync/sync.py check
sh hooks/onyo-mode.test.sh
sh hooks/replay.test.sh

if git diff --cached -- . ':(exclude)sync/PIN' ':(exclude)sync/patches' | grep -E '^\+[^+]' | grep -qi cursor; then
	echo "added upstream text mentions Cursor; port it with an [A] hunk before it can merge" >&2
	exit 2
fi

pin=$(cut -c1-7 sync/PIN)
branch="sync/pstack-$pin"
if [ "$(gh pr list --head "$branch" --state open --json number --jq 'length')" != "0" ]; then
	echo "a PR for $branch is already open"
	exit 0
fi

git checkout -q -b "$branch"
git -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
	commit -q -m "Sync ostack to pstack $pin"
git push -q -u origin "$branch"
gh pr create --base main --head "$branch" --title "Sync ostack to pstack $pin" \
	--body "Automated sync to pstack \`$pin\`. Generated files, patches, and \`sync/PIN\` were produced by \`sync/sync.py bump\` and passed \`check\` and the hook tests. See [sync/README.md](sync/README.md)."
gh pr merge --squash --auto "$branch"
