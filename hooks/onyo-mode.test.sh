#!/bin/sh
# Runs hooks/onyo-mode.sh as each kind of session and checks what it prints.
hook="$(cd "$(dirname "$0")" && pwd)/onyo-mode.sh"
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
fails=0

run() {
	env -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_PROJECTS_SESSION -u CLAUDE_CODE_COORDINATOR_MODE \
		CLAUDE_PROJECT_DIR="$dir" "$@" sh "$hook"
}

check() {
	name=$1 out=$2 want=$3 forbid=$4
	if ! printf '%s' "$out" | grep -qF -- "$want"; then
		echo "FAIL $name: missing '$want'"; fails=$((fails + 1)); return
	fi
	if [ -n "$forbid" ] && printf '%s' "$out" | grep -qF -- "$forbid"; then
		echo "FAIL $name: has '$forbid'"; fails=$((fails + 1)); return
	fi
	echo "ok   $name"
}

out=$(run)
check "solo session gets onyo-mode" "$out" "This session's role is: solo." "You are a Claude Projects"
check "solo session gets the skill body" "$out" "## Non-negotiables" "disable-model-invocation"

out=$(run CLAUDE_CODE_ENTRYPOINT=remote_projects CLAUDE_CODE_COORDINATOR_MODE=1)
check "coordinator gets its overlay" "$out" "## You are a Claude Projects coordinator" "## You are a Claude Projects thread"
check "coordinator gets the skill body" "$out" "## Playbooks"

out=$(run CLAUDE_CODE_PROJECTS_SESSION=1 CLAUDE_CODE_COORDINATOR_MODE=1)
check "coordinator found by the projects flag alone" "$out" "This session's role is: coordinator."

out=$(run CLAUDE_CODE_ENTRYPOINT=remote_projects)
check "thread gets its overlay" "$out" "## You are a Claude Projects thread" "## You are a Claude Projects coordinator"

out=$(run CLAUDE_CODE_COORDINATOR_MODE=1)
check "coordinator mode outside Projects stays solo" "$out" "This session's role is: solo."

printf '# notes\n\nonyo-mode off\n' > "$dir/CLAUDE.md"
out=$(run)
if [ -z "$out" ]; then echo "ok   onyo-mode off in CLAUDE.md prints nothing"; else echo "FAIL onyo-mode off in CLAUDE.md printed text"; fails=$((fails + 1)); fi
rm "$dir/CLAUDE.md"

printf 'Never write onyo-mode off in prose like this.\n' > "$dir/CLAUDE.local.md"
out=$(run)
check "a sentence that mentions onyo-mode off does not opt out" "$out" "This session's role is: solo."

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
