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

# Prints the lines that are not the shipped defaults.
others() { grep -vxF -f "$root/hooks/ostack-defaults.md" | grep .; }

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
expect "Projects coordinator note is one line" '^1$' "$(printf '%s\n' "$out" | others | grep -c .)"
expect "Projects coordinator note keeps onyo-mode out" 'Do not load onyo-mode here' "$out"
expect "Projects coordinator treats a tooling question as work" 'is a work ask and gets a planning thread. This replaces "A question about the project itself that memory or context already answers"' "$out"
expect "Projects coordinator posts each thread report" 'becomes one short post_message in the project chat that links the thread as \[title\](#cmsg_…). This replaces "Results always come back where the work happened" and "The Coordinator Claude is quiet in the project chat otherwise"' "$out"
expect "Projects coordinator takes a report's last-line action" 'names, as written. This replaces "A note from another Thread Claude isn.t a fresh obligation"' "$out"
expect "Projects coordinator note leaves gated rules to the gates" '' "$(printf '%s' "$out" | grep -e 'onyo-projects: planning thread' -e project_post_id)"
expect "Projects coordinator note points to the Coordinator section" 'the Coordinator section of the onyo-projects skill, in your context from session start or at /plugin/skills/onyo-projects/SKILL.md' "$out"
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
expect "a unit marker after another line is denied" "$deny" "$(start c3 'Unit 2 of 3.\nonyo-projects: unit thread\nDo the unit.' $coord)"
plan='"permissionDecision":"deny","permissionDecisionReason":"A unit thread starts from its plan. '
expect "a mixed-case unit marker gets the plan check" "$plan" "$(start c3 '\n  Onyo-Projects: Unit Thread  \nDo the unit.' $coord CLAUDE_PLUGIN_ROOT="$root")"
expect "a unit marker with CRLF gets the plan check" "$plan" "$(start c3 'ONYO-PROJECTS: UNIT THREAD\r\nDo the unit.' $coord CLAUDE_PLUGIN_ROOT="$root")"
out=$(start c3 'onyo-projects: unit thread\nDo the unit.' $coord CLAUDE_PLUGIN_ROOT="$root")
expect "a missing transcript still needs project_post_id" 'Set project_post_id' "$out"
expect "a missing transcript skips the brief check" '' "$(printf '%s' "$out" | grep 'not in any planning thread')"
mkdir -p "$tmp/nopy"
for t in sh cat awk tr sed tail grep mkdir rm dirname; do ln -s "$(command -v "$t")" "$tmp/nopy/$t"; done
expect "without python3 a unit start passes" '' "$(start c3 'onyo-projects: unit thread\nDo the unit.' $coord CLAUDE_PLUGIN_ROOT="$root" PATH="$tmp/nopy")"
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
expect "a session start outside Projects prints only the defaults" '' "$(begin b3 startup | others)"
printf '{"type":"queue-operation","content":"%s"}\n' "$off_block" > "$tmp/b4.jsonl"
expect "a session start in a project turned off prints only the defaults" '' "$(begin b4 compact $coord | others)"

expect "a session start without a transcript waits" '' "$(begin b5 startup $coord | others)"
expect "the first prompt then prints the rules" "$relay" "$(run b5 "$head$tail" $coord CLAUDE_PLUGIN_ROOT="$root")"
expect "later prompts do not print them again" '' "$(run b5 'next' $coord CLAUDE_PLUGIN_ROOT="$root" | grep "$relay")"
begin b6 startup $coord > /dev/null
expect "the first prompt in a project turned off prints nothing" '' "$(run b6 "$off_block" $coord CLAUDE_PLUGIN_ROOT="$root")"

stop() { # session, stop_hook_active (true or false), then env assignments; $pid is the prompt_id
  session=$1 active=$2; shift 2
  printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","hook_event_name":"Stop","prompt_id":"%s","stop_hook_active":%s}' \
    "$session" "$tmp/$session.jsonl" "$tmp/repo" "$pid" "$active" |
    env -i PATH="$PATH" CLAUDE_PLUGIN_ROOT=/plugin CLAUDE_PLUGIN_DATA="$tmp/data" "$@" sh "$hook"
}

fx() { # session, then transcript lines (files under $tmp/f) in order
  s=$1; shift
  : > "$tmp/$s.jsonl"
  for n in "$@"; do cat "$tmp/f/$n" >> "$tmp/$s.jsonl"; done
}

