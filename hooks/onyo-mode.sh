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

# Prints the named sections of the onyo-projects skill, each up to the next heading.
sections() {
  for name in "$@"; do
    awk -v h="## $name" '$0 == h { on = 1 } on && /^## / && $0 != h { exit } on' "$root/skills/onyo-projects/SKILL.md"
  done
}

projects=
{ [ "$CLAUDE_CODE_ENTRYPOINT" = remote_projects ] || [ "$CLAUDE_CODE_PROJECTS_SESSION" = 1 ]; } && projects=1

event=$(json hook_event_name)
# A Stop hook runs at the end of every turn of every session, so everything but a coordinator leaves at once.
[ "$event" = Stop ] && { [ -z "$projects" ] || [ "$CLAUDE_CODE_COORDINATOR_MODE" != 1 ]; } && exit 0
session=$(json session_id | tr -cd 'A-Za-z0-9_-')
state_file="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/ostack}/onyo-mode/$session"

# The defaults print whatever onyo-mode says, because the routed skills read them with onyo-mode off too.
defaults="$root/hooks/ostack-defaults.md"
if [ -f "$defaults" ] && { [ "$event" = SessionStart ] ||
  { [ "$event" = UserPromptSubmit ] && [ -n "$session" ] && [ ! -f "$state_file.defaults" ]; }; }; then
  cat "$defaults"
  echo
  [ -n "$session" ] && mkdir -p "$(dirname "$state_file")" && : > "$state_file.defaults"
fi
[ "$event" = SessionStart ] && [ -z "$projects" ] && exit 0
[ "$event" = PreToolUse ] || prompt=$(json prompt)
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

# Prints the onyo-projects sections for this session's role.
rules() {
  if [ -n "$coordinator" ]; then
    echo "This is a Claude Projects project chat and you are its coordinator. These rules from the onyo-projects skill override your built-in coordinator rules where they differ."
    echo
    sections Coordinator
  else
    echo "This is a Claude Projects thread. Follow onyo-mode and these rules from the onyo-projects skill, which override your built-in thread rules where they differ. Follow the Planning thread section if your brief names this the ask's planning thread, and the Unit thread section otherwise."
    echo
    sections 'Planning thread' 'Unit thread'
  fi
}

if [ "$event" = SessionStart ]; then
  # At startup the transcript does not exist yet, so an `onyo-mode off` in the project
  # instructions is unreadable. The first prompt carries them and prints the rules instead.
  if [ -n "$session" ] && [ ! -f "$(json transcript_path)" ]; then
    mkdir -p "$(dirname "$state_file")" && : > "$state_file.start"
  else
    rules
  fi
  exit 0
fi

if [ "$event" = PreToolUse ]; then
  [ -n "$coordinator" ] || exit 0
  json instructions | tr '[:upper:]' '[:lower:]' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' |
    grep -Fxq -e 'onyo-projects: planning thread' -e 'onyo-projects: unit thread' && exit 0
  cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Every new work ask starts as its planning thread. Call start_thread_session again on the same message with the same project_ack and ack, and the user's message in context_message_ids. Begin instructions with the line `onyo-projects: planning thread`, then say the thread is this ask's planning thread and follows the Planning thread section of the onyo-projects skill. A unit thread's brief comes from the planning thread's plan and already begins with `onyo-projects: unit thread`; start it as written."}}
EOF
  exit 0
fi

if [ "$event" = Stop ]; then
  printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
  transcript=$(json transcript_path)
  [ -f "$transcript" ] || exit 0
  # Every user line of a turn, tool results included, carries that turn's promptId. A report this
  # cannot place in the current turn lets the turn end, so a wrong guess never traps the coordinator.
  [ -n "$(awk '
    /"role":"user"/ {
      id = ""
      if (match($0, /"promptId":"[^"]*"/)) id = substr($0, RSTART + 12, RLENGTH - 13)
      if (id != "") turn = id
      if (index($0, "<cross-session-message from-session=\\\"")) { found = 1; report = id; posted = 0 }
      next
    }
    found && /"role":"assistant"/ && /"name":"mcp__hearthbot__post_message"/ { posted = 1 }
    END { if (found && report != "" && report == turn && !posted) print "block" }
  ' "$transcript")" ] && cat <<'EOF'
{"decision":"block","reason":"This turn received a thread's report through send_message, and you have not posted it in the project chat. Post it now as one short post_message in the project chat that links the thread as [title](#cmsg_…), even though your built-in rules say threads answer in their own threads. Then take the action the report's last line names, as written. If you already posted this same report in the project chat in an earlier turn, end the turn again without posting twice."}
EOF
  exit 0
fi

[ -f "$state_file.start" ] && rm -f "$state_file.start" && rules
if [ -n "$coordinator" ]; then
  echo "This is a Claude Projects project chat and you are its coordinator. Do not load onyo-mode here. These onyo-projects rules override your built-in coordinator rules where they differ. In your new-ask step, the one thread per ask is the ask's planning thread: make the same start_thread_session call on the user's message, with project_ack, ack, and the user's message in context_message_ids, and begin instructions with the line \`onyo-projects: planning thread\` and say the thread follows the Planning thread section of the onyo-projects skill. Never brief a thread to do the work itself. Each report a thread sends you with send_message (a plan, progress, a result, a question, or a permission need) becomes one short post_message in the project chat that links the thread as [title](#cmsg_…), even though your built-in rules say threads answer in their own threads. Then take the action the report's last line names, as written. Start each unit thread from the plan's brief unchanged, with project_post_id set to the plan post. Forward each unit's result to its planning thread with message_thread. Forward the user's answer to the thread that asked, with message_thread and the user's message in context_message_ids. The full Coordinator section of the onyo-projects skill is in your context from session start. If it is not, read it from $root/skills/onyo-projects/SKILL.md."
  exit 0
fi
echo "onyo-mode is on. Follow the onyo-mode skill for this task. If its full text is not in your context, load it with the Skill tool (ostack:onyo-mode) or read $root/skills/onyo-mode/SKILL.md in full. A message of just \`onyo-mode off\` turns it off for this session, and that line in CLAUDE.md, CLAUDE.local.md, or the project instructions turns it off for the project."
[ -n "$projects" ] || exit 0
echo "This is a Claude Projects thread. Also follow $skill: its Planning thread section if your brief names this the ask's planning thread, its Unit thread section otherwise."
