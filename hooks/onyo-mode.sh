#!/bin/sh
# Default on. A line that is only `onyo-mode off` (or `onyo-mode on`) decides otherwise:
# in a message for the rest of the session, or in CLAUDE.md, CLAUDE.local.md, or the
# Claude Projects instructions for the project. The session's word beats the project's.
input=$(cat)
root=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}

# Prints the decoded value of a top-level string field of the hook input.
json() {
  printf '%s' "$input" | awk -v key="\"$1\"" '
    { s = s $0 "\n" }
    END {
      i = index(s, key); if (!i) exit
      s = substr(s, i + length(key))
      if (!match(s, /^[ \t\n]*:[ \t\n]*"/)) exit
      s = substr(s, RLENGTH + 1); out = ""
      for (j = 1; j <= length(s); j++) {
        c = substr(s, j, 1)
        if (c == "\"") break
        if (c == "\\") { c = substr(s, ++j, 1); if (c == "n") c = "\n"; else if (c == "t") c = "\t"; else if (c == "r") c = "" }
        out = out c
      }
      print out
    }'
}

# Reads text, JSON-escaped or not, and prints the state its last onyo-mode line sets.
switch() {
  awk '{ gsub(/\\n/, "\n"); print }' | tr '[:upper:]' '[:lower:]' |
    sed -nE 's/^[[:space:]]*(<[^>]*>)?[[:space:]]*onyo-mode:? (on|off)\.?[[:space:]]*(<.*)?$/\2/p' | tail -n 1
}

# Prints the first project instructions block in the text.
instructions() {
  awk '!on && (i = index($0, "<project-instructions")) { on = 1; $0 = substr($0, i) }
    on { e = index($0, "</project-instructions"); if (e) { print substr($0, 1, e); exit } print }' "$@"
}

projects=
{ [ "$CLAUDE_CODE_ENTRYPOINT" = remote_projects ] || [ "$CLAUDE_CODE_PROJECTS_SESSION" = 1 ]; } && projects=1

event=$(json hook_event_name)
[ "$event" = PreToolUse ] || prompt=$(json prompt)
session=$(json session_id | tr -cd 'A-Za-z0-9_-')
state_file="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/ostack}/onyo-mode/$session"
said=$(printf '%s\n' "$prompt" | sed '/<project-instructions/,/<\/project-instructions/d' | switch)
if [ -n "$said" ] && [ -n "$session" ]; then
  mkdir -p "$(dirname "$state_file")" && echo "$said" > "$state_file"
fi
[ -n "$session" ] && state=$(cat "$state_file" 2>/dev/null)

if [ -z "$state" ]; then
  dir=${CLAUDE_PROJECT_DIR:-$(json cwd)}
  for f in "$dir/CLAUDE.md" "$dir/.claude/CLAUDE.md" "$dir/CLAUDE.local.md"; do
    [ -f "$f" ] && state=$(switch < "$f")
    [ -n "$state" ] && break
  done
fi
if [ -z "$state" ] && [ -n "$projects" ]; then
  block=$(printf '%s\n' "$prompt" | instructions)
  transcript=$(json transcript_path)
  [ -n "$block" ] || [ ! -f "$transcript" ] || block=$(instructions "$transcript")
  state=$(printf '%s\n' "$block" | switch)
fi

if [ "$said" = off ]; then
  echo "The user turned onyo-mode off for the rest of this session. Confirm it in one line, and say that a message of just \`onyo-mode on\` turns it back on."
  exit 0
fi
[ "$state" = off ] && exit 0

skill="the onyo-projects skill (ostack:onyo-projects, or $root/skills/onyo-projects/SKILL.md)"
coordinator=
[ -n "$projects" ] && [ "$CLAUDE_CODE_COORDINATOR_MODE" = 1 ] && coordinator=1

if [ "$event" = PreToolUse ]; then
  [ -n "$coordinator" ] || exit 0
  json instructions | tr '[:upper:]' '[:lower:]' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' |
    grep -Fxq -e 'onyo-projects: planning thread' -e 'onyo-projects: unit thread' && exit 0
  cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Every new work ask starts as its planning thread. Call start_thread_session again on the same message with the same project_ack and ack, and the user's message in context_message_ids. Begin instructions with the line `onyo-projects: planning thread`, then say the thread is this ask's planning thread and follows the Planning thread section of the onyo-projects skill. A unit thread's brief comes from the planning thread's plan and already begins with `onyo-projects: unit thread`; start it as written."}}
EOF
  exit 0
fi

if [ -n "$coordinator" ]; then
  echo "This is a Claude Projects project chat and you are its coordinator. Do not load onyo-mode here. In your new-ask step, the one thread per ask is the ask's planning thread: make the same start_thread_session call on the user's message, with project_ack, ack, and the user's message in context_message_ids, and begin instructions with the line \`onyo-projects: planning thread\` and say the thread follows the Planning thread section of the onyo-projects skill. Never brief a thread to do the work itself. When a thread's message names your next action, take it as written. The Coordinator section of $skill has the rest."
  exit 0
fi
echo "onyo-mode is on. Follow the onyo-mode skill for this task. If its full text is not in your context, load it with the Skill tool (ostack:onyo-mode) or read $root/skills/onyo-mode/SKILL.md in full. A message of just \`onyo-mode off\` turns it off for this session, and that line in CLAUDE.md, CLAUDE.local.md, or the project instructions turns it off for the project."
[ -n "$projects" ] || exit 0
echo "This is a Claude Projects thread. Also follow $skill: its Planning thread section if your brief names this the ask's planning thread, its Unit thread section otherwise."
