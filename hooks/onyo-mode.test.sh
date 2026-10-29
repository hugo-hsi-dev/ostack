#!/bin/sh
# Runs hooks/onyo-mode.sh as each kind of session and checks the three parts it prints.
root="$(cd "$(dirname "$0")/.." && pwd)"
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
# An install path as long as a real plugin cache path, so the size check is honest.
long="$dir/Library/Application Support/Claude/local-agent-mode-sessions/e0363e69-6675-41fd-821d-64a9b561d8f2/17684eaf-9f14-4fa3-a599-a1450f0f62fc/rpm/plugin_01P211vsfEm7RpNU1j1fqbCp"
mkdir -p "$(dirname "$long")" && ln -s "$root" "$long"
# Claude Code keeps a hook command's output whole up to 10,000 characters. Leave room for a smaller limit elsewhere.
limit=9500
fails=0
pass() { echo "ok   $1"; }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }

run() {
	part=$1; shift
	env -u CLAUDE_CODE_ENTRYPOINT -u CLAUDE_CODE_PROJECTS_SESSION -u CLAUDE_CODE_COORDINATOR_MODE \
		CLAUDE_PLUGIN_ROOT="$long" CLAUDE_PROJECT_DIR="$dir" "$@" sh "$root/hooks/onyo-mode.sh" "$part"
}

has() { printf '%s' "$2" | grep -qF -- "$3" && pass "$1" || fail "$1: missing '$3'"; }
lacks() { printf '%s' "$2" | grep -qF -- "$3" && fail "$1: has '$3'" || pass "$1"; }
fits() {
	size=$(printf '%s' "$2" | wc -m | tr -d ' ')
	[ "$size" -lt "$limit" ] && pass "$1 fits ($size characters)" || fail "$1 is $size characters, over $limit"
}

# Every `## ` section of onyo-mode must reach a solo session or thread exactly once across the three parts.
covers() {
	label=$1; shift
	all=$(for p in 1 2 3; do run "$p" "$@"; done)
	before=$fails
	for h in $(grep '^## ' "$root/skills/onyo-mode/SKILL.md" | sed 's/^## //; s/ /_/g'); do
		h=$(echo "$h" | tr _ ' ')
		count=$(printf '%s\n' "$all" | grep -cxF "## $h")
		[ "$count" = 1 ] || fail "$label gets '## $h' $count times"
	done
	[ "$fails" = "$before" ] && pass "$label gets every onyo-mode section once"
}

for p in 1 2 3; do fits "solo part $p" "$(run $p)"; done
has "solo part 1 opens with the solo note" "$(run 1)" "# onyo-mode is on"
lacks "solo part 1 leaves the frontmatter out" "$(run 1)" "disable-model-invocation"
has "solo note names the skills folder" "$(run 1)" "$long/skills/<name>/SKILL.md"
covers solo

for p in 1 2 3; do fits "thread part $p" "$(run $p CLAUDE_CODE_ENTRYPOINT=remote_projects)"; done
has "thread part 1 opens with the thread note" "$(run 1 CLAUDE_CODE_ENTRYPOINT=remote_projects)" "# ostack: you are a thread"
covers thread CLAUDE_CODE_ENTRYPOINT=remote_projects

coord="CLAUDE_CODE_ENTRYPOINT=remote_projects CLAUDE_CODE_COORDINATOR_MODE=1"
for p in 1 2 3; do fits "coordinator part $p" "$(run $p $coord)"; done
has "coordinator part 1 states the override" "$(run 1 $coord)" "This replaces your default of one start_thread per ask."
has "coordinator part 1 carries Orchestrate" "$(run 1 $coord)" "### Orchestrate"
sum=$(cksum < "$root/skills/onyo-mode/playbooks/orchestrate.md" | awk '{ print $1 }')
has "coordinator note names the playbook's checksum" "$(run 1 $coord)" "<!-- ostack: orchestrate $sum -->"
lacks "coordinator part 1 leaves out the full onyo-mode" "$(run 1 $coord)" "## Non-negotiables"
[ -z "$(run 2 $coord)" ] && pass "coordinator part 2 is empty" || fail "coordinator part 2 printed text"
has "coordinator part 3 carries the playbooks" "$(run 3 $coord)" "## Playbooks"
has "coordinator found by the projects flag alone" "$(run 1 CLAUDE_CODE_PROJECTS_SESSION=1 CLAUDE_CODE_COORDINATOR_MODE=1)" "you are this project's coordinator"
has "coordinator mode outside Projects stays solo" "$(run 1 CLAUDE_CODE_COORDINATOR_MODE=1)" "# onyo-mode is on"

printf '# notes\n\nonyo-mode off\n' > "$dir/CLAUDE.md"
[ -z "$(run 1)$(run 2)$(run 3)" ] && pass "onyo-mode off in CLAUDE.md prints nothing" || fail "onyo-mode off in CLAUDE.md printed text"
rm "$dir/CLAUDE.md"
printf 'Never write onyo-mode off in prose like this.\n' > "$dir/CLAUDE.local.md"
has "a sentence that mentions onyo-mode off does not opt out" "$(run 1)" "# onyo-mode is on"

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