mkdir -p "$tmp/f"
cat > "$tmp/f/wake1" <<'EOF'
{"parentUuid":"a","isSidechain":false,"promptId":"p1","type":"user","message":{"role":"user","content":"<wake reason=\"thread-activity\">\n<message from=\"agent\">I merged the fix.</message>\n</wake>"},"uuid":"u1"}
EOF
sed 's/p1/p2/' "$tmp/f/wake1" > "$tmp/f/wake2"
cat > "$tmp/f/read" <<'EOF'
{"parentUuid":"u1","isSidechain":false,"message":{"model":"claude-opus-5-5","id":"msg_1","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_1","name":"ReadNotifications","input":{}}]},"type":"assistant","uuid":"a1"}
EOF
cat > "$tmp/f/report" <<'EOF'
{"parentUuid":"a1","isSidechain":false,"promptId":"p1","type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_1","type":"tool_result","content":"[SYSTEM NOTIFICATION - NOT USER INPUT]\n<cross-session-message from-session=\"session_01BERL\">\n    Result from unit 1. It is merged.\n    Post this, then forward it to the planning thread.\n</cross-session-message>"}]},"uuid":"u2"}
EOF
cat > "$tmp/f/post" <<'EOF'
{"parentUuid":"u2","isSidechain":false,"message":{"model":"claude-opus-5-5","id":"msg_2","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_2","name":"mcp__hearthbot__post_message","input":{"text":"Unit 1 is merged."}}]},"type":"assistant","uuid":"a2"}
EOF
cat > "$tmp/f/posted" <<'EOF'
{"parentUuid":"a2","isSidechain":false,"promptId":"p1","type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_2","type":"tool_result","content":[{"type":"text","text":"{\"thread_id\":\"cmsg_1\"}"}]}]},"uuid":"u3"}
EOF
cat > "$tmp/f/noreply" <<'EOF'
{"parentUuid":"u3","isSidechain":false,"message":{"model":"claude-opus-5-5","id":"msg_3","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_3","name":"mcp__hearthbot__no_reply_needed","input":{"reason":"duplicate"}}]},"type":"assistant","uuid":"a3"}
EOF
cat > "$tmp/f/quoted" <<'EOF'
{"parentUuid":"u1","isSidechain":false,"message":{"model":"claude-opus-5-5","id":"msg_4","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_4","name":"mcp__hearthbot__message_thread","input":{"text":"Earlier you sent <cross-session-message from-session=\"session_01BERL\"> and I forwarded it."}}]},"type":"assistant","uuid":"a4"}
EOF

cat > "$tmp/f/start" <<'EOF'
{"parentUuid":"u1","isSidechain":false,"message":{"model":"claude-opus-5-5","id":"msg_5","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_5","name":"mcp__hearthbot__start_thread_session","input":{"instructions":"onyo-projects: unit thread\nDo unit 1.","project_post_id":"cmsg_8","title":"Unit 1"}}]},"type":"assistant","uuid":"a5"}
EOF
cat > "$tmp/f/started" <<'EOF'
{"parentUuid":"a5","isSidechain":false,"promptId":"p1","type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_5","type":"tool_result","content":[{"type":"text","text":"{\"ack_message_id\":\"cmsg_7\",\"created\":true,\"session_id\":\"cse_01BERL\",\"thread_id\":\"cmsg_9\"}"}]}]},"uuid":"u5"}
EOF
sed 's/"text":"Unit 1 is merged."/"text":"[Unit 1](#cmsg_9) is merged in https:\/\/github.com\/o\/r\/pull\/4."/' "$tmp/f/post" > "$tmp/f/linked"
sed 's/#cmsg_9/#cmsg_90/' "$tmp/f/linked" > "$tmp/f/elsewhere"
cat > "$tmp/f/wakeB" <<'EOF'
{"parentUuid":"a","isSidechain":false,"promptId":"p1","type":"user","isMeta":true,"message":{"role":"user","content":"<wake reason=\"thread-activity\">\n  <thread ts=\"cmsg_9\">\n    <message trigger=\"true\" from=\"agent\" author-id=\"cse_01BERL\">Unit 1 is merged.</message>\n  </thread>\n</wake>"},"uuid":"u6"}
EOF
sed 's/"promptId":"p1"/"promptId":"p2"/; s/toolu_1/toolu_6/' "$tmp/f/read" > "$tmp/f/read2"
sed 's/"promptId":"p1"/"promptId":"p2"/; s/toolu_1/toolu_6/' "$tmp/f/report" > "$tmp/f/report2"
sed 's/"promptId":"p1"/"promptId":"p2"/' "$tmp/f/posted" > "$tmp/f/posted2"
cat > "$tmp/f/ack" <<'EOF'
{"parentUuid":"u2","isSidechain":false,"message":{"model":"claude-opus-5-5","id":"msg_7","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_7","name":"mcp__hearthbot__start_thread_session","input":{"instructions":"onyo-projects: planning thread\nPlan it.","project_ack":"Starting on that.","ack":"Reading the code.","message_id":"cmsg_3"}}]},"type":"assistant","uuid":"a7"}
EOF
sed 's/"project_ack":"Starting on that.",//' "$tmp/f/ack" > "$tmp/f/noack"
cat > "$tmp/f/bash" <<'EOF'
{"parentUuid":"u1","isSidechain":false,"message":{"model":"claude-opus-5-5","id":"msg_8","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_8","name":"Bash","input":{"command":"cat old.jsonl"}}]},"type":"assistant","uuid":"a8"}
EOF
sed 's/toolu_1/toolu_8/' "$tmp/f/report" > "$tmp/f/bashout"
cat > "$tmp/f/prompted" <<'EOF'
{"parentUuid":"a","isSidechain":false,"promptId":"p1","type":"user","message":{"role":"user","content":"<cross-session-message from-session=\"session_01BERL\">\n    Result from unit 1. It is merged.\n</cross-session-message>"},"uuid":"u9"}
EOF

