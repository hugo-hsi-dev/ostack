#!/bin/sh
# Prints the onyo-mode note for this session's role. Claude Code shows only the first 2 KB of a long hook output, so each note stays under that and points at the files it needs.
root=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
project=${CLAUDE_PROJECT_DIR:-$PWD}

for f in "$project/CLAUDE.md" "$project/CLAUDE.local.md"; do
	[ -f "$f" ] && grep -qiE '^[[:space:]]*onyo-mode:? off\.?[[:space:]]*$' "$f" && exit 0
done

role=solo
if [ "$CLAUDE_CODE_ENTRYPOINT" = remote_projects ] || [ "$CLAUDE_CODE_PROJECTS_SESSION" = 1 ]; then
	role=thread
	[ "$CLAUDE_CODE_COORDINATOR_MODE" = 1 ] && role=coordinator
fi

awk -v onyo="$root/skills/onyo-mode" -v skills="$root/skills" \
	'{ gsub(/\{\{ONYO\}\}/, onyo); gsub(/\{\{SKILLS\}\}/, skills); print }' "$root/hooks/roles/$role.md"
