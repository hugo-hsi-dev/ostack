#!/bin/sh
# Prints part $1 of 3 of this session's onyo-mode text. Claude Code keeps a hook command's output whole only up
# to 10,000 characters, and shows a 2,000-character preview of anything longer, so each part stays under that.
part=${1:-1}
root=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
project=${CLAUDE_PROJECT_DIR:-$PWD}
onyo="$root/skills/onyo-mode"

for f in "$project/CLAUDE.md" "$project/CLAUDE.local.md"; do
	[ -f "$f" ] && grep -qiE '^[[:space:]]*onyo-mode:? off\.?[[:space:]]*$' "$f" && exit 0
done

role=solo
if [ "$CLAUDE_CODE_ENTRYPOINT" = remote_projects ] || [ "$CLAUDE_CODE_PROJECTS_SESSION" = 1 ]; then
	role=thread
	[ "$CLAUDE_CODE_COORDINATOR_MODE" = 1 ] && role=coordinator
fi

# Prints a role note with its paths filled in.
note() {
	sum=$(cksum < "$onyo/playbooks/orchestrate.md" | awk '{ print $1 }')
	awk -v onyo="$onyo" -v skills="$root/skills" -v sum="$sum" \
		'{ gsub(/\{\{ONYO\}\}/, onyo); gsub(/\{\{SKILLS\}\}/, skills); gsub(/\{\{ORCH\}\}/, sum); print }' "$root/hooks/roles/$1.md"
	echo
}

# Prints onyo-mode's text between its frontmatter and its first `## ` section.
preamble() {
	awk 'n < 2 { if ($0 == "---") n++; next } /^## / { exit } { print }' "$onyo/SKILL.md"
}

# Prints each `## ` section of onyo-mode named in $1, a `|`-separated list.
sections() {
	awk -v want="|$1|" '
		/^## / { on = index(want, "|" substr($0, 4) "|") > 0 }
		on { print }
	' "$onyo/SKILL.md"
}

case "$role:$part" in
coordinator:1) note coordinator; cat "$onyo/playbooks/orchestrate.md" ;;
coordinator:2) ;;
coordinator:3) echo "# onyo-mode's playbooks, part 3 of 3"; echo; sections Playbooks ;;
*:1) note "$role"; preamble; sections 'Non-negotiables|Autonomy|Writing the reply|Comments' ;;
*:2) echo "# onyo-mode, part 2 of 3"; echo; sections 'Principles|Subagents' ;;
*:3) echo "# onyo-mode, part 3 of 3"; echo; sections Playbooks ;;
esac
