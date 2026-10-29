#!/bin/sh
# Runs hooks/onyo-mode.sh as each kind of session and checks what it prints.
root="$(cd "$(dirname "$0")/.." && pwd)"
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
# An install path as long as a real plugin cache path, so the size check is honest.
long="$dir/Library/Application Support/Claude/local-agent-mode-sessions/e0363e69-6675-41fd-821d-64a9b561d8f2/17684eaf-9f14-4fa3-a599-a1450f0f62fc/rpm/plugin_01P211vsfEm7RpNU1j1fqbCp"
mkdir -p "$(dirname "$long")" && ln -s "$root" "$long"
fails=0

run() {
	env -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_PROJECTS_SESSION -u CLAUDE_CODE_COORDINATOR_MODE \
		CLAUDE_PLUGIN_ROOT="$long" CLAUDE_PROJECT_DIR="$dir" "$@" sh "$root/hooks/onyo-mode.sh"
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

fits() {
	size=$(printf '%s' "$2" | wc -c | tr -d ' ')
	if [ "$size" -lt 2000 ]; then echo "ok   $1 fits the 2 KB preview ($size bytes)"; else echo "FAIL $1 is $size bytes, over the 2 KB preview"; fails=$((fails + 1)); fi
}

out=$(run)
check "solo session gets the solo note" "$out" "# onyo-mode is on" "you are this project's coordinator"
check "solo note points at onyo-mode's file" "$out" "$long/skills/onyo-mode/SKILL.md" "{{"
fits "solo note" "$out"

out=$(run CLAUDE_CODE_ENTRYPOINT=remote_projects CLAUDE_CODE_COORDINATOR_MODE=1)
check "coordinator gets the coordinator note" "$out" "This replaces your default of one start_thread per ask." "you are a thread"
check "coordinator note points at the playbooks" "$out" "$long/skills/onyo-mode/playbooks/" "{{"
fits "coordinator note" "$out"

out=$(run CLAUDE_CODE_PROJECTS_SESSION=1 CLAUDE_CODE_COORDINATOR_MODE=1)
check "coordinator found by the projects flag alone" "$out" "you are this project's coordinator"

out=$(run CLAUDE_CODE_ENTRYPOINT=remote_projects)
check "thread gets the thread note" "$out" "# ostack: you are a thread" "you are this project's coordinator"
fits "thread note" "$out"

out=$(run CLAUDE_CODE_COORDINATOR_MODE=1)
check "coordinator mode outside Projects stays solo" "$out" "# onyo-mode is on"

for playbook in $(sed -n 's/^Playbooks: //p' "$root/hooks/roles/coordinator.md" | sed 's/\. Read.*//' | tr -d ','); do
	[ -f "$root/skills/onyo-mode/playbooks/$playbook.md" ] || { echo "FAIL coordinator lists $playbook, which has no playbook file"; fails=$((fails + 1)); }
done
listed=$(sed -n 's/^Playbooks: //p' "$root/hooks/roles/coordinator.md" | tr ',' '\n' | wc -l | tr -d ' ')
files=$(ls "$root/skills/onyo-mode/playbooks" | wc -l | tr -d ' ')
[ "$listed" = "$files" ] && echo "ok   coordinator lists all $files playbooks" || { echo "FAIL coordinator lists $listed playbooks, $files exist"; fails=$((fails + 1)); }

printf '# notes\n\nonyo-mode off\n' > "$dir/CLAUDE.md"
out=$(run)
if [ -z "$out" ]; then echo "ok   onyo-mode off in CLAUDE.md prints nothing"; else echo "FAIL onyo-mode off in CLAUDE.md printed text"; fails=$((fails + 1)); fi
rm "$dir/CLAUDE.md"

printf 'Never write onyo-mode off in prose like this.\n' > "$dir/CLAUDE.local.md"
out=$(run)
check "a sentence that mentions onyo-mode off does not opt out" "$out" "# onyo-mode is on"

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
