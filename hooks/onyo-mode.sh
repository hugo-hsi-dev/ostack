#!/bin/sh
# Prints onyo-mode, plus an overlay for a Claude Projects coordinator or thread, into the session's context.
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

skill="$root/skills/onyo-mode/SKILL.md"
cat <<EOF
# onyo-mode is on

ostack's hook turned onyo-mode on for this session. Follow it for every task. A greeting, a quick question, or a one-line answer gets a plain reply, with no playbook. A line of just \`onyo-mode off\` in CLAUDE.md or CLAUDE.local.md turns it off.

Its file is \`$skill\`, so bundled skills live at \`$root/skills/<name>/SKILL.md\`. This session's role is: $role.

EOF
[ "$role" = solo ] || { cat "$root/hooks/roles/$role.md"; echo; }
awk 'n >= 2; /^---$/ && n < 2 { n++ }' "$skill"
