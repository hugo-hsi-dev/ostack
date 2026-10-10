#!/bin/sh
# expansion: the user typed /onyo-mode as a slash command.
# skill: Claude loaded onyo-mode with the Skill tool.
# submit: every prompt, including Projects messages, which arrive as text.
event=$1
input=$(cat)

field() {
  printf '%s' "$input" | sed -n "s/.*\"$1\" *: *\"\([^\"]*\)\".*/\1/p" | head -n 1
}

session=$(field session_id | tr -cd 'A-Za-z0-9_-')
[ -n "$session" ] || exit 0
state_dir="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/ostack}/onyo-mode"
state_file="$state_dir/$session"
skill="${CLAUDE_PLUGIN_ROOT}/skills/onyo-mode/SKILL.md"

if [ "$event" = skill ]; then
  [ -z "$(field agent_id)" ] || exit 0
  case $(field skill) in
    onyo-mode | ostack:onyo-mode) mkdir -p "$state_dir" && echo on > "$state_file" ;;
  esac
  exit 0
elif [ "$event" = expansion ]; then
  case $(field command_name) in
    onyo-mode | ostack:onyo-mode) ;;
    *) exit 0 ;;
  esac
  case $(field command_args) in
    off | 'off '*) toggle=off ;;
    *) toggle=on ;;
  esac
else
  match=$(printf '%s' "$input" | grep -oE '(^|[[:space:]>"])/(ostack:)?onyo-mode([[:space:]]+off)?([^[:alnum:]:/_-]|$)' | head -n 1)
  case $match in
    '') toggle= ;;
    *off*) toggle=off ;;
    *) toggle=on ;;
  esac
fi

if [ "$toggle" = off ]; then
  mkdir -p "$state_dir" && echo off > "$state_file"
  if [ "$event" = expansion ]; then
    echo "onyo-mode is off for the rest of this session. Type /onyo-mode to turn it back on." >&2
    exit 2
  fi
  echo "The user turned onyo-mode off for the rest of this session. Confirm it in one line."
  exit 0
fi

if [ "$toggle" = on ] && [ "$(cat "$state_file" 2>/dev/null)" != on ]; then
  mkdir -p "$state_dir" && echo on > "$state_file"
  echo "onyo-mode now stays on for the rest of this session. Tell the user once, in one line, that /onyo-mode off turns it off."
fi
[ "$event" = expansion ] && exit 0

state=$(cat "$state_file" 2>/dev/null)
[ -n "$state" ] || state=${OSTACK_ONYO_MODE:-off}
[ "$state" = on ] || exit 0

cat <<MSG
onyo-mode is on for this session. Treat this message as if the user had typed /onyo-mode before it, and follow the onyo-mode skill at $skill. If its full text is not in your context, because you have not read it this session or compaction dropped it, load it before your first step, with the Skill tool or by reading the file in full. /onyo-mode off turns the mode off.
MSG
