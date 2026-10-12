#!/bin/sh
# Runs hooks/onyo-mode.sh the way Claude Code does and checks what it prints.
root="$(cd "$(dirname "$0")/.." && pwd)"
hook="$root/hooks/onyo-mode.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fails=0

run() { # session, prompt (JSON-escaped), then env assignments
  session=$1 prompt=$2; shift 2
  printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","hook_event_name":"UserPromptSubmit","prompt":"%s"}' \
    "$session" "$tmp/$session.jsonl" "$tmp/repo" "$prompt" |
    env -i PATH="$PATH" CLAUDE_PLUGIN_ROOT=/plugin CLAUDE_PLUGIN_DATA="$tmp/data" "$@" sh "$hook"
}

start() { # session, instructions (JSON-escaped), then env assignments
  session=$1 instructions=$2; shift 2
  printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"mcp__hearthbot__start_thread_session","tool_input":{"message_id":"cmsg_1","project_ack":"yes","ack":"ok","instructions":"%s"}}' \
    "$session" "$tmp/$session.jsonl" "$tmp/repo" "$instructions" |
    env -i PATH="$PATH" CLAUDE_PLUGIN_ROOT=/plugin CLAUDE_PLUGIN_DATA="$tmp/data" "$@" sh "$hook"
}

begin() { # session, source, then env assignments
  session=$1 source=$2; shift 2
  printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","hook_event_name":"SessionStart","source":"%s"}' \
    "$session" "$tmp/$session.jsonl" "$tmp/repo" "$source" |
    env -i PATH="$PATH" CLAUDE_PLUGIN_ROOT="$root" CLAUDE_PLUGIN_DATA="$tmp/data" "$@" sh "$hook"
}

expect() { # name, pattern ('' = no output), actual
  if [ -z "$2" ]; then [ -z "$3" ] && ok=1 || ok=
  else printf '%s' "$3" | grep -q -- "$2" && ok=1 || ok=
  fi
  if [ -n "$ok" ]; then echo "ok   $1"; else echo "FAIL $1"; printf '     got: %s\n' "$3"; fails=$((fails + 1)); fi
}

mkdir -p "$tmp/repo"
on='^onyo-mode is on'
head='<session-context>\n<project-instructions nonce=\"x\" untrusted=\"true\">\nProject instructions:\n    Merge PRs when green.\n'
tail='</project-instructions nonce=\"x\">\n</session-context>\n<wake><message>fix the bug</message></wake>'

out=$(run s1 'fix the login bug')
expect "on by default" "$on" "$out"
expect "no Projects line outside Projects" '' "$(printf '%s' "$out" | grep Projects)"

expect "a message turns it off" 'turned onyo-mode off' "$(run s2 'onyo-mode off')"
expect "off lasts the session" '' "$(run s2 'next task')"
expect "a message turns it back on" "$on" "$(run s2 'Onyo-mode on.')"
expect "quoting the line in prose changes nothing" "$on" "$(run s3 'add a line like \"onyo-mode off\" to the docs')"

echo 'onyo-mode off' > "$tmp/repo/CLAUDE.local.md"
expect "CLAUDE.local.md turns it off" '' "$(run s4 'fix it')"
printf '# Notes\n\nonyo-mode on\n' > "$tmp/repo/CLAUDE.md"
expect "CLAUDE.md is read before CLAUDE.local.md" "$on" "$(run s4 'fix it')"
rm "$tmp/repo/CLAUDE.md"
expect "the session's word beats the project's" "$on" "$(run s4 'onyo-mode on')"
rm "$tmp/repo/CLAUDE.local.md"

thread='CLAUDE_CODE_ENTRYPOINT=remote_projects CLAUDE_CODE_PROJECTS_SESSION=1'
out=$(run p1 "$head$tail" $thread)
expect "Projects thread is on" "$on" "$out"
expect "Projects thread gets the planning and unit sections" 'Planning thread section if your brief names this the ask.s planning thread, its Unit thread section otherwise' "$out"
out=$(run p2 "$head$tail" $thread CLAUDE_CODE_COORDINATOR_MODE=1)
expect "Projects coordinator posts each thread report" 'Each report a thread sends you with send_message (a plan, progress, a result, a question, or a permission need) becomes one short post_message in the project chat' "$out"
expect "Projects coordinator relays unit results to the planner" 'Forward each unit.s result to its planning thread with message_thread' "$out"
expect "Projects coordinator line spells out the rules, not a pointer" '' "$(printf '%s' "$out" | grep 'has the rest')"
expect "Projects coordinator makes the ask's planning thread" 'the one thread per ask is the ask.s planning thread' "$out"
expect "Projects coordinator briefs the planning marker" 'begin instructions with the line `onyo-projects: planning thread`' "$out"
expect "Projects coordinator text is not JSON" '' "$(printf '%s' "$out" | grep '^{')"
expect "Projects coordinator does not load onyo-mode" '' "$(printf '%s' "$out" | grep "$on")"

