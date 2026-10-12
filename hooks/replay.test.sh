#!/bin/sh
# Replays real coordinator turns (hooks/fixtures) through hooks/onyo-mode.sh and checks each outcome.
root="$(cd "$(dirname "$0")/.." && pwd)"
hook="$root/hooks/onyo-mode.sh"
fixtures="$root/hooks/fixtures"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/repo"
fails=0
seen=

# Cases the hook gets wrong today. A change that fixes one deletes it here.
gaps=

# Builds the hook input Claude Code sends: case, event, transcript, tool_input.
event() {
  path=$tmp/none.jsonl
  [ "$3" = - ] || path=$fixtures/$3
  prompt_id=$(grep -o '"promptId":"[^"]*"' "$path" 2>/dev/null | tail -n 1 | cut -d'"' -f4)
  printf '{"session_id":"replay-%s","transcript_path":"%s","cwd":"%s","prompt_id":"%s","hook_event_name":"%s"' \
    "$1" "$path" "$tmp/repo" "$prompt_id" "$2"
  if [ "$2" = Stop ]; then printf ',"stop_hook_active":false}'
  else printf ',"tool_name":"mcp__hearthbot__start_thread_session","tool_input":%s}' "$(cat "$fixtures/$4")"
  fi
}

# Names what the hook decided from its exit status and what it printed.
outcome() {
  [ "$1" = 0 ] || { echo "exit $1"; return; }
  case $2 in
    '') echo allow ;;
    *'"decision":"block"'*) echo block ;;
    *'"permissionDecision":"deny"'*) echo deny ;;
    *) echo "unknown: $2" ;;
  esac
}

tab=$(printf '\t')
{
  read -r _
  while IFS=$tab read -r name kind transcript input should _ || [ -n "$name" ]; do
    seen="$seen $name"
    need=$transcript
    [ "$kind" = Stop ] || need=$input
    for f in "$transcript" "$input"; do
      [ "$f" = - ] && [ "$f" != "$need" ] || [ -f "$fixtures/$f" ] || { echo "FAIL $name has no fixture $f"; fails=$((fails + 1)); continue 2; }
    done
    out=$(event "$name" "$kind" "$transcript" "$input" |
      env -i PATH="$PATH" CLAUDE_PLUGIN_ROOT="$root" CLAUDE_PLUGIN_DATA="$tmp/data" \
        CLAUDE_CODE_ENTRYPOINT=remote_projects CLAUDE_CODE_PROJECTS_SESSION=1 CLAUDE_CODE_COORDINATOR_MODE=1 sh "$hook")
    got=$(outcome $? "$out")
    case " $gaps " in *" $name "*) gap=1 ;; *) gap= ;; esac
    if [ "$got" = "$should" ] && [ -z "$gap" ]; then echo "ok   $name"
    elif [ "$got" = "$should" ]; then
      echo "FAIL $name"; echo "     the hook gets this right now. Remove it from gaps in hooks/replay.test.sh."; fails=$((fails + 1))
    elif [ -n "$gap" ] && case $got in allow | block | deny) true ;; *) false ;; esac; then echo "gap  $name (should $should, got $got)"
    else echo "FAIL $name"; echo "     should $should, got $got"; fails=$((fails + 1))
    fi
  done
} < "$fixtures/expected.tsv"

for name in $gaps; do
  case "$seen " in *" $name "*) ;; *) echo "FAIL $name is in gaps but has no fixture"; fails=$((fails + 1)) ;; esac
done

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