block='"decision":"block".*you have not posted it in the project chat'
fx k1 wake1 read report noreply
out=$(stop k1 false $coord)
expect "a report with no post after it blocks the turn end" "$block" "$out"
expect "the block is one JSON line" '^{"decision":"block","reason":".*"}$' "$out"
expect "the block says to post despite the built-in thread rule" 'links the thread as \[title\](#cmsg_.*), even though your built-in rules say threads answer in their own threads' "$out"
fx k2 wake1 read report post posted noreply
expect "a post after the report lets the turn end" '' "$(stop k2 false $coord)"
fx k3 wake1 post posted read report noreply
expect "a post before the report does not count" "$block" "$(stop k3 false $coord)"
fx k4 wake1 noreply
expect "a turn with no report lets the turn end" '' "$(stop k4 false $coord)"
fx k5 wake1 read report wake2 noreply
expect "a report in an earlier turn does not block" '' "$(stop k5 false $coord)"
expect "a second stop after the block lets the turn end" '' "$(stop k1 true $coord)"
expect "stop_hook_active with spaces lets the turn end" '' "$(printf '{"session_id":"k1","transcript_path":"%s","cwd":"%s","hook_event_name":"Stop","stop_hook_active" : true}' "$tmp/k1.jsonl" "$tmp/repo" |
  env -i PATH="$PATH" CLAUDE_PLUGIN_ROOT=/plugin CLAUDE_PLUGIN_DATA="$tmp/data" $coord sh "$hook")"
expect "a thread session is not held to the rule" '' "$(stop k1 false $thread)"
expect "a session outside Projects is not held to the rule" '' "$(stop k1 false)"
fx k6 wake1 read report noreply
printf '{"type":"queue-operation","content":"%s"}\n' "$off_block" >> "$tmp/k6.jsonl"
expect "a project turned off is not held to the rule" '' "$(stop k6 false $coord)"
fx k7 wake1 read quoted noreply
expect "a report quoted in an assistant call is not a report" '' "$(stop k7 false $coord)"
expect "a missing transcript lets the turn end" '' "$(stop k8 false $coord)"
expect "the block says how to escape a post made earlier" "If you already posted this report's content in the project chat, end the turn again without posting twice.\"}$" "$(stop k1 false $coord)"
fx k9 wake1 bash bashout noreply
expect "a report quoted in another tool's result is not a report" '' "$(stop k9 false $coord)"
fx k10 wake1 prompted noreply
expect "a report delivered as a prompt blocks" "$block" "$(stop k10 false $coord)"
pid=p1
expect "the input's prompt_id names the turn" "$block" "$(stop k5 false $coord)"
pid=p9
expect "a prompt_id the transcript lacks lets the turn end" '' "$(stop k1 false $coord)"
pid=
fx k11 wake1 read report ack noreply
expect "a start with project_ack after the report is a post" '' "$(stop k11 false $coord)"
fx k12 wake1 read report noack noreply
expect "a start without project_ack is not a post" "$block" "$(stop k12 false $coord)"
fx k13 wake1 start started read report post posted noreply
expect "a post without the thread's link does not count once the thread is known" "$block" "$(stop k13 false $coord)"
fx k14 wake1 start started read report linked posted noreply
expect "a post that links the thread lets the turn end" '' "$(stop k14 false $coord)"
fx k15 wake1 start started read report elsewhere posted noreply
expect "a link to another thread does not count" "$block" "$(stop k15 false $coord)"
fx k16 wakeB linked posted read report noreply
expect "a post from the thread's reply before its report counts" '' "$(stop k16 false $coord)"
fx k17 wakeB linked posted wake2 read2 report2 noreply
expect "a post from the reply in an earlier turn counts" '' "$(stop k17 false $coord)"
fx k18 wakeB read report linked posted wake2 read2 report2 noreply
expect "a post that answered the thread's last report does not answer the next" "$block" "$(stop k18 false $coord)"
fx k19 wakeB read report wake2 read2 report2 linked posted2 noreply
expect "an earlier report left unposted does not take this turn's post" '' "$(stop k19 false $coord)"