off_block="$head    onyo-mode off\n$tail"
expect "project instructions turn it off" '' "$(run p3 "$off_block" $thread)"
printf '{"type":"queue-operation","content":"%s"}\n{"type":"user","message":"onyo-mode on is how you turn it back on"}\n' "$off_block" > "$tmp/p3.jsonl"
expect "later prompts read the instructions from the transcript" '' "$(run p3 '<wake><message>next</message></wake>' $thread)"
expect "the instructions apply only in Projects" "$on" "$(run p3 '<wake><message>next</message></wake>')"
expect "a Projects message turns it off" 'turned onyo-mode off' \
  "$(run p4 '<wake>\n  <message trigger=\"true\" from=\"human\">onyo-mode off</message>\n</wake>' $thread)"

coord="$thread CLAUDE_CODE_COORDINATOR_MODE=1"
deny='"permissionDecision":"deny".*`onyo-projects: planning thread`'
expect "coordinator start without a marker is denied" "$deny" "$(start c1 'Fix the login bug.\nRun the tests.' $coord)"
expect "the denial is one JSON line" '^{"hookSpecificOutput":{"hookEventName":"PreToolUse".*}}$' "$(start c1 'Fix the login bug.' $coord)"
expect "a marker in prose is still denied" "$deny" "$(start c1 'Start with onyo-projects: planning thread and fix it' $coord)"
expect "a planning marker passes" '' "$(start c2 'onyo-projects: planning thread\nThis is the ask planning thread.' $coord)"
expect "a mixed-case unit marker passes" '' "$(start c3 'Unit 2 of 3.\n  Onyo-Projects: Unit Thread  \nDo the unit.' $coord)"
expect "a unit marker with CRLF passes" '' "$(start c3 'ONYO-PROJECTS: UNIT THREAD\r\nDo the unit.' $coord)"
expect "a thread start outside the coordinator passes" '' "$(start c4 'Fix the login bug.' $thread)"
expect "a thread start outside Projects passes" '' "$(start c5 'Fix the login bug.')"
printf '{"type":"queue-operation","content":"%s"}\n' "$off_block" > "$tmp/c7.jsonl"
expect "instructions in the transcript that turn it off pass" '' "$(start c7 'Fix it.' $coord)"
run c8 'onyo-mode off' $coord > /dev/null
expect "a session that turned it off passes" '' "$(start c8 'Fix it.' $coord)"
expect "a session that turned it back on is denied again" "$deny" "$(run c8 'onyo-mode on' $coord > /dev/null; start c8 'Fix it.' $coord)"

relay='Turn each report a thread sends you with `send_message` into one short `post_message`'
printf '{"type":"user","message":"earlier turns"}\n' > "$tmp/b1.jsonl"
out=$(begin b1 compact $coord)
expect "a coordinator session start prints the override line" '^This is a Claude Projects project chat and you are its coordinator. These rules from the onyo-projects skill override' "$out"
expect "a coordinator session start prints the relay rule" "$relay" "$out"
expect "a coordinator session start stops before the Planning thread section" '' "$(printf '%s' "$out" | grep '^## Planning thread')"
cp "$tmp/b1.jsonl" "$tmp/b2.jsonl"
out=$(begin b2 resume $thread)
expect "a thread session start prints the Unit thread section" '^## Unit thread' "$out"
expect "a thread session start prints the report rule" 'Get its ID once with `get_channel_session_id`' "$out"
expect "a thread session start skips the Coordinator section" '' "$(printf '%s' "$out" | grep '^## Coordinator')"
cp "$tmp/b1.jsonl" "$tmp/b3.jsonl"
expect "a session start outside Projects prints nothing" '' "$(begin b3 startup)"
printf '{"type":"queue-operation","content":"%s"}\n' "$off_block" > "$tmp/b4.jsonl"
expect "a session start in a project turned off prints nothing" '' "$(begin b4 compact $coord)"

expect "a session start without a transcript waits" '' "$(begin b5 startup $coord)"
expect "the first prompt then prints the rules" "$relay" "$(run b5 "$head$tail" $coord CLAUDE_PLUGIN_ROOT="$root")"
expect "later prompts do not print them again" '' "$(run b5 'next' $coord CLAUDE_PLUGIN_ROOT="$root" | grep "$relay")"
begin b6 startup $coord > /dev/null
expect "the first prompt in a project turned off prints nothing" '' "$(run b6 "$off_block" $coord CLAUDE_PLUGIN_ROOT="$root")"

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