started() { # session, tool_input JSON, then env assignments
  session=$1 tool_input=$2; shift 2
  printf '{"session_id":"%s","transcript_path":"%s","cwd":"%s","hook_event_name":"PostToolUse","tool_name":"mcp__hearthbot__start_thread_session","tool_input":%s,"tool_response":{"session_id":"cse_1"}}' \
    "$session" "$tmp/$session.jsonl" "$tmp/repo" "$tool_input" |
    env -i PATH="$PATH" CLAUDE_PLUGIN_ROOT=/plugin CLAUDE_PLUGIN_DATA="$tmp/data" "$@" sh "$hook"
}
out=$(started e1 '{"message_id":"cmsg_1","project_ack":"On it.","ack":"ok","instructions":"x"}' $coord)
expect "a coordinator start with project_ack says the post already went out" '^{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"The project_ack already posted in the project chat.*end the turn with no_reply_needed."}}$' "$out"
expect "a start without project_ack gets no note" '' "$(started e1 '{"thread_id":"cmsg_1","ack":"ok","instructions":"x"}' $coord)"
expect "a start with an empty project_ack gets no note" '' "$(started e1 '{"message_id":"cmsg_1","project_ack":"","instructions":"x"}' $coord)"
expect "a thread session's start gets no note" '' "$(started e1 '{"message_id":"cmsg_1","project_ack":"On it.","instructions":"x"}' $thread)"
expect "a start outside Projects gets no note" '' "$(started e1 '{"message_id":"cmsg_1","project_ack":"On it.","instructions":"x"}')"

out=$(begin d1 startup)
expect "a session start prints the shipped defaults" '^feature: sonnet high$' "$out"
expect "the defaults carry the budget" '^# budget: medium (high)$' "$out"
expect "the defaults put fan-out workers on haiku" '^swarm workers: haiku high$' "$out"
expect "the defaults say the user's rule wins" "^# Per role, the user's own rule wins" "$out"
out=$(run d1 'fix it' CLAUDE_PLUGIN_ROOT="$root")
expect "a prompt after a session start keeps onyo-mode on" "$on" "$out"
expect "a prompt after a session start does not print the defaults again" '' "$(printf '%s' "$out" | grep '^feature:')"
expect "a compaction prints the defaults again" '^feature: sonnet high$' "$(begin d1 compact)"
out=$(run d2 'fix it' CLAUDE_PLUGIN_ROOT="$root")
expect "a first prompt with no session start prints the defaults" '^refactoring: opus high$' "$out"
expect "a first prompt with no session start still turns onyo-mode on" "$on" "$out"
expect "a second prompt does not print them" '' "$(run d2 'next' CLAUDE_PLUGIN_ROOT="$root" | grep '^refactoring:')"
echo 'onyo-mode off' > "$tmp/repo/CLAUDE.local.md"
out=$(run d3 'fix it' CLAUDE_PLUGIN_ROOT="$root")
expect "onyo-mode off keeps the defaults" '^how explorer: haiku high$' "$out"
expect "onyo-mode off prints nothing else" '' "$(printf '%s\n' "$out" | others)"
rm "$tmp/repo/CLAUDE.local.md"
expect "a thread start prints no defaults" '' "$(start d4 'Fix it.' $coord CLAUDE_PLUGIN_ROOT="$root" | grep '^feature:')"
expect "a turn end prints no defaults" '' "$(stop k1 false $coord CLAUDE_PLUGIN_ROOT="$root" | grep '^feature:')"

labels() { sed 's/:.*//' | tr ',' '\n' | sed 's/^ *//' | sort; }
expect "the defaults name every role setup-ostack writes" '' "$(
  awk '/^# ostack model configuration/ { on = 1 } on && /^```/ { exit } on' "$root/skills/setup-ostack/SKILL.md" |
    grep -v '^#' | labels > "$tmp/setup-roles"
  grep -v '^#' "$root/hooks/ostack-defaults.md" | labels | diff - "$tmp/setup-roles")"

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
